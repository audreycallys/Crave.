import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';
import 'add_entry_page.dart';

class EntryDetailPage extends StatefulWidget {
  final String entryId;

  const EntryDetailPage({super.key, required this.entryId});

  @override
  State<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends State<EntryDetailPage> {
  Map<String, dynamic>? entry;
  int? currentUserId;

  bool isLoading = true;
  bool hasChanges = false;
  String? errorMessage;

  final TextEditingController commentController = TextEditingController();

  List<Map<String, dynamic>> comments = [];
  bool isCommentsLoading = false;
  bool isSubmittingComment = false;

  bool get isOwner {
    if (entry == null || currentUserId == null) return false;
    return entry!['userId']?.toString() == currentUserId.toString();
  }

  bool get isPublic => entry?['isPublic'] == true;

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> fetchDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.get('/entries/${widget.entryId}');
      final userId = await ApiService.getCurrentUserId();

      if (!mounted) return;

      setState(() {
        entry = Map<String, dynamic>.from(response['data']['entry']);
        currentUserId = userId;
        isLoading = false;
      });

      if (isPublic) {
        await fetchComments();
      } else {
        setState(() {
          comments = [];
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> fetchComments() async {
    if (!isPublic) return;

    setState(() {
      isCommentsLoading = true;
    });

    try {
      final response = await ApiService.getComments(widget.entryId);
      final data = response['data']['comments'] as List;

      if (!mounted) return;

      setState(() {
        comments = data.map((item) => Map<String, dynamic>.from(item)).toList();
        isCommentsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isCommentsLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load comments: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  Future<void> addComment() async {
    final content = commentController.text.trim();

    if (content.isEmpty || isSubmittingComment) return;

    setState(() {
      isSubmittingComment = true;
    });

    try {
      await ApiService.createComment(widget.entryId, content);

      if (!mounted) return;

      commentController.clear();
      FocusScope.of(context).unfocus();

      await fetchComments();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to add comment: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmittingComment = false;
        });
      }
    }
  }

  Future<void> editComment(Map<String, dynamic> comment) async {
    final controller = TextEditingController(
      text: comment['content']?.toString() ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Comment'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 4,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'Write your comment...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final content = controller.text.trim();

                if (content.isNotEmpty) {
                  Navigator.pop(dialogContext, content);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null || !mounted) return;

    try {
      await ApiService.updateComment(comment['id'].toString(), result);

      if (!mounted) return;

      await fetchComments();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment updated successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update comment: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  Future<void> deleteComment(Map<String, dynamic> comment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Comment?'),
          content: const Text('Are you sure you want to delete this comment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    try {
      await ApiService.deleteComment(comment['id'].toString());

      if (!mounted) return;

      await fetchComments();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete comment: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  Future<void> editEntry() async {
    if (!isOwner || entry == null) return;

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => AddEntryPage(entry: entry!)),
    );

    if (result == true && mounted) {
      hasChanges = true;
      await fetchDetail();
    }
  }

  Future<void> handleBack() async {
    Navigator.pop(context, hasChanges);
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

  String formatCommentDate(dynamic date) {
    if (date == null) return '';

    final parsedDate = DateTime.tryParse(date.toString());

    if (parsedDate == null) return '';

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

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    Color iconColor = AppColors.primary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        style: IconButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: iconColor,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          fixedSize: const Size(40, 40),
          padding: EdgeInsets.zero,
        ),
        icon: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, hasChanges);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : errorMessage != null
              ? _buildError()
              : entry == null
              ? _buildError()
              : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final photoUrl = entry!['photoUrl']?.toString() ?? '';
    final category = entry!['category']?.toString() ?? 'Food';

    final user = entry!['user'] is Map
        ? Map<String, dynamic>.from(entry!['user'])
        : <String, dynamic>{};

    final userName = user['name']?.toString() ?? 'User';
    final userPhoto = user['profilePhotoUrl']?.toString() ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: handleBack,
              tooltip: 'Back',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.textPrimary,
              ),
            ),
            const Expanded(
              child: Text(
                'Experience Details',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (isOwner) ...[
              _buildActionButton(
                icon: Icons.edit_outlined,
                onPressed: editEntry,
                tooltip: 'Edit entry',
              ),
              _buildActionButton(
                icon: Icons.delete_outline_rounded,
                onPressed: deleteEntry,
                tooltip: 'Delete entry',
                iconColor: Colors.red,
              ),
            ] else
              const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 20),
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
        const SizedBox(height: 18),
        _buildOwnerInfo(userName, userPhoto),
        const SizedBox(height: 22),
        _buildCategoryAndRating(category),
        const SizedBox(height: 12),
        Text(
          entry!['menuName']?.toString() ?? 'Untitled',
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 18),
        _buildInformation(),
        const SizedBox(height: 26),
        const Text(
          'Experience Notes',
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            entry!['notes']?.toString().isNotEmpty == true
                ? entry!['notes'].toString()
                : 'No notes added for this experience.',
            style: const TextStyle(
              fontSize: 13,
              height: 1.7,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (isPublic) ...[const SizedBox(height: 30), _buildCommentsSection()],
      ],
    );
  }

  Widget _buildOwnerInfo(String name, String photoUrl) {
    return Row(
      children: [
        CircleAvatar(
          radius: 21,
          backgroundColor: AppColors.primarySoft,
          backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
          child: photoUrl.isEmpty
              ? const Icon(
                  Icons.person_rounded,
                  size: 22,
                  color: AppColors.primary,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Food experience',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        if (isOwner)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isPublic ? AppColors.primarySoft : AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPublic ? Icons.public_rounded : Icons.lock_outline_rounded,
                  size: 13,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  isPublic ? 'Public' : 'Private',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
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
        borderRadius: BorderRadius.circular(16),
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
          if (isOwner) ...[
            const Divider(height: 24, color: AppColors.border),
            _infoRow(
              Icons.visibility_outlined,
              'Visibility',
              isPublic ? 'Public' : 'Private',
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 19),
        const SizedBox(width: 12),
        SizedBox(
          width: 76,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            softWrap: true,
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

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Comments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                comments.length.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCommentInput(),
        const SizedBox(height: 20),
        if (isCommentsLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (comments.isEmpty)
          _buildEmptyComments()
        else
          ...comments.map(_buildCommentCard),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: commentController,
            maxLines: 3,
            minLines: 1,
            maxLength: 1000,
            decoration: const InputDecoration(
              hintText: 'Share your thoughts...',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
              border: InputBorder.none,
              counterText: '',
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ElevatedButton(
              onPressed: isSubmittingComment ? null : addComment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isSubmittingComment
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Text(
                      'Post Comment',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyComments() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 30,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 10),
          Text(
            'No comments yet',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Be the first to share your thoughts.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment) {
    final user = comment['user'] is Map
        ? Map<String, dynamic>.from(comment['user'])
        : <String, dynamic>{};

    final commentUserId = comment['userId']?.toString();
    final isCommentOwner = commentUserId == currentUserId?.toString();
    final canDelete = isCommentOwner || isOwner;

    final name = user['name']?.toString() ?? 'User';
    final photoUrl = user['profilePhotoUrl']?.toString() ?? '';
    final content = comment['content']?.toString() ?? '';
    final date = formatCommentDate(comment['createdAt']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.primarySoft,
                backgroundImage: photoUrl.isNotEmpty
                    ? NetworkImage(photoUrl)
                    : null,
                child: photoUrl.isEmpty
                    ? const Icon(
                        Icons.person_rounded,
                        size: 19,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCommentOwner || canDelete)
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.textSecondary,
                    size: 21,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      editComment(comment);
                    } else if (value == 'delete') {
                      deleteComment(comment);
                    }
                  },
                  itemBuilder: (context) => [
                    if (isCommentOwner)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    if (canDelete)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                              size: 18,
                            ),
                            SizedBox(width: 10),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textPrimary,
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
            TextButton(onPressed: handleBack, child: const Text('Go back')),
          ],
        ),
      ),
    );
  }

  Future<void> deleteEntry() async {
    if (!isOwner) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Entry?'),
          content: const Text(
            'Are you sure you want to delete this entry? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    try {
      await ApiService.delete('/entries/${widget.entryId}');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entry deleted successfully')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete entry: $e')));
    }
  }
}
