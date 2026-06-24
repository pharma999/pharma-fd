import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Controller/family_report_controller.dart';
import 'package:home_care/Controller/profile_controller.dart';
import 'package:home_care/Model/family_member_model.dart';
import 'package:home_care/Model/medical_record_model.dart';
import 'package:home_care/Api/Config/api_config.dart';
import 'package:home_care/Pages/Profile/FamilyReport/member_report_page.dart';

// ── Record type → theme color mapping ────────────────────────────────────────
// All colors from colors_coning.dart — no hardcoded hex values.
const _typeColor = {
  'LAB_REPORT':   kPrimary,
  'PRESCRIPTION': kSuccess,
  'XRAY':         kWarning,
  'ECG':          kError,
  'OTHER':        kTeal,
};
const _typeIcon = {
  'LAB_REPORT':   Icons.biotech_rounded,
  'PRESCRIPTION': Icons.medication_rounded,
  'XRAY':         Icons.healing_rounded,
  'ECG':          Icons.monitor_heart_rounded,
  'OTHER':        Icons.description_rounded,
};

Color _colorFor(String type) => _typeColor[type] ?? kTextMedium;
IconData _iconFor(String type)  => _typeIcon[type]  ?? Icons.description_rounded;

// ── Family Reports Page ───────────────────────────────────────────────────────

class FamilyReportsPage extends StatefulWidget {
  const FamilyReportsPage({super.key});

  @override
  State<FamilyReportsPage> createState() => _FamilyReportsPageState();
}

class _FamilyReportsPageState extends State<FamilyReportsPage>
    with SingleTickerProviderStateMixin {
  late final FamilyReportController ctrl;
  late final ProfileController profileCtrl;

  // Search & filter
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _activeFilter; // null = All

  // List animation
  late AnimationController _listAnim;

  static const _types = ['LAB_REPORT', 'PRESCRIPTION', 'XRAY', 'ECG', 'OTHER'];

  @override
  void initState() {
    super.initState();
    ctrl = Get.isRegistered<FamilyReportController>()
        ? Get.find<FamilyReportController>()
        : Get.put(FamilyReportController());
    profileCtrl = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());

    _listAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });

    // Trigger list animation after data loads
    ever(ctrl.medicalRecords, (_) {
      if (_listAnim.isDismissed) _listAnim.forward();
    });
  }

  @override
  void dispose() {
    _listAnim.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MedicalRecord> get _filteredRecords {
    var list = ctrl.medicalRecords.toList();
    if (_activeFilter != null) {
      list = list.where((r) => r.recordType == _activeFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((r) =>
              r.title.toLowerCase().contains(_searchQuery) ||
              r.doctorName.toLowerCase().contains(_searchQuery) ||
              r.recordType.toLowerCase().contains(_searchQuery))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Obx(() {
        final loading = ctrl.isLoadingMembers.value || ctrl.isLoadingRecords.value;
        if (loading) return _buildSkeleton();

        return RefreshIndicator(
          color: kPrimary,
          onRefresh: () async => ctrl.loadAll(),
          child: CustomScrollView(
            slivers: [
              // ── Gradient header ─────────────────────────────────────────
              SliverToBoxAdapter(child: _buildHeader()),

              // ── Stats row ───────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildStats()),

              // ── Family Members ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: _SectionLabel(
                  icon: Icons.groups_rounded,
                  title: 'Family Members',
                  action: TextButton.icon(
                    onPressed: () => _showAddMemberDialog(context),
                    icon: const Icon(Icons.add_rounded, size: 16, color: kPrimary),
                    label: const Text('Add',
                        style: TextStyle(color: kPrimary, fontSize: 13)),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: Obx(() => ctrl.familyMembers.isEmpty
                    ? const SliverToBoxAdapter(child: _EmptyMembers())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _MemberCard(member: ctrl.familyMembers[i]),
                          childCount: ctrl.familyMembers.length,
                        ),
                      )),
              ),

              // ── Reports ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _SectionLabel(
                  icon: Icons.description_rounded,
                  title: 'My Reports',
                ),
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kBorder),
                      boxShadow: [
                        BoxShadow(
                            color: kTextDark.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search reports…',
                        hintStyle: const TextStyle(
                            color: kTextLight, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: kPrimary, size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    size: 18, color: kTextLight),
                                onPressed: () => _searchCtrl.clear())
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
              ),

              // Filter chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _activeFilter == null,
                        color: kPrimary,
                        onTap: () => setState(() => _activeFilter = null),
                      ),
                      ..._types.map((t) => _FilterChip(
                            label: t.replaceAll('_', ' '),
                            selected: _activeFilter == t,
                            color: _colorFor(t),
                            onTap: () => setState(() =>
                                _activeFilter = _activeFilter == t ? null : t),
                          )),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Records list (animated)
              Obx(() {
                final records = _filteredRecords;
                if (records.isEmpty) {
                  return const SliverToBoxAdapter(child: _EmptyReports());
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _AnimatedRecordCard(
                        record: records[i],
                        ctrl: ctrl,
                        index: i,
                        controller: _listAnim,
                      ),
                      childCount: records.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() => FloatingActionButton.extended(
            backgroundColor: kPrimary,
            elevation: 4,
            onPressed: ctrl.isUploading.value
                ? null
                : () => _showUploadSheet(context),
            icon: ctrl.isUploading.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: kSurface, strokeWidth: 2))
                : const Icon(Icons.upload_file_rounded, color: kSurface),
            label: Text(
              ctrl.isUploading.value ? 'Uploading…' : 'Upload Report',
              style: const TextStyle(
                  color: kSurface, fontWeight: FontWeight.w600),
            ),
          )),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Obx(() {
      final u = profileCtrl.user.value;
      final imageUrl = u?.profileImage ?? '';
      final fullUrl = imageUrl.isNotEmpty
          ? (imageUrl.startsWith('http')
              ? imageUrl
              : '${ApiConfig.baseUrl.replaceAll('/api', '')}$imageUrl')
          : '';
      final name = u?.name ?? 'User';
      final initial = name.trim().isNotEmpty
          ? name.trim()[0].toUpperCase()
          : '?';

      return Stack(children: [
        // Gradient background
        Container(
          height: 200,
          decoration: const BoxDecoration(
            gradient: kPrimaryGradient,
            borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
        ),

        // Decorative circle
        Positioned(
          right: -40, top: -40,
          child: Container(
            width: 180, height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimaryLight.withValues(alpha: 0.12),
            ),
          ),
        ),

        // Content
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(children: [
              // Top bar
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: kSurface, size: 20),
                  onPressed: () => Get.back(),
                ),
                const Expanded(
                  child: Text('Family Reports',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded,
                      color: kSurface, size: 22),
                  onPressed: ctrl.loadAll,
                ),
              ]),
              const SizedBox(height: 10),

              // Avatar + user info
              Row(children: [
                // Avatar
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kSurface, width: 2.5),
                    gradient: fullUrl.isEmpty ? kPrimaryGradientV : null,
                    image: fullUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(fullUrl),
                            fit: BoxFit.cover)
                        : null,
                    boxShadow: [
                      BoxShadow(
                          color: kPrimaryDark.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: fullUrl.isEmpty
                      ? Center(
                          child: Text(initial,
                              style: const TextStyle(
                                  color: kSurface,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)))
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              color: kSurface,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Head of Household',
                          style: TextStyle(
                              color: kAccent, fontSize: 13)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: kSurface.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'ID: ${(u?.userId ?? '').isNotEmpty ? u!.userId.substring(0, 8).toUpperCase() : "—"}',
                          style: const TextStyle(
                              color: kSurface, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ]);
    });
  }

  // ── STATS ────────────────────────────────────────────────────────────────────

  Widget _buildStats() {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(children: [
            _StatCard(
              value: '${ctrl.memberCount}',
              label: 'Members',
              icon: Icons.groups_rounded,
              color: kPrimary,
            ),
            _StatCard(
              value: '${ctrl.recordCount}',
              label: 'Reports',
              icon: Icons.description_rounded,
              color: kTeal,
            ),
            _StatCard(
              value: '0',
              label: 'Conditions',
              icon: Icons.health_and_safety_rounded,
              color: kWarning,
            ),
            _StatCard(
              value: ctrl.medicalRecords.isNotEmpty
                  ? ctrl.medicalRecords.first.recordDate
                      .split('-')
                      .reversed
                      .join('/')
                  : '—',
              label: 'Last Report',
              icon: Icons.event_rounded,
              color: kSuccess,
            ),
          ]),
        ));
  }

  // ── SKELETON ─────────────────────────────────────────────────────────────────

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      child: Column(children: [
        // Header skeleton
        Container(
          height: 200,
          decoration: const BoxDecoration(
            gradient: kPrimaryGradientV,
            borderRadius:
                BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
              child: Row(children: [
                _Shimmer(width: 72, height: 72,
                    radius: 36, base: kPrimaryMid, hi: kPrimary),
                const SizedBox(width: 16),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _Shimmer(width: 130, height: 18,
                      radius: 6, base: kPrimaryMid, hi: kPrimary),
                  const SizedBox(height: 8),
                  _Shimmer(width: 90, height: 12,
                      radius: 4, base: kPrimaryMid, hi: kPrimary),
                ]),
              ]),
            ),
          ),
        ),
        // Stats skeleton
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: List.generate(
              4,
              (_) => Expanded(
                child: _Shimmer(
                    height: 80,
                    radius: 14,
                    margin: const EdgeInsets.symmetric(horizontal: 4)),
              ),
            ),
          ),
        ),
        // Cards skeleton
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: List.generate(
              4,
              (_) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  _Shimmer(width: 44, height: 44, radius: 12),
                  const SizedBox(width: 12),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Shimmer(width: 150, height: 14, radius: 6),
                        const SizedBox(height: 8),
                        _Shimmer(width: 100, height: 10, radius: 4),
                      ]),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ── DIALOGS / SHEETS ─────────────────────────────────────────────────────────

  void _showAddMemberDialog(BuildContext context) {
    final nameCtrl     = TextEditingController();
    final relationCtrl = TextEditingController();
    final dobCtrl      = TextEditingController();
    final bloodCtrl    = TextEditingController();
    String gender = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Family Member',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: kTextDark)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _Field('Name *', nameCtrl),
              const SizedBox(height: 12),
              _Field('Relation (e.g. Spouse, Son)', relationCtrl),
              const SizedBox(height: 12),
              _Field('Date of Birth (YYYY-MM-DD)', dobCtrl),
              const SizedBox(height: 12),
              _Field('Blood Group', bloodCtrl),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['MALE', 'FEMALE', 'OTHER'].map((g) {
                  final sel = gender == g;
                  return GestureDetector(
                    onTap: () => setS(() => gender = g),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel
                            ? kPrimary
                            : kPrimary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel
                                ? kPrimary
                                : kBorder),
                      ),
                      child: Text(g,
                          style: TextStyle(
                              color: sel ? kSurface : kTextMedium,
                              fontSize: 12,
                              fontWeight: sel
                                  ? FontWeight.w600
                                  : FontWeight.normal)),
                    ),
                  );
                }).toList(),
              ),
            ]),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel',
                    style: TextStyle(color: kTextMedium))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: kSurface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty ||
                    relationCtrl.text.trim().isEmpty) {
                  Get.snackbar('Required',
                      'Name and relation are required',
                      snackPosition: SnackPosition.BOTTOM);
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
                  Get.snackbar('Added',
                      'Family member added successfully',
                      backgroundColor: kSuccess.withValues(alpha: 0.1),
                      colorText: kSuccess,
                      snackPosition: SnackPosition.BOTTOM);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
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

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? action;
  const _SectionLabel(
      {required this.icon, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 10),
      child: Row(children: [
        Container(
          width: 4, height: 18,
          decoration: BoxDecoration(
              gradient: kPrimaryGradientV,
              borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 18, color: kPrimary),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: kTextDark)),
        const Spacer(),
        if (action != null) action!,
      ]),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          Text(value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: value.length > 4 ? 11 : 16,
                  fontWeight: FontWeight.w800,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: kTextLight)),
        ]),
      ),
    );
  }
}

// ── Filter chip ───────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.selected,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected ? color : kBorder,
              width: selected ? 1.5 : 1),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? kSurface : kTextMedium)),
      ),
    );
  }
}

// ── Family member card ────────────────────────────────────────────────────────

class _MemberCard extends StatefulWidget {
  final FamilyMemberModel member;
  const _MemberCard({required this.member});

  @override
  State<_MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<_MemberCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.member;
    final initials = m.name.isNotEmpty ? m.name[0].toUpperCase() : '?';
    final sub =
        '${m.relation}${m.dateOfBirth.isNotEmpty ? ' • ${m.dateOfBirth}' : ''}';

    return GestureDetector(
      onTap: () => Get.to(() => MemberReportPage(member: m)),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
            boxShadow: [
              BoxShadow(
                  color: kTextDark.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(children: [
            // Avatar
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: m.profileImage.isEmpty ? kPrimaryGradient : null,
                image: m.profileImage.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(m.profileImage),
                        fit: BoxFit.cover)
                    : null,
                boxShadow: [
                  BoxShadow(
                      color: kPrimary.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2))
                ],
              ),
              child: m.profileImage.isEmpty
                  ? Center(
                      child: Text(initials,
                          style: const TextStyle(
                              color: kSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)))
                  : null,
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: kTextDark)),
                    const SizedBox(height: 2),
                    Text(sub,
                        style: const TextStyle(
                            color: kTextMedium, fontSize: 12)),
                  ]),
            ),
            // Blood group badge
            if (m.bloodGroup.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kError.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: kError.withValues(alpha: 0.25)),
                ),
                child: Text(m.bloodGroup,
                    style: const TextStyle(
                        color: kError,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: kTextLight),
          ]),
        ),
      ),
    );
  }
}

// ── Animated record card ──────────────────────────────────────────────────────

class _AnimatedRecordCard extends StatelessWidget {
  final MedicalRecord record;
  final FamilyReportController ctrl;
  final int index;
  final AnimationController controller;
  const _AnimatedRecordCard(
      {required this.record,
      required this.ctrl,
      required this.index,
      required this.controller});

  @override
  Widget build(BuildContext context) {
    final delay = (index * 0.08).clamp(0.0, 0.6);
    final anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: controller,
          curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeOut)),
    );
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) => Opacity(
        opacity: anim.value,
        child: Transform.translate(
            offset: Offset(0, 20 * (1 - anim.value)), child: child),
      ),
      child: _RecordCard(record: record, ctrl: ctrl),
    );
  }
}

// ── Record card ───────────────────────────────────────────────────────────────

class _RecordCard extends StatefulWidget {
  final MedicalRecord record;
  final FamilyReportController ctrl;
  const _RecordCard({required this.record, required this.ctrl});

  @override
  State<_RecordCard> createState() => _RecordCardState();
}

class _RecordCardState extends State<_RecordCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final r     = widget.record;
    final color = _colorFor(r.recordType);
    final icon  = _iconFor(r.recordType);

    return GestureDetector(
      onTap: () => _showDetail(context),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
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
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  // Type icon
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  // Title + date
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
                          Text(r.recordDate,
                              style: const TextStyle(
                                  color: kTextLight, fontSize: 12)),
                        ]),
                  ),
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      r.recordType.replaceAll('_', ' '),
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 10),
                    ),
                  ),
                ]),

                // Doctor / hospital
                if (r.doctorName.isNotEmpty || r.hospitalName.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: kDivider),
                  const SizedBox(height: 10),
                  Row(children: [
                    if (r.doctorName.isNotEmpty) ...[
                      const Icon(Icons.person_outline_rounded,
                          size: 13, color: kTextLight),
                      const SizedBox(width: 4),
                      Text(r.doctorName,
                          style: const TextStyle(
                              color: kTextMedium, fontSize: 12)),
                      const SizedBox(width: 12),
                    ],
                    if (r.hospitalName.isNotEmpty) ...[
                      const Icon(Icons.local_hospital_outlined,
                          size: 13, color: kTextLight),
                      const SizedBox(width: 4),
                      Expanded(
                          child: Text(r.hospitalName,
                              style: const TextStyle(
                                  color: kTextMedium, fontSize: 12),
                              overflow: TextOverflow.ellipsis)),
                    ],
                  ]),
                ],

                // File + delete row
                const SizedBox(height: 10),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (r.fileUrl.isNotEmpty)
                        GestureDetector(
                          onTap: () => _openFile(r.fileUrl),
                          child: Row(children: [
                            Icon(Icons.attach_file_rounded,
                                size: 15, color: color),
                            const SizedBox(width: 4),
                            Text('View File',
                                style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                          ]),
                        )
                      else
                        const SizedBox.shrink(),
                      GestureDetector(
                        onTap: () => _confirmDelete(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: kError.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete_outline_rounded,
                              size: 16, color: kError),
                        ),
                      ),
                    ]),
              ]),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final r     = widget.record;
    final color = _colorFor(r.recordType);
    final icon  = _iconFor(r.recordType);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
            color: kSurface,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: kBorder,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),

          // Type icon + title
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: kTextDark)),
                    Text(r.recordType.replaceAll('_', ' '),
                        style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ]),
            ),
          ]),
          const SizedBox(height: 20),
          const Divider(color: kDivider),
          const SizedBox(height: 12),

          // Detail rows
          _DetailRow(Icons.calendar_today_rounded, 'Date', r.recordDate),
          if (r.doctorName.isNotEmpty)
            _DetailRow(Icons.person_outline_rounded, 'Doctor', r.doctorName),
          if (r.hospitalName.isNotEmpty)
            _DetailRow(Icons.local_hospital_outlined, 'Hospital', r.hospitalName),
          if (r.fileUrl.isNotEmpty)
            _DetailRow(Icons.attach_file_rounded, 'File',
                r.fileUrl.split('/').last),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _openFile(String url) {
    final full = url.startsWith('http')
        ? url
        : '${ApiConfig.baseUrl.replaceAll('/api', '')}$url';
    Get.snackbar('Opening File', full,
        snackPosition: SnackPosition.BOTTOM);
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Record',
            style: TextStyle(color: kTextDark)),
        content: Text('Delete "${widget.record.title}"?',
            style: const TextStyle(color: kTextMedium)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: kTextMedium))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: kError,
                foregroundColor: kSurface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context);
              widget.ctrl.deleteRecord(widget.record.recordId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Upload sheet ──────────────────────────────────────────────────────────────

class _UploadSheet extends StatefulWidget {
  final FamilyReportController ctrl;
  const _UploadSheet({required this.ctrl});

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

  Future<void> _pick() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _pickedFile = File(picked.path));
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      Get.snackbar('Required', 'Title is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_dateCtrl.text.trim().isEmpty) {
      Get.snackbar('Required', 'Record date is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (_pickedFile == null) {
      Get.snackbar('Required', 'Please select a file',
          snackPosition: SnackPosition.BOTTOM);
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
      Get.snackbar('Uploaded', 'Report uploaded successfully',
          backgroundColor: kSuccess.withValues(alpha: 0.1),
          colorText: kSuccess,
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar(
          'Error',
          widget.ctrl.errorMessage.value.isNotEmpty
              ? widget.ctrl.errorMessage.value
              : 'Upload failed',
          snackPosition: SnackPosition.BOTTOM);
    }
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
                decoration: BoxDecoration(
                    color: kBorder,
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
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
                final sel = _recordType == t;
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
                            fontWeight: sel
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 11)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          _Field('Title *', _titleCtrl),
          const SizedBox(height: 12),
          _Field('Record Date (YYYY-MM-DD) *', _dateCtrl),
          const SizedBox(height: 12),
          _Field('Doctor Name', _doctorCtrl),
          const SizedBox(height: 12),
          _Field('Hospital Name', _hospitalCtrl),
          const SizedBox(height: 16),

          // File picker
          GestureDetector(
            onTap: _pick,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                    color: kPrimary.withValues(alpha: 0.4), width: 1.5),
                borderRadius: BorderRadius.circular(12),
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
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _pickedFile != null
                            ? _pickedFile!.path
                                .split(Platform.pathSeparator)
                                .last
                            : 'Tap to select image / PDF',
                        style: TextStyle(
                          color: _pickedFile != null
                              ? kPrimary
                              : kTextMedium,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
            ),
          ),
          const SizedBox(height: 24),

          // Submit
          SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: kSurface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0),
              onPressed: _submit,
              child: const Text('Upload Report',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Empty states ──────────────────────────────────────────────────────────────

class _EmptyMembers extends StatelessWidget {
  const _EmptyMembers();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: kPrimary.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kPrimary.withValues(alpha: 0.15))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.group_add_rounded,
            size: 44, color: kPrimary.withValues(alpha: 0.4)),
        const SizedBox(height: 10),
        const Text('No family members added yet',
            style: TextStyle(color: kTextMedium, fontSize: 13)),
      ]),
    );
  }
}

class _EmptyReports extends StatelessWidget {
  const _EmptyReports();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder)),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.06),
                shape: BoxShape.circle),
            child: Icon(Icons.folder_open_rounded,
                size: 44, color: kPrimary.withValues(alpha: 0.4)),
          ),
          const SizedBox(height: 16),
          const Text('No Family Reports Available',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kTextDark)),
          const SizedBox(height: 8),
          const Text(
              'Upload your first report using the button below.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextMedium, fontSize: 13)),
        ]),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String hint;
  final TextEditingController ctrl;
  const _Field(this.hint, this.ctrl);

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
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 15, color: kPrimary),
        const SizedBox(width: 10),
        SizedBox(
          width: 68,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12, color: kTextMedium)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kTextDark)),
        ),
      ]),
    );
  }
}

// ── Shimmer skeleton ──────────────────────────────────────────────────────────

class _Shimmer extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;
  final Color? base;
  final Color? hi;

  const _Shimmer({
    this.width,
    required this.height,
    this.radius = 8,
    this.margin,
    this.base,
    this.hi,
  });

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _color = ColorTween(
      begin: widget.base ?? kBorder,
      end: widget.hi ?? kDivider,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
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
        width: widget.width,
        height: widget.height,
        margin: widget.margin,
        decoration: BoxDecoration(
          color: _color.value,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}
