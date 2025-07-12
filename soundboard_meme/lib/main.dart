import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
          colorScheme: ColorScheme.dark(
            background: const Color(0xFF121212),
            primary: const Color(0xFF9C27B0),
            secondary: Colors.tealAccent.shade200,
          ),
          textTheme: GoogleFonts.rubikTextTheme(
            ThemeData.dark().textTheme,
          ),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
