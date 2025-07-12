import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import '../providers/sound_provider.dart';
import '../models/sound.dart';
import 'downloads_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SoundProvider>(context);
    final isFavoritesPage = _currentIndex == 1;
    final isDownloadsPage = _currentIndex == 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isDownloadsPage
              ? 'Downloaded Sounds'
              : isFavoritesPage
              ? 'Favorite Sounds'
              : 'Meme Sound Board',
        ),
        bottom: !isFavoritesPage && !isDownloadsPage
            ? PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: provider.setSearch,
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: provider.categories
                            .map(
                              (c) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                child: ChoiceChip(
                                  label: Text(c),
                                  selected: provider.category == c,
                                  onSelected: (_) => provider.setCategory(c),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
      body: isDownloadsPage
          ? const DownloadsScreen()
          : SoundGridScreen(
              sounds: !isFavoritesPage
                  ? provider.sounds
                  : provider.favoriteSounds,
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download),
            label: 'Downloads',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class SoundGridScreen extends StatelessWidget {
  final List<Sound> sounds;
  const SoundGridScreen({super.key, required this.sounds});

  @override
  Widget build(BuildContext context) {
    // final soundProvider = Provider.of<SoundProvider>(context);
    // final sounds = soundProvider.sounds; // or your list of Sound

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of tiles per row
        childAspectRatio: 1, // Adjust for height vs width
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: sounds.length,
      itemBuilder: (context, index) {
        return SoundTile(sound: sounds[index]);
      },
    );
  }
}

class SoundTile extends StatelessWidget {
  final Sound sound;
  const SoundTile({super.key, required this.sound});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SoundProvider>(context, listen: false);

    return GestureDetector(
      onTap: () async {
        final player = AudioPlayer();
        await player.play(AssetSource(sound.assetPath));
      },
      onLongPress: () {
        _showSoundOptions(context, sound, provider);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(sound.imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: .25),
                BlendMode.darken,
              ),
            ),
          ),
          child: Stack(
            children: [
              // Sound name at bottom center
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .4),
                  ),
                  child: Text(
                    sound.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 3, color: Colors.black)],
                    ),
                  ),
                ),
              ),

              // Favorite Icon at top right
              Positioned(
                top: 1,
                right: 1,
                child: IconButton(
                  icon: Icon(
                    sound.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: sound.isFavorite ? Colors.red : Colors.white,
                  ),
                  onPressed: () => provider.toggleFavorite(sound),
                ),
              ),

              // Download Icon at top left
              Positioned(
                top: 1,
                left: 1,
                child: Consumer<SoundProvider>(
                  builder: (context, soundProvider, child) {
                    final isDownloaded = soundProvider.isSoundDownloaded(sound);
                    final isDownloading = soundProvider.isDownloading;

                    return IconButton(
                      icon: isDownloading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              isDownloaded
                                  ? Icons.download_done
                                  : Icons.download,
                              color: isDownloaded ? Colors.green : Colors.white,
                            ),
                      onPressed: isDownloading || isDownloaded
                          ? null
                          : () async {
                              try {
                                await soundProvider.downloadSound(sound);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${sound.name} downloaded successfully!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to download ${sound.name}: $e',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSoundOptions(
    BuildContext context,
    Sound sound,
    SoundProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Consumer<SoundProvider>(
          builder: (context, soundProvider, child) {
            final isDownloaded = soundProvider.isSoundDownloaded(sound);

            return SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.play_arrow),
                    title: const Text('Play Sound'),
                    onTap: () async {
                      final player = AudioPlayer();
                      await player.play(AssetSource(sound.assetPath));
                      Navigator.pop(context);
                    },
                  ),
                  if (!isDownloaded)
                    ListTile(
                      leading: const Icon(Icons.download),
                      title: const Text('Download Sound'),
                      onTap: () async {
                        Navigator.pop(context);
                        try {
                          await soundProvider.downloadSound(sound);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${sound.name} downloaded successfully!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Failed to download ${sound.name}: $e',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  if (isDownloaded) ...[
                    ListTile(
                      leading: const Icon(Icons.open_in_new),
                      title: const Text('Open with Other App'),
                      onTap: () async {
                        Navigator.pop(context);
                        await _openDownloadedFile(
                          context,
                          sound,
                          soundProvider,
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.folder_open),
                      title: const Text('Open in File Manager'),
                      onTap: () async {
                        Navigator.pop(context);
                        await _openFileLocation(context, sound, soundProvider);
                      },
                    ),
                  ],
                  ListTile(
                    leading: Icon(
                      sound.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: sound.isFavorite ? Colors.red : null,
                    ),
                    title: Text(
                      sound.isFavorite
                          ? 'Remove from Favorites'
                          : 'Add to Favorites',
                    ),
                    onTap: () {
                      provider.toggleFavorite(sound);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openDownloadedFile(
    BuildContext context,
    Sound sound,
    SoundProvider provider,
  ) async {
    try {
      final fileName =
          '${sound.name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_')}.mp3';
      final downloadedSounds = provider.downloadedSounds;
      final filePath = downloadedSounds.firstWhere(
        (path) => path.contains(fileName),
        orElse: () => '',
      );

      if (filePath.isNotEmpty) {
        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open file: ${result.message}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File not found. Please download again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openFileLocation(
    BuildContext context,
    Sound sound,
    SoundProvider provider,
  ) async {
    try {
      final fileName =
          '${sound.name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_')}.mp3';
      final downloadedSounds = provider.downloadedSounds;
      final filePath = downloadedSounds.firstWhere(
        (path) => path.contains(fileName),
        orElse: () => '',
      );

      if (filePath.isNotEmpty) {
        final directory = File(filePath).parent.path;
        final result = await OpenFilex.open(directory);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open folder: ${result.message}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File not found. Please download again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening folder: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
