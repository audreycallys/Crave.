import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class CategoryFilter extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onChanged;

  const CategoryFilter({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  static const List<String> categories = ['All', 'Food', 'Drink'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = selectedCategory == category;

        return ChoiceChip(
          label: Text(category),
          selected: isSelected,
          onSelected: (_) => onChanged(category),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.white,
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          labelStyle: TextStyle(
            color: isSelected ? AppColors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 9),
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 0),
          visualDensity: VisualDensity.compact,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          showCheckmark: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      }).toList(),
    );
  }
}
