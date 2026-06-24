import 'package:home_care/Config/colors_coning.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:home_care/Controller/profile_controller.dart';
import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Api/Config/api_config.dart';

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  final ProfileController _ctrl = Get.find<ProfileController>();

  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _houseCtrl;
  late TextEditingController _streetCtrl;
  late TextEditingController _landmarkCtrl;
  late TextEditingController _pinCtrl;

  String _selectedGender = '';
  String _selectedBloodGroup = '';
  File? _pickedImage;

  static const _genders = ['MALE', 'FEMALE', 'OTHER'];
  static const _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

  @override
  void initState() {
    super.initState();
    _syncControllers();
    // Auto-enter edit mode for new users who have no name yet
    final u = _ctrl.user.value;
    if (u == null || u.name.trim().isEmpty) {
      _isEditing = true;
    }
  }

  void _syncControllers() {
    final u = _ctrl.user.value;
    _nameCtrl     = TextEditingController(text: u?.name ?? '');
    _emailCtrl    = TextEditingController(text: u?.email ?? '');
    _phoneCtrl    = TextEditingController(text: u?.phoneNumber ?? '');
    _houseCtrl    = TextEditingController(text: u?.address1?.houseNumber ?? '');
    _streetCtrl   = TextEditingController(text: u?.address1?.street ?? '');
    _landmarkCtrl = TextEditingController(text: u?.address1?.landmark ?? '');
    _pinCtrl      = TextEditingController(text: u?.address1?.pinCode ?? '');
    _selectedGender    = u?.gender ?? '';
    _selectedBloodGroup = u?.bloodGroup ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _houseCtrl.dispose();
    _streetCtrl.dispose();
    _landmarkCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: kBorder,
                      borderRadius: BorderRadius.circular(2))),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: kPrimary),
                title: const Text('Take a photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: kPrimary),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    final picked =
        await ImagePicker().pickImage(source: source, imageQuality: 75);
    if (picked != null) setState(() => _pickedImage = File(picked.path));
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Required', 'Please enter your name',
          backgroundColor: kError.withValues(alpha: 0.1),
          colorText: kError,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    setState(() => _isSaving = true);

    String uploadedImageUrl = '';
    if (_pickedImage != null) {
      try {
        final resp = await ApiClient().uploadFile(_pickedImage!.path);
        uploadedImageUrl =
            ((resp as Map<String, dynamic>)['data'] as Map?)?['url']
                    as String? ??
                '';
      } catch (e) {
        // image upload failed — continue saving other fields
      }
    }

    final ok = await _ctrl.updateProfile(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      gender: _selectedGender,
      bloodGroup: _selectedBloodGroup,
      profileImageUrl: uploadedImageUrl,
    );

    if (_houseCtrl.text.trim().isNotEmpty ||
        _streetCtrl.text.trim().isNotEmpty) {
      await _ctrl.updateAddress(
        addressType: 'address1',
        houseNumber: _houseCtrl.text.trim(),
        street: _streetCtrl.text.trim(),
        landmark: _landmarkCtrl.text.trim(),
        pinCode: _pinCtrl.text.trim(),
        latitude: '',
        longitude: '',
      );
    }

    setState(() => _isSaving = false);

    if (ok && mounted) {
      setState(() {
        _isEditing = false;
        _pickedImage = null;
      });
      Get.snackbar(
        'Success',
        'Profile saved successfully',
        backgroundColor: kSuccess.withValues(alpha: 0.1),
        colorText: kSuccess,
        snackPosition: SnackPosition.BOTTOM,
        icon: const Icon(Icons.check_circle, color: Colors.green),
      );
    }
  }

  void _startEditing() {
    _syncControllers();
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    _syncControllers();
    setState(() {
      _isEditing = false;
      _pickedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final u = _ctrl.user.value;
      final isNew = u == null || u.name.trim().isEmpty;

      return Scaffold(
        backgroundColor: kBackground,
        body: CustomScrollView(
          slivers: [
            // ── Header ───────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: kPrimary,
              foregroundColor: kSurface,
              leading: IconButton(
                icon: Icon(_isEditing
                    ? Icons.close
                    : Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () {
                  if (_isEditing && !isNew) {
                    _cancelEditing();
                  } else {
                    Get.back();
                  }
                },
              ),
              actions: [
                if (_isSaving)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: kSurface)),
                  )
                else
                  TextButton(
                    onPressed: _isEditing ? _save : _startEditing,
                    child: Text(
                      _isEditing ? 'Save' : 'Edit',
                      style: const TextStyle(
                          color: kSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kPrimary, kPrimaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                          right: -30,
                          top: -30,
                          child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Colors.white.withValues(alpha: 0.08)))),
                      Positioned(
                          left: -20,
                          bottom: -20,
                          child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Colors.white.withValues(alpha: 0.06)))),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 70, 0, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Avatar
                            Center(
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  _buildAvatar(u?.profileImage),
                                  if (_isEditing)
                                    GestureDetector(
                                      onTap: _pickImage,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: kSurface),
                                        child: const Icon(Icons.camera_alt,
                                            color: kPrimary, size: 18),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (!_isEditing) ...[
                              Text(
                                u?.name.isNotEmpty == true
                                    ? u!.name
                                    : 'New User',
                                style: const TextStyle(
                                    color: kSurface,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                u?.phoneNumber ?? '',
                                style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.85),
                                    fontSize: 12),
                              ),
                            ] else
                              Text(
                                isNew ? 'Create Your Profile' : 'Edit Profile',
                                style: TextStyle(
                                    color: kSurface.withValues(alpha: 0.9),
                                    fontSize: 13),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Form body ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Personal info
                    _SectionCard(
                      title: 'Personal Information',
                      icon: Icons.person_outline,
                      children: [
                        _field('Full Name', _nameCtrl,
                            hint: 'Enter your full name'),
                        _field('Email',    _emailCtrl,
                            hint: 'Enter your email',
                            type: TextInputType.emailAddress),
                        _field('Phone',    _phoneCtrl,
                            enabled: false),
                        _genderRow(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Health info
                    _SectionCard(
                      title: 'Health Information',
                      icon: Icons.favorite_border,
                      children: [
                        _bloodGroupPicker(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Address
                    _SectionCard(
                      title: 'Primary Address',
                      icon: Icons.location_on_outlined,
                      children: [
                        _field('House / Flat No.', _houseCtrl,
                            hint: 'e.g. 12A'),
                        _field('Street / Area',    _streetCtrl,
                            hint: 'e.g. MG Road'),
                        _field('Landmark',         _landmarkCtrl,
                            hint: 'e.g. Near City Mall'),
                        _field('PIN Code',         _pinCtrl,
                            hint: '6-digit PIN',
                            type: TextInputType.number),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Account read-only info
                    if (!_isEditing && u != null) ...[
                      _SectionCard(
                        title: 'Account Info',
                        icon: Icons.shield_outlined,
                        children: [
                          _infoRow(Icons.verified_user_outlined, 'Role',
                              u.role),
                          _infoRow(Icons.circle,                 'Status',
                              u.status,
                              valueColor: u.status == 'ACTIVE'
                                  ? Colors.green
                                  : Colors.orange),
                          _infoRow(Icons.card_membership_outlined,
                              'Service Plan', u.userService),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Save button (bottom)
                    if (_isEditing)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: kSurface, strokeWidth: 2))
                            : Text(
                                isNew ? 'Create Profile' : 'Save Changes',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: kSurface),
                              ),
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Avatar ──────────────────────────────────────────────────────────────────
  Widget _buildAvatar(String? imageUrl) {
    ImageProvider? img;
    if (_pickedImage != null) {
      img = FileImage(_pickedImage!);
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      final full = imageUrl.startsWith('http')
          ? imageUrl
          : '${ApiConfig.baseUrl.replaceAll('/api', '')}$imageUrl';
      img = NetworkImage(full);
    }
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kSurface, width: 3),
        color: kSurface.withValues(alpha: 0.25),
        image: img != null
            ? DecorationImage(image: img, fit: BoxFit.cover)
            : null,
      ),
      child: img == null
          ? const Icon(Icons.person, size: 44, color: kSurface)
          : null,
    );
  }

  // ── Field ───────────────────────────────────────────────────────────────────
  Widget _field(
    String label,
    TextEditingController ctrl, {
    bool enabled = true,
    String? hint,
    TextInputType type = TextInputType.text,
  }) {
    final active = _isEditing && enabled;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        enabled: active,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: kTextMedium, fontSize: 13),
          hintStyle: TextStyle(color: kTextLight, fontSize: 13),
          filled: true,
          fillColor: active ? Colors.white : Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kPrimary, width: 2)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: kBorder)),
        ),
        style: TextStyle(
            color: active ? Colors.black87 : kTextMedium,
            fontSize: 14),
      ),
    );
  }

  // ── Gender row ──────────────────────────────────────────────────────────────
  Widget _genderRow() {
    if (!_isEditing) {
      return _field('Gender',
          TextEditingController(text: _selectedGender.isEmpty ? '—' : _selectedGender),
          enabled: false);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gender',
              style:
                  TextStyle(color: kTextMedium, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: _genders.map((g) {
              final sel = _selectedGender == g;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = g),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: sel ? kPrimary : kSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: sel ? kPrimary : kBorder),
                    ),
                    child: Text(g,
                        style: TextStyle(
                            color: sel ? Colors.white : Colors.grey.shade700,
                            fontSize: 13,
                            fontWeight: sel
                                ? FontWeight.w600
                                : FontWeight.normal)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Blood group picker ──────────────────────────────────────────────────────
  Widget _bloodGroupPicker() {
    if (!_isEditing) {
      return _field('Blood Group',
          TextEditingController(
              text: _selectedBloodGroup.isEmpty ? '—' : _selectedBloodGroup),
          enabled: false);
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Blood Group',
              style:
                  TextStyle(color: kTextMedium, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _bloodGroups.map((bg) {
              final sel = _selectedBloodGroup == bg;
              return GestureDetector(
                onTap: () => setState(() => _selectedBloodGroup = bg),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? kPrimary : kSurface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: sel
                            ? kPrimary
                            : kBorder),
                  ),
                  child: Text(bg,
                      style: TextStyle(
                          color: sel ? Colors.white : Colors.grey.shade700,
                          fontSize: 13,
                          fontWeight: sel
                              ? FontWeight.bold
                              : FontWeight.normal)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Read-only info row ──────────────────────────────────────────────────────
  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: kTextMedium),
          const SizedBox(width: 10),
          Text(label,
              style:
                  TextStyle(color: kTextMedium, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }
}

// ── Section card wrapper ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard(
      {required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: kPrimary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: kPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
