import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Config/colors_coning.dart';

class DoctorSelectionPage extends StatefulWidget {
  const DoctorSelectionPage({super.key});

  @override
  State<DoctorSelectionPage> createState() => _DoctorSelectionPageState();
}

class _DoctorSelectionPageState extends State<DoctorSelectionPage> {
  final _client = ApiClient();

  String appointmentType = 'online';
  String? selectedDoctorId;
  List<Doctor> _doctors = [];
  bool _loading = true;

  // Fallback list used when API returns nothing
  static final List<Doctor> _fallback = [
    Doctor(id: 'doc_1', name: 'Dr. Rajesh Kumar',
        specialization: 'General Physician', experience: '10 years',
        rating: 4.8, consultationFee: 500, isAvailable: true,
        nextAvailable: 'Today, 2:30 PM'),
    Doctor(id: 'doc_2', name: 'Dr. Priya Sharma',
        specialization: 'Cardiologist', experience: '8 years',
        rating: 4.9, consultationFee: 800, isAvailable: true,
        nextAvailable: 'Today, 3:00 PM'),
    Doctor(id: 'doc_3', name: 'Dr. Amit Singh',
        specialization: 'Orthopedic', experience: '12 years',
        rating: 4.7, consultationFee: 600, isAvailable: false,
        nextAvailable: 'Tomorrow, 10:00 AM'),
    Doctor(id: 'doc_4', name: 'Dr. Neha Gupta',
        specialization: 'Dermatologist', experience: '6 years',
        rating: 4.6, consultationFee: 550, isAvailable: true,
        nextAvailable: 'Today, 4:00 PM'),
  ];

  @override
  void initState() {
    super.initState();
    appointmentType = Get.arguments as String? ?? 'online';
    _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    setState(() => _loading = true);
    try {
      final res = await _client.get('doctors', requiresAuth: true);
      final raw = (res['data'] as List<dynamic>?) ?? [];
      if (raw.isNotEmpty) {
        setState(() {
          _doctors = raw
              .whereType<Map>()
              .map((d) => Doctor.fromJson(Map<String, dynamic>.from(d)))
              .toList();
        });
      } else {
        // Backend has no doctors yet — use fallback so the flow still works
        setState(() => _doctors = _fallback);
      }
    } catch (_) {
      setState(() { _doctors = _fallback; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: kPrimary,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
        ),
        title: Text(
          appointmentType == 'online'
              ? 'Online Consultation'
              : 'In-Clinic Visit',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : RefreshIndicator(
              onRefresh: _fetchDoctors,
              color: kPrimary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Row(children: [
                      Container(width: 4, height: 20,
                          decoration: BoxDecoration(
                              gradient: kPrimaryGradientV,
                              borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 10),
                      const Text('Select a Doctor',
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: kTextDark)),
                    ]),
                    const SizedBox(height: 16),
                    ..._doctors.map((d) => _DoctorCard(
                          doctor: d,
                          isSelected: selectedDoctorId == d.id,
                          onTap: () =>
                              setState(() => selectedDoctorId = d.id),
                        )),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: selectedDoctorId == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    final selected =
                        _doctors.firstWhere((d) => d.id == selectedDoctorId);
                    Get.toNamed('/appointment-booking',
                        arguments: {
                          'doctor': selected,
                          'type': appointmentType
                        });
                  },
                  child: const Text('Continue',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ),
    );
  }
}

// ── Doctor card ───────────────────────────────────────────────────────────────

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final bool isSelected;
  final VoidCallback onTap;
  const _DoctorCard(
      {required this.doctor,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? kPrimary : kBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? kPrimary.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Avatar
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                      colors: [kPrimary, kPrimaryMid],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  boxShadow: [
                    BoxShadow(
                        color: kPrimary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3))
                  ],
                ),
                child: Center(
                  child: Text(
                    doctor.name.isNotEmpty
                        ? doctor.name.split(' ').last[0].toUpperCase()
                        : 'D',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(doctor.name,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: kTextDark),
                                overflow: TextOverflow.ellipsis),
                          ),
                          _StatusBadge(available: doctor.isAvailable),
                        ]),
                    const SizedBox(height: 3),
                    Text(doctor.specialization,
                        style: const TextStyle(
                            fontSize: 12, color: kTextMedium)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.star_rounded,
                          size: 14, color: kWarning),
                      const SizedBox(width: 3),
                      Text(
                          '${doctor.rating.toStringAsFixed(1)} · ${doctor.experience}',
                          style: const TextStyle(
                              fontSize: 11, color: kTextMedium)),
                    ]),
                  ],
                ),
              ),
              // Selection indicator
              if (isSelected)
                const Icon(Icons.check_circle_rounded,
                    color: kPrimary, size: 22),
            ]),
            const SizedBox(height: 12),
            const Divider(height: 1, color: kDivider),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _InfoChip(
                  label: 'Fee',
                  value: '₹${doctor.consultationFee}',
                  color: kSuccess),
              _InfoChip(
                  label: 'Next slot',
                  value: doctor.nextAvailable,
                  color: kPrimary),
            ]),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool available;
  const _StatusBadge({required this.available});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: available
            ? kSuccess.withValues(alpha: 0.1)
            : kError.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(available ? 'Available' : 'Busy',
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: available ? kSuccess : kError)),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _InfoChip(
      {required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: const TextStyle(fontSize: 10, color: kTextLight)),
      Text(value,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: color)),
    ]);
  }
}

// ── Doctor model ──────────────────────────────────────────────────────────────

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final double rating;
  final int consultationFee;
  final bool isAvailable;
  final String nextAvailable;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    required this.consultationFee,
    required this.isAvailable,
    required this.nextAvailable,
  });

  factory Doctor.fromJson(Map<String, dynamic> j) {
    final avail = j['availability'] as Map<String, dynamic>?;
    return Doctor(
      id:              j['doctor_id'] ?? j['_id'] ?? j['id'] ?? '',
      name:            j['name']         as String? ?? 'Doctor',
      specialization:  j['specialty']    as String? ?? j['specialization'] as String? ?? '',
      experience:      '${j['experience_years'] ?? j['years_of_experience'] ?? 0} years',
      rating:          (j['rating'] ?? 0.0).toDouble(),
      consultationFee: (j['consultation_fee'] ?? j['hourly_rate'] ?? 0).toInt(),
      isAvailable:     j['is_available'] as bool? ?? true,
      nextAvailable:   avail?['next_slot'] as String? ?? 'Check schedule',
    );
  }
}
