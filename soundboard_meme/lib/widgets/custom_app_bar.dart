import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showFilters;
  final Widget? searchBar;
  final Widget? categoryChips;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showFilters = false,
    this.searchBar,
    this.categoryChips,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 80);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradient = LinearGradient(
      colors: [
        theme.colorScheme.primary.withAlpha((0.6 * 255).round()),
        theme.colorScheme.primary,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return AppBar(
      title: Text(
        '$title 🎵',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: gradient),
      ),
      actions: actions,
      bottom: showFilters
          ? PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                child: Column(
                  children: [
                    if (searchBar != null) searchBar!,
                    const SizedBox(height: 8),
                    if (categoryChips != null) categoryChips!,
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
