import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const SoundboardApp());
}

class SoundboardApp extends StatelessWidget {
  const SoundboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meme Soundboard',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const SoundboardHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SoundboardHomePage extends StatelessWidget {
  const SoundboardHomePage({super.key});

  final List<_SoundItem> sounds = const [
    _SoundItem('Plankton Aughhhhh', 'assets/sounds/Plankton Aughhhhh.mp3'),
    _SoundItem('Tung Tung Sahur', 'assets/sounds/tung-tung-sahur.mp3'),
    _SoundItem('WAIT..WHAT', 'assets/sounds/WAIT..WHAT.mp3'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meme Soundboard'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: sounds.length,
        itemBuilder: (context, index) {
          final sound = sounds[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.music_note),
              title: Text(sound.title),
              onTap: () async {
                final player = AudioPlayer();
                await player.play(AssetSource(sound.assetPath.replaceFirst('assets/', '')));
              },
            ),
          );
        },
      ),
    );
  }
}

class _SoundItem {
  final String title;
  final String assetPath;
  const _SoundItem(this.title, this.assetPath);
}
