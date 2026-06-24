import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Api/Core/api_client.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Pages/Appointment/doctor_selection_page.dart';

class AppointmentBookingPage extends StatefulWidget {
  const AppointmentBookingPage({super.key});

  @override
  State<AppointmentBookingPage> createState() => _AppointmentBookingPageState();
}

class _AppointmentBookingPageState extends State<AppointmentBookingPage> {
  final _client = ApiClient();

  late Doctor doctor;
  late String appointmentType;
  String? selectedDate;
  String? selectedTime;
  bool _isBooking = false;
  final TextEditingController notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map;
    doctor = arguments['doctor'];
    appointmentType = arguments['type'];
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (selectedDate == null || selectedTime == null) return;
    setState(() => _isBooking = true);
    try {
      // Build ISO-8601 scheduled_at from selectedDate (d/m/y) + selectedTime
      final parts = selectedDate!.split('/');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      final timeParts = selectedTime!.replaceAll(' AM', '').replaceAll(' PM', '').split(':');
      var hour = int.parse(timeParts[0]);
      if (selectedTime!.contains('PM') && hour != 12) hour += 12;
      if (selectedTime!.contains('AM') && hour == 12) hour = 0;
      final scheduledAt = DateTime(year, month, day, hour,
          timeParts.length > 1 ? int.parse(timeParts[1]) : 0);

      final res = await _client.post('appointments', {
        'doctor_id':    doctor.id,
        'type':         appointmentType.toUpperCase(),
        'scheduled_at': scheduledAt.toUtc().toIso8601String(),
        'notes':        notesController.text.trim(),
      }, requiresAuth: true);

      final bookingId = (res['data'] as Map<String, dynamic>?)?['appointment_id']
          ?? (res['data'] as Map<String, dynamic>?)?['id']
          ?? '';

      if (!mounted) return;
      Get.toNamed('/appointment-confirmation', arguments: {
        'doctor':     doctor,
        'type':       appointmentType,
        'date':       selectedDate,
        'time':       selectedTime,
        'notes':      notesController.text,
        'booking_id': bookingId,
      });
    } catch (e) {
      if (!mounted) return;
      Get.snackbar(
        'Booking Failed',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kError.withValues(alpha: 0.1),
        colorText: kError,
      );
    } finally {
      if (mounted) setState(() => _isBooking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey, size: 20),
        ),
        title: const Text(
          'Book Appointment',
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Info Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      doctor.name.isNotEmpty
                          ? doctor.name.split(' ').last[0].toUpperCase()
                          : 'D',
                      style: const TextStyle(
                          color: Color(0xFF00BCD4),
                          fontWeight: FontWeight.bold,
                          fontSize: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          doctor.specialization,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
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
            ),

            const SizedBox(height: 24),

            // Select Date
            const Text(
              'Select Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDateSelector(),

            const SizedBox(height: 24),

            // Select Time
            const Text(
              'Select Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTimeSelector(),

            const SizedBox(height: 24),

            // Additional Notes
            const Text(
              'Additional Information (Optional)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'Describe your symptoms or reason for consultation...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF00BCD4),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Appointment Type Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appointmentType == 'online'
                    ? Colors.blue.shade50
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: appointmentType == 'online'
                      ? Colors.blue.shade200
                      : Colors.green.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    appointmentType == 'online'
                        ? Icons.video_call
                        : Icons.location_on,
                    color: appointmentType == 'online'
                        ? Colors.blue.shade700
                        : Colors.green.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointmentType == 'online'
                          ? 'Video consultation link will be shared via WhatsApp'
                          : 'Visit confirmed clinic location will be shared',
                      style: TextStyle(
                        fontSize: 12,
                        color: appointmentType == 'online'
                            ? Colors.blue.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BCD4),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: (selectedDate != null && selectedTime != null && !_isBooking)
              ? _confirm
              : null,
          child: _isBooking
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Text(
                  'Confirm Appointment',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final dates = [
      DateTime.now(),
      DateTime.now().add(const Duration(days: 1)),
      DateTime.now().add(const Duration(days: 2)),
      DateTime.now().add(const Duration(days: 3)),
      DateTime.now().add(const Duration(days: 4)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: dates
            .map(
              (date) => GestureDetector(
                onTap: () {
                  setState(
                    () =>
                        selectedDate = '${date.day}/${date.month}/${date.year}',
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color:
                        selectedDate == '${date.day}/${date.month}/${date.year}'
                        ? const Color(0xFF00BCD4)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color:
                          selectedDate ==
                              '${date.day}/${date.month}/${date.year}'
                          ? const Color(0xFF00BCD4)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getDayName(date.weekday),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              selectedDate ==
                                  '${date.day}/${date.month}/${date.year}'
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              selectedDate ==
                                  '${date.day}/${date.month}/${date.year}'
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTimeSelector() {
    final times = [
      '9:00 AM',
      '10:00 AM',
      '11:00 AM',
      '2:00 PM',
      '3:00 PM',
      '4:00 PM',
      '5:00 PM',
      '6:00 PM',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: times
          .map(
            (time) => GestureDetector(
              onTap: () => setState(() => selectedTime = time),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selectedTime == time
                      ? const Color(0xFF00BCD4)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selectedTime == time
                        ? const Color(0xFF00BCD4)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selectedTime == time
                        ? Colors.white
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
