import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:home_care/Pages/Appointment/doctor_selection_page.dart';

class AppointmentConfirmationPage extends StatefulWidget {
  const AppointmentConfirmationPage({super.key});

  @override
  State<AppointmentConfirmationPage> createState() =>
      _AppointmentConfirmationPageState();
}

class _AppointmentConfirmationPageState
    extends State<AppointmentConfirmationPage> {
  late Doctor doctor;
  late String appointmentType;
  late String date;
  late String time;
  late String notes;
  bool isConfirmed = false;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map;
    doctor = arguments['doctor'];
    appointmentType = arguments['type'];
    date = arguments['date'];
    time = arguments['time'];
    notes = arguments['notes'];

    // Auto confirm after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => isConfirmed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: const Text(
            'Appointment Booking',
            style: TextStyle(
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // Success Icon/Animation
              isConfirmed ? _buildSuccessAnimation() : _buildLoadingAnimation(),

              const SizedBox(height: 30),

              // Confirmation Text
              Text(
                isConfirmed ? 'Appointment Confirmed!' : 'Confirming...',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                isConfirmed
                    ? 'Your appointment has been successfully booked'
                    : 'Please wait while we confirm your appointment',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              if (isConfirmed) ...[
                // Appointment Details
                _buildDetailCard(
                  title: 'Doctor',
                  value: doctor.name,
                  icon: Icons.person,
                ),
                const SizedBox(height: 12),
                _buildDetailCard(
                  title: 'Specialization',
                  value: doctor.specialization,
                  icon: Icons.medical_information,
                ),
                const SizedBox(height: 12),
                _buildDetailCard(
                  title: 'Appointment Type',
                  value: appointmentType == 'online'
                      ? 'Video Consultation'
                      : 'In-Clinic Visit',
                  icon: appointmentType == 'online'
                      ? Icons.video_call
                      : Icons.location_on,
                ),
                const SizedBox(height: 12),
                _buildDetailCard(
                  title: 'Date',
                  value: date,
                  icon: Icons.calendar_today,
                ),
                const SizedBox(height: 12),
                _buildDetailCard(
                  title: 'Time',
                  value: time,
                  icon: Icons.access_time,
                ),
                const SizedBox(height: 12),
                _buildDetailCard(
                  title: 'Consultation Fee',
                  value: '₹${doctor.consultationFee}',
                  icon: Icons.currency_rupee,
                  valueColor: const Color(0xFF00BCD4),
                ),

                const SizedBox(height: 24),

                // Info Cards
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Confirmation details have been sent to your registered phone number',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                if (appointmentType == 'online')
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Video call link will be shared 15 min before the appointment',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.purple.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Clinic address & directions will be shared via WhatsApp',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 30),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Get.offAllNamed('/bottomAppBar'),
                    icon: const Icon(Icons.home),
                    label: const Text('Back to Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'Reminder Set',
                        'You will get a reminder 1 hour before appointment',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    },
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Set Reminder'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00BCD4)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.green.shade100,
          ),
          alignment: Alignment.center,
          child: Icon(Icons.check_circle, color: Colors.green, size: 60),
        ),
      ],
    );
  }

  Widget _buildLoadingAnimation() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
          ),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(
            color: Color(0xFF00BCD4),
            strokeWidth: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard({
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: const Color(0xFF00BCD4), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
