class Sound {
  final String id;
  final String name;
  final String assetPath;
  final String imagePath;
  final String category;
  bool isFavorite;

  Sound({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.imagePath,
    required this.category,
    this.isFavorite = false,
  });
}