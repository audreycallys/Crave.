import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/entry_grid_card.dart';
import '../../widgets/food_diary_calendar.dart';
import '../../widgets/category_filter.dart';

class HomePage extends StatefulWidget {
  final VoidCallback? onEntryChanged;
  final VoidCallback? onProfileTap;
  final VoidCallback? onExploreTap;

  const HomePage({
    super.key,
    this.onEntryChanged,
    this.onProfileTap,
    this.onExploreTap,
  });

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<dynamic> entries = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    fetchEntries();
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

  Future<void> _handleEntryChanged() async {
    await fetchEntries();
    widget.onEntryChanged?.call();
  }

  List<dynamic> get filteredEntries {
    if (selectedCategory == 'All') return entries;

    return entries
        .where((entry) => entry['category'] == selectedCategory)
        .toList();
  }

  int get foodCount =>
      entries.where((entry) => entry['category'] == 'Food').length;

  int get drinkCount =>
      entries.where((entry) => entry['category'] == 'Drink').length;

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
              const SizedBox(height: 28),
              _buildIntro(),
              const SizedBox(height: 20),
              const FoodDiaryCalendar(),
              const SizedBox(height: 28),
              _buildStatistics(),
              const SizedBox(height: 28),
              _buildCategorySection(),
              const SizedBox(height: 28),
              _buildRecentSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.restaurant_rounded,
              color: AppColors.primary,
              size: 27,
            ),
            const SizedBox(width: 10),
            const Text(
              'crave.',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: IconButton(
            onPressed: widget.onProfileTap,
            tooltip: 'Profile',
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('What are you craving?', style: AppTheme.pageTitle),
        const SizedBox(height: 8),
        const Text(
          'Discover new flavors and memorable experiences.',
          style: AppTheme.bodyText,
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Community overview', style: AppTheme.sectionTitle),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.auto_stories_rounded,
                label: 'Experiences',
                value: entries.length,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                icon: Icons.restaurant_rounded,
                label: 'Food',
                value: foodCount,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                icon: Icons.local_cafe_rounded,
                label: 'Drinks',
                value: drinkCount,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 21),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: AppTheme.caption),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Explore categories', style: AppTheme.sectionTitle),
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

  Widget _buildRecentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent experiences', style: AppTheme.sectionTitle),
            TextButton(
              onPressed: widget.onExploreTap,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'See all',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
            icon: Icons.restaurant_outlined,
            title: 'Nothing to discover yet',
            description:
                'There are no public culinary experiences yet. Be the first to share yours!',
            buttonText: 'Refresh',
            onPressed: fetchEntries,
          )
        else if (filteredEntries.isEmpty)
          _buildMessage(
            icon: Icons.search_off_rounded,
            title: 'No experiences found',
            description: 'There are no entries in this category yet.',
            buttonText: 'Show all',
            onPressed: () {
              setState(() {
                selectedCategory = 'All';
              });
            },
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredEntries.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
              childAspectRatio: 0.55,
            ),
            itemBuilder: (context, index) {
              return EntryGridCard(
                entry: Map<String, dynamic>.from(filteredEntries[index]),
                onEntryChanged: _handleEntryChanged,
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
