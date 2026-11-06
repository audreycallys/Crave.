import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'home/home_page.dart';
import '../widgets/floating_bottom_nav.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const HomePage(),
    const _PlaceholderPage(
      title: 'Explore',
      description: 'Discover culinary experiences from others.',
      icon: Icons.explore_outlined,
    ),
    const _PlaceholderPage(
      title: 'Add Entry',
      description: 'Record your latest culinary experience.',
      icon: Icons.add_circle_outline_rounded,
    ),
    const _PlaceholderPage(
      title: 'My Journal',
      description: 'Your personal culinary collection.',
      icon: Icons.book_outlined,
    ),
    const _PlaceholderPage(
      title: 'Profile',
      description: 'Manage your Crave account.',
      icon: Icons.person_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      extendBody: true,
      bottomNavigationBar: FloatingBottomNav(
        selectedIndex: selectedIndex,
        onItemSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _PlaceholderPage({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 52, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
