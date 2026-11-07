import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class FloatingBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const FloatingBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      Icons.home_rounded,
      Icons.explore_outlined,
      Icons.add_rounded,
      Icons.book_outlined,
      Icons.person_outline_rounded,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.10),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = selectedIndex == index;
          final isAddButton = index == 2;

          return GestureDetector(
            onTap: () => onItemSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isAddButton ? 48 : 46,
              height: 48,
              decoration: BoxDecoration(
                color: isAddButton
                    ? AppColors.primary
                    : isSelected
                    ? AppColors.primarySoft
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                items[index],
                size: isAddButton ? 27 : 23,
                color: isAddButton
                    ? AppColors.white
                    : isSelected
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
          );
        }),
      ),
    );
  }
}
