# Meme Soundboard

This repository contains a Flutter project located in `soundboard_meme/`.
The `lib` directory holds the Dart source while platform folders like
`android/` and `ios/` provide build targets.

## Directory overview

- `lib/` – main application code
  - `main.dart` starts the app
  - `screens/` includes pages such as `home_page.dart` and `downloads_screen.dart`
  - `widgets/` provides reusable components like `emoji_background.dart` and `sound_tile.dart`
  - `models/` defines data models
  - `providers/` holds state logic
  - `services/` contains helpers like `download_service.dart`
- `assets/` – images and audio (e.g. `Plankton Aughhhhh.mp3`)
- Standard Flutter platform directories: `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`

Run project commands with Flutter:

```sh
flutter pub get
flutter analyze
```
