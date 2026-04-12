// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:home_care/Controller/service_cart_controller.dart';
// import 'package:home_care/Controller/service_professionals_controller.dart';
// import 'package:home_care/Helper/logger_service.dart';
// import 'package:home_care/Pages/Professionals/professionals_list_page.dart';
// import 'package:home_care/Pages/Booking/booking_confirmation_page.dart';

// class AllServicesPage extends StatelessWidget {
//   const AllServicesPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final cartController = Get.find<ServiceCartController>();
//     final profController = Get.find<ServiceProfessionalsController>();

//     final services = [
//       {
//         'id': 'nursing_care',
//         'title': 'Nursing Care',
//         'icon': Icons.safety_check,
//         'gradient': [const Color(0xFF4F46E5), const Color(0xFF312E81)],
//         'description': 'Professional nursing care for patients at home',
//         'price': 500.0,
//       },
//       {
//         'id': 'physiotherapy',
//         'title': 'Physiotherapy',
//         'icon': Icons.show_chart,
//         'gradient': [const Color(0xFF9333EA), const Color(0xFFF43F5E)],
//         'description': 'Expert physiotherapy and rehabilitation services',
//         'price': 600.0,
//       },
//       {
//         'id': 'elder_care',
//         'title': 'Elder Care',
//         'icon': Icons.favorite,
//         'gradient': [const Color(0xFFFF512F), const Color(0xFFDD2476)],
//         'description': 'Comprehensive care services for elderly individuals',
//         'price': 550.0,
//       },
//       {
//         'id': 'mental_health',
//         'title': 'Mental Health',
//         'icon': Icons.psychology,
//         'gradient': [const Color(0xFF10B981), const Color(0xFF047857)],
//         'description': 'Counseling and mental health support services',
//         'price': 700.0,
//       },
//       {
//         'id': 'checkups',
//         'title': 'Checkups',
//         'icon': Icons.calendar_today,
//         'gradient': [const Color(0xFFF59E0B), const Color(0xFFB45309)],
//         'description': 'Regular health checkups and consultations',
//         'price': 400.0,
//       },
//       {
//         'id': 'emergency',
//         'title': 'Emergency',
//         'icon': Icons.warning,
//         'gradient': [const Color(0xFFE11D48), const Color(0xFFBE123C)],
//         'description': '24/7 emergency medical response',
//         'price': 1000.0,
//       },
//       {
//         'id': 'therapy',
//         'title': 'Therapy',
//         'icon': Icons.self_improvement,
//         'gradient': [const Color(0xFF2563EB), const Color(0xFF1E3A8A)],
//         'description': 'Behavioral and occupational therapy',
//         'price': 650.0,
//       },
//       {
//         'id': 'baby_care',
//         'title': 'Baby Care',
//         'icon': Icons.child_care,
//         'gradient': [const Color(0xFFFB923C), const Color(0xFFF97316)],
//         'description': 'Expert baby care and pediatric services',
//         'price': 450.0,
//       },
//       {
//         'id': 'rehabilitation',
//         'title': 'Rehabilitation',
//         'icon': Icons.health_and_safety,
//         'gradient': [const Color(0xFF16A34A), const Color(0xFF065F46)],
//         'description': 'Post-surgery rehabilitation and recovery',
//         'price': 750.0,
//       },
//       {
//         'id': 'vaccination',
//         'title': 'Vaccination',
//         'icon': Icons.vaccines,
//         'gradient': [const Color(0xFF0284C7), const Color(0xFF0369A1)],
//         'description': 'Immunization and vaccination services',
//         'price': 300.0,
//       },
//       {
//         'id': 'lab_tests',
//         'title': 'Lab Tests',
//         'icon': Icons.science,
//         'gradient': [const Color(0xFF6366F1), const Color(0xFF4338CA)],
//         'description': 'Home-based laboratory testing services',
//         'price': 350.0,
//       },
//     ];

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: const Text('All Healthcare Services'),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: const Color(0xFF6BC4FF),
//         foregroundColor: Colors.white,
//       ),
//       body: GridView.builder(
//         padding: const EdgeInsets.all(16),
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 1.0,
//           crossAxisSpacing: 16,
//           mainAxisSpacing: 16,
//         ),
//         itemCount: services.length,
//         itemBuilder: (context, index) {
//           final service = services[index];
//           final gradient = service['gradient'] as List<Color>;

//           return Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withValues(alpha: 0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Icon, Title, and Price
//                   Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Container(
//                         width: 55,
//                         height: 55,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           gradient: LinearGradient(
//                             colors: gradient,
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                         ),
//                         child: Icon(
//                           service['icon'] as IconData,
//                           size: 28,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         service['title'] as String,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF312E81),
//                         ),
//                       ),
//                       const SizedBox(height: 3),
//                       Text(
//                         '₹${(service['price'] as double).toStringAsFixed(0)}',
//                         style: TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green.shade600,
//                         ),
//                       ),
//                     ],
//                   ),

//                   // Action Buttons
//                   Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const SizedBox(height: 4),
//                       SizedBox(
//                         width: double.infinity,
//                         height: 26,
//                         child: OutlinedButton(
//                           onPressed: () {
//                             // Add to Cart logic
//                             cartController.addService(
//                               serviceId: service['id'] as String,
//                               title: service['title'] as String,
//                               icon: service['icon'] as IconData,
//                               color: gradient.first,
//                               price: service['price'] as double,
//                             );
//                             Get.snackbar(
//                               'Added to Cart',
//                               '${service['title']} added to cart',
//                               snackPosition: SnackPosition.BOTTOM,
//                               backgroundColor: Colors.green.shade600,
//                               colorText: Colors.white,
//                               duration: const Duration(seconds: 2),
//                             );
//                           },
//                           style: OutlinedButton.styleFrom(
//                             foregroundColor: Colors.grey.shade700,
//                             side: BorderSide(
//                               color: Colors.grey.shade300,
//                               width: 1,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             padding: const EdgeInsets.symmetric(vertical: 0),
//                           ),
//                           child: const Text(
//                             'Add to Cart',
//                             style: TextStyle(
//                               fontSize: 8,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       SizedBox(
//                         width: double.infinity,
//                         height: 26,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             // Book Now logic
//                             final serviceTitle = service['title'] as String;
//                             profController.selectService(
//                               service['id'] as String,
//                               serviceTitle,
//                             );

//                             // Navigate to service detail page
//                             Get.to(
//                               () => ServiceDetailPage(
//                                 serviceId: service['id'] as String,
//                                 title: service['title'] as String,
//                                 icon: service['icon'] as IconData,
//                                 gradient: gradient,
//                                 description:
//                                     (service['description'] ??
//                                             'Professional healthcare service')
//                                         as String,
//                                 price: service['price'] as double,
//                               ),
//                             );
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF4F46E5),
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             padding: const EdgeInsets.symmetric(vertical: 0),
//                             elevation: 0,
//                           ),
//                           child: const Text(
//                             'Book Now',
//                             style: TextStyle(
//                               fontSize: 8,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// /// Service Detail Page
// class ServiceDetailPage extends StatefulWidget {
//   final String serviceId;
//   final String title;
//   final IconData icon;
//   final List<Color> gradient;
//   final String description;
//   final double price;

//   const ServiceDetailPage({
//     super.key,
//     required this.serviceId,
//     required this.title,
//     required this.icon,
//     required this.gradient,
//     required this.description,
//     required this.price,
//   });

//   @override
//   State<ServiceDetailPage> createState() => _ServiceDetailPageState();
// }

// class _ServiceDetailPageState extends State<ServiceDetailPage> {
//   bool isAdded = false;

//   @override
//   Widget build(BuildContext context) {
//     final cartController = Get.find<ServiceCartController>();
//     final profController = Get.find<ServiceProfessionalsController>();

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: CustomScrollView(
//         slivers: [
//           // Header with gradient
//           SliverAppBar(
//             expandedHeight: 280,
//             pinned: true,
//             flexibleSpace: FlexibleSpaceBar(
//               title: Text(
//                 widget.title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               background: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: widget.gradient,
//                   ),
//                 ),
//                 child: Center(
//                   child: Icon(
//                     widget.icon,
//                     size: 100,
//                     color: Colors.white.withValues(alpha: 0.9),
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           // Content
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Price
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 8,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.amber.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.amber.shade200),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(
//                           Icons.currency_rupee,
//                           color: Colors.amber,
//                           size: 18,
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           widget.price.toStringAsFixed(0),
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.amber,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Description
//                   const Text(
//                     'About this service',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF312E81),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.blue.shade200, width: 1),
//                     ),
//                     child: Text(
//                       widget.description,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Colors.black87,
//                         height: 1.6,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),

//                   // Benefits
//                   const Text(
//                     'Benefits',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF312E81),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   _buildBenefit('✓ Professional healthcare providers'),
//                   _buildBenefit('✓ Flexible scheduling'),
//                   _buildBenefit('✓ Home-based services'),
//                   _buildBenefit('✓ Affordable pricing'),
//                   _buildBenefit('✓ Emergency support available'),
//                   const SizedBox(height: 24),

//                   // Add to Cart Button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: isAdded
//                             ? Colors.green
//                             : const Color(0xFF4F46E5),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 4,
//                       ),
//                       onPressed: () {
//                         if (!isAdded) {
//                           // Add to cart
//                           cartController.addService(
//                             serviceId: widget.serviceId,
//                             title: widget.title,
//                             icon: widget.icon,
//                             color: widget.gradient[0],
//                             price: widget.price,
//                           );

//                           // Filter professionals for this service
//                           profController.selectService(
//                             widget.serviceId,
//                             widget.title,
//                           );

//                           LoggerService.success(
//                             'Added ${widget.title} to cart',
//                           );

//                           setState(() {
//                             isAdded = true;
//                           });

//                           Get.snackbar(
//                             '✓ Added to Cart',
//                             '${widget.title} has been added. Showing available professionals.',
//                             snackPosition: SnackPosition.BOTTOM,
//                             backgroundColor: Colors.green,
//                             colorText: Colors.white,
//                             duration: const Duration(seconds: 2),
//                           );

//                           Future.delayed(const Duration(seconds: 2), () {
//                             Get.back();
//                           });
//                         }
//                       },
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             isAdded ? Icons.check_circle : Icons.shopping_cart,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             isAdded ? 'Added to Cart!' : 'Add to Cart',
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   // Book Now Button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF10B981),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 4,
//                       ),
//                       onPressed: () {
//                         // Select service and navigate to booking confirmation
//                         profController.selectService(
//                           widget.serviceId,
//                           widget.title,
//                         );

//                         LoggerService.success('Booking ${widget.title}');

//                         // Navigate directly to BookingConfirmationPage with booking details
//                         Get.to(
//                           () => BookingConfirmationPage(
//                             serviceName: widget.title,
//                             serviceIcon: widget.icon,
//                             serviceColor: widget.gradient[0],
//                             bookingDetails: {
//                               'service': widget.title,
//                               'price': widget.price.toStringAsFixed(0),
//                               'date': 'Today',
//                               'time': 'Select from professional availability',
//                               'payment': 'Online Payment',
//                             },
//                           ),
//                         );
//                       },
//                       child: const Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.calendar_today, size: 20),
//                           SizedBox(width: 8),
//                           Text(
//                             'Book Appointment',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBenefit(String text) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Text(
//         text,
//         style: const TextStyle(fontSize: 13, color: Colors.black87),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/service_cart_controller.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Pages/Booking/booking_confirmation_page.dart';
import 'package:home_care/Pages/Professionals/professional_detail_page.dart';

class AllServicesPage extends StatelessWidget {
  const AllServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ServiceCartController cartController =
        Get.find<ServiceCartController>();
    final ServiceProfessionalsController profController =
        Get.find<ServiceProfessionalsController>();

    final List<Map<String, dynamic>> services = [
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
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text(
          'All Healthcare Services',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF6BC4FF),
        foregroundColor: Colors.white,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (context, index) {
          final service = services[index];
          final List<Color> gradient = service['gradient'] as List<Color>;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
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
                  const SizedBox(height: 10),
                  Text(
                    service['title'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF312E81),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${(service['price'] as double).toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service['description'] as String,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: OutlinedButton(
                            onPressed: () {
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
                                margin: const EdgeInsets.all(12),
                                borderRadius: 10,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF4F46E5),
                              side: BorderSide(color: Colors.grey.shade300),
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Add to Cart',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () {
                              profController.selectService(
                                service['id'] as String,
                                service['title'] as String,
                              );

                              Get.to(
                                () => ServiceDetailPage(
                                  serviceId: service['id'] as String,
                                  title: service['title'] as String,
                                  icon: service['icon'] as IconData,
                                  gradient: gradient,
                                  description: service['description'] as String,
                                  price: service['price'] as double,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4F46E5),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Book Now',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
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
  bool showAllProfessionals = false;

  late final ServiceCartController cartController;
  late final ServiceProfessionalsController profController;

  @override
  void initState() {
    super.initState();

    cartController = Get.find<ServiceCartController>();

    if (Get.isRegistered<ServiceProfessionalsController>()) {
      profController = Get.find<ServiceProfessionalsController>();
    } else {
      profController = Get.put(ServiceProfessionalsController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      profController.selectService(widget.serviceId, widget.title);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: widget.gradient.first,
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
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const Text(
                    'Available Professionals',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF312E81),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    final allProfessionals =
                        profController.filteredProfessionals;

                    if (allProfessionals.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 30,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person_off,
                              size: 48,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No professionals available for ${widget.title}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final visibleProfessionals = showAllProfessionals
                        ? allProfessionals
                        : allProfessionals.take(3).toList();

                    return Column(
                      children: [
                        ...visibleProfessionals.map((pro) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () => Get.to(
                                          () => ProfessionalDetailPage(
                                            professionalId: pro.id,
                                            name: pro.name,
                                            role: pro.role,
                                            serviceName: pro.serviceName,
                                            rating: pro.rating,
                                            available: pro.available,
                                            yearsExperience:
                                                pro.yearsExperience,
                                            distance: pro.distance,
                                            estimatedDuration:
                                                pro.estimatedDuration,
                                            availableTimeStart:
                                                pro.availableTimeStart,
                                            availableTimeEnd:
                                                pro.availableTimeEnd,
                                          ),
                                        ),
                                        child: Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.blue.shade400,
                                                Colors.indigo.shade600,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        pro.name,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color(
                                                            0xFF312E81,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        pro.role,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      const Icon(
                                                        Icons.star_rounded,
                                                        color: Colors.amber,
                                                        size: 14,
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        pro.rating.toString(),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 12,
                                              runSpacing: 8,
                                              children: [
                                                _miniInfo(
                                                  Icons.work_outline,
                                                  '${pro.yearsExperience} yrs exp',
                                                  Colors.grey.shade600,
                                                ),
                                                _miniInfo(
                                                  Icons.location_on_outlined,
                                                  pro.distance,
                                                  Colors.blue.shade400,
                                                ),
                                                _miniInfo(
                                                  Icons.schedule,
                                                  '${pro.estimatedDuration} min',
                                                  Colors.green.shade600,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 12,
                                                  color: Colors.orange.shade600,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'Today: ${pro.availableTimeStart} - ${pro.availableTimeEnd}',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors
                                                          .orange
                                                          .shade700,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
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
                                  Divider(
                                    color: Colors.grey.shade200,
                                    height: 1,
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.blue.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.medical_services,
                                          size: 16,
                                          color: Colors.blue.shade600,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Specializes in: ${pro.serviceName}',
                                            style: TextStyle(
                                              color: Colors.blue.shade700,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: pro.available
                                            ? Colors.green
                                            : Colors.grey,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        pro.available
                                            ? 'Available Now'
                                            : 'Unavailable',
                                        style: TextStyle(
                                          color: pro.available
                                              ? Colors.green
                                              : Colors.grey,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () {
                                          Get.to(
                                            () => ProfessionalDetailPage(
                                              professionalId: pro.id,
                                              name: pro.name,
                                              role: pro.role,
                                              serviceName: pro.serviceName,
                                              rating: pro.rating,
                                              available: pro.available,
                                              yearsExperience:
                                                  pro.yearsExperience,
                                              distance: pro.distance,
                                              estimatedDuration:
                                                  pro.estimatedDuration,
                                              availableTimeStart:
                                                  pro.availableTimeStart,
                                              availableTimeEnd:
                                                  pro.availableTimeEnd,
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'View',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: pro.available
                                            ? () {
                                                Get.to(
                                                  () => ProfessionalDetailPage(
                                                    professionalId: pro.id,
                                                    name: pro.name,
                                                    role: pro.role,
                                                    serviceName:
                                                        pro.serviceName,
                                                    rating: pro.rating,
                                                    available: pro.available,
                                                    yearsExperience:
                                                        pro.yearsExperience,
                                                    distance: pro.distance,
                                                    estimatedDuration:
                                                        pro.estimatedDuration,
                                                    availableTimeStart:
                                                        pro.availableTimeStart,
                                                    availableTimeEnd:
                                                        pro.availableTimeEnd,
                                                  ),
                                                );
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: pro.available
                                              ? Colors.blue.shade600
                                              : Colors.grey.shade300,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Book Now',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        if (allProfessionals.length > 3)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  showAllProfessionals = !showAllProfessionals;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF4F46E5),
                                side: const BorderSide(
                                  color: Color(0xFF4F46E5),
                                  width: 1.5,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    showAllProfessionals
                                        ? 'Show Less'
                                        : 'Show All (${allProfessionals.length - 3} more)',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    showAllProfessionals
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                  const SizedBox(height: 24),
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
                        if (isAdded) return;

                        cartController.addService(
                          serviceId: widget.serviceId,
                          title: widget.title,
                          icon: widget.icon,
                          color: widget.gradient.first,
                          price: widget.price,
                        );

                        LoggerService.success('Added ${widget.title} to cart');

                        setState(() {
                          isAdded = true;
                        });

                        Get.snackbar(
                          '✓ Added to Cart',
                          '${widget.title} has been added.',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2),
                        );
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
                        LoggerService.success('Booking ${widget.title}');
                        Get.to(
                          () => BookingConfirmationPage(
                            serviceName: widget.title,
                            serviceIcon: widget.icon,
                            serviceColor: widget.gradient.first,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
