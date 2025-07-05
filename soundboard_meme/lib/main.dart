import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const SoundBoardApp());

class SoundBoardApp extends StatelessWidget {
  const SoundBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Soundboard',
      theme: _buildTheme(),
      home: const SoundBoardHome(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(18),
          elevation: 8,
          shadowColor: Colors.black54,
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class SoundBoardHome extends StatefulWidget {
  const SoundBoardHome({super.key});

  @override
  State<SoundBoardHome> createState() => _SoundBoardHomeState();
}

class _SoundBoardHomeState extends State<SoundBoardHome> {
  static const int maxItemsPerPage = 12;
  
  final List<SoundItem> _sounds = SoundData.getSounds();
  final AudioPlayerManager _audioManager = AudioPlayerManager();
  int _currentPage = 0;

  void _playSound(String fileName) async {
    await _audioManager.playSound(fileName);
  }

  void _stopAllSounds() {
    _audioManager.stopAllSounds();
  }

  void _navigateToPage(int direction) {
    setState(() {
      _currentPage = (_currentPage + direction).clamp(0, _getMaxPages() - 1);
    });
  }

  int _getMaxPages() {
    return (_sounds.length / maxItemsPerPage).ceil();
  }

  @override
  void dispose() {
    _audioManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('🎵 Soundboard'),
      centerTitle: true,
      elevation: 10,
      backgroundColor: Colors.black87,
      actions: [
        IconButton(
          icon: const Icon(Icons.stop),
          tooltip: 'Stop All',
          onPressed: _stopAllSounds,
        ),
      ],
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final layoutConfig = ResponsiveLayoutConfig.fromConstraints(constraints);
        final pageSounds = _getPaginatedSounds(layoutConfig.itemsPerPage);

        return Column(
          children: [
            Expanded(
              child: SoundGrid(
                sounds: pageSounds,
                layoutConfig: layoutConfig,
                onSoundPressed: _playSound,
              ),
            ),
            PaginationControls(
              currentPage: _currentPage,
              totalPages: (_sounds.length / layoutConfig.itemsPerPage).ceil(),
              onPreviousPressed: _currentPage > 0 ? () => _navigateToPage(-1) : null,
              onNextPressed: (_currentPage + 1) * layoutConfig.itemsPerPage < _sounds.length
                  ? () => _navigateToPage(1)
                  : null,
              screenWidth: constraints.maxWidth,
            ),
          ],
        );
      },
    );
  }

  List<SoundItem> _getPaginatedSounds(int itemsPerPage) {
    final startIndex = _currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, _sounds.length);
    return _sounds.sublist(startIndex, endIndex);
  }
}

class ResponsiveLayoutConfig {
  final int crossAxisCount;
  final double buttonSize;
  final int itemsPerPage;
  final double spacing;
  final double padding;

  const ResponsiveLayoutConfig({
    required this.crossAxisCount,
    required this.buttonSize,
    required this.itemsPerPage,
    required this.spacing,
    required this.padding,
  });

  factory ResponsiveLayoutConfig.fromConstraints(BoxConstraints constraints) {
    final screenWidth = constraints.maxWidth;
    final screenHeight = constraints.maxHeight;

    // Determine grid configuration based on screen size
    final int crossAxisCount;
    if (screenWidth < 600) {
      crossAxisCount = 2; // Mobile
    } else if (screenWidth < 900) {
      crossAxisCount = 3; // Tablet
    } else if (screenWidth < 1200) {
      crossAxisCount = 4; // Desktop small
    } else {
      crossAxisCount = 5; // Desktop large
    }

    // Calculate button size and layout
    const double appBarHeight = 56;
    const double paginationHeight = 60;
    const double verticalPadding = 32;
    const double extraMargin = 20;

    final double availableHeight = screenHeight - 
        appBarHeight - paginationHeight - verticalPadding - extraMargin;

    double buttonSize = ((screenWidth - 60) / crossAxisCount) - 20;
    buttonSize = buttonSize.clamp(100.0, 180.0);

    final int maxRows = (availableHeight / (buttonSize + 20)).floor().clamp(1, 6);
    final int itemsPerPage = crossAxisCount * maxRows;

    return ResponsiveLayoutConfig(
      crossAxisCount: crossAxisCount,
      buttonSize: buttonSize,
      itemsPerPage: itemsPerPage,
      spacing: screenWidth < 600 ? 12 : 20,
      padding: screenWidth < 600 ? 16 : 32,
    );
  }
}

class SoundGrid extends StatelessWidget {
  final List<SoundItem> sounds;
  final ResponsiveLayoutConfig layoutConfig;
  final Function(String) onSoundPressed;

  const SoundGrid({
    super.key,
    required this.sounds,
    required this.layoutConfig,
    required this.onSoundPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: layoutConfig.padding,
          vertical: 16,
        ),
        child: Wrap(
          spacing: layoutConfig.spacing,
          runSpacing: layoutConfig.spacing,
          alignment: WrapAlignment.center,
          children: sounds.map((sound) {
            return SizedBox(
              width: layoutConfig.buttonSize,
              height: layoutConfig.buttonSize,
              child: AnimatedSoundButton(
                sound: sound,
                onPressed: () => onSoundPressed(sound.file),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback? onPreviousPressed;
  final VoidCallback? onNextPressed;
  final double screenWidth;

  const PaginationControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    this.onPreviousPressed,
    this.onNextPressed,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.black87,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavigationButton(
              onPressed: onPreviousPressed,
              icon: Icons.arrow_back_ios,
              label: screenWidth < 600 ? 'ก่อน' : 'ก่อนหน้า',
            ),
            _buildPageIndicator(),
            _buildNavigationButton(
              onPressed: onNextPressed,
              icon: Icons.arrow_forward_ios,
              label: screenWidth < 600 ? 'ถัด' : 'ถัดไป',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
  }) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: 12,
            horizontal: screenWidth < 600 ? 8 : 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Expanded(
      flex: screenWidth < 600 ? 1 : 2,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'หน้า ${currentPage + 1}',
              style: TextStyle(
                fontSize: screenWidth < 600 ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              'จาก $totalPages',
              style: TextStyle(
                fontSize: screenWidth < 600 ? 12 : 14,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AudioPlayerManager {
  final List<AudioPlayer> _activePlayers = [];

  Future<void> playSound(String fileName) async {
    final player = AudioPlayer();
    _activePlayers.add(player);
    
    await player.play(AssetSource('sounds/$fileName'));
    
    player.onPlayerComplete.listen((event) {
      _activePlayers.remove(player);
      player.dispose();
    });
  }

  void stopAllSounds() {
    for (var player in _activePlayers) {
      player.stop();
      player.dispose();
    }
    _activePlayers.clear();
  }

  void dispose() {
    stopAllSounds();
  }
}

class SoundData {
  static List<SoundItem> getSounds() {
    return [
      SoundItem('tung-tung-sahur', 'tung-tung-sahur.mp3', Icons.music_note, Colors.deepPurple),
      SoundItem('Plankton Aughhhhh', 'Plankton Aughhhhh.mp3', Icons.surround_sound, Colors.teal),
      SoundItem('WAIT..WHAT', 'WAIT..WHAT.mp3', Icons.music_note, Colors.deepPurple),
      SoundItem('tung-tung-sahur', 'tung-tung-sahur.mp3', Icons.music_note, Colors.deepPurple),
      SoundItem('Plankton Aughhhhh', 'Plankton Aughhhhh.mp3', Icons.surround_sound, Colors.teal),
      SoundItem('WAIT..WHAT', 'WAIT..WHAT.mp3', Icons.music_note, Colors.deepPurple),
    ];
  }
}

class SoundItem {
  final String name;
  final String file;
  final IconData icon;
  final Color color;
  final String? image;

  const SoundItem(this.name, this.file, this.icon, this.color, {this.image});
}

class AnimatedSoundButton extends StatefulWidget {
  final SoundItem sound;
  final VoidCallback onPressed;

  const AnimatedSoundButton({
    super.key,
    required this.sound,
    required this.onPressed,
  });

  @override
  State<AnimatedSoundButton> createState() => _AnimatedSoundButtonState();
}

class _AnimatedSoundButtonState extends State<AnimatedSoundButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonSize = constraints.maxWidth;
        final iconSize = (buttonSize * 0.3).clamp(24.0, 54.0);
        final fontSize = (buttonSize * 0.12).clamp(12.0, 20.0);
        
        return Listener(
          onPointerDown: (_) => setState(() => _pressed = true),
          onPointerUp: (_) => setState(() => _pressed = false),
          child: AnimatedScale(
            scale: _pressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Material(
              elevation: 12,
              borderRadius: BorderRadius.circular(buttonSize * 0.15),
              color: widget.sound.color.withAlpha((0.95 * 255).toInt()),
              child: InkWell(
                borderRadius: BorderRadius.circular(buttonSize * 0.15),
                splashColor: Colors.white24,
                onTap: widget.onPressed,
                child: Padding(
                  padding: EdgeInsets.all(buttonSize * 0.08),
                  child: _buildButtonContent(buttonSize, iconSize, fontSize),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildButtonContent(double buttonSize, double iconSize, double fontSize) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          widget.sound.icon,
          size: iconSize,
          color: Colors.white,
        ),
        SizedBox(height: buttonSize * 0.08),
        Flexible(
          child: Text(
            widget.sound.name,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Colors.white,
              shadows: const [
                Shadow(
                  blurRadius: 4,
                  color: Colors.black54,
                  offset: Offset(1, 2),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.sound.image != null) ...[
          SizedBox(height: buttonSize * 0.06),
          Image.asset(
            widget.sound.image!,
            height: buttonSize * 0.2,
            fit: BoxFit.contain,
          ),
        ],
      ],
    );
  }
}