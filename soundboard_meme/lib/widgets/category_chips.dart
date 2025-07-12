import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;
  const CategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories
            .map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(c, style: GoogleFonts.rubik()),
                  selected: selected == c,
                  selectedColor: theme.colorScheme.primary.withOpacity(0.3),
                  onSelected: (_) => onSelected(c),
                  backgroundColor:
                      theme.colorScheme.surfaceVariant.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: theme.colorScheme.outline),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
