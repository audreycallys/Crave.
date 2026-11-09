import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../pages/entries/entry_detail_page.dart';

class EntryGridCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final VoidCallback? onEntryChanged;

  const EntryGridCard({super.key, required this.entry, this.onEntryChanged});

  String formatPrice(dynamic price) {
    final amount = double.tryParse(price.toString());

    if (amount == null) return price.toString();

    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');

    return 'Rp$formatted';
  }

  String formatDate(dynamic date) {
    if (date == null || date.toString().isEmpty) return '';

    final parsedDate = DateTime.tryParse(date.toString());

    if (parsedDate == null) return date.toString();

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}';
  }

  Future<void> openDetail(BuildContext context) async {
    final entryId = entry['id'];

    if (entryId == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EntryDetailPage(entryId: entryId.toString()),
      ),
    );

    if (!context.mounted) return;

    if (result == true) {
      onEntryChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = entry['photoUrl']?.toString() ?? '';
    final category = entry['category']?.toString() ?? 'Food';
    final menuName = entry['menuName']?.toString() ?? 'Untitled';
    final placeName = entry['placeName']?.toString() ?? '';
    final date = formatDate(entry['dateTried']);
    final rating = entry['rating'] ?? 0;

    return GestureDetector(
      onTap: () => openDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(photoUrl),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _imageBadge(
                      icon: category == 'Drink'
                          ? Icons.local_cafe_rounded
                          : Icons.restaurant_rounded,
                      label: category,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _imageBadge(
                      icon: Icons.star_rounded,
                      label: '$rating/5',
                      iconColor: const Color(0xFFD6A928),
                      textColor: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  if (placeName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _detailItem(Icons.location_on_outlined, placeName),
                  ],
                  if (date.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    _detailItem(Icons.calendar_today_rounded, date),
                  ],
                  const SizedBox(height: 8),
                  const Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 8),
                  Text(
                    formatPrice(entry['price'] ?? 0),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String photoUrl) {
    if (photoUrl.isEmpty) return _imagePlaceholder();

    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _imagePlaceholder();
      },
    );
  }

  Widget _imageBadge({
    required IconData icon,
    required String label,
    Color iconColor = AppColors.primary,
    Color textColor = AppColors.primary,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: iconColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.primarySoft,
      child: const Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 35,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
