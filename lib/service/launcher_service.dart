//launches the actual games. triggers the start proccesses

import 'dart:io';
import 'package:pulse/models/game.dart';
class LauncherService {
  Future<bool> launchGame(Game game) async {
    try {
      // Start the executable in its own working directory
      await Process.start(
        game.exePath,
        [],
        workingDirectory: game.workingDirectory,
        runInShell: true,
      );
      return true;
    } catch (e) {
      print("Failed to launch game: $e");
      return false;
    }
  }
}