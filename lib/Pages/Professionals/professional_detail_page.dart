import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Pages/Booking/confirm_booking_page.dart';

/// Professional Detail Page
class ProfessionalDetailPage extends StatefulWidget {
  final String professionalId;
  final String name;
  final String role;
  final String serviceName;
  final double rating;
  final bool available;
  final int yearsExperience;
  final String distance;
  final int estimatedDuration;
  final String availableTimeStart;
  final String availableTimeEnd;

  const ProfessionalDetailPage({
    super.key,
    required this.professionalId,
    required this.name,
    required this.role,
    required this.serviceName,
    required this.rating,
    required this.available,
    required this.yearsExperience,
    required this.distance,
    this.estimatedDuration = 30,
    this.availableTimeStart = '2:00 PM',
    this.availableTimeEnd = '4:00 PM',
  });

  @override
  State<ProfessionalDetailPage> createState() => _ProfessionalDetailPageState();
}

class _ProfessionalDetailPageState extends State<ProfessionalDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Header with avatar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.blue.shade600,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade600, Colors.blue.shade400],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade400,
                            Colors.indigo.shade600,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Role
                  Center(
                    child: Column(
                      children: [
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF312E81),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.role,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.rating} Rating',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.work_outline,
                          label: 'Experience',
                          value: '${widget.yearsExperience} years',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.location_on_outlined,
                          label: 'Distance',
                          value: widget.distance,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          icon: Icons.check_circle_outline,
                          label: 'Status',
                          value: widget.available ? 'Available' : 'Unavailable',
                          color: widget.available ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Specialization
                  const Text(
                    'Specialization',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF312E81),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.medical_services,
                          color: Colors.blue.shade600,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.serviceName,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Qualifications
                  const Text(
                    'Qualifications',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF312E81),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQualification('Bachelor of Science in Nursing'),
                  _buildQualification('Certified Nursing Assistant (CNA)'),
                  _buildQualification('Advanced Life Support (ALS)'),
                  const SizedBox(height: 24),

                  // Availability
                  const Text(
                    'Availability',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF312E81),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildAvailabilitySlot('Mon - Fri', '9:00 AM - 6:00 PM'),
                  _buildAvailabilitySlot('Saturday', '10:00 AM - 4:00 PM'),
                  _buildAvailabilitySlot('Sunday', 'On-call'),
                  const SizedBox(height: 28),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.available
                            ? Colors.blue.shade600
                            : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: widget.available
                          ? () {
                              LoggerService.info(
                                'Booking appointment with ${widget.name}',
                              );
                              Get.to(
                                () => ConfirmBookingPage(
                                  professionalId: widget.professionalId,
                                  professionalName: widget.name,
                                  professionalRole: widget.role,
                                  serviceName: widget.serviceName,
                                  rating: widget.rating,
                                  yearsExperience: widget.yearsExperience,
                                  distance: widget.distance,
                                  estimatedDuration: widget.estimatedDuration,
                                  availableTimeStart: widget.availableTimeStart,
                                  availableTimeEnd: widget.availableTimeEnd,
                                ),
                              );
                            }
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(
                            widget.available
                                ? 'Book Appointment'
                                : 'Not Available',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualification(String qualification) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              qualification,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySlot(String day, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Booking Page
class BookingPage extends StatefulWidget {
  final String professionalId;
  final String professionalName;
  final String specialization;
  final double rating;

  const BookingPage({
    super.key,
    required this.professionalId,
    required this.professionalName,
    required this.specialization,
    required this.rating,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  String? selectedSlot;
  String? selectedPurpose;
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now().add(const Duration(days: 1));
    selectedTime = const TimeOfDay(hour: 10, minute: 0);
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Professional Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.indigo.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.professionalName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF312E81),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.specialization,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${widget.rating}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Select Date
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF312E81),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate.isBefore(DateTime.now())
                      ? DateTime.now()
                      : selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  setState(() {
                    selectedDate = date;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Select Time
            const Text(
              'Select Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF312E81),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (time != null) {
                  setState(() {
                    selectedTime = time;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 12),
                    Text(
                      '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Select Purpose
            const Text(
              'Purpose of Visit',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF312E81),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedPurpose,
              items:
                  [
                        'Consultation',
                        'Follow-up',
                        'Check-up',
                        'Treatment',
                        'Other',
                      ]
                      .map(
                        (purpose) => DropdownMenuItem(
                          value: purpose,
                          child: Text(purpose),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedPurpose = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Select purpose',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            const Text(
              'Additional Notes (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF312E81),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Any additional information...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 28),

            // Booking Summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF312E81),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Professional', widget.professionalName),
                  _buildSummaryRow(
                    'Date',
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  ),
                  _buildSummaryRow(
                    'Time',
                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  ),
                  if (selectedPurpose != null)
                    _buildSummaryRow('Purpose', selectedPurpose!),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                onPressed: selectedPurpose != null
                    ? () {
                        LoggerService.success(
                          'Appointment booked with ${widget.professionalName}',
                        );
                        Get.snackbar(
                          '✓ Booking Confirmed',
                          'Your appointment has been booked successfully!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
                        Future.delayed(const Duration(seconds: 2), () {
                          Get.back();
                          Get.back();
                        });
                      }
                    : null,
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
