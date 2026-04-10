import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DoctorSelectionPage extends StatefulWidget {
  const DoctorSelectionPage({super.key});

  @override
  State<DoctorSelectionPage> createState() => _DoctorSelectionPageState();
}

class _DoctorSelectionPageState extends State<DoctorSelectionPage> {
  String appointmentType = 'online';
  String? selectedDoctorId;

  final List<Doctor> doctors = [
    Doctor(
      id: 'doc_1',
      name: 'Dr. Rajesh Kumar',
      specialization: 'General Physician',
      experience: '10 years',
      rating: 4.8,
      consultationFee: 500,
      profileImage: Icons.person,
      isAvailable: true,
      nextAvailable: 'Today, 2:30 PM',
    ),
    Doctor(
      id: 'doc_2',
      name: 'Dr. Priya Sharma',
      specialization: 'Cardiologist',
      experience: '8 years',
      rating: 4.9,
      consultationFee: 800,
      profileImage: Icons.favorite,
      isAvailable: true,
      nextAvailable: 'Today, 3:00 PM',
    ),
    Doctor(
      id: 'doc_3',
      name: 'Dr. Amit Singh',
      specialization: 'Orthopedic',
      experience: '12 years',
      rating: 4.7,
      consultationFee: 600,
      profileImage: Icons.accessibility,
      isAvailable: false,
      nextAvailable: 'Tomorrow, 10:00 AM',
    ),
    Doctor(
      id: 'doc_4',
      name: 'Dr. Neha Gupta',
      specialization: 'Dermatologist',
      experience: '6 years',
      rating: 4.6,
      consultationFee: 550,
      profileImage: Icons.spa,
      isAvailable: true,
      nextAvailable: 'Today, 4:00 PM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    appointmentType = Get.arguments ?? 'online';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
        ),
        title: Text(
          appointmentType == 'online'
              ? 'Online Consultation'
              : 'In-Clinic Visit',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6BC4FF), Color(0xFFE3F2FD)],
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select a Doctor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...doctors.map((doctor) => _buildDoctorCard(doctor)),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: selectedDoctorId != null
          ? Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  final selected = doctors.firstWhere(
                    (d) => d.id == selectedDoctorId,
                  );
                  Get.toNamed(
                    '/appointment-booking',
                    arguments: {'doctor': selected, 'type': appointmentType},
                  );
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    bool isSelected = selectedDoctorId == doctor.id;
    return GestureDetector(
      onTap: () => setState(() => selectedDoctorId = doctor.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF00BCD4) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF00BCD4).withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    doctor.profileImage,
                    color: const Color(0xFF00BCD4),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (doctor.isAvailable)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Available',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Busy',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialization,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${doctor.rating} · ${doctor.experience}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Consultation Fee',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '₹${doctor.consultationFee}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00BCD4),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Next Available',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      doctor.nextAvailable,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final double rating;
  final int consultationFee;
  final IconData profileImage;
  final bool isAvailable;
  final String nextAvailable;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    required this.consultationFee,
    required this.profileImage,
    required this.isAvailable,
    required this.nextAvailable,
  });
}
