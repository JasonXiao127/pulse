import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/game.dart';
import '../service/storage_service.dart';
import '../service/launcher_service.dart';

class GameProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final LauncherService _launcherService = LauncherService();

  List<Game> _games = [];
  List<Game> get games => _games;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> loadGames() async {
    _isLoading = true;
    notifyListeners();
    _games = await _storageService.loadGames();
    _isLoading = false;
    notifyListeners();
  }

  // Private helper to extract high-res icons (256x256) using Windows Win32 API inside PowerShell
  Future<String?> _extractIconFromExe(String exePath, String gameId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final iconFolder = Directory('${appDir.path}/launcher_icons');
      
      if (!await iconFolder.exists()) {
        await iconFolder.create(recursive: true);
      }

      final outputPath = '${iconFolder.path}/$gameId.png';

      final escapedExePath = exePath.replaceAll("'", "''");
      final escapedOutputPath = outputPath.replaceAll("'", "''");

      // Dynamic C# compilation via PowerShell utilizing Win32's PrivateExtractIcons.
      // Note: The closing '"@' must remain at the absolute start of its line to satisfy PowerShell parser rules.
      final psCommand = '''
      Add-Type -AssemblyName System.Drawing;
      \$code = @"
      using System;
      using System.Drawing;
      using System.Runtime.InteropServices;

      public class IconHelper {
          [DllImport("user32.dll", CharSet = CharSet.Unicode)]
          public static extern uint PrivateExtractIcons(
              string lpszFile,
              int nIconIndex,
              int cxIcon,
              int cyIcon,
              IntPtr[] phicon,
              uint[] piconid,
              uint nIcons,
              uint flags
          );

          [DllImport("user32.dll", SetLastError = true)]
          [return: MarshalAs(UnmanagedType.Bool)]
          public static extern bool DestroyIcon(IntPtr hIcon);

          public static void SaveIcon(string exePath, string outputPath, int size) {
              IntPtr[] phicon = new IntPtr[1];
              uint[] piconid = new uint[1];
              
              // Extract the icon at the specified size (e.g. 256x256)
              uint result = PrivateExtractIcons(exePath, 0, size, size, phicon, piconid, 1, 0);
              
              if (result > 0 && phicon[0] != IntPtr.Zero) {
                  try {
                      using (Icon icon = Icon.FromHandle(phicon[0])) {
                          using (Bitmap bmp = icon.ToBitmap()) {
                              bmp.Save(outputPath, System.Drawing.Imaging.ImageFormat.Png);
                          }
                      }
                  } finally {
                      DestroyIcon(phicon[0]);
                  }
              } else {
                  throw new Exception("No icon resources found at the requested size.");
              }
          }
      }
"@;
      Add-Type -TypeDefinition \$code -ReferencedAssemblies "System.Drawing";
      [IconHelper]::SaveIcon('$escapedExePath', '$escapedOutputPath', 256);
      ''';

      final result = await Process.run(
        'powershell', 
        ['-NoProfile', '-NonInteractive', '-Command', psCommand],
      );

      if (result.exitCode == 0 && await File(outputPath).exists()) {
        return outputPath;
      } else {
        print("PowerShell extraction error: ${result.stderr}");
      }
    } catch (e) {
      print("Failed to extract high-res icon: $e");
    }
    return null;
  }

  Future<void> pickAndAddGame() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['exe'],
    );

    if (result != null && result.files.single.path != null) {
      _isLoading = true;
      notifyListeners();

      final String fullPath = result.files.single.path!;
      final String workingDir = p.dirname(fullPath);
      final String defaultTitle = p.basenameWithoutExtension(fullPath);
      final String gameId = DateTime.now().millisecondsSinceEpoch.toString();

      final String? extractedIconPath = await _extractIconFromExe(fullPath, gameId);

      final newGame = Game(
        id: gameId,
        title: defaultTitle,
        exePath: fullPath,
        workingDirectory: workingDir,
        imagePath: extractedIconPath, 
      );

      _games.add(newGame);
      await _storageService.saveGames(_games);
      
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeGame(String id) async {
    final game = _games.firstWhere((g) => g.id == id);
    if (game.imagePath != null) {
      final iconFile = File(game.imagePath!);
      if (await iconFile.exists()) {
        await iconFile.delete();
      }
    }

    _games.removeWhere((g) => g.id == id);
    await _storageService.saveGames(_games);
    notifyListeners();
  }

  Future<void> playGame(Game game) async {
    await _launcherService.launchGame(game);
  }
}