import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.restaurant_rounded,
                  size: 27,
                  color: AppColors.primary,
                ),
                SizedBox(width: 10),
                Text(
                  'crave.',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
