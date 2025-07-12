import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:open_filex/open_filex.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import '../providers/sound_provider.dart';
import '../theme/app_theme.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SoundProvider>(
      builder: (context, provider, child) {
        final downloadedSounds = provider.downloadedSounds;

        if (downloadedSounds.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.download_outlined,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No downloaded sounds yet',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Download sounds from the home page to see them here',
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textHint,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final filePath = downloadedSounds[index];
                  final fileName = filePath.split(Platform.pathSeparator).last;
                  final soundName = fileName
                      .replaceAll('.mp3', '')
                      .replaceAll('_', ' ');

                  return _DownloadedSoundCard(
                    filePath: filePath,
                    soundName: soundName,
                  );
                }, childCount: downloadedSounds.length),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DownloadedSoundCard extends StatelessWidget {
  final String filePath;
  final String soundName;

  const _DownloadedSoundCard({required this.filePath, required this.soundName});

  @override
  Widget build(BuildContext context) {
    final fileSize = File(filePath).existsSync()
        ? (File(filePath).lengthSync() / 1024).toStringAsFixed(1)
        : '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.music_note_rounded,
            color: AppTheme.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          soundName,
          style: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          'Downloaded • $fileSize KB',
          style: GoogleFonts.rubik(fontSize: 12, color: AppTheme.textSecondary),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
          color: AppTheme.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) async {
            switch (value) {
              case 'play':
                await _playSound();
                break;
              case 'open':
                await _openFile(context);
                break;
              case 'folder':
                await _openFolder(context);
                break;
              case 'delete':
                await _deleteFile(context);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'play',
              child: Row(
                children: [
                  Icon(Icons.play_arrow_rounded, color: AppTheme.accentColor),
                  const SizedBox(width: 12),
                  Text(
                    'Play',
                    style: GoogleFonts.rubik(color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'open',
              child: Row(
                children: [
                  Icon(
                    Icons.open_in_new_rounded,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Open with...',
                    style: GoogleFonts.rubik(color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'folder',
              child: Row(
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Show in folder',
                    style: GoogleFonts.rubik(color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_rounded, color: Colors.red.shade400),
                  const SizedBox(width: 12),
                  Text(
                    'Delete',
                    style: GoogleFonts.rubik(color: Colors.red.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _playSound(),
      ),
    );
  }

  Future<void> _playSound() async {
    try {
      final player = AudioPlayer();
      await player.play(DeviceFileSource(filePath));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  Future<void> _openFile(BuildContext context) async {
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot open file: ${result.message}',
              style: GoogleFonts.rubik(),
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e', style: GoogleFonts.rubik()),
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

  Future<void> _openFolder(BuildContext context) async {
    try {
      final directory = File(filePath).parent.path;
      final result = await OpenFilex.open(directory);
      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot open folder: ${result.message}',
              style: GoogleFonts.rubik(),
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error opening folder: $e',
              style: GoogleFonts.rubik(),
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

  Future<void> _deleteFile(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: Text(
          'Delete Sound',
          style: GoogleFonts.rubik(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "$soundName"? This action cannot be undone.',
          style: GoogleFonts.rubik(color: AppTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.rubik(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
              style: GoogleFonts.rubik(color: Colors.red.shade400),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await File(filePath).delete();
        final provider = Provider.of<SoundProvider>(context, listen: false);
        provider.removeDownloadedSound(filePath);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Sound deleted successfully',
                style: GoogleFonts.rubik(),
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error deleting file: $e',
                style: GoogleFonts.rubik(),
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
}
