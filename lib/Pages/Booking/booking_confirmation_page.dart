import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

class BookingConfirmationPage extends StatefulWidget {
  final String serviceName;
  final IconData serviceIcon;
  final Color serviceColor;
  final Map<String, dynamic> bookingDetails;

  const BookingConfirmationPage({
    super.key,
    required this.serviceName,
    required this.serviceIcon,
    required this.serviceColor,
    required this.bookingDetails,
  });

  @override
  State<BookingConfirmationPage> createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  late Timer trackingTimer;
  int currentStep = 0; // 0: Confirmed, 1: Professional Assigned, 2: On the Way, 3: Arrived
  double eta = 15; // minutes
  double distance = 2.5; // km

  @override
  void initState() {
    super.initState();
    startRealTimeTracking();
  }

  void startRealTimeTracking() {
    trackingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      setState(() {
        // Simulate progress
        if (currentStep < 3) {
          if (eta > 0) {
            eta -= 0.5;
            distance -= 0.02;
          } else if (currentStep < 3) {
            currentStep++;
            eta = 15;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    trackingTimer.cancel();
    super.dispose();
  }

  String getStepLabel(int step) {
    switch (step) {
      case 0:
        return 'Booking Confirmed';
      case 1:
        return 'Professional Assigned';
      case 2:
        return 'On The Way';
      case 3:
        return 'Arrived';
      default:
        return '';
    }
  }

  IconData getStepIcon(int step) {
    switch (step) {
      case 0:
        return Icons.check_circle;
      case 1:
        return Icons.account_circle;
      case 2:
        return Icons.directions_car;
      case 3:
        return Icons.location_on;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.offAllNamed('/bottomAppBar'),
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
        ),
        title: const Text(
          'Booking Confirmed',
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Status Card
            _buildStatusCard(),
            const SizedBox(height: 20),

            // Real-Time Tracking
            _buildTrackingCard(),
            const SizedBox(height: 20),

            // Timeline Steps
            _buildTimelineSteps(),
            const SizedBox(height: 20),

            // Professional Details (shown after assigned)
            if (currentStep >= 1) _buildProfessionalCard(),
            const SizedBox(height: 20),

            // Location Map Placeholder
            if (currentStep >= 2) _buildMapPlaceholder(),
            const SizedBox(height: 20),

            // Booking Details
            _buildBookingDetailsCard(),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF00BCD4),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking Confirmed!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BCD4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Booking ID: #BK${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Live Tracking',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ETA',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${eta.toStringAsFixed(0)} min',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Distance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${distance.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white30,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      getStepLabel(currentStep),
                      style: const TextStyle(
                        color: Color(0xFF00BCD4),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSteps() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Timeline',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: index < 3 ? 12 : 0),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index <= currentStep
                              ? const Color(0xFF00BCD4)
                              : Colors.grey.shade200,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          getStepIcon(index),
                          color:
                              index <= currentStep ? Colors.white : Colors.grey,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 50,
                        child: Text(
                          getStepLabel(index),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: index <= currentStep
                                ? Colors.black87
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCard() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Professional Assigned',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.person, color: Color(0xFF00BCD4), size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Expert Professional • 4.8 ⭐',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.call, color: Color(0xFF00BCD4), size: 20),
                    onPressed: () {},
                  ),
                  const Text(
                    'Call',
                    style: TextStyle(fontSize: 10, color: Color(0xFF00BCD4)),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat,
                        color: Color(0xFF00BCD4), size: 20),
                    onPressed: () {},
                  ),
                  const Text(
                    'Chat',
                    style: TextStyle(fontSize: 10, color: Color(0xFF00BCD4)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'Google Maps Integration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Real-time location tracking (Requires google_maps_flutter)',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Details',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Service', widget.bookingDetails['service'] ?? '-'),
          const SizedBox(height: 8),
          _buildDetailRow('Date', widget.bookingDetails['date'] ?? '-'),
          const SizedBox(height: 8),
          _buildDetailRow('Time', widget.bookingDetails['time'] ?? '-'),
          const SizedBox(height: 8),
          _buildDetailRow('Amount', '₹${widget.bookingDetails['price'] ?? '0'}'),
          const SizedBox(height: 8),
          _buildDetailRow('Payment', widget.bookingDetails['payment'] ?? '-'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    final displayValue = value?.toString() ?? '-';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          displayValue,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BCD4),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {},
          child: const Text(
            'Share Booking Details',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: Color(0xFF00BCD4)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => Get.offAllNamed('/bottomAppBar'),
          child: const Text(
            'Back To Home',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF00BCD4),
            ),
          ),
        ),
      ],
    );
  }
}
