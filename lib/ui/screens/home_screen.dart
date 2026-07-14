import 'package:flutter/material.dart';
import '../../providers/game_provider.dart';
import '../widgets/game_card.dart';

class HomeScreen extends StatelessWidget {
  final GameProvider provider;

  const HomeScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: provider,
        builder: (context, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.games.isEmpty) {
            return Center(
              child: Text(
                'No games added yet.\nClick the "+" button to add an .exe game.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          // Grid with square cards to preserve the 256x256 icon aspect ratio
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 280,      // max width per card
                childAspectRatio: 1.0,         // square cards
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: provider.games.length,
              itemBuilder: (context, index) {
                final game = provider.games[index];
                return GameCard(
                  game: game,
                  onPlay: () => provider.playGame(game),
                  onDelete: () => provider.removeGame(game.id),
                );
              },
            ),
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
