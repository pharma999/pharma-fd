import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Pages/Booking/booking_confirmation_page.dart';

class ConfirmBookingPage extends StatefulWidget {
  final String professionalId;
  final String professionalName;
  final String professionalRole;
  final String serviceName;
  final double rating;
  final int yearsExperience;
  final String distance;
  final int estimatedDuration;
  final String availableTimeStart;
  final String availableTimeEnd;

  const ConfirmBookingPage({
    super.key,
    required this.professionalId,
    required this.professionalName,
    required this.professionalRole,
    required this.serviceName,
    required this.rating,
    required this.yearsExperience,
    required this.distance,
    required this.estimatedDuration,
    required this.availableTimeStart,
    required this.availableTimeEnd,
  });

  @override
  State<ConfirmBookingPage> createState() => _ConfirmBookingPageState();
}

class _ConfirmBookingPageState extends State<ConfirmBookingPage> {
  bool isProcessing = false;

  void _confirmBooking() {
    setState(() => isProcessing = true);

    // Simulate processing
    Future.delayed(const Duration(seconds: 1), () {
      Get.to(
        () => BookingConfirmationPage(
          serviceName: widget.serviceName,
          serviceIcon: Icons.medical_services,
          serviceColor: Colors.blue.shade600,
          bookingDetails: {
            'professional': widget.professionalName,
            'role': widget.professionalRole,
            'date': 'Today',
            'time': '${widget.availableTimeStart} - ${widget.availableTimeEnd}',
            'duration': '${widget.estimatedDuration} minutes',
            'distance': widget.distance,
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
        ),
        title: const Text(
          'Confirm Booking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Professional Card
              _buildProfessionalCard(),
              const SizedBox(height: 24),

              // Booking Details Section
              _buildBookingDetailsSection(),
              const SizedBox(height: 24),

              // Summary Section
              _buildSummarySection(),
              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionalCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.indigo.shade600,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                            widget.professionalRole,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            widget.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Experience and Distance
                Row(
                  children: [
                    Icon(
                      Icons.work_outline,
                      size: 12,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.yearsExperience} yrs exp',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: Colors.blue.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.distance,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue.shade400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Booking Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetailItem(
          icon: Icons.medical_services,
          label: 'Service',
          value: widget.serviceName,
          iconColor: Colors.blue.shade600,
        ),
        const SizedBox(height: 12),
        _buildDetailItem(
          icon: Icons.calendar_today,
          label: 'Date',
          value: 'Today',
          iconColor: Colors.purple.shade600,
        ),
        const SizedBox(height: 12),
        _buildDetailItem(
          icon: Icons.access_time,
          label: 'Time Slot',
          value: '${widget.availableTimeStart} - ${widget.availableTimeEnd}',
          iconColor: Colors.orange.shade600,
        ),
        const SizedBox(height: 12),
        _buildDetailItem(
          icon: Icons.schedule,
          label: 'Duration',
          value: '${widget.estimatedDuration} minutes',
          iconColor: Colors.green.shade600,
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Important Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF312E81),
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.info_outline,
            text:
                'Our professional will arrive within ${widget.distance} at your booked time slot',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.phone,
            text: 'You will receive a call 10 minutes before arrival',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            icon: Icons.shield,
            text: 'All professionals are verified and insured',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.blue.shade700,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue.shade700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Confirm Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isProcessing ? null : _confirmBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              disabledBackgroundColor: Colors.grey.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isProcessing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Processing...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : const Text(
                    'Confirm Booking',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Cancel Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isProcessing ? null : () => Get.back(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(
                color: Colors.grey.shade400,
                width: 1,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
