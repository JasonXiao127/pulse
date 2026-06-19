import 'package:flutter/material.dart';
import '../../../models/game.dart';
import 'dart:io';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onPlay;
  final VoidCallback onDelete;

  const GameCard({
    super.key,
    required this.game,
    required this.onPlay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Helper to decide what to show in the leading slot
    Widget leadingWidget;
    
    if (game.imagePath != null && File(game.imagePath!).existsSync()) {
      leadingWidget = ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.file(
          File(game.imagePath!),
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      );
    } else {
      leadingWidget = const SizedBox(
        width: 50,
        height: 50,
        child: Icon(Icons.sports_esports, size: 36, color: Color.fromARGB(255, 72, 107, 167)),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: leadingWidget, // <-- Displays the image or fallback icon
        title: Text(
          game.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          game.exePath,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: onDelete,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('PLAY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: onPlay,
            ),
          ],
        ),
      ),
    );
  }
}