import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../widgets/entry_card.dart';

class MyEntriesPage extends StatefulWidget {
  final VoidCallback? onEntryChanged;

  const MyEntriesPage({super.key, this.onEntryChanged});

  @override
  State<MyEntriesPage> createState() => MyEntriesPageState();
}

class MyEntriesPageState extends State<MyEntriesPage> {
  List<dynamic> entries = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    fetchMyEntries();
  }

  Future<void> fetchMyEntries() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

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
    if (selectedCategory == 'All') return entries;

    return entries
        .where((entry) => entry['category'] == selectedCategory)
        .toList();
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', 'Food', 'Drink'];

    return Row(
      children: categories.map((category) {
        final isSelected = selectedCategory == category;

        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              const SizedBox(height: 5),
              const Text(
                'Every bite, saved in your story.',
                style: AppTheme.pageSubtitle,
              ),
              const SizedBox(height: 28),
              _buildCategoryFilter(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('My experiences', style: AppTheme.sectionTitle),
                  Row(
                    children: [
                      Text(
                        '${filteredEntries.length} entries',
                        style: AppTheme.caption,
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 38,
                        height: 38,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          tooltip: 'Refresh entries',
                          onPressed: isLoading ? null : fetchMyEntries,
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 100),
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
              else if (filteredEntries.isEmpty)
                _buildMessage(
                  icon: Icons.search_off_rounded,
                  title: 'No entries found',
                  description:
                      'You have no ${selectedCategory.toLowerCase()} entries yet.',
                  buttonText: 'Show all',
                  onPressed: () {
                    setState(() {
                      selectedCategory = 'All';
                    });
                  },
                )
              else
                ...filteredEntries.map(
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

  Widget _buildMessage({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    VoidCallback? onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 70),
      child: Column(
        children: [
          Icon(icon, size: 55, color: AppColors.primary),
          const SizedBox(height: 18),
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
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: onPressed ?? fetchMyEntries,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }
}
