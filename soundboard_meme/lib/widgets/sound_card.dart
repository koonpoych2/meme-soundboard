import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/sound.dart';
import '../providers/sound_provider.dart';
import '../theme/app_theme.dart';

class SoundCard extends StatefulWidget {
  final Sound sound;

  const SoundCard({super.key, required this.sound});

  @override
  State<SoundCard> createState() => _SoundCardState();
}

class _SoundCardState extends State<SoundCard>
    with SingleTickerProviderStateMixin {
  late final AudioPlayer _player;
  late final SoundProvider _provider;
  late AnimationController _animationController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _provider = Provider.of<SoundProvider>(context, listen: false);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _provider.addListener(_onProviderChanged);
    _onProviderChanged();
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
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  Future<void> _playSound() async {
    try {
      await _player.stop();
      await _player.setReleaseMode(
        _provider.isLooping ? ReleaseMode.loop : ReleaseMode.stop,
      );
      await _player.play(AssetSource(widget.sound.assetPath));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: _playSound,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final scale = 1.0 - (_animationController.value * 0.05);
          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _isPressed
                        ? AppTheme.primaryColor.withOpacity(0.3)
                        : Colors.black.withOpacity(0.2),
                    blurRadius: _isPressed ? 12 : 8,
                    offset: Offset(0, _isPressed ? 2 : 4),
                    spreadRadius: _isPressed ? 1 : 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Background Image
                    Positioned.fill(
                      child: Image.asset(
                        widget.sound.imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.surfaceColor,
                            child: const Icon(
                              Icons.music_note,
                              color: AppTheme.textSecondary,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),

                    // Gradient Overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.7),
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Sound Name
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.sound.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.rubik(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            shadows: [
                              const Shadow(
                                blurRadius: 4,
                                color: Colors.black54,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Favorite Button
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Consumer<SoundProvider>(
                        builder: (context, provider, child) {
                          return Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    widget.sound.isFavorite
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    color: widget.sound.isFavorite
                                        ? AppTheme.primaryColor
                                        : Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () =>
                                      provider.toggleFavorite(widget.sound),
                                  padding: const EdgeInsets.all(4),
                                  constraints: const BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                              )
                              .animate(target: widget.sound.isFavorite ? 1 : 0)
                              .scale(
                                begin: const Offset(1.0, 1.0),
                                end: const Offset(1.2, 1.2),
                                duration: 200.ms,
                                curve: Curves.elasticOut,
                              );
                        },
                      ),
                    ),

                    // Download Button
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Consumer<SoundProvider>(
                        builder: (context, provider, child) {
                          final isDownloaded = provider.isSoundDownloaded(
                            widget.sound,
                          );
                          final isDownloading = provider.isDownloading;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: isDownloading
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppTheme.accentColor,
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      isDownloaded
                                          ? Icons.download_done_rounded
                                          : Icons.download_rounded,
                                      color: isDownloaded
                                          ? AppTheme.accentColor
                                          : Colors.white,
                                      size: 20,
                                    ),
                              onPressed: isDownloading || isDownloaded
                                  ? null
                                  : () => _downloadSound(provider),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Play Indicator
                    if (_isPressed)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _downloadSound(SoundProvider provider) async {
    try {
      await provider.downloadSound(widget.sound);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.sound.name} downloaded successfully! 🎉',
              style: GoogleFonts.rubik(fontWeight: FontWeight.w500),
            ),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to download ${widget.sound.name} 😞',
              style: GoogleFonts.rubik(fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
}
