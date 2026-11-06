import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';

class EntryDetailPage extends StatefulWidget {
  final String entryId;

  const EntryDetailPage({super.key, required this.entryId});

  @override
  State<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends State<EntryDetailPage> {
  Map<String, dynamic>? entry;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.get('/entries/${widget.entryId}');

      if (!mounted) return;

      setState(() {
        entry = Map<String, dynamic>.from(response['data']['entry']);
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

  String formatPrice(dynamic price) {
    final amount = double.tryParse(price.toString());

    if (amount == null) return price.toString();

    final formatted = amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.');

    return 'Rp$formatted';
  }

  String formatDate(dynamic date) {
    if (date == null) return '-';

    final parsedDate = DateTime.tryParse(date.toString());

    if (parsedDate == null) return date.toString();

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${parsedDate.day} ${months[parsedDate.month - 1]} ${parsedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
            ? _buildError()
            : entry == null
            ? _buildError()
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final photoUrl = entry!['photoUrl']?.toString() ?? '';
    final category = entry!['category']?.toString() ?? 'Food';

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          pinned: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          title: const Text(
            'Experience Details',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: photoUrl.isNotEmpty
                        ? Image.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _imagePlaceholder();
                            },
                          )
                        : _imagePlaceholder(),
                  ),
                ),

                const SizedBox(height: 24),

                _buildCategoryAndRating(category),

                const SizedBox(height: 14),

                Text(
                  entry!['menuName']?.toString() ?? 'Untitled',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 22),

                _buildInformation(),

                const SizedBox(height: 26),

                const Text(
                  'My Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    entry!['notes']?.toString().isNotEmpty == true
                        ? entry!['notes'].toString()
                        : 'No notes added for this experience.',
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.7,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryAndRating(String category) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            category,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFD6A928), size: 20),
            const SizedBox(width: 5),
            Text(
              '${entry!['rating'] ?? 0}/5',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInformation() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _infoRow(
            Icons.location_on_outlined,
            'Place',
            entry!['placeName']?.toString().isNotEmpty == true
                ? entry!['placeName'].toString()
                : '-',
          ),
          const Divider(height: 24, color: AppColors.border),
          _infoRow(
            Icons.calendar_today_outlined,
            'Date tried',
            formatDate(entry!['dateTried']),
          ),
          const Divider(height: 24, color: AppColors.border),
          _infoRow(
            Icons.payments_outlined,
            'Price',
            formatPrice(entry!['price'] ?? 0),
          ),
          const Divider(height: 24, color: AppColors.border),
          _infoRow(
            Icons.public_rounded,
            'Visibility',
            entry!['isPublic'] == true ? 'Public' : 'Private',
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 19),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
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
          size: 55,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: AppColors.primary,
            ),
            const SizedBox(height: 15),
            const Text(
              'Unable to load experience',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Experience not found.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: fetchDetail,
              child: const Text('Try again'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}
