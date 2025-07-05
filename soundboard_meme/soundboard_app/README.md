# Soundboard App

A simple soundboard application built with Flutter. This app allows users to play various sound effects by tapping on buttons displayed in a grid layout.

## Features

- Play multiple sound effects including Click, Laugh, Cheer, Clap, Boom, and Wow.
- User-friendly interface with a dark theme.
- Responsive design that adapts to different screen sizes.

## Project Structure

```
soundboard_app
├── lib
│   ├── main.dart                # Entry point of the application
│   ├── screens
│   │   └── home_screen.dart     # Home screen displaying sound buttons
│   ├── models
│   │   └── sound_item.dart      # Model representing a sound item
│   └── widgets
│       └── sound_button.dart     # Custom button widget for playing sounds
├── assets
│   └── sounds
│       ├── click.mp3            # Sound asset for Click
│       ├── laugh.mp3            # Sound asset for Laugh
│       ├── cheer.mp3            # Sound asset for Cheer
│       ├── clap.mp3             # Sound asset for Clap
│       ├── boom.mp3             # Sound asset for Boom
│       └── wow.mp3              # Sound asset for Wow
├── pubspec.yaml                 # Flutter project configuration
└── README.md                    # Project documentation
```

## Getting Started

1. Clone the repository:
   ```
   git clone <repository-url>
   ```

2. Navigate to the project directory:
   ```
   cd soundboard_app
   ```

3. Install the dependencies:
   ```
   flutter pub get
   ```

4. Run the application:
   ```
   flutter run
   ```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for details.