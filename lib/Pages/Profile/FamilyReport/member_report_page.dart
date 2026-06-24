import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:home_care/Api/Config/api_config.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Controller/family_report_controller.dart';
import 'package:home_care/Model/family_member_model.dart';
import 'package:home_care/Model/medical_record_model.dart';

// ── Type → theme color map (all from colors_coning.dart) ─────────────────────
const _typeColors = {
  'LAB_REPORT':   kPrimary,
  'PRESCRIPTION': kSuccess,
  'XRAY':         kWarning,
  'ECG':          kError,
  'OTHER':        kTeal,
};
const _typeIcons = {
  'LAB_REPORT':   Icons.biotech_rounded,
  'PRESCRIPTION': Icons.medication_rounded,
  'XRAY':         Icons.healing_rounded,
  'ECG':          Icons.monitor_heart_rounded,
  'OTHER':        Icons.description_rounded,
};
Color _colorFor(String t) => _typeColors[t] ?? kTextMedium;
IconData _iconFor(String t) => _typeIcons[t] ?? Icons.description_rounded;

class MemberReportPage extends StatefulWidget {
  final FamilyMemberModel member;
  const MemberReportPage({super.key, required this.member});

  @override
  State<MemberReportPage> createState() => _MemberReportPageState();
}

class _MemberReportPageState extends State<MemberReportPage> {
  late final FamilyReportController _ctrl;

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
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            backgroundColor: kPrimary,
            foregroundColor: kSurface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: kSurface, size: 20),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(m.name,
                  style: const TextStyle(
                      color: kSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
              background: Container(
                decoration: const BoxDecoration(gradient: kPrimaryGradient),
                child: Stack(children: [
                  Positioned(
                    right: -30, top: -30,
                    child: Container(
                      width: 150, height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kPrimaryLight.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Avatar
                          Container(
                            width: 76, height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: kSurface, width: 2.5),
                              gradient: m.profileImage.isEmpty
                                  ? kPrimaryGradientV
                                  : null,
                              image: m.profileImage.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(m.profileImage),
                                      fit: BoxFit.cover)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                    color: kPrimaryDark.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))
                              ],
                            ),
                            child: m.profileImage.isEmpty
                                ? Center(
                                    child: Text(initials,
                                        style: const TextStyle(
                                            color: kSurface,
                                            fontSize: 26,
                                            fontWeight: FontWeight.bold)))
                                : null,
                          ),
                          const SizedBox(height: 10),
                          Text(m.name,
                              style: const TextStyle(
                                  color: kSurface,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _Chip(m.relation),
                              if (m.bloodGroup.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                _Chip(m.bloodGroup,
                                    bg: kError.withValues(alpha: 0.6)),
                              ],
                              if (m.gender.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                _Chip(m.gender),
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    final count =
                        (_ctrl.memberRecords[widget.member.familyMemberId] ??
                                [])
                            .length;
                    return Row(children: [
                      Container(
                        width: 4, height: 18,
                        decoration: BoxDecoration(
                            gradient: kPrimaryGradientV,
                            borderRadius: BorderRadius.circular(2)),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$count Report${count == 1 ? '' : 's'}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kTextDark),
                      ),
                    ]);
                  }),
                  Obx(() => _ctrl.isUploading.value
                      ? const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: kPrimary))
                      : GestureDetector(
                          onTap: () => _showUploadSheet(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: kPrimaryGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: kPrimary.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2))
                              ],
                            ),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(Icons.upload_file_rounded,
                                  color: kSurface, size: 16),
                              SizedBox(width: 6),
                              Text('Upload',
                                  style: TextStyle(
                                      color: kSurface,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ]),
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
                  children:
                      List.generate(3, (_) => const _RecordSkeleton()),
                );
              }

              final records =
                  _ctrl.memberRecords[widget.member.familyMemberId] ?? [];

              if (records.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                        color: kSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kBorder)),
                    child: Column(children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                            color: kPrimary.withValues(alpha: 0.06),
                            shape: BoxShape.circle),
                        child: Icon(Icons.folder_open_rounded,
                            size: 44,
                            color: kPrimary.withValues(alpha: 0.4)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No reports for ${widget.member.name}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: kTextDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      const Text('Upload the first report using the button above.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: kTextMedium, fontSize: 13)),
                    ]),
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

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _UploadSheet(ctrl: _ctrl, memberId: widget.member.familyMemberId),
    );
  }
}

// ── Small chip used in header ─────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final Color? bg;
  const _Chip(this.label, {this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg ?? kSurface.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: const TextStyle(
              color: kSurface, fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }
}

// ── Record card ───────────────────────────────────────────────────────────────

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
    await Share.share('${widget.record.title}\n$_fullUrl',
        subject: widget.record.title);
  }

  Future<void> _download() async {
    if (_fullUrl.isEmpty) return;
    setState(() => _isDownloading = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final ext =
          _fullUrl.contains('.') ? _fullUrl.split('.').last : 'pdf';
      final fileName =
          '${widget.record.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final savePath = '${dir.path}/$fileName';
      await Dio().download(_fullUrl, savePath);
      if (mounted) {
        Get.snackbar('Downloaded', 'Saved as $fileName',
            backgroundColor: kSuccess.withValues(alpha: 0.1),
            colorText: kSuccess,
            snackPosition: SnackPosition.BOTTOM,
            icon: const Icon(Icons.check_circle_rounded, color: kSuccess));
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
        title: const Text('Delete Report',
            style: TextStyle(color: kTextDark)),
        content: Text('Delete "${widget.record.title}"?',
            style: const TextStyle(color: kTextMedium)),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel',
                  style: TextStyle(color: kTextMedium))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: kError,
                foregroundColor: kSurface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Get.back();
              widget.ctrl
                  .deleteMemberRecord(widget.record.recordId, widget.memberId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r     = widget.record;
    final color = _colorFor(r.recordType);
    final icon  = _iconFor(r.recordType);
    final hasFile = _fullUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(children: [
        // Info row
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12)),
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
                            color: kTextDark)),
                    const SizedBox(height: 3),
                    Row(children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 11, color: kTextLight),
                      const SizedBox(width: 4),
                      Text(r.recordDate,
                          style: const TextStyle(
                              fontSize: 11, color: kTextMedium)),
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
                  ]),
            ),
            // Delete
            GestureDetector(
              onTap: _confirmDelete,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: kError.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.delete_outline_rounded,
                    size: 16, color: kError),
              ),
            ),
          ]),
        ),

        // Doctor / hospital
        if (r.doctorName.isNotEmpty || r.hospitalName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Row(children: [
              if (r.doctorName.isNotEmpty) ...[
                const Icon(Icons.person_outline_rounded,
                    size: 13, color: kTextLight),
                const SizedBox(width: 4),
                Text(r.doctorName,
                    style: const TextStyle(
                        fontSize: 11, color: kTextMedium)),
                const SizedBox(width: 12),
              ],
              if (r.hospitalName.isNotEmpty) ...[
                const Icon(Icons.local_hospital_outlined,
                    size: 13, color: kTextLight),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(r.hospitalName,
                        style: const TextStyle(
                            fontSize: 11, color: kTextMedium),
                        overflow: TextOverflow.ellipsis)),
              ],
            ]),
          ),

        // Action bar
        if (hasFile)
          Container(
            decoration: BoxDecoration(
              color: kBackground,
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16)),
            ),
            child: Row(children: [
              _ActionBtn(
                icon: Icons.visibility_outlined,
                label: 'View',
                color: color,
                onTap: _view,
              ),
              Container(width: 1, height: 36, color: kDivider),
              _ActionBtn(
                icon: Icons.share_outlined,
                label: 'Share',
                color: kSuccess,
                onTap: _share,
              ),
              Container(width: 1, height: 36, color: kDivider),
              _ActionBtn(
                icon: _isDownloading
                    ? Icons.hourglass_bottom
                    : Icons.download_outlined,
                label: _isDownloading ? 'Saving…' : 'Download',
                color: kPrimary,
                onTap: _isDownloading ? null : _download,
              ),
            ]),
          ),
      ]),
    );
  }
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
        splashColor: color.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(children: [
            Icon(icon, color: onTap != null ? color : kTextLight, size: 18),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: onTap != null ? color : kTextLight,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

// ── Upload sheet ──────────────────────────────────────────────────────────────

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
  File?  _pickedFile;
  bool   _submitting = false;

  static const _types = [
    'LAB_REPORT', 'PRESCRIPTION', 'XRAY', 'ECG', 'OTHER'
  ];

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
      backgroundColor: ok
          ? kSuccess.withValues(alpha: 0.1)
          : kError.withValues(alpha: 0.1),
      colorText: ok ? kSuccess : kError,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Handle
          Center(
            child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: kBorder,
                    borderRadius: BorderRadius.circular(2))),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Upload Report',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kTextDark)),
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: kTextLight)),
          ]),
          const SizedBox(height: 16),

          // Type chips
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _types.map((t) {
                final sel   = _recordType == t;
                final color = _colorFor(t);
                return GestureDetector(
                  onTap: () => setState(() => _recordType = t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? color : color.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? color : kBorder,
                          width: sel ? 1.5 : 1),
                    ),
                    child: Text(t.replaceAll('_', ' '),
                        style: TextStyle(
                            color: sel ? kSurface : color,
                            fontSize: 11,
                            fontWeight: sel
                                ? FontWeight.w600
                                : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          _MField('Title *', _titleCtrl),
          const SizedBox(height: 12),
          // Date picker field
          TextField(
            controller: _dateCtrl,
            readOnly: true,
            onTap: _pickDate,
            style: const TextStyle(fontSize: 14, color: kTextDark),
            decoration: InputDecoration(
              hintText: 'Record Date *',
              hintStyle: const TextStyle(color: kTextLight, fontSize: 13),
              suffixIcon: const Icon(Icons.calendar_today_rounded,
                  size: 18, color: kTextLight),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorder)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorder)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kPrimary, width: 1.5)),
            ),
          ),
          const SizedBox(height: 12),
          _MField('Doctor Name (optional)', _doctorCtrl),
          const SizedBox(height: 12),
          _MField('Hospital Name (optional)', _hospitalCtrl),
          const SizedBox(height: 16),

          // File picker
          GestureDetector(
            onTap: _pickFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                    color: kPrimary.withValues(alpha: 0.4), width: 1.5),
                borderRadius: BorderRadius.circular(14),
                color: kPrimary.withValues(alpha: 0.04),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        _pickedFile != null
                            ? Icons.check_circle_rounded
                            : Icons.upload_file_rounded,
                        color: kPrimary,
                        size: 20),
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
                                ? kPrimary
                                : kTextMedium,
                            fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: kSurface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0),
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: kSurface, strokeWidth: 2))
                  : const Text('Upload Report',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _MField extends StatelessWidget {
  final String hint;
  final TextEditingController ctrl;
  const _MField(this.hint, this.ctrl);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(fontSize: 14, color: kTextDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kTextLight, fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorder)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorder)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimary, width: 1.5)),
      ),
    );
  }
}

// ── Skeleton ──────────────────────────────────────────────────────────────────

class _RecordSkeleton extends StatefulWidget {
  const _RecordSkeleton();

  @override
  State<_RecordSkeleton> createState() => _RecordSkeletonState();
}

class _RecordSkeletonState extends State<_RecordSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _color = ColorTween(begin: kBorder, end: kDivider)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _color,
      builder: (_, __) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        height: 78,
        decoration: BoxDecoration(
            color: kSurface, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(
              margin: const EdgeInsets.all(14),
              width: 46, height: 46,
              decoration: BoxDecoration(
                  color: _color.value,
                  borderRadius: BorderRadius.circular(12))),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: 12, width: 140,
                    decoration: BoxDecoration(
                        color: _color.value,
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(
                    height: 10, width: 90,
                    decoration: BoxDecoration(
                        color: _color.value?.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4))),
              ]),
        ]),
      ),
    );
  }
}
