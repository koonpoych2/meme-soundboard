import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/sound_provider.dart';
import '../models/sound.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meme Sound Board'),
        bottom: !isFavoritesPage
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
    body: SoundGridScreen(sounds: provider.sounds,),
    bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: 'Home'),
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
  const SoundGridScreen({super.key,required this.sounds});
  
  
  @override
  Widget build(BuildContext context) {
    // final soundProvider = Provider.of<SoundProvider>(context);
    // final sounds = soundProvider.sounds; // or your list of Sound

    return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of tiles per row
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
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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
                      shadows: [
                        Shadow(blurRadius: 3, color: Colors.black),
                      ],
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
            ],
          ),
        ),
      ),
    );
  }
}


