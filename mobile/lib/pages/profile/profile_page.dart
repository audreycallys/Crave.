import 'dart:convert';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../auth/login_page.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> user = {};

  bool isLoading = true;
  bool isLoggingOut = false;

  int totalEntries = 0;
  int publicEntries = 0;
  int privateEntries = 0;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final token = await ApiService.getToken();

      if (token != null) {
        final parts = token.split('.');

        if (parts.length == 3) {
          final payload = jsonDecode(
            utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
          );

          if (payload is Map) {
            user = Map<String, dynamic>.from(payload);
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to decode user token: $e');
    }

    try {
      final response = await ApiService.get('/users/profile');

      if (response['data'] is Map) {
        user = Map<String, dynamic>.from(response['data']);
      }
    } catch (e) {
      debugPrint('Failed to load profile information: $e');
    }

    try {
      final response = await ApiService.get('/entries/my');
      final entries = response['data']['entries'] as List;

      totalEntries = entries.length;

      publicEntries = entries.where((entry) {
        return entry['isPublic'] == true;
      }).length;

      privateEntries = totalEntries - publicEntries;
    } catch (e) {
      debugPrint('Failed to load profile activity: $e');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> openEditProfile() async {
    final updatedUser = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => EditProfilePage(user: user)),
    );

    if (updatedUser != null && mounted) {
      setState(() {
        user = updatedUser;
      });
    }
  }

  String get initials {
    final name = user['name']?.toString() ?? 'User';
    final words = name.trim().split(RegExp(r'\s+'));

    if (words.length > 1 && words[0].isNotEmpty && words[1].isNotEmpty) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }

    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  Future<void> handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Log Out',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to log out of your Crave account?',
            style: AppTheme.bodyText,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    setState(() {
      isLoggingOut = true;
    });

    await ApiService.removeToken();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget buildActivityItem({required String title, required int value}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTheme.caption.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget buildActivityCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          buildActivityItem(title: 'Total Entries', value: totalEntries),
          Container(width: 1, height: 38, color: AppColors.border),
          buildActivityItem(title: 'Public', value: publicEntries),
          Container(width: 1, height: 38, color: AppColors.border),
          buildActivityItem(title: 'Private', value: privateEntries),
        ],
      ),
    );
  }

  Widget buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.caption),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileAvatar() {
    final photoUrl = user['profilePhotoUrl']?.toString() ?? '';

    return Container(
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primarySoft,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Center(
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7771D1), AppColors.primary],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: photoUrl.isNotEmpty
                ? Image.network(
                    photoUrl,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = user['name']?.toString() ?? 'Crave User';
    final email = user['email']?.toString() ?? '-';
    final bio = user['bio']?.toString() ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: fetchProfile,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 120),
                  children: [
                    const Text('My Profile', style: AppTheme.pageTitle),
                    const SizedBox(height: 30),
                    Center(
                      child: Column(
                        children: [
                          buildProfileAvatar(),
                          const SizedBox(height: 18),
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(email, style: AppTheme.pageSubtitle),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: openEditProfile,
                            icon: const Icon(Icons.edit_outlined, size: 17),
                            label: const Text('Edit Profile'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 38),
                    const Text('Your Activity', style: AppTheme.sectionTitle),
                    const SizedBox(height: 14),
                    buildActivityCard(),
                    const SizedBox(height: 28),
                    const Text(
                      'Account Information',
                      style: AppTheme.sectionTitle,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          buildInfoTile(
                            icon: Icons.person_outline_rounded,
                            title: 'Full Name',
                            value: name,
                          ),
                          const Divider(color: AppColors.border),
                          buildInfoTile(
                            icon: Icons.email_outlined,
                            title: 'Email Address',
                            value: email,
                          ),
                          const Divider(color: AppColors.border),
                          buildInfoTile(
                            icon: Icons.notes_rounded,
                            title: 'Bio',
                            value: bio,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: isLoggingOut ? null : handleLogout,
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.redAccent,
                        ),
                        label: Text(
                          isLoggingOut ? 'Logging out...' : 'Log Out',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          side: const BorderSide(color: Color(0xFFF2DADA)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
