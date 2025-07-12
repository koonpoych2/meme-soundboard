import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import '../providers/sound_provider.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SoundProvider>(
      builder: (context, provider, child) {
        final downloadedSounds = provider.downloadedSounds;

        if (downloadedSounds.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No downloaded sounds yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Download sounds from the home page to see them here',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: downloadedSounds.length,
          itemBuilder: (context, index) {
            final filePath = downloadedSounds[index];
            final fileName = filePath.split('/').last;
            final soundName = fileName
                .replaceAll('.mp3', '')
                .replaceAll('_', ' ');

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.music_note, color: Colors.blue),
                title: Text(
                  soundName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Downloaded • ${(File(filePath).lengthSync() / 1024).toStringAsFixed(1)} KB',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      tooltip: 'Play sound',
                      onPressed: () async {
                        final player = AudioPlayer();
                        await player.play(DeviceFileSource(filePath));
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      tooltip: 'Open with other app',
                      onPressed: () async {
                        try {
                          final result = await OpenFilex.open(filePath);
                          if (result.type != ResultType.done) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Cannot open file: ${result.message}',
                                  ),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error opening file: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.folder_open),
                      tooltip: 'Open in file manager',
                      onPressed: () async {
                        try {
                          final directory = File(filePath).parent.path;
                          print('Opening directory: $directory');
                          print('File path: $filePath');
                          final result = await OpenFilex.open(directory);
                          if (result.type != ResultType.done) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Cannot open folder: ${result.message}\\nPath: $directory',
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: const Duration(seconds: 5),
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Opened folder: $directory'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error opening folder: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete file',
                      onPressed: () {
                        _showDeleteDialog(
                          context,
                          filePath,
                          soundName,
                          provider,
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    String filePath,
    String soundName,
    SoundProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Sound'),
          content: Text('Are you sure you want to delete "$soundName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final file = File(filePath);
                  if (file.existsSync()) {
                    await file.delete();
                    provider.removeDownloadedSound(filePath);
                  }
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$soundName deleted successfully')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete $soundName')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
