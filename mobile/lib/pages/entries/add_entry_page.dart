import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../services/api_service.dart';

class AddEntryPage extends StatefulWidget {
  final VoidCallback? onEntryCreated;
  final Map<String, dynamic>? entry;

  const AddEntryPage({super.key, this.onEntryCreated, this.entry});

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  final _formKey = GlobalKey<FormState>();

  final menuNameController = TextEditingController();
  final placeNameController = TextEditingController();
  final priceController = TextEditingController();
  final notesController = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();

  XFile? selectedPhoto;

  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();

  int selectedRating = 5;
  bool isPublic = false;
  bool isLoading = false;

  bool get isEditMode => widget.entry != null;

  String get existingPhotoUrl => widget.entry?['photoUrl']?.toString() ?? '';

  @override
  void initState() {
    super.initState();

    if (isEditMode) {
      final data = widget.entry!;

      menuNameController.text = data['menuName']?.toString() ?? '';
      placeNameController.text = data['placeName']?.toString() ?? '';
      priceController.text = data['price']?.toString() ?? '';
      notesController.text = data['notes']?.toString() ?? '';

      selectedCategory = data['category']?.toString() ?? 'Food';

      selectedDate =
          DateTime.tryParse(data['dateTried']?.toString() ?? '') ??
          DateTime.now();

      selectedRating = int.tryParse(data['rating']?.toString() ?? '') ?? 5;

      final visibility = data['isPublic'];
      isPublic = visibility == true || visibility.toString() == 'true';
    }
  }

  @override
  void dispose() {
    menuNameController.dispose();
    placeNameController.dispose();
    priceController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> pickPhoto() async {
    try {
      final photo = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (photo == null) return;

      setState(() {
        selectedPhoto = photo;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to select photo: $e')));
    }
  }

  Future<void> selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              surface: AppColors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  String formatDate(DateTime date) {
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  Future<void> submitEntry() async {
    if (!_formKey.currentState!.validate()) return;

    if (!isEditMode && selectedPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo first.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final fields = {
        'menuName': menuNameController.text.trim(),
        'placeName': placeNameController.text.trim(),
        'category': selectedCategory,
        'price': priceController.text.trim(),
        'dateTried': formatDate(selectedDate),
        'rating': selectedRating.toString(),
        'notes': notesController.text.trim(),
        'isPublic': isPublic.toString(),
      };

      final response;

      if (isEditMode) {
        final photoBytes = selectedPhoto != null
            ? await selectedPhoto!.readAsBytes()
            : null;

        response = await ApiService.putMultipart(
          '/entries/${widget.entry!['id']}',
          fields: fields,
          photoBytes: photoBytes,
          fileName: selectedPhoto?.name,
          mimeType: selectedPhoto?.mimeType,
        );
      } else {
        final photoBytes = await selectedPhoto!.readAsBytes();

        response = await ApiService.postMultipart(
          '/entries',
          fields: fields,
          photoBytes: photoBytes,
          fileName: selectedPhoto!.name,
          mimeType: selectedPhoto!.mimeType,
        );
      }

      if (!mounted) return;

      if (isEditMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Entry updated successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );

        Navigator.pop(context, true);
      } else {
        widget.onEntryCreated?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Entry created successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );

        _formKey.currentState!.reset();

        menuNameController.clear();
        placeNameController.clear();
        priceController.clear();
        notesController.clear();

        setState(() {
          selectedPhoto = null;
          selectedCategory = 'Food';
          selectedDate = DateTime.now();
          selectedRating = 5;
          isPublic = false;
        });
      }
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
          isLoading = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      filled: true,
      fillColor: AppColors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _sectionTitle(String title, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (required)
            const Text(' *', style: TextStyle(color: Colors.redAccent)),
        ],
      ),
    );
  }

  Widget _buildPhotoPreview() {
    if (selectedPhoto != null) {
      return FutureBuilder(
        future: selectedPhoto!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    if (existingPhotoUrl.isNotEmpty) {
      return Image.network(
        existingPhotoUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return _photoPlaceholder();
        },
      );
    }

    return _photoPlaceholder();
  }

  Widget _photoPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 42,
          color: AppColors.primary,
        ),
        SizedBox(height: 12),
        Text(
          'Add your food photo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Tap to choose from gallery',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final categories = ['Food', 'Drink'];

    return Row(
      children: categories.map((category) {
        final isSelected = selectedCategory == category;

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: category == 'Food' ? 8 : 0,
                left: category == 'Drink' ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primarySoft : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category == 'Food'
                        ? Icons.restaurant_rounded
                        : Icons.local_cafe_rounded,
                    size: 19,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRatingSelector() {
    return Row(
      children: List.generate(5, (index) {
        final rating = index + 1;
        final isSelected = rating <= selectedRating;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedRating = rating;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
              color: const Color(0xFFD6A928),
              size: 34,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVisibilitySelector() {
    return Column(
      children: [
        _visibilityOption(
          title: 'Public',
          description: 'Everyone can see this entry.',
          icon: Icons.public_rounded,
          value: true,
        ),
        const SizedBox(height: 10),
        _visibilityOption(
          title: 'Private',
          description: 'Only you can see this entry.',
          icon: Icons.lock_outline_rounded,
          value: false,
        ),
      ],
    );
  }

  Widget _visibilityOption({
    required String title,
    required String description,
    required IconData icon,
    required bool value,
  }) {
    final isSelected = isPublic == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          isPublic = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySoft : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 21,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 130),
          children: [
            Text(
              isEditMode ? 'Edit Entry' : 'Add Entry',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              isEditMode
                  ? 'Update your culinary experience.'
                  : 'Capture a new culinary experience.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('Food Photo', required: !isEditMode),
                  GestureDetector(
                    onTap: isLoading ? null : pickPhoto,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildPhotoPreview(),
                          if (selectedPhoto != null ||
                              existingPhotoUrl.isNotEmpty)
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.all(9),
                                decoration: const BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Menu Name', required: true),
                  TextFormField(
                    controller: menuNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration('e.g. Hawaiian Pizza'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Menu name is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Place Name'),
                  TextFormField(
                    controller: placeNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration('Where did you try it?'),
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Category', required: true),
                  _buildCategorySelector(),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Price', required: true),
                            TextFormField(
                              controller: priceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: _inputDecoration('e.g. 25000'),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Price is required';
                                }

                                final price = double.tryParse(value.trim());

                                if (price == null || price < 0) {
                                  return 'Invalid price';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle('Date Tried', required: true),
                            GestureDetector(
                              onTap: isLoading ? null : selectDate,
                              child: Container(
                                height: 56,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 17,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        formatDate(selectedDate),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionTitle('Your Rating', required: true),
                  _buildRatingSelector(),
                  const SizedBox(height: 20),
                  _sectionTitle('Notes'),
                  TextFormField(
                    controller: notesController,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _inputDecoration(
                      'Write about your experience...',
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Visibility'),
                  _buildVisibilitySelector(),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : submitEntry,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : Text(
                              isEditMode ? 'Save Changes' : 'Save Entry',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
}
