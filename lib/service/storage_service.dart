import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pulse/models/game.dart';

class StorageService {
  Future<File> _getStorageFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/game_launcher_data.json');
  }

  Future<void> saveGames(List<Game> games) async {
    final file = await _getStorageFile();
    final jsonList = games.map((g) => g.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<List<Game>> loadGames() async {
    try {
      final file = await _getStorageFile();
      if (!await file.exists()) return [];
      
      final content = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((json) => Game.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}