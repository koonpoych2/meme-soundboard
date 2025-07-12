import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sound.dart';
import '../services/download_service.dart';

class SoundProvider extends ChangeNotifier {
  // Start with an empty list of sounds. Add your own
  // entries pointing to assets in `assets/sounds` and
  // `assets/images`.
  final List<Sound> _sounds = [
    Sound(
      id: '1',
      name: 'Tung Tung sahur',
      assetPath: 'sounds/tung-tung-sahur.mp3',
      imagePath: 'assets/images/tung-tung-tung-sahur.jpg',
      category: 'Nature',
      isFavorite: false,
    ),
    Sound(
      id: '2',
      name: 'Plankton Aughhhhh',
      assetPath: 'sounds/Plankton Aughhhhh.mp3',
      imagePath: 'assets/images/Plankton Aughhhhh.jpg',
      category: 'Test',
      isFavorite: false,
    ),
  ];

  String _searchQuery = '';
  String _category = 'All';
  List<String> _downloadedSounds = [];
  bool _isDownloading = false;

  SoundProvider() {
    _loadFavorites();
    _loadDownloadedSounds();
  }

  String get category => _category;
  List<String> get downloadedSounds => _downloadedSounds;
  bool get isDownloading => _isDownloading;

  List<Sound> get sounds {
    var list = _sounds;
    if (_category != 'All') {
      list = list.where((s) => s.category == _category).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where(
            (s) => s.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return list;
  }

  List<String> get categories => [
    'All',
    ...{for (var s in _sounds) s.category},
  ];

  List<Sound> get favoriteSounds => _sounds.where((s) => s.isFavorite).toList();

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = prefs.getStringList('favoriteSounds') ?? [];
    for (var sound in _sounds) {
      sound.isFavorite = favoriteIds.contains(sound.id);
    }
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteIds = _sounds
        .where((s) => s.isFavorite)
        .map((s) => s.id)
        .toList();
    await prefs.setStringList('favoriteSounds', favoriteIds);
  }

  void toggleFavorite(Sound sound) {
    sound.isFavorite = !sound.isFavorite;
    _saveFavorites();
    notifyListeners();
  }

  void setCategory(String category) {
    _category = category;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> _loadDownloadedSounds() async {
    _downloadedSounds = await DownloadService.getDownloadedSounds();
    notifyListeners();
  }

  Future<String?> downloadSound(Sound sound) async {
    _isDownloading = true;
    notifyListeners();

    try {
      final filePath = await DownloadService.downloadSound(sound);
      if (filePath != null) {
        _downloadedSounds.add(filePath);
        notifyListeners();
      }
      return filePath;
    } catch (e) {
      rethrow;
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  bool isSoundDownloaded(Sound sound) {
    final fileName =
        '${sound.name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_')}.mp3';
    return _downloadedSounds.any((path) => path.contains(fileName));
  }

  void removeDownloadedSound(String filePath) {
    _downloadedSounds.remove(filePath);
    notifyListeners();
  }
}
