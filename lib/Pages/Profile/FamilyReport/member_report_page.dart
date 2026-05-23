import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:home_care/Api/Config/api_config.dart';
import 'package:home_care/Controller/family_report_controller.dart';
import 'package:home_care/Model/family_member_model.dart';
import 'package:home_care/Model/medical_record_model.dart';

class MemberReportPage extends StatefulWidget {
  final FamilyMemberModel member;
  const MemberReportPage({super.key, required this.member});

  @override
  State<MemberReportPage> createState() => _MemberReportPageState();
}

class _MemberReportPageState extends State<MemberReportPage> {
  late final FamilyReportController _ctrl;

  static const _purple = Color(0xFF8E54E9);

  @override
  void initState() {
    super.initState();
    _ctrl = Get.isRegistered<FamilyReportController>()
        ? Get.find<FamilyReportController>()
        : Get.put(FamilyReportController());
    _ctrl.loadMemberRecords(widget.member.familyMemberId);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    final initials =
        m.name.trim().isNotEmpty ? m.name[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _purple,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(m.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8E54E9), Color(0xFFF05A22)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(children: [
                  Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  Colors.white.withValues(alpha: 0.08)))),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 38,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.25),
                            backgroundImage: m.profileImage.isNotEmpty
                                ? NetworkImage(m.profileImage)
                                : null,
                            child: m.profileImage.isEmpty
                                ? Text(initials,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold))
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(m.name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _badge(m.relation),
                              if (m.bloodGroup.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                _badge(m.bloodGroup,
                                    color:
                                        Colors.red.withValues(alpha: 0.7)),
                              ],
                              if (m.gender.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                _badge(m.gender),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),

          // ── Reports section header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    final count = (_ctrl.memberRecords[
                                widget.member.familyMemberId] ??
                            [])
                        .length;
                    return Text(
                      '$count Report${count == 1 ? '' : 's'}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1F36)),
                    );
                  }),
                  Obx(() => _ctrl.isUploading.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _purple))
                      : GestureDetector(
                          onTap: () => _showUploadSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: _purple,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.upload_file,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text('Upload',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            ),
          ),

          // ── Reports list ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Obx(() {
              if (_ctrl.isLoadingMemberRecords.value) {
                return Column(
                  children: List.generate(3, (_) => const _RecordSkeleton()),
                );
              }

              final records =
                  _ctrl.memberRecords[widget.member.familyMemberId] ?? [];

              if (records.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      Icon(Icons.folder_open,
                          size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No reports uploaded yet\nfor ${widget.member.name}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.grey.shade500, height: 1.6),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _showUploadSheet(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: const Text('Upload First Report'),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  children: records
                      .map((r) => _RecordCard(
                            record: r,
                            memberId: widget.member.familyMemberId,
                            ctrl: _ctrl,
                          ))
                      .toList(),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, {Color? color}) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500)),
    );
  }

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UploadSheet(
          ctrl: _ctrl, memberId: widget.member.familyMemberId),
    );
  }
}

// ── Record card ────────────────────────────────────────────────────────────────

class _RecordCard extends StatefulWidget {
  final MedicalRecord record;
  final String memberId;
  final FamilyReportController ctrl;
  const _RecordCard(
      {required this.record,
      required this.memberId,
      required this.ctrl});

  @override
  State<_RecordCard> createState() => _RecordCardState();
}

class _RecordCardState extends State<_RecordCard> {
  bool _isDownloading = false;

  static const _typeColors = {
    'LAB_REPORT': Color(0xFF1A56DB),
    'PRESCRIPTION': Color(0xFF10B981),
    'XRAY': Color(0xFFF59E0B),
    'ECG': Color(0xFFEF4444),
    'OTHER': Color(0xFF6B7280),
  };
  static const _typeIcons = {
    'LAB_REPORT': Icons.biotech,
    'PRESCRIPTION': Icons.medication,
    'XRAY': Icons.healing,
    'ECG': Icons.monitor_heart,
    'OTHER': Icons.description,
  };

  String get _fullUrl {
    final url = widget.record.fileUrl;
    if (url.isEmpty) return '';
    return url.startsWith('http')
        ? url
        : '${ApiConfig.baseUrl.replaceAll('/api', '')}$url';
  }

  Future<void> _view() async {
    if (_fullUrl.isEmpty) return;
    final uri = Uri.parse(_fullUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _share() async {
    if (_fullUrl.isEmpty) return;
    await Share.share('${widget.record.title}\n$_fullUrl', subject: widget.record.title);
  }

  Future<void> _download() async {
    if (_fullUrl.isEmpty) return;
    setState(() => _isDownloading = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final ext = _fullUrl.contains('.') ? _fullUrl.split('.').last : 'pdf';
      final fileName =
          '${widget.record.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final savePath = '${dir.path}/$fileName';

      await Dio().download(_fullUrl, savePath);

      if (mounted) {
        Get.snackbar(
          'Downloaded',
          'Saved as $fileName',
          backgroundColor: Colors.green.shade50,
          colorText: Colors.green.shade700,
          snackPosition: SnackPosition.BOTTOM,
          icon: const Icon(Icons.check_circle, color: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar('Download failed', e.toString(),
            snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Report'),
        content: Text('Delete "${widget.record.title}"?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Get.back();
              widget.ctrl.deleteMemberRecord(
                  widget.record.recordId, widget.memberId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.record;
    final color = _typeColors[r.recordType] ?? const Color(0xFF6B7280);
    final icon = _typeIcons[r.recordType] ?? Icons.description;
    final hasFile = _fullUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // ── Info row ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1A1F36))),
                      const SizedBox(height: 3),
                      Row(children: [
                        Icon(Icons.calendar_today,
                            size: 11, color: Colors.grey.shade400),
                        const SizedBox(width: 4),
                        Text(r.recordDate,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            r.recordType.replaceAll('_', ' '),
                            style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                // Delete
                IconButton(
                  onPressed: _confirmDelete,
                  icon: Icon(Icons.delete_outline,
                      color: Colors.red.shade300, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Doctor / hospital row
          if (r.doctorName.isNotEmpty || r.hospitalName.isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Row(children: [
                if (r.doctorName.isNotEmpty) ...[
                  Icon(Icons.person_outline,
                      size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(r.doctorName,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(width: 12),
                ],
                if (r.hospitalName.isNotEmpty) ...[
                  Icon(Icons.local_hospital_outlined,
                      size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(r.hospitalName,
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis)),
                ],
              ]),
            ),

          // ── Action bar ──────────────────────────────────────────────────
          if (hasFile)
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  _ActionBtn(
                    icon: Icons.visibility_outlined,
                    label: 'View',
                    color: color,
                    onTap: _view,
                  ),
                  _vDivider(),
                  _ActionBtn(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    color: const Color(0xFF10B981),
                    onTap: _share,
                  ),
                  _vDivider(),
                  _ActionBtn(
                    icon: _isDownloading
                        ? Icons.hourglass_bottom
                        : Icons.download_outlined,
                    label: _isDownloading ? 'Saving…' : 'Download',
                    color: const Color(0xFF1A56DB),
                    onTap: _isDownloading ? null : _download,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _vDivider() =>
      Container(width: 1, height: 36, color: Colors.grey.shade200);
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 3),
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Upload bottom sheet ────────────────────────────────────────────────────────

class _UploadSheet extends StatefulWidget {
  final FamilyReportController ctrl;
  final String memberId;
  const _UploadSheet({required this.ctrl, required this.memberId});

  @override
  State<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends State<_UploadSheet> {
  final _titleCtrl    = TextEditingController();
  final _doctorCtrl   = TextEditingController();
  final _hospitalCtrl = TextEditingController();
  final _dateCtrl     = TextEditingController();

  String _recordType = 'LAB_REPORT';
  File? _pickedFile;
  bool _submitting = false;

  static const _purple = Color(0xFF8E54E9);
  static const _types = ['LAB_REPORT', 'PRESCRIPTION', 'XRAY', 'ECG', 'OTHER'];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _doctorCtrl.dispose();
    _hospitalCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _pickedFile = File(picked.path));
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (d != null) {
      _dateCtrl.text =
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Required', 'Please enter a title',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_dateCtrl.text.trim().isEmpty) {
      Get.snackbar('Required', 'Please select a date',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_pickedFile == null) {
      Get.snackbar('Required', 'Please select a file',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    setState(() => _submitting = true);
    Navigator.pop(context);

    final ok = await widget.ctrl.uploadReportForMember(
      familyMemberId: widget.memberId,
      filePath: _pickedFile!.path,
      title: _titleCtrl.text.trim(),
      recordType: _recordType,
      recordDate: _dateCtrl.text.trim(),
      doctorName: _doctorCtrl.text.trim(),
      hospitalName: _hospitalCtrl.text.trim(),
    );

    Get.snackbar(
      ok ? 'Uploaded' : 'Failed',
      ok ? 'Report uploaded successfully' : widget.ctrl.errorMessage.value,
      backgroundColor:
          ok ? Colors.green.shade50 : Colors.red.shade50,
      colorText:
          ok ? Colors.green.shade700 : Colors.red.shade700,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Upload Report',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),

            // Type chips
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _types.map((t) {
                  final sel = _recordType == t;
                  return GestureDetector(
                    onTap: () => setState(() => _recordType = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? _purple : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(t.replaceAll('_', ' '),
                          style: TextStyle(
                              color: sel
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: sel
                                  ? FontWeight.w600
                                  : FontWeight.normal)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            _Field('Title *', _titleCtrl),
            const SizedBox(height: 12),
            // Date picker field
            TextField(
              controller: _dateCtrl,
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                hintText: 'Record Date *',
                hintStyle: TextStyle(
                    color: Colors.grey.shade400, fontSize: 13),
                suffixIcon:
                    const Icon(Icons.calendar_today, size: 18),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: _purple, width: 1.5)),
              ),
            ),
            const SizedBox(height: 12),
            _Field('Doctor Name (optional)', _doctorCtrl),
            const SizedBox(height: 12),
            _Field('Hospital Name (optional)', _hospitalCtrl),
            const SizedBox(height: 16),

            // File picker
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: _purple.withValues(alpha: 0.4),
                      width: 1.5),
                  borderRadius: BorderRadius.circular(14),
                  color: _purple.withValues(alpha: 0.04),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        _pickedFile != null
                            ? Icons.check_circle
                            : Icons.upload_file,
                        color: _purple),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _pickedFile != null
                            ? _pickedFile!.path
                                .split(Platform.pathSeparator)
                                .last
                            : 'Select image or PDF',
                        style: TextStyle(
                            color: _pickedFile != null
                                ? _purple
                                : Colors.grey.shade600,
                            fontSize: 13),
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
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Upload Report',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String hint;
  final TextEditingController ctrl;
  const _Field(this.hint, this.ctrl);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: Colors.grey.shade400, fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF8E54E9), width: 1.5)),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _RecordSkeleton extends StatelessWidget {
  const _RecordSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
              margin: const EdgeInsets.all(14),
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12))),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 12,
                    width: 140,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(
                    height: 10,
                    width: 90,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
