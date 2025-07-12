import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/sound_provider.dart';
import 'screens/home_page.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SoundProvider(),
      child: MaterialApp(
        title: 'Meme Sound Board',
        theme: AppTheme.theme,
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
