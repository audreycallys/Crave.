import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../widgets/floating_bottom_nav.dart';
import 'home/home_page.dart';
import 'entries/my_entries_page.dart';
import 'entries/add_entry_page.dart';
import 'profile/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final GlobalKey<HomePageState> _homeKey = GlobalKey<HomePageState>();

  final GlobalKey<MyEntriesPageState> _myEntriesKey =
      GlobalKey<MyEntriesPageState>();

  void _refreshHomeEntries() {
    _homeKey.currentState?.fetchEntries();
  }

  void _refreshMyEntries() {
    _myEntriesKey.currentState?.fetchMyEntries();
  }

  void _refreshAllEntries() {
    _refreshHomeEntries();
    _refreshMyEntries();
  }

  late final List<Widget> pages = [
    HomePage(key: _homeKey, onEntryChanged: _refreshMyEntries),
    const _PlaceholderPage(
      title: 'Explore',
      description: 'Discover culinary experiences from others.',
      icon: Icons.explore_outlined,
    ),
    AddEntryPage(onEntryCreated: _refreshAllEntries),
    MyEntriesPage(key: _myEntriesKey, onEntryChanged: _refreshHomeEntries),
    const ProfilePage(),
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
              Icon(icon, size: 60, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
