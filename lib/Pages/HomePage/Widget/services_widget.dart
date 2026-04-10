import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/service_cart_controller.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';
import 'package:home_care/Pages/Services/all_services_page.dart';

class HealthCareServicesUi extends StatelessWidget {
  const HealthCareServicesUi({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceProfesController = Get.put(ServiceProfessionalsController());
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

    return Container(
      color: const Color(0xFFE0E7FF),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header with "See All" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Healthcare Services",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF312E81),
                ),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const AllServicesPage()),
                child: Row(
                  children: [
                    const Text(
                      'See All',
                      style: TextStyle(
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 13,
                      color: Color(0xFF4F46E5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 🔹 Horizontal scroll list (Quick Services)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: services.map((service) {
                return GestureDetector(
                  onTap: () {
                    final serviceId = service['id'] as String;
                    final serviceTitle = service['title'] as String;
                    final serviceIcon = service['icon'] as IconData;
                    final serviceGradient = service['gradient'] as List<Color>;
                    final serviceDescription =
                        service['description'] ??
                        'Professional healthcare service';
                    final servicePrice = service['price'] ?? 500.0;

                    // Navigate to service detail page
                    Get.to(
                      () => ServiceDetailPage(
                        serviceId: serviceId,
                        title: serviceTitle,
                        icon: serviceIcon,
                        gradient: serviceGradient,
                        description: serviceDescription as String,
                        price: servicePrice as double,
                      ),
                    );
                  },
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 8.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: service['gradient'] as List<Color>,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Icon(
                              service['icon'] as IconData,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            service['title'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF312E81),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class HealthcareCategoriesBar extends StatelessWidget {
//   const HealthcareCategoriesBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final categories = [
//       {'title': 'All', 'icon': Icons.apps},
//       {'title': 'Nursing', 'icon': Icons.safety_check},
//       {'title': 'Physiotherapy', 'icon': Icons.show_chart},
//       {'title': 'Elder Care', 'icon': Icons.favorite},
//       {'title': 'Mental Health', 'icon': Icons.psychology},
//       {'title': 'Checkups', 'icon': Icons.calendar_today},
//       {'title': 'Emergency', 'icon': Icons.warning},
//       {'title': 'Therapy', 'icon': Icons.self_improvement},
//       {'title': 'Baby Care', 'icon': Icons.child_care},
//       {'title': 'Lab Tests', 'icon': Icons.science},
//     ];

//     return SizedBox(
//       height: 90,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           final category = categories[index];
//           return Container(
//             width: 80,
//             margin: const EdgeInsets.only(right: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 5,
//                   offset: const Offset(0, 3),
//                 ),
//               ],
//             ),
//             child: InkWell(
//               borderRadius: BorderRadius.circular(16),
//               onTap: () {},
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CircleAvatar(
//                       backgroundColor: const Color(0xFFEEF2FF),
//                       radius: 22,
//                       child: Icon(
//                         category['icon'] as IconData,
//                         color: const Color(0xFF4F46E5),
//                         size: 24,
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       category['title'] as String,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF312E81),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
