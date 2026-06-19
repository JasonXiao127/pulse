import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pulse/models/game.dart';
import 'package:pulse/service/storage_service.dart';
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

  // Private helper to extract the icon from the EXE using Windows PowerShell
  Future<String?> _extractIconFromExe(String exePath, String gameId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final iconFolder = Directory('${appDir.path}/launcher_icons');
      
      // Ensure the directory to store extracted icons exists
      if (!await iconFolder.exists()) {
        await iconFolder.create(recursive: true);
      }

      final outputPath = '${iconFolder.path}/$gameId.png';

      // Standardize paths for PowerShell execution
      final escapedExePath = exePath.replaceAll("'", "''");
      final escapedOutputPath = outputPath.replaceAll("'", "''");

      // PowerShell command utilizing .NET's Drawing library to extract and save the icon
      final psCommand = '''
      Add-Type -AssemblyName System.Drawing;
      [System.Drawing.Icon]::ExtractAssociatedIcon('$escapedExePath').ToBitmap().Save('$escapedOutputPath', [System.Drawing.Imaging.ImageFormat]::Png);
      ''';

      // Run the process invisibly in the background
      final result = await Process.run(
        'powershell', 
        ['-NoProfile', '-NonInteractive', '-Command', psCommand],
      );

      if (result.exitCode == 0 && await File(outputPath).exists()) {
        return outputPath;
      } else {
        print("PowerShell error: ${result.stderr}");
      }
    } catch (e) {
      print("Failed to extract icon: $e");
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

      // Extract the icon automatically on import
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
    // Delete the saved icon file to keep storage clean
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