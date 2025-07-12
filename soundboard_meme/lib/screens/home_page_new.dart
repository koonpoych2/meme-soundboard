import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/sound_provider.dart';
import '../models/sound.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_search_bar.dart';
import '../widgets/category_chips.dart';
import '../widgets/sound_card.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../theme/app_theme.dart';
import 'downloads_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  String _getPageTitle() {
    switch (_currentIndex) {
      case 1:
        return 'Favorite Sounds';
      case 2:
        return 'Downloaded Sounds';
      default:
        return 'Meme Sound Board';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SoundProvider>(context);
    final isFavoritesPage = _currentIndex == 1;
    final isDownloadsPage = _currentIndex == 2;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: _getPageTitle(),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                provider.isLooping
                    ? Icons.repeat_on_rounded
                    : Icons.repeat_rounded,
                color: provider.isLooping
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondary,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                provider.toggleLooping();
              },
              tooltip: provider.isLooping ? 'Disable Loop' : 'Enable Loop',
            ),
          ),
        ],
        bottom: !isFavoritesPage && !isDownloadsPage
            ? Column(
                children: [
                  CustomSearchBar(
                    onChanged: provider.setSearch,
                    hintText: 'Search dank memes…',
                  ),
                  CategoryChips(
                    categories: provider.categories,
                    selectedCategory: provider.category,
                    onCategorySelected: provider.setCategory,
                  ),
                  const SizedBox(height: 8),
                ],
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
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          HapticFeedback.selectionClick();
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
    if (sounds.isEmpty) {
      return _buildEmptyState();
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              return SoundCard(sound: sounds[index]);
            }, childCount: sounds.length),
          ),
        ),
        // Add some bottom padding for better scrolling experience
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],
    );
  }

  Widget _buildEmptyState() {
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
              Icons.music_off_rounded,
              size: 64,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No sounds found',
            style: AppTheme.titleMedium.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or category filter',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
