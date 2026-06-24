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
import 'package:home_care/Model/medical_record_model.dart';

class RecordsPage extends StatelessWidget {
  const RecordsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.isRegistered<FamilyReportController>()
        ? Get.find<FamilyReportController>()
        : Get.put(FamilyReportController());
    return _RecordsView(ctrl: ctrl);
  }
}

class _RecordsView extends StatelessWidget {
  final FamilyReportController ctrl;
  const _RecordsView({required this.ctrl});

  // theme: kSuccess

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kSuccess, kPrimaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kSurface, size: 20),
        ),
        title: const Text('My Medical Records',
            style: TextStyle(color: kSurface, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: kSurface),
            onPressed: ctrl.loadMedicalRecords,
          ),
        ],
      ),
      floatingActionButton: Obx(() => FloatingActionButton.extended(
        backgroundColor: kSuccess,
        onPressed: ctrl.isUploading.value ? null : () => _showUploadSheet(context),
        icon: ctrl.isUploading.value
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: kSurface, strokeWidth: 2))
            : const Icon(Icons.upload_file, color: kSurface),
        label: Text(ctrl.isUploading.value ? 'Uploading…' : 'Upload Report',
            style: const TextStyle(color: kSurface)),
      )),
      body: Obx(() {
        if (ctrl.isLoadingRecords.value && ctrl.medicalRecords.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: kSuccess));
        }
        if (ctrl.medicalRecords.isEmpty) {
          return _EmptyState(onUpload: () => _showUploadSheet(context));
        }
        return RefreshIndicator(
          color: kSuccess,
          onRefresh: ctrl.loadMedicalRecords,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: ctrl.medicalRecords.length,
            itemBuilder: (_, i) => _RecordCard(record: ctrl.medicalRecords[i], ctrl: ctrl),
          ),
        );
      }),
    );
  }

  void _showUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UploadSheet(ctrl: ctrl),
    );
  }
}

// ── Record card ────────────────────────────────────────────────────────────────

class _RecordCard extends StatelessWidget {
  final MedicalRecord record;
  final FamilyReportController ctrl;
  const _RecordCard({required this.record, required this.ctrl});

  static const _typeColors = <String, Color>{
    'LAB_REPORT': kPrimary,
    'PRESCRIPTION': kSuccess,
    'XRAY': kWarning,
    'ECG': kError,
    'OTHER': kTextMedium,
  };

  static const _typeIcons = <String, IconData>{
    'LAB_REPORT': Icons.biotech,
    'PRESCRIPTION': Icons.medication_outlined,
    'XRAY': Icons.healing,
    'ECG': Icons.monitor_heart_outlined,
    'OTHER': Icons.description_outlined,
  };

  String get _fullUrl {
    if (record.fileUrl.isEmpty) return '';
    return record.fileUrl.startsWith('http')
        ? record.fileUrl
        : '${ApiConfig.baseUrl.replaceAll('/api', '')}${record.fileUrl}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _typeColors[record.recordType] ?? kTextMedium;
    final icon = _typeIcons[record.recordType] ?? Icons.description_outlined;
    final hasFile = record.fileUrl.isNotEmpty;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: kTextDark.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Info row ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(record.recordDate,
                            style: TextStyle(fontSize: 12, color: kTextMedium)),
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
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                  ),
                ],
              ),
            ),
            if (record.doctorName.isNotEmpty || record.hospitalName.isNotEmpty) ...[
              const Divider(height: 1, indent: 16, endIndent: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    if (record.doctorName.isNotEmpty) ...[
                      Icon(Icons.person_outline, size: 13, color: kTextLight),
                      const SizedBox(width: 4),
                      Text(record.doctorName,
                          style: TextStyle(fontSize: 12, color: kTextMedium)),
                      const SizedBox(width: 12),
                    ],
                    if (record.hospitalName.isNotEmpty) ...[
                      Icon(Icons.local_hospital_outlined, size: 13, color: kTextLight),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(record.hospitalName,
                            style: TextStyle(fontSize: 12, color: kTextMedium),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            // ── Action bar (always visible) ───────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
              ),
              child: Row(
                children: [
                  _ActionBtn(
                    icon: Icons.open_in_new,
                    label: 'View',
                    color: hasFile ? color : kTextLight,
                    onTap: hasFile ? () => _openFile() : null,
                  ),
                  _vDivider(),
                  _ActionBtn(
                    icon: Icons.download_outlined,
                    label: 'Download',
                    color: hasFile ? kPrimary : kTextLight,
                    onTap: hasFile ? () => _download() : null,
                  ),
                  _vDivider(),
                  _ActionBtn(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    color: hasFile ? kPurple : kTextLight,
                    onTap: hasFile ? () => _share() : null,
                  ),
                  _vDivider(),
                  _ActionBtn(
                    icon: Icons.delete_outline,
                    label: 'Delete',
                    color: kError,
                    onTap: () => _confirmDelete(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vDivider() => Container(width: 1, height: 36, color: kBorder);

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RecordDetailSheet(record: record),
    );
  }

  void _openFile() async {
    final url = _fullUrl;
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _download() async {
    try {
      final url = _fullUrl;
      if (url.isEmpty) return;
      final dir = await getApplicationDocumentsDirectory();
      final fileName = url.split('/').last;
      final savePath = '${dir.path}/$fileName';
      await Dio().download(url, savePath);
      Get.snackbar('Downloaded', 'Saved to documents', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: kSuccess.withValues(alpha: 0.1), colorText: kSuccess);
    } catch (e) {
      Get.snackbar('Error', 'Download failed', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _share() async {
    final url = _fullUrl;
    if (url.isEmpty) {
      await Share.share(record.title);
      return;
    }
    await Share.share('${record.title}\n$url', subject: record.title);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Record'),
        content: Text('Delete "${record.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kError, foregroundColor: kSurface),
            onPressed: () {
              Navigator.pop(context);
              ctrl.deleteRecord(record.recordId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

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
              Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Record detail sheet ────────────────────────────────────────────────────────

class _RecordDetailSheet extends StatelessWidget {
  final MedicalRecord record;
  const _RecordDetailSheet({required this.record});

  static const _typeColors = <String, Color>{
    'LAB_REPORT': kPrimary,
    'PRESCRIPTION': kSuccess,
    'XRAY': kWarning,
    'ECG': kError,
    'OTHER': kTextMedium,
  };

  @override
  Widget build(BuildContext context) {
    final color = _typeColors[record.recordType] ?? kTextMedium;

    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
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
              decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.description_outlined, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(record.title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 16),
          _Row(Icons.calendar_today, 'Date', record.recordDate),
          _Row(Icons.category_outlined, 'Type', record.recordType.replaceAll('_', ' ')),
          if (record.doctorName.isNotEmpty)
            _Row(Icons.person_outline, 'Doctor', record.doctorName),
          if (record.hospitalName.isNotEmpty)
            _Row(Icons.local_hospital_outlined, 'Hospital', record.hospitalName),
          if (record.description.isNotEmpty)
            _Row(Icons.notes_outlined, 'Notes', record.description),
          if (record.fileUrl.isEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Icon(Icons.info_outline, size: 16, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text('No file attached to this record',
                    style: TextStyle(fontSize: 13, color: Colors.orange.shade700)),
              ]),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 15, color: kSuccess),
        const SizedBox(width: 10),
        SizedBox(width: 72, child: Text(label,
            style: TextStyle(fontSize: 13, color: kTextMedium))),
        Expanded(child: Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

// ── Upload sheet ───────────────────────────────────────────────────────────────

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
  File? _file;

  static const _types = ['LAB_REPORT', 'PRESCRIPTION', 'XRAY', 'ECG', 'OTHER'];
  // theme: kSuccess

  @override
  void dispose() {
    _titleCtrl.dispose();
    _doctorCtrl.dispose();
    _hospitalCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _file = File(picked.path));
  }

  Future<void> _pickDate() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (dt != null) {
      _dateCtrl.text = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Title is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_dateCtrl.text.trim().isEmpty) {
      Get.snackbar('Error', 'Date is required', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_file == null) {
      Get.snackbar('Error', 'Please select a file', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Navigator.pop(context);
    final ok = await widget.ctrl.uploadReport(
      filePath: _file!.path,
      title: _titleCtrl.text.trim(),
      recordType: _recordType,
      recordDate: _dateCtrl.text.trim(),
      doctorName: _doctorCtrl.text.trim(),
      hospitalName: _hospitalCtrl.text.trim(),
    );
    if (ok) {
      Get.snackbar('Uploaded', 'Report saved successfully',
          backgroundColor: kSuccess.withValues(alpha: 0.1), colorText: kSuccess,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error',
          widget.ctrl.errorMessage.value.isNotEmpty ? widget.ctrl.errorMessage.value : 'Upload failed',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Upload Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 14),
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
                        color: sel ? kSuccess : Colors.grey.shade100,
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
            const SizedBox(height: 14),
            _Field('Title *', _titleCtrl, accent: kSuccess),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: _Field('Record Date *', _dateCtrl, accent: kSuccess,
                    suffix: const Icon(Icons.calendar_today, size: 16)),
              ),
            ),
            const SizedBox(height: 10),
            _Field('Doctor Name', _doctorCtrl, accent: kSuccess),
            const SizedBox(height: 10),
            _Field('Hospital Name', _hospitalCtrl, accent: kSuccess),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: kSuccess.withValues(alpha: 0.4), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                  color: kSuccess.withValues(alpha: 0.04),
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_file != null ? Icons.check_circle : Icons.upload_file, color: kSuccess),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _file != null
                          ? _file!.path.split(Platform.pathSeparator).last
                          : 'Tap to select image',
                      style: TextStyle(color: _file != null ? kSuccess : kTextMedium, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSuccess,
                  foregroundColor: kSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _submit,
                child: const Text('Upload Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
  final Color accent;
  final Widget? suffix;
  const _Field(this.hint, this.ctrl, {required this.accent, this.suffix});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: kTextLight, fontSize: 13),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: kBorder),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onUpload;
  const _EmptyState({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.folder_open_outlined, size: 72, color: kBorder),
        const SizedBox(height: 12),
        Text('No records yet', style: TextStyle(fontSize: 16, color: kTextMedium)),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: onUpload,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload your first report'),
        ),
      ]),
    );
  }
}
