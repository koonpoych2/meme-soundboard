import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/sound.dart';
import '../providers/sound_provider.dart';

class SoundCard extends StatefulWidget {
  final Sound sound;
  const SoundCard({super.key, required this.sound});

  @override
  State<SoundCard> createState() => _SoundCardState();
}

class _SoundCardState extends State<SoundCard> {
  late final AudioPlayer _player;
  late final SoundProvider _provider;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _provider = Provider.of<SoundProvider>(context, listen: false);
    _provider.addListener(_onProviderChanged);
  }

  void _onProviderChanged() {
    _player.setReleaseMode(
      _provider.isLooping ? ReleaseMode.loop : ReleaseMode.stop,
    );
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    _player.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    await _player.stop();
    await _player.setReleaseMode(
      _provider.isLooping ? ReleaseMode.loop : ReleaseMode.stop,
    );
    await _player.play(AssetSource(widget.sound.assetPath));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: _play,
      child: Card(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.1),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                widget.sound.imagePath,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.25),
                colorBlendMode: BlendMode.darken,
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: Consumer<SoundProvider>(
                builder: (context, provider, _) {
                  final isDownloaded = provider.isSoundDownloaded(widget.sound);
                  final isDownloading = provider.isDownloading;
                  return IconButton(
                    iconSize: 20,
                    icon: isDownloading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            isDownloaded
                                ? Icons.download_done
                                : Icons.download,
                            color: isDownloaded
                                ? Colors.green
                                : theme.colorScheme.onSurface,
                          ),
                    onPressed: isDownloading || isDownloaded
                        ? null
                        : () async {
                            try {
                              await provider.downloadSound(widget.sound);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${widget.sound.name} downloaded!',
                                    ),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to download: $e'),
                                  ),
                                );
                              }
                            }
                          },
                  );
                },
              ),
            ),
            Positioned(
              right: 4,
              top: 4,
              child: IconButton(
                iconSize: 20,
                icon: Icon(
                  widget.sound.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: widget.sound.isFavorite
                      ? Colors.redAccent
                      : theme.colorScheme.onSurface,
                ),
                onPressed: () => _provider.toggleFavorite(widget.sound),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black.withOpacity(0.4),
                child: Text(
                  widget.sound.name,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.rubik(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().scale(duration: 150.ms),
    );
  }
}
