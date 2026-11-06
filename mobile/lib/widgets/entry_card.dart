import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class EntryCard extends StatelessWidget {
  final Map<String, dynamic> entry;

  const EntryCard({super.key, required this.entry});

  String formatPrice(dynamic price) {
    final amount = double.tryParse(price.toString());

    if (amount == null) return price.toString();

    final number = amount.toStringAsFixed(0);
    final formatted = number.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'Rp$formatted';
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = entry['photoUrl']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food photo
          AspectRatio(
            aspectRatio: 16 / 10,
            child: photoUrl.isNotEmpty
                ? Image.network(
                    photoUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _imagePlaceholder();
                    },
                  )
                : _imagePlaceholder(),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        entry['category']?.toString() ?? 'Food',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFD6A928),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${entry['rating'] ?? 0}/5',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Menu name
                Text(
                  entry['menuName']?.toString() ?? 'Untitled',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                // Place
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        entry['placeName']?.toString() ?? '-',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Price
                Text(
                  formatPrice(entry['price'] ?? 0),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.primarySoft,
      child: const Center(
        child: Icon(
          Icons.restaurant_rounded,
          size: 45,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
