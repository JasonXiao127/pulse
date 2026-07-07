import 'package:flutter/material.dart';
import 'dart:io';
import '../../../models/game.dart';

class GameCard extends StatefulWidget {
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
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Use the extracted icon if available; otherwise show a fallback icon
    final imageProvider = (widget.game.imagePath != null &&
            File(widget.game.imagePath!).existsSync())
        ? FileImage(File(widget.game.imagePath!)) as ImageProvider
        : null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onPlay,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Poster background (square, preserves 256x256)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[900], // fallback background
                image: imageProvider != null
                    ? DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover, // cover the square, no stretching
                      )
                    : null,
              ),
              child: imageProvider == null
                  ? const Icon(
                      Icons.sports_esports,
                      size: 80,
                      color: Colors.white54,
                    )
                  : null,
            ),
            // Dark overlay on hover
            AnimatedOpacity(
              opacity: _isHovering ? 0.6 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
              ),
            ),
            // Hover play indicator
            AnimatedOpacity(
              opacity: _isHovering ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'PLAY',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Title and file path at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.game.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.game.exePath,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Delete button in top-right corner
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.8),
                  padding: const EdgeInsets.all(6),
                  minimumSize: const Size(32, 32),
                ),
                onPressed: widget.onDelete,
                tooltip: 'Remove game',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
