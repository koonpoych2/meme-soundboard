import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/sound_provider.dart';
import '../models/sound.dart';
import '../widgets/emoji_background.dart';
import '../widgets/sound_tile.dart';
import 'downloads_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  Key _titleKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SoundProvider>(context);
    final isFavoritesPage = _currentIndex == 1;
    final isDownloadsPage = _currentIndex == 2;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFEB3B),
        title: GestureDetector(
          onTap: () => setState(() => _titleKey = UniqueKey()),
          child: Animate(
            key: _titleKey,
            effects: const [ShakeEffect(duration: Duration(milliseconds: 500))],
            child: Text(
            isDownloadsPage
                ? '📥 Downloads'
                : isFavoritesPage
                    ? '❤️ Favorites'
                    : '🔥 Meme Sound Board 🔊',
            style: GoogleFonts.bangers(fontSize: 24),
          ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              provider.isLooping ? Icons.repeat_on : Icons.repeat,
            ),
            onPressed: provider.toggleLooping,
          ),
        ],
        bottom: !isFavoritesPage && !isDownloadsPage
            ? PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search 🔍 dank memes...',
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
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: ChoiceChip(
                                  label: Text(
                                    c == 'Nature'
                                        ? '🌍 Nature'
                                        : c == 'Test'
                                            ? '🧪 Test'
                                            : '🔥 All',
                                    style: GoogleFonts.lilitaOne(),
                                  ),
                                  selected: provider.category == c,
                                  selectedColor: Colors.pinkAccent,
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: const BorderSide(color: Colors.pinkAccent),
                                  ),
                                  onSelected: (_) => provider.setCategory(c),
                                ).animate(target: provider.category == c ? 1 : 0)
                                  .scale(
                                    duration: const Duration(milliseconds: 200),
                                    begin: const Offset(1, 1),
                                    end: const Offset(1.2, 1.2),
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
      body: Stack(
        children: [
          const EmojiBackground(),
          isDownloadsPage
              ? const DownloadsScreen()
              : SoundGridScreen(
                  sounds: !isFavoritesPage
                      ? provider.sounds
                      : provider.favoriteSounds,
                ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: Animate(
              target: _currentIndex == 0 ? 1 : 0,
              effects: [
                ScaleEffect(
                  duration: const Duration(milliseconds: 300),
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  curve: Curves.elasticOut,
                )
              ],
              child: const Text('🏠', style: TextStyle(fontSize: 24)),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Animate(
              target: _currentIndex == 1 ? 1 : 0,
              effects: [
                ScaleEffect(
                  duration: const Duration(milliseconds: 300),
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  curve: Curves.elasticOut,
                )
              ],
              child: const Text('❤️', style: TextStyle(fontSize: 24)),
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Animate(
              target: _currentIndex == 2 ? 1 : 0,
              effects: [
                ScaleEffect(
                  duration: const Duration(milliseconds: 300),
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  curve: Curves.elasticOut,
                )
              ],
              child: const Text('📥', style: TextStyle(fontSize: 24)),
            ),
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

