import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../providers/sound_provider.dart';
import '../models/sound.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SoundProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meme Sound Board'),
        bottom: PreferredSize(
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
                          padding: const EdgeInsets.symmetric(horizontal: 4),
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
        ),
      ),
      body: ListView.builder(
        itemCount: provider.sounds.length,
        itemBuilder: (context, index) {
          final sound = provider.sounds[index];
          return SoundTile(sound: sound);
        },
      ),
    );
  }
}

class SoundTile extends StatelessWidget {
  final Sound sound;
  const SoundTile({super.key, required this.sound});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SoundProvider>(context, listen: false);
    return ListTile(
      leading: Image.asset(sound.imagePath, width: 40, height: 40),
      title: Text(sound.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              sound.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: sound.isFavorite ? Colors.red : null,
            ),
            onPressed: () => provider.toggleFavorite(sound),
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () async {
              final player = AudioPlayer();
              await player.play(AssetSource(sound.assetPath));
            },
          ),
        ],
      ),
    );
  }
}