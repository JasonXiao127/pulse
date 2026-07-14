import 'package:flutter/material.dart';
import 'providers/game_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Create a single instance of the GameProvider
  final GameProvider _gameProvider = GameProvider();

  @override
  void initState() {
    super.initState();
    // Load the games from local storage when the app starts
    _gameProvider.loadGames();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game Launcher',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeScreen(provider: _gameProvider),
    );
  }
}