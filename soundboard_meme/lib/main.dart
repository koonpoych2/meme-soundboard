import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/sound_provider.dart';
import 'screens/home_page.dart';

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
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.pinkAccent,
          scaffoldBackgroundColor: Colors.orange[50],
        ),
        home: const HomePage(),
      ),
    );
  }
}
