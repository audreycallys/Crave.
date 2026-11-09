import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  Uint8List? photoBytes;
  String? photoFileName;
  String? photoMimeType;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController.text = widget.user['name']?.toString() ?? '';
    bioController.text = widget.user['bio']?.toString() ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> pickProfilePhoto() async {
    try {
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1000,
      );

      if (image == null) return;

      final bytes = await image.readAsBytes();

      if (!mounted) return;

      setState(() {
        photoBytes = bytes;
        photoFileName = image.name;
        photoMimeType = image.mimeType ?? 'image/jpeg';
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to select profile photo.')),
      );
    }
  }

  String get initials {
    final name = nameController.text.trim();

    if (name.isEmpty) return 'U';

    final words = name.split(RegExp(r'\s+'));

    if (words.length > 1) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }

    return name[0].toUpperCase();
  }

  Widget buildInitials() {
    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget buildPhotoPreview() {
    final photoUrl = widget.user['profilePhotoUrl']?.toString() ?? '';

    if (photoBytes != null) {
      return Image.memory(
        photoBytes!,
        width: 116,
        height: 116,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return buildInitials();
        },
      );
    }

    if (photoUrl.isNotEmpty) {
      return Image.network(
        photoUrl,
        width: 116,
        height: 116,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return buildInitials();
        },
      );
    }

    return buildInitials();
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();
    final bio = bioController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name cannot be empty.')));
      return;
    }

    if (name.length > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot exceed 100 characters.')),
      );
      return;
    }

    if (bio.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bio cannot exceed 500 characters.')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      final response = await ApiService.putMultipart(
        '/users/profile',
        fields: {'name': name, 'bio': bio},
        photoBytes: photoBytes,
        fileName: photoFileName,
        mimeType: photoMimeType,
      );

      if (!mounted) return;

      final updatedUser = Map<String, dynamic>.from(response['data']);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, updatedUser);
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

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    int? maxLength,
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
          maxLines: maxLines,
          maxLength: maxLength,
          textCapitalization: TextCapitalization.sentences,
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
                    'Edit Profile',
                    textAlign: TextAlign.center,
                    style: AppTheme.pageTitle,
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 116,
                        height: 116,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primarySoft,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: ClipOval(child: buildPhotoPreview()),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Material(
                          color: AppColors.primary,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: isSaving ? null : pickProfilePhoto,
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                color: AppColors.white,
                                size: 19,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: isSaving ? null : pickProfilePhoto,
                    child: const Text(
                      'Change Profile Photo',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
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
                  buildTextField(
                    label: 'Full Name',
                    controller: nameController,
                    hint: 'Enter your name',
                    maxLength: 100,
                  ),
                  const SizedBox(height: 20),
                  buildTextField(
                    label: 'Bio',
                    controller: bioController,
                    hint: 'Tell something about yourself',
                    maxLines: 4,
                    maxLength: 500,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveProfile,
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
                        'Save Changes',
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
