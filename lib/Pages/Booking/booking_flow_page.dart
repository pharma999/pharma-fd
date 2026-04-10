import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Pages/Booking/booking_confirmation_page.dart';

class BookingFlowPage extends StatefulWidget {
  final String serviceName;
  final IconData serviceIcon;
  final Color serviceColor;

  const BookingFlowPage({
    super.key,
    this.serviceName = 'Service',
    this.serviceIcon = Icons.home,
    this.serviceColor = const Color(0xFF00BCD4),
  });

  @override
  State<BookingFlowPage> createState() => _BookingFlowPageState();
}

class _BookingFlowPageState extends State<BookingFlowPage> {
  int currentStep = 0;
  final PageController pageController = PageController();

  // Form Controllers
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String? selectedPaymentMethod;

  @override
  void dispose() {
    pageController.dispose();
    dateController.dispose();
    timeController.dispose();
    locationController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void nextStep() {
    if (currentStep < 3) {
      setState(() => currentStep++);
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void confirmBooking() {
    Get.to(
      () => BookingConfirmationPage(
        serviceName: widget.serviceName,
        serviceIcon: widget.serviceIcon,
        serviceColor: widget.serviceColor,
        bookingDetails: {
          'date': dateController.text.isNotEmpty ? dateController.text : '-',
          'time': timeController.text.isNotEmpty ? timeController.text : '-',
          'location': locationController.text.isNotEmpty
              ? locationController.text
              : '-',
          'notes': notesController.text,
          'payment': selectedPaymentMethod ?? '-',
        },
      ),
    );
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
        title: const Text(
          'Book Service',
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
          // Progress Indicator
          _buildProgressIndicator(),
          const SizedBox(height: 24),

          // Page Content
          Expanded(
            child: PageView(
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildServiceDetailsStep(),
                _buildDateTimeStep(),
                _buildLocationStep(),
                _buildPaymentStep(),
              ],
            ),
          ),

          // Navigation Buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index <= currentStep
                        ? const Color(0xFF00BCD4)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${currentStep + 1} of 4',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.serviceColor.withValues(alpha: 0.1),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      widget.serviceIcon,
                      color: widget.serviceColor,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.serviceName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Professional Service',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.serviceColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '₹500 - ₹1000',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: widget.serviceColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'About Service',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Professional ${widget.serviceName.toLowerCase()} service at your doorstep. Experienced professionals with verified credentials.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDateTimeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Date & Time',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTextField('Select Date', dateController, Icons.calendar_today),
          const SizedBox(height: 16),
          _buildTextField('Select Time', timeController, Icons.access_time),
          const SizedBox(height: 16),
          const Text(
            'Available Time Slots',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['9:00 AM', '11:00 AM', '2:00 PM', '4:00 PM', '6:00 PM']
                .map(
                  (time) => GestureDetector(
                    onTap: () => setState(() => timeController.text = time),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: timeController.text == time
                            ? const Color(0xFF00BCD4)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: timeController.text == time
                              ? const Color(0xFF00BCD4)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(
                          color: timeController.text == time
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Location',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Enter Your Address',
            locationController,
            Icons.location_on,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            'Additional Notes (Optional)',
            notesController,
            Icons.note,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'We will track your professional in real-time and send you updates.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Method',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPaymentOption('Credit/Debit Card', 'card'),
          const SizedBox(height: 12),
          _buildPaymentOption('UPI (Google Pay, PhonePe)', 'upi'),
          const SizedBox(height: 12),
          _buildPaymentOption('Wallet', 'wallet'),
          const SizedBox(height: 12),
          _buildPaymentOption('Net Banking', 'netbanking'),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFF00BCD4).withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Billing Summary',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Service Fee'),
                      Text(
                        '₹500',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Booking Fee'),
                      Text(
                        '₹50',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '₹550',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF00BCD4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(String title, String value) {
    return GestureDetector(
      onTap: () => setState(() => selectedPaymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedPaymentMethod == value
                ? const Color(0xFF00BCD4)
                : Colors.grey.shade300,
            width: selectedPaymentMethod == value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: selectedPaymentMethod == value
              ? const Color(0xFF00BCD4).withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedPaymentMethod == value
                      ? const Color(0xFF00BCD4)
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: selectedPaymentMethod == value
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF00BCD4),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF00BCD4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: previousStep,
                child: const Text(
                  'Previous',
                  style: TextStyle(
                    color: Color(0xFF00BCD4),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: currentStep < 3 ? nextStep : confirmBooking,
              child: Text(
                currentStep < 3 ? 'Next' : 'Confirm Booking',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
