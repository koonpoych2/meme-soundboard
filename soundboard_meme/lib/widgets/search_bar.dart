import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const SearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      onChanged: onChanged,
      style: GoogleFonts.rubik(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search dank memes…',
        hintStyle: GoogleFonts.rubik(color: Colors.grey.shade400),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest
            .withAlpha((0.1 * 255).round()),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: Colors.grey.shade700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide(color: theme.colorScheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
