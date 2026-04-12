import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/admin_controller.dart';
import 'package:home_care/Model/doctor_model.dart';

class AdminApprovalsPage extends StatefulWidget {
  const AdminApprovalsPage({super.key});

  @override
  State<AdminApprovalsPage> createState() => _AdminApprovalsPageState();
}

class _AdminApprovalsPageState extends State<AdminApprovalsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final ctrl = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    ctrl.fetchDoctors(approvalStatus: 'PENDING');
    ctrl.fetchNurses(approvalStatus: 'PENDING');
    ctrl.fetchHospitals(approvalStatus: 'PENDING');
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Pending Approvals',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        bottom: TabBar(
          controller: _tab,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Doctors'),
            Tab(text: 'Nurses'),
            Tab(text: 'Hospitals'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Obx(() => Row(
                  children: ['PENDING', 'APPROVED', 'REJECTED']
                      .map((f) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(f),
                              selected: ctrl.approvalFilter.value == f,
                              onSelected: (_) {
                                ctrl.approvalFilter.value = f;
                                ctrl.fetchDoctors(approvalStatus: f);
                                ctrl.fetchNurses(approvalStatus: f);
                                ctrl.fetchHospitals(approvalStatus: f);
                              },
                              selectedColor: const Color(0xFF1A237E)
                                  .withValues(alpha: 0.15),
                            ),
                          ))
                      .toList(),
                )),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _DoctorApprovalList(ctrl: ctrl),
                _NurseApprovalList(ctrl: ctrl),
                _HospitalApprovalList(ctrl: ctrl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Doctor approval list ───────────────────────────────────────────────────

class _DoctorApprovalList extends StatelessWidget {
  final AdminController ctrl;
  const _DoctorApprovalList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoadingApprovals.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (ctrl.doctors.isEmpty) {
        return const Center(child: Text('No doctors to show'));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ctrl.doctors.length,
        itemBuilder: (_, i) =>
            _DoctorCard(doctor: ctrl.doctors[i], ctrl: ctrl),
      );
    });
  }
}

class _DoctorCard extends StatelessWidget {
  final DoctorModel doctor;
  final AdminController ctrl;
  const _DoctorCard({required this.doctor, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _ApprovalCard(
      title: doctor.name,
      subtitle: '${doctor.specialty} • ${doctor.experience} yrs exp',
      detail: '₹${doctor.consultationFee.toInt()} consultation fee',
      rating: doctor.rating,
      isPending: doctor.availability == 'OFFLINE',
      onApprove: () => ctrl.approveDoctor(doctor.id, 'APPROVED'),
      onReject: () => ctrl.approveDoctor(doctor.id, 'REJECTED'),
      showActions: ctrl.approvalFilter.value == 'PENDING',
    );
  }
}

// ── Nurse approval list ────────────────────────────────────────────────────

class _NurseApprovalList extends StatelessWidget {
  final AdminController ctrl;
  const _NurseApprovalList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoadingApprovals.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (ctrl.nurses.isEmpty) {
        return const Center(child: Text('No nurses to show'));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ctrl.nurses.length,
        itemBuilder: (_, i) =>
            _NurseCard(nurse: ctrl.nurses[i], ctrl: ctrl),
      );
    });
  }
}

class _NurseCard extends StatelessWidget {
  final NurseModel nurse;
  final AdminController ctrl;
  const _NurseCard({required this.nurse, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return _ApprovalCard(
      title: nurse.name,
      subtitle: '${nurse.category} • ${nurse.experience} yrs exp',
      detail: '₹${nurse.hourlyRate.toInt()}/hr',
      rating: nurse.rating,
      isPending: !nurse.isAvailable,
      onApprove: () => ctrl.approveNurse(nurse.id, 'APPROVED'),
      onReject: () => ctrl.approveNurse(nurse.id, 'REJECTED'),
      showActions: ctrl.approvalFilter.value == 'PENDING',
    );
  }
}

// ── Hospital approval list ─────────────────────────────────────────────────

class _HospitalApprovalList extends StatelessWidget {
  final AdminController ctrl;
  const _HospitalApprovalList({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.isLoadingApprovals.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (ctrl.hospitals.isEmpty) {
        return const Center(child: Text('No hospitals to show'));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ctrl.hospitals.length,
        itemBuilder: (_, i) {
          final h = ctrl.hospitals[i];
          return _ApprovalCard(
            title: h['name'] ?? 'Hospital',
            subtitle: h['city'] ?? '',
            detail: 'Reg: ${h['registration_number'] ?? '—'}',
            rating: (h['rating'] ?? 0).toDouble(),
            isPending: h['approval_status'] == 'PENDING',
            onApprove: () =>
                ctrl.approveHospital(h['id'] ?? '', 'APPROVED'),
            onReject: () =>
                ctrl.approveHospital(h['id'] ?? '', 'REJECTED'),
            showActions: ctrl.approvalFilter.value == 'PENDING',
          );
        },
      );
    });
  }
}

// ── Shared approval card ───────────────────────────────────────────────────

class _ApprovalCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String detail;
  final double rating;
  final bool isPending;
  final bool showActions;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalCard({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.rating,
    required this.isPending,
    required this.showActions,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                if (rating > 0)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    color: Colors.grey.shade600, fontSize: 13)),
            Text(detail,
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 12)),
            if (showActions) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close,
                          color: Colors.red, size: 16),
                      label: const Text('Reject',
                          style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
