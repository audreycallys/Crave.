import 'package:flutter/material.dart';

import '../widgets/floating_bottom_nav.dart';
import 'home/home_page.dart';
import 'explore/explore_page.dart';
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
  final GlobalKey<ExplorePageState> _exploreKey = GlobalKey<ExplorePageState>();

  void _refreshHomeEntries() {
    _homeKey.currentState?.fetchEntries();
  }

  void _refreshMyEntries() {
    _myEntriesKey.currentState?.fetchMyEntries();
  }

  void _refreshExploreEntries() {
    _exploreKey.currentState?.fetchEntries();
  }

  void _refreshAllEntries() {
    _refreshHomeEntries();
    _refreshMyEntries();
    _refreshExploreEntries();
  }

  void _onItemSelected(int index) {
    if (index == selectedIndex) return;

    if (index == 1) {
      _refreshExploreEntries();
    }

    setState(() {
      selectedIndex = index;
    });
  }

  void _openProfile() {
    setState(() {
      selectedIndex = 4;
    });
  }

  void _openExplore() {
    _refreshExploreEntries();

    setState(() {
      selectedIndex = 1;
    });
  }

  late final List<Widget> pages = [
    HomePage(
      key: _homeKey,
      onEntryChanged: _refreshMyEntries,
      onProfileTap: _openProfile,
      onExploreTap: _openExplore,
    ),
    ExplorePage(key: _exploreKey),
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
        onItemSelected: _onItemSelected,
      ),
    );
  }
}
