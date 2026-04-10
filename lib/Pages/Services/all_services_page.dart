import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/service_cart_controller.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Pages/Professionals/professionals_list_page.dart';
import 'package:home_care/Pages/Booking/booking_confirmation_page.dart';

class AllServicesPage extends StatelessWidget {
  const AllServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<ServiceCartController>();
    final profController = Get.find<ServiceProfessionalsController>();

    final services = [
      {
        'id': 'nursing_care',
        'title': 'Nursing Care',
        'icon': Icons.safety_check,
        'gradient': [const Color(0xFF4F46E5), const Color(0xFF312E81)],
        'description': 'Professional nursing care for patients at home',
        'price': 500.0,
      },
      {
        'id': 'physiotherapy',
        'title': 'Physiotherapy',
        'icon': Icons.show_chart,
        'gradient': [const Color(0xFF9333EA), const Color(0xFFF43F5E)],
        'description': 'Expert physiotherapy and rehabilitation services',
        'price': 600.0,
      },
      {
        'id': 'elder_care',
        'title': 'Elder Care',
        'icon': Icons.favorite,
        'gradient': [const Color(0xFFFF512F), const Color(0xFFDD2476)],
        'description': 'Comprehensive care services for elderly individuals',
        'price': 550.0,
      },
      {
        'id': 'mental_health',
        'title': 'Mental Health',
        'icon': Icons.psychology,
        'gradient': [const Color(0xFF10B981), const Color(0xFF047857)],
        'description': 'Counseling and mental health support services',
        'price': 700.0,
      },
      {
        'id': 'checkups',
        'title': 'Checkups',
        'icon': Icons.calendar_today,
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFB45309)],
        'description': 'Regular health checkups and consultations',
        'price': 400.0,
      },
      {
        'id': 'emergency',
        'title': 'Emergency',
        'icon': Icons.warning,
        'gradient': [const Color(0xFFE11D48), const Color(0xFFBE123C)],
        'description': '24/7 emergency medical response',
        'price': 1000.0,
      },
      {
        'id': 'therapy',
        'title': 'Therapy',
        'icon': Icons.self_improvement,
        'gradient': [const Color(0xFF2563EB), const Color(0xFF1E3A8A)],
        'description': 'Behavioral and occupational therapy',
        'price': 650.0,
      },
      {
        'id': 'baby_care',
        'title': 'Baby Care',
        'icon': Icons.child_care,
        'gradient': [const Color(0xFFFB923C), const Color(0xFFF97316)],
        'description': 'Expert baby care and pediatric services',
        'price': 450.0,
      },
      {
        'id': 'rehabilitation',
        'title': 'Rehabilitation',
        'icon': Icons.health_and_safety,
        'gradient': [const Color(0xFF16A34A), const Color(0xFF065F46)],
        'description': 'Post-surgery rehabilitation and recovery',
        'price': 750.0,
      },
      {
        'id': 'vaccination',
        'title': 'Vaccination',
        'icon': Icons.vaccines,
        'gradient': [const Color(0xFF0284C7), const Color(0xFF0369A1)],
        'description': 'Immunization and vaccination services',
        'price': 300.0,
      },
      {
        'id': 'lab_tests',
        'title': 'Lab Tests',
        'icon': Icons.science,
        'gradient': [const Color(0xFF6366F1), const Color(0xFF4338CA)],
        'description': 'Home-based laboratory testing services',
        'price': 350.0,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('All Healthcare Services'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF6BC4FF),
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          final service = services[index];
          final gradient = service['gradient'] as List<Color>;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon, Title, and Price
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Icon(
                          service['icon'] as IconData,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        service['title'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF312E81),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '₹${(service['price'] as double).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),

                  // Action Buttons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        height: 26,
                        child: OutlinedButton(
                          onPressed: () {
                            // Add to Cart logic
                            cartController.addService(
                              serviceId: service['id'] as String,
                              title: service['title'] as String,
                              icon: service['icon'] as IconData,
                              color: gradient.first,
                              price: service['price'] as double,
                            );
                            Get.snackbar(
                              'Added to Cart',
                              '${service['title']} added to cart',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green.shade600,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                            side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                          child: const Text(
                            'Add to Cart',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        width: double.infinity,
                        height: 26,
                        child: ElevatedButton(
                          onPressed: () {
                            // Book Now logic
                            final serviceTitle = service['title'] as String;
                            profController.selectService(
                              service['id'] as String,
                              serviceTitle,
                            );

                            // Navigate to service detail page
                            Get.to(
                              () => ServiceDetailPage(
                                serviceId: service['id'] as String,
                                title: service['title'] as String,
                                icon: service['icon'] as IconData,
                                gradient: gradient,
                                description:
                                    (service['description'] ??
                                            'Professional healthcare service')
                                        as String,
                                price: service['price'] as double,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Book Now',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Service Detail Page
class ServiceDetailPage extends StatefulWidget {
  final String serviceId;
  final String title;
  final IconData icon;
  final List<Color> gradient;
  final String description;
  final double price;

  const ServiceDetailPage({
    super.key,
    required this.serviceId,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.description,
    required this.price,
  });

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  bool isAdded = false;

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<ServiceCartController>();
    final profController = Get.find<ServiceProfessionalsController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header with gradient
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.gradient,
                  ),
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    size: 100,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
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
                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.currency_rupee,
                          color: Colors.amber,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.price.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'About this service',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF312E81),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200, width: 1),
                    ),
                    child: Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Benefits
                  const Text(
                    'Benefits',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF312E81),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBenefit('✓ Professional healthcare providers'),
                  _buildBenefit('✓ Flexible scheduling'),
                  _buildBenefit('✓ Home-based services'),
                  _buildBenefit('✓ Affordable pricing'),
                  _buildBenefit('✓ Emergency support available'),
                  const SizedBox(height: 24),

                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAdded
                            ? Colors.green
                            : const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        if (!isAdded) {
                          // Add to cart
                          cartController.addService(
                            serviceId: widget.serviceId,
                            title: widget.title,
                            icon: widget.icon,
                            color: widget.gradient[0],
                            price: widget.price,
                          );

                          // Filter professionals for this service
                          profController.selectService(
                            widget.serviceId,
                            widget.title,
                          );

                          LoggerService.success(
                            'Added ${widget.title} to cart',
                          );

                          setState(() {
                            isAdded = true;
                          });

                          Get.snackbar(
                            '✓ Added to Cart',
                            '${widget.title} has been added. Showing available professionals.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            duration: const Duration(seconds: 2),
                          );

                          Future.delayed(const Duration(seconds: 2), () {
                            Get.back();
                          });
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isAdded ? Icons.check_circle : Icons.shopping_cart,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isAdded ? 'Added to Cart!' : 'Add to Cart',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () {
                        // Select service and navigate to booking confirmation
                        profController.selectService(
                          widget.serviceId,
                          widget.title,
                        );

                        LoggerService.success('Booking ${widget.title}');

                        // Navigate directly to BookingConfirmationPage with booking details
                        Get.to(
                          () => BookingConfirmationPage(
                            serviceName: widget.title,
                            serviceIcon: widget.icon,
                            serviceColor: widget.gradient[0],
                            bookingDetails: {
                              'service': widget.title,
                              'price': widget.price.toStringAsFixed(0),
                              'date': 'Today',
                              'time': 'Select from professional availability',
                              'payment': 'Online Payment',
                            },
                          ),
                        );
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Book Appointment',
                            style: TextStyle(
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

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }
}
