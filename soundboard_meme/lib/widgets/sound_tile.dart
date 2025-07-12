import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../models/sound.dart';
import '../providers/sound_provider.dart';

class SoundTile extends StatefulWidget {
  final Sound sound;
  const SoundTile({super.key, required this.sound});

  @override
  State<SoundTile> createState() => _SoundTileState();
}

class _SoundTileState extends State<SoundTile> with TickerProviderStateMixin {
  late final AudioPlayer _player;
  late final SoundProvider _provider;
  late final ConfettiController _confetti;
  late final String _emoji;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _provider = Provider.of<SoundProvider>(context, listen: false);
    _provider.addListener(_onProviderChanged);
    _onProviderChanged();
    _confetti = ConfettiController(duration: const Duration(milliseconds: 400));
    _emoji = ['🔥', '💀', '😎'][_random.nextInt(3)];
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
    _confetti.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    await _player.stop();
    await _player.setReleaseMode(
      _provider.isLooping ? ReleaseMode.loop : ReleaseMode.stop,
    );
    await _player.play(AssetSource(widget.sound.assetPath));
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 50);
    }
    _confetti.play();
  }

  @override
  Widget build(BuildContext context) {
    final isFav = widget.sound.isFavorite;
    final bars = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        5,
        (index) => Container(
          width: 3,
          height: 6.0 + _random.nextInt(10),
          color: Colors.white,
        ),
      ),
    );

    return Animate(
      effects: const [ScaleEffect(begin: 1, end: 1.05)],
      onPlay: (controller) => controller.forward(from: 0),
      child: GestureDetector(
        onTap: _play,
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.sound.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Text(_emoji),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.sound.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4, child: bars),
                  ],
                ),
              ),
            ),
            Positioned(
              child: ConfettiWidget(
                confettiController: _confetti,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.6,
                numberOfParticles: 8,
                maxBlastForce: 8,
                minBlastForce: 4,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : Colors.white,
                ),
                onPressed: () => _provider.toggleFavorite(widget.sound),
              ),
            ),
          ],
        ).animate().boxShadow(color: Colors.pinkAccent, blurRadius: 10),
      ),
    );
  }
}
