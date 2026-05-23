import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:home_care/Controller/family_report_controller.dart';
import 'package:home_care/Controller/profile_controller.dart';
import 'package:home_care/Model/family_member_model.dart';
import 'package:home_care/Model/medical_record_model.dart';
import 'package:home_care/Api/Config/api_config.dart';
import 'package:home_care/Pages/Profile/FamilyReport/member_report_page.dart';

class FamilyReportsPage extends StatefulWidget {
  const FamilyReportsPage({super.key});

  @override
  State<FamilyReportsPage> createState() => _FamilyReportsPageState();
}

class _FamilyReportsPageState extends State<FamilyReportsPage> {
  late final FamilyReportController ctrl;
  late final ProfileController profileCtrl;

  static const _purple = Color(0xFF8E54E9);
  static const _orange = Color(0xFFF05A22);

  @override
  void initState() {
    super.initState();
    ctrl = Get.isRegistered<FamilyReportController>()
        ? Get.find<FamilyReportController>()
        : Get.put(FamilyReportController());
    profileCtrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _purple,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_purple, _orange],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Header(ctrl: ctrl, profileCtrl: profileCtrl),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Obx(() {
                    final loading = ctrl.isLoadingMembers.value || ctrl.isLoadingRecords.value;
                    if (loading) {
                      return const Center(child: CircularProgressIndicator(color: _purple));
                    }
                    return RefreshIndicator(
                      color: _purple,
                      onRefresh: () async => ctrl.loadAll(),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _StatsRow(ctrl: ctrl),
                            const SizedBox(height: 32),
                            _SectionHeader(icon: Icons.groups_outlined, title: 'FAMILY MEMBERS'),
                            const SizedBox(height: 16),
                            ...ctrl.familyMembers.map((m) => _MemberCard(member: m)),
                            _AddMemberButton(ctrl: ctrl),
                            const SizedBox(height: 32),
                            _SectionHeader(icon: Icons.description_outlined, title: 'MY REPORTS'),
                            const SizedBox(height: 16),
                            ...ctrl.medicalRecords.map((r) => _RecordCard(record: r, ctrl: ctrl)),
                            if (ctrl.medicalRecords.isEmpty)
                              const _EmptyState(message: 'No reports yet. Upload your first report.'),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(() => FloatingActionButton.extended(
        backgroundColor: _purple,
        onPressed: ctrl.isUploading.value ? null : () => _showUploadDialog(context, ctrl),
        icon: ctrl.isUploading.value
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Icon(Icons.upload_file, color: Colors.white),
        label: Text(ctrl.isUploading.value ? 'Uploading…' : 'Upload Report',
            style: const TextStyle(color: Colors.white)),
      )),
    );
  }

  static void _showUploadDialog(BuildContext context, FamilyReportController ctrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UploadSheet(ctrl: ctrl),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final FamilyReportController ctrl;
  final ProfileController profileCtrl;
  const _Header({required this.ctrl, required this.profileCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final u = profileCtrl.user.value;
      final imageUrl = u?.profileImage ?? '';
      final fullUrl = imageUrl.isNotEmpty
          ? (imageUrl.startsWith('http') ? imageUrl : '${ApiConfig.baseUrl.replaceAll('/api', '')}$imageUrl')
          : '';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                const Text('Family Reports',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: ctrl.loadAll,
                ),
              ],
            ),
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white24,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: fullUrl.isNotEmpty ? NetworkImage(fullUrl) : null,
                child: fullUrl.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              u?.name ?? 'User',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text('Head of Household',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
              child: Text(
                'USER ID: ${(u?.userId ?? '').isNotEmpty ? u!.userId.substring(0, 8).toUpperCase() : "—"}',
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    });
  }
}

// ── Stats ─────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final FamilyReportController ctrl;
  const _StatsRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      children: [
        Expanded(child: _StatCard(
          value: '${ctrl.memberCount}',
          label: 'MEMBERS',
          bg: const Color(0xFFF3EFFF),
          textColor: const Color(0xFF7B61FF),
        )),
        const SizedBox(width: 16),
        Expanded(child: _StatCard(
          value: '${ctrl.recordCount}',
          label: 'REPORTS',
          bg: const Color(0xFFFFF7ED),
          textColor: const Color(0xFFF59E0B),
        )),
      ],
    ));
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color textColor;
  const _StatCard({required this.value, required this.label, required this.bg, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: textColor.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF7B61FF)),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(color: Color(0xFF7B61FF), fontWeight: FontWeight.bold, letterSpacing: 1.1)),
      ],
    );
  }
}

// ── Family member card ────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  final FamilyMemberModel member;
  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final initials = member.name.isNotEmpty ? member.name[0].toUpperCase() : '?';
    final sub = '${member.relation}${member.dateOfBirth.isNotEmpty ? ' • ${member.dateOfBirth}' : ''}';

    return GestureDetector(
      onTap: () => Get.to(() => MemberReportPage(member: member)),
      child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFF3EFFF),
            backgroundImage: member.profileImage.isNotEmpty ? NetworkImage(member.profileImage) : null,
            child: member.profileImage.isEmpty
                ? Text(initials, style: const TextStyle(color: Color(0xFF7B61FF), fontWeight: FontWeight.bold))
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(sub, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
          ),
          if (member.bloodGroup.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(member.bloodGroup,
                  style: TextStyle(color: Colors.red.shade600, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
        ],
      ),
    ));
  }
}

// ── Add member button ─────────────────────────────────────────────────────────

class _AddMemberButton extends StatelessWidget {
  final FamilyReportController ctrl;
  const _AddMemberButton({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddMemberDialog(context),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD1C4E9), width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Color(0xFF8E54E9)),
            SizedBox(width: 8),
            Text('Add Family Member',
                style: TextStyle(color: Color(0xFF8E54E9), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final relationCtrl = TextEditingController();
    final dobCtrl = TextEditingController();
    final bloodCtrl = TextEditingController();
    String gender = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Family Member', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _DialogField('Name *', nameCtrl),
                const SizedBox(height: 12),
                _DialogField('Relation (e.g. Spouse, Son)', relationCtrl),
                const SizedBox(height: 12),
                _DialogField('Date of Birth (YYYY-MM-DD)', dobCtrl),
                const SizedBox(height: 12),
                _DialogField('Blood Group', bloodCtrl),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['MALE', 'FEMALE', 'OTHER'].map((g) {
                    final sel = gender == g;
                    return GestureDetector(
                      onTap: () => setS(() => gender = g),
                      child: Chip(
                        label: Text(g, style: TextStyle(color: sel ? Colors.white : Colors.grey.shade700, fontSize: 12)),
                        backgroundColor: sel ? const Color(0xFF8E54E9) : Colors.grey.shade100,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8E54E9)),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty || relationCtrl.text.trim().isEmpty) {
                  Get.snackbar('Error', 'Name and relation are required', snackPosition: SnackPosition.BOTTOM);
                  return;
                }
                Navigator.pop(ctx);
                final ok = await ctrl.addFamilyMember(
                  name: nameCtrl.text.trim(),
                  relation: relationCtrl.text.trim(),
                  gender: gender,
                  dateOfBirth: dobCtrl.text.trim(),
                  bloodGroup: bloodCtrl.text.trim(),
                );
                if (ok) {
                  Get.snackbar('Success', 'Family member added',
                      backgroundColor: Colors.green.shade50, colorText: Colors.green.shade700,
                      snackPosition: SnackPosition.BOTTOM);
                }
              },
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Record card ───────────────────────────────────────────────────────────────

class _RecordCard extends StatelessWidget {
  final MedicalRecord record;
  final FamilyReportController ctrl;
  const _RecordCard({required this.record, required this.ctrl});

  static const _typeColors = {
    'LAB_REPORT': Colors.blue,
    'PRESCRIPTION': Colors.green,
    'XRAY': Colors.orange,
    'ECG': Colors.red,
    'OTHER': Colors.grey,
  };

  static const _typeIcons = {
    'LAB_REPORT': Icons.biotech,
    'PRESCRIPTION': Icons.medication,
    'XRAY': Icons.healing,
    'ECG': Icons.monitor_heart,
    'OTHER': Icons.description,
  };

  @override
  Widget build(BuildContext context) {
    final color = _typeColors[record.recordType] ?? Colors.grey;
    final icon = _typeIcons[record.recordType] ?? Icons.description;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(record.recordDate,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(record.recordType.replaceAll('_', ' '),
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          if (record.doctorName.isNotEmpty || record.hospitalName.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                if (record.doctorName.isNotEmpty) ...[
                  Icon(Icons.person_outline, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(record.doctorName, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(width: 12),
                ],
                if (record.hospitalName.isNotEmpty) ...[
                  Icon(Icons.local_hospital_outlined, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Expanded(child: Text(record.hospitalName,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      overflow: TextOverflow.ellipsis)),
                ],
              ],
            ),
          ],
          if (record.fileUrl.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => _openFile(record.fileUrl),
                  child: Row(
                    children: [
                      Icon(Icons.attach_file, size: 16, color: color),
                      const SizedBox(width: 4),
                      Text('View File', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _confirmDelete(context),
                  child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade300),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => _confirmDelete(context),
                child: Icon(Icons.delete_outline, size: 18, color: Colors.red.shade300),
              ),
            ),
          ],
        ],
      ),
    ));
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(record.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _DetailRow(Icons.calendar_today, 'Date', record.recordDate),
            _DetailRow(Icons.category_outlined, 'Type', record.recordType.replaceAll('_', ' ')),
            if (record.doctorName.isNotEmpty)
              _DetailRow(Icons.person_outline, 'Doctor', record.doctorName),
            if (record.hospitalName.isNotEmpty)
              _DetailRow(Icons.local_hospital_outlined, 'Hospital', record.hospitalName),
            if (record.fileUrl.isNotEmpty)
              _DetailRow(Icons.attach_file, 'File', record.fileUrl.split('/').last),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _openFile(String url) {
    final fullUrl = url.startsWith('http') ? url : '${ApiConfig.baseUrl.replaceAll('/api', '')}$url';
    Get.snackbar('File', fullUrl, snackPosition: SnackPosition.BOTTOM);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Record'),
        content: Text('Delete "${record.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ctrl.deleteRecord(record.recordId);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── Upload bottom sheet ───────────────────────────────────────────────────────

class _UploadSheet extends StatefulWidget {
  final FamilyReportController ctrl;
  const _UploadSheet({required this.ctrl});

  @override
  State<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends State<_UploadSheet> {
  final _titleCtrl = TextEditingController();
  final _doctorCtrl = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  String _recordType = 'LAB_REPORT';
  File? _pickedFile;

  static const _types = ['LAB_REPORT', 'PRESCRIPTION', 'XRAY', 'ECG', 'OTHER'];
  static const _purple = Color(0xFF8E54E9);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _doctorCtrl.dispose();
    _hospitalCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _pickedFile = File(picked.path));
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Title is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_dateCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Record date is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_pickedFile == null) {
      Get.snackbar('Error', 'Please select a file', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    Navigator.pop(context);

    final ok = await widget.ctrl.uploadReport(
      filePath: _pickedFile!.path,
      title: _titleCtrl.text.trim(),
      recordType: _recordType,
      recordDate: _dateCtrl.text.trim(),
      doctorName: _doctorCtrl.text.trim(),
      hospitalName: _hospitalCtrl.text.trim(),
    );

    if (ok) {
      Get.snackbar('Success', 'Report uploaded successfully',
          backgroundColor: Colors.green.shade50, colorText: Colors.green.shade700,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error', widget.ctrl.errorMessage.value.isNotEmpty
          ? widget.ctrl.errorMessage.value : 'Upload failed',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Upload Report',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),

            // Report type chips
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _types.map((t) {
                  final sel = _recordType == t;
                  return GestureDetector(
                    onTap: () => setState(() => _recordType = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? _purple : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(t.replaceAll('_', ' '),
                          style: TextStyle(
                            color: sel ? Colors.white : Colors.grey.shade700,
                            fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 12,
                          )),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            _DialogField('Title *', _titleCtrl),
            const SizedBox(height: 12),
            _DialogField('Record Date (YYYY-MM-DD) *', _dateCtrl),
            const SizedBox(height: 12),
            _DialogField('Doctor Name', _doctorCtrl),
            const SizedBox(height: 12),
            _DialogField('Hospital Name', _hospitalCtrl),
            const SizedBox(height: 16),

            // File picker
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: _purple.withValues(alpha: 0.4), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                  color: _purple.withValues(alpha: 0.04),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_pickedFile != null ? Icons.check_circle : Icons.upload_file,
                        color: _purple),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _pickedFile != null
                            ? _pickedFile!.path.split(Platform.pathSeparator).last
                            : 'Tap to select image / PDF',
                        style: TextStyle(
                          color: _pickedFile != null ? _purple : Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _submit,
                child: const Text('Upload Report',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _DialogField extends StatelessWidget {
  final String hint;
  final TextEditingController ctrl;
  const _DialogField(this.hint, this.ctrl);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF8E54E9), width: 1.5),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 15, color: const Color(0xFF8E54E9)),
        const SizedBox(width: 10),
        SizedBox(width: 72, child: Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500))),
        Expanded(child: Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.folder_open, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
