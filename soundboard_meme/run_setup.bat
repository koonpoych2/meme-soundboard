@echo off
cd c:\Users\guide\Documents\meme-soundboard\soundboard_meme
echo Installing dependencies...
flutter pub get
echo.
echo Analyzing code...
flutter analyze --no-fatal-infos
echo.
echo Ready to run! Use: flutter run
