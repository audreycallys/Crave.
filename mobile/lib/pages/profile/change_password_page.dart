import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isSaving = false;
  bool showCurrentPassword = false;
  bool showNewPassword = false;
  bool showConfirmPassword = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> changePassword() async {
    final currentPassword = currentPasswordController.text;
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New passwords do not match.')),
      );
      return;
    }

    if (currentPassword == newPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'New password must be different from current password.',
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await ApiService.put('/auth/change-password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Widget buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          enableSuggestions: false,
          autocorrect: false,
          style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                isVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: isSaving ? null : () => Navigator.pop(context),
                  tooltip: 'Back',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Change Password',
                    textAlign: TextAlign.center,
                    style: AppTheme.pageTitle,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildPasswordField(
                    label: 'Current Password',
                    hint: 'Enter your current password',
                    controller: currentPasswordController,
                    isVisible: showCurrentPassword,
                    onToggle: () {
                      setState(() {
                        showCurrentPassword = !showCurrentPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  buildPasswordField(
                    label: 'New Password',
                    hint: 'Enter your new password',
                    controller: newPasswordController,
                    isVisible: showNewPassword,
                    onToggle: () {
                      setState(() {
                        showNewPassword = !showNewPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  buildPasswordField(
                    label: 'Confirm New Password',
                    hint: 'Re-enter your new password',
                    controller: confirmPasswordController,
                    isVisible: showConfirmPassword,
                    onToggle: () {
                      setState(() {
                        showConfirmPassword = !showConfirmPassword;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Use a new password that is different from your current password.',
              style: AppTheme.bodyText,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: isSaving ? null : changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.5,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.white,
                        ),
                      )
                    : const Text(
                        'Update Password',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
