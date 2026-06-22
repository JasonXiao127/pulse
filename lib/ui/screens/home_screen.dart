import 'package:flutter/material.dart';
import '../../providers/game_provider.dart';
import '../widgets/game_card.dart';

class HomeScreen extends StatelessWidget {
  final GameProvider provider;

  const HomeScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('My Offline Game Launcher'),
        centerTitle: true,
      ), */
      body: ListenableBuilder(
        listenable: provider,
        builder: (context, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.games.isEmpty) {
            return const Center(
              child: Text(
                'No games added yet.\nClick the "+" button to add an .exe game.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.games.length,
            itemBuilder: (context, index) {
              final game = provider.games[index];
              return GameCard(
                game: game,
                onPlay: () => provider.playGame(game),
                onDelete: () => provider.removeGame(game.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => provider.pickAndAddGame(),
        tooltip: 'Add Game',
        child: const Icon(Icons.add),
      ),
    );
  }
}