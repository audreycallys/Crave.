import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
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

                          const _FoodJournalPreview(),

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

class _FoodJournalPreview extends StatelessWidget {
  const _FoodJournalPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your food diary',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: AppColors.primary,
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Row(
            children: [
              Expanded(
                child: _DateItem(day: 'MON', date: '02'),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _DateItem(day: 'TUE', date: '03'),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _DateItem(day: 'WED', date: '04', selected: true),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _DateItem(day: 'THU', date: '05'),
              ),
              SizedBox(width: 6),
              Expanded(
                child: _DateItem(day: 'FRI', date: '06'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=1381&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=NHwxMjA3fDA%3D',
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 64,
                        height: 64,
                        color: AppColors.border,
                        child: const Icon(
                          Icons.local_cafe_rounded,
                          color: AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hawaiian Pizza',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Pizza's Papa · Rp150.000",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: Color(0xFFD6A928),
                          ),
                          SizedBox(width: 3),
                          Text(
                            '4.8 / 5',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateItem extends StatelessWidget {
  final String day;
  final String date;
  final bool selected;

  const _DateItem({
    required this.day,
    required this.date,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.accent : AppColors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
