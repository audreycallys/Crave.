import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/entry_card.dart';
import '../../widgets/category_filter.dart';

class MyEntriesPage extends StatefulWidget {
  final VoidCallback? onEntryChanged;

  const MyEntriesPage({super.key, this.onEntryChanged});

  @override
  State<MyEntriesPage> createState() => MyEntriesPageState();
}

class MyEntriesPageState extends State<MyEntriesPage> {
  final TextEditingController searchController = TextEditingController();

  List<dynamic> entries = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedCategory = 'All';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchMyEntries();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchMyEntries() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.get('/entries/my');

      if (!mounted) return;

      setState(() {
        entries = response['data']['entries'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _handleEntryChanged() async {
    await fetchMyEntries();
    widget.onEntryChanged?.call();
  }

  List<dynamic> get filteredEntries {
    return entries.where((entry) {
      final category = entry['category']?.toString() ?? '';
      final menuName = entry['menuName']?.toString().toLowerCase() ?? '';
      final placeName = entry['placeName']?.toString().toLowerCase() ?? '';

      final matchesCategory =
          selectedCategory == 'All' || category == selectedCategory;

      final matchesSearch =
          menuName.contains(searchQuery) || placeName.contains(searchQuery);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _clearFilters() {
    searchController.clear();

    setState(() {
      searchQuery = '';
      selectedCategory = 'All';
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = filteredEntries;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchMyEntries,
          color: AppColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
            children: [
              const Text('My Journal', style: AppTheme.pageTitle),
              const SizedBox(height: 8),
              const Text(
                'Every bite, saved in your story.',
                style: AppTheme.bodyText,
              ),
              const SizedBox(height: 26),
              _buildSearchBar(),
              const SizedBox(height: 24),
              CategoryFilter(
                selectedCategory: selectedCategory,
                onChanged: (category) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('My experiences', style: AppTheme.sectionTitle),
                  Text('${results.length} entries', style: AppTheme.caption),
                ],
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (errorMessage != null)
                _buildMessage(
                  icon: Icons.wifi_off_rounded,
                  title: 'Something went wrong',
                  description: errorMessage!,
                  buttonText: 'Try again',
                )
              else if (entries.isEmpty)
                _buildMessage(
                  icon: Icons.book_outlined,
                  title: 'Your journal is empty',
                  description:
                      'Start saving your favorite culinary experiences here.',
                  buttonText: 'Refresh',
                )
              else if (results.isEmpty)
                _buildMessage(
                  icon: Icons.search_off_rounded,
                  title: 'No entries found',
                  description:
                      'Try another keyword or choose a different category.',
                  buttonText: 'Clear filters',
                  onPressed: _clearFilters,
                )
              else
                ...results.map(
                  (entry) => EntryCard(
                    key: ValueKey(entry['id']),
                    entry: Map<String, dynamic>.from(entry),
                    onEntryChanged: _handleEntryChanged,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value.trim().toLowerCase();
          });
        },
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search your entries...',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    setState(() {
                      searchQuery = '';
                    });
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 19,
                    color: AppColors.textSecondary,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    VoidCallback? onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 35, bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.sectionTitle,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTheme.bodyText,
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onPressed ?? fetchMyEntries,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
