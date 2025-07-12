import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:open_filex/open_filex.dart';
import 'dart:io';
import '../providers/sound_provider.dart';
import '../models/sound.dart';
import 'downloads_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/search_bar.dart' as sb;
import '../widgets/category_chips.dart';
import '../widgets/main_bottom_nav.dart';
import '../widgets/sound_card.dart';

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
      appBar: CustomAppBar(
        title: isDownloadsPage
            ? 'Downloaded Sounds'
            : isFavoritesPage
                ? 'Favorite Sounds'
                : 'Meme Sound Board',
        showFilters: !isFavoritesPage && !isDownloadsPage,
        searchBar:
            sb.SearchBar(onChanged: !isFavoritesPage ? provider.setSearch : null),
        categoryChips: CategoryChips(
          categories: provider.categories,
          selected: provider.category,
          onSelected: provider.setCategory,
        ),
        actions: [
          IconButton(
            icon: Icon(
              provider.isLooping ? Icons.repeat_on : Icons.repeat,
            ),
            onPressed: provider.toggleLooping,
          ),
        ],
      ),
      body: isDownloadsPage
          ? const DownloadsScreen()
          : SoundGridScreen(
              sounds: !isFavoritesPage
                  ? provider.sounds
                  : provider.favoriteSounds,
            ),
      bottomNavigationBar: MainBottomNav(
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
        return SoundCard(sound: sounds[index]);
      },
    );
  }
}
