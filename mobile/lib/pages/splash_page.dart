import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../widgets/food_diary_calendar.dart';
import 'auth/login_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxHeight < 700;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 30),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _BrandHeader(),

                          SizedBox(height: isCompact ? 42 : 60),

                          const Text(
                            'Every bite\n'
                            'tells a story.',
                            style: TextStyle(
                              fontSize: 46,
                              fontWeight: FontWeight.w800,
                              height: 1.08,
                              letterSpacing: -2,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Keep track of the flavors you love,\n'
                            'the places you visit, and every\n'
                            'little food memory.',
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: AppColors.textSecondary,
                            ),
                          ),

                          SizedBox(height: isCompact ? 25 : 40),

                          const FoodDiaryCalendar(),

                          SizedBox(height: isCompact ? 35 : 55),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text('Get Started'),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Center(
                            child: Text(
                              'Save every flavor, remember every moment.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.restaurant_rounded, size: 27, color: AppColors.primary),
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
    );
  }
}
