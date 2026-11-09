import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/entry_grid_card.dart';
import '../../widgets/category_filter.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => ExplorePageState();
}

class ExplorePageState extends State<ExplorePage> {
  final TextEditingController searchController = TextEditingController();

  List<dynamic> entries = [];

  bool isLoading = true;
  String? errorMessage;
  String selectedCategory = 'All';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchEntries();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchEntries() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.get('/entries');

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

  int get foodCount {
    return entries.where((entry) => entry['category'] == 'Food').length;
  }

  int get drinkCount {
    return entries.where((entry) => entry['category'] == 'Drink').length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: fetchEntries,
          color: AppColors.primary,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
            children: [
              _buildHeader(),
              const SizedBox(height: 26),
              _buildSearchBar(),
              const SizedBox(height: 28),
              _buildCategorySection(),
              const SizedBox(height: 28),
              _buildResultsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Explore', style: AppTheme.pageTitle),
        const SizedBox(height: 8),
        const Text(
          'Discover new flavors shared by the Crave community.',
          style: AppTheme.bodyText,
        ),
      ],
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
          hintText: 'Search food or places...',
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

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categories', style: AppTheme.sectionTitle),
        const SizedBox(height: 6),
        Text(
          '${entries.length} experiences · $foodCount food · $drinkCount drinks',
          style: AppTheme.caption,
        ),
        const SizedBox(height: 14),
        CategoryFilter(
          selectedCategory: selectedCategory,
          onChanged: (category) {
            setState(() {
              selectedCategory = category;
            });
          },
        ),
      ],
    );
  }

  Widget _buildResultsSection() {
    final results = filteredEntries;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Discover experiences', style: AppTheme.sectionTitle),
            Text('${results.length} posts', style: AppTheme.caption),
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
            onPressed: fetchEntries,
          )
        else if (entries.isEmpty)
          _buildMessage(
            icon: Icons.explore_outlined,
            title: 'Nothing to explore yet',
            description:
                'There are no public experiences available yet. Check back later!',
            buttonText: 'Refresh',
            onPressed: fetchEntries,
          )
        else if (results.isEmpty)
          _buildMessage(
            icon: Icons.search_off_rounded,
            title: 'No experiences found',
            description: 'Try another keyword or choose a different category.',
            buttonText: 'Clear filters',
            onPressed: () {
              searchController.clear();
              setState(() {
                searchQuery = '';
                selectedCategory = 'All';
              });
            },
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
              childAspectRatio: 0.55,
            ),
            itemBuilder: (context, index) {
              return EntryGridCard(
                entry: Map<String, dynamic>.from(results[index]),
                onEntryChanged: fetchEntries,
              );
            },
          ),
      ],
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required VoidCallback onPressed,
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
          OutlinedButton(onPressed: onPressed, child: Text(buttonText)),
        ],
      ),
    );
  }
}
