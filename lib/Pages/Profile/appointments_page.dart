import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  State<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  int selectedTab = 0; // 0: Upcoming, 1: Previous

  final List<Appointment> upcomingAppointments = [
    Appointment(
      doctorName: 'Dr. Sarah Johnson',
      specialty: 'Cardiologist',
      date: '15 Apr 2026',
      time: '2:00 PM',
      status: 'Confirmed',
      image: '👨‍⚕️',
      doctorContact: '+1 (555) 123-4567',
      hospital: 'City General Hospital',
      appointmentNotes:
          'Please bring your previous medical records and any current medications.',
      patientName: 'John Doe',
      appointmentType: 'Consultation',
    ),
    Appointment(
      doctorName: 'Dr. Mike Chen',
      specialty: 'Neurologist',
      date: '18 Apr 2026',
      time: '4:30 PM',
      status: 'Pending',
      image: '👨‍⚕️',
      doctorContact: '+1 (555) 987-6543',
      hospital: 'Neurology Center',
      appointmentNotes:
          'MRI results will be discussed. Please arrive 15 minutes early.',
      patientName: 'John Doe',
      appointmentType: 'Follow-up',
    ),
  ];

  final List<Appointment> previousAppointments = [
    Appointment(
      doctorName: 'Dr. Emily Brown',
      specialty: 'General Practitioner',
      date: '10 Apr 2026',
      time: '10:00 AM',
      status: 'Completed',
      image: '👩‍⚕️',
      doctorContact: '+1 (555) 456-7890',
      hospital: 'Family Medical Center',
      appointmentNotes:
          'Routine check-up completed. Next appointment in 6 months.',
      patientName: 'John Doe',
      appointmentType: 'Check-up',
    ),
    Appointment(
      doctorName: 'Dr. Robert Wilson',
      specialty: 'Dermatologist',
      date: '05 Apr 2026',
      time: '11:30 AM',
      status: 'Completed',
      image: '👨‍⚕️',
      doctorContact: '+1 (555) 321-0987',
      hospital: 'Skin Care Clinic',
      appointmentNotes:
          'Skin biopsy results were normal. Continue with prescribed treatment.',
      patientName: 'John Doe',
      appointmentType: 'Consultation',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
        ),
        title: const Text(
          'My Appointments',
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
      body: Column(
        children: [
          // Tab Selector
          Container(
            margin: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTab('Upcoming', 0),
                const SizedBox(width: 12),
                _buildTab('History', 1),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Appointments List
          Expanded(
            child: selectedTab == 0
                ? _buildAppointmentsList(upcomingAppointments)
                : _buildAppointmentsList(previousAppointments),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00BCD4) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No appointments',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final statusColor = appointment.status == 'Completed'
        ? Colors.green
        : appointment.status == 'Confirmed'
        ? Colors.blue
        : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.blue.shade100, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  appointment.image,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      appointment.specialty,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appointment.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                appointment.date,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(width: 20),
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                appointment.time,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'View Details',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Appointment {
  final String doctorName;
  final String specialty;
  final String date;
  final String time;
  final String status;
  final String image;
  final String doctorContact;
  final String hospital;
  final String appointmentNotes;
  final String patientName;
  final String appointmentType;

  Appointment({
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.time,
    required this.status,
    required this.image,
    required this.doctorContact,
    required this.hospital,
    required this.appointmentNotes,
    required this.patientName,
    required this.appointmentType,
  });
}
