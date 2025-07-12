import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/sound.dart';

class DownloadService {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final permission = await Permission.storage.request();
      if (permission != PermissionStatus.granted) {
        final managePermission = await Permission.manageExternalStorage
            .request();
        return managePermission == PermissionStatus.granted;
      }
      return true;
    }
    return true; // iOS doesn't need explicit storage permission for app documents
  }

  static Future<String?> downloadSound(Sound sound) async {
    try {
      // Request permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        throw Exception('Storage permission denied');
      }

      // Get the downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!downloadsDir.existsSync()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) {
        throw Exception('Could not access downloads directory');
      }

      // Create a subdirectory for our app
      final appDir = Directory('${downloadsDir.path}/SoundboardMeme');
      if (!appDir.existsSync()) {
        appDir.createSync(recursive: true);
      }

      // Load the asset
      final byteData = await rootBundle.load('assets/${sound.assetPath}');
      final bytes = byteData.buffer.asUint8List();

      // Create the file name (sanitize the sound name)
      final fileName =
          '${sound.name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(' ', '_')}.mp3';
      final filePath = '${appDir.path}/$fileName';

      // Write the file
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      return filePath;
    } catch (e) {
      throw Exception('Failed to download sound: $e');
    }
  }

  static Future<List<String>> getDownloadedSounds() async {
    try {
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!downloadsDir.existsSync()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) return [];

      final appDir = Directory('${downloadsDir.path}/SoundboardMeme');
      if (!appDir.existsSync()) return [];

      final files = appDir
          .listSync()
          .where((file) => file is File && file.path.endsWith('.mp3'))
          .map((file) => file.path)
          .toList();

      return files;
    } catch (e) {
      return [];
    }
  }
}
