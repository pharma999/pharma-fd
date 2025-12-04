import 'package:flutter/material.dart';

class HealthCareServicesUi extends StatelessWidget {
  const HealthCareServicesUi({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      {
        'title': 'Nursing Care',
        'icon': Icons.safety_check,
        'gradient': [Color(0xFF4F46E5), Color(0xFF312E81)],
      },
      {
        'title': 'Physiotherapy',
        'icon': Icons.show_chart,
        'gradient': [Color(0xFF9333EA), Color(0xFFF43F5E)],
      },
      {
        'title': 'Elder Care',
        'icon': Icons.favorite,
        'gradient': [Color(0xFFFF512F), Color(0xFFDD2476)],
      },
      {
        'title': 'Mental Health',
        'icon': Icons.psychology,
        'gradient': [Color(0xFF10B981), Color(0xFF047857)],
      },
      {
        'title': 'Checkups',
        'icon': Icons.calendar_today,
        'gradient': [Color(0xFFF59E0B), Color(0xFFB45309)],
      },
      {
        'title': 'Emergency',
        'icon': Icons.warning,
        'gradient': [Color(0xFFE11D48), Color(0xFFBE123C)],
      },
      {
        'title': 'Therapy ',
        'icon': Icons.self_improvement,
        'gradient': [Color(0xFF2563EB), Color(0xFF1E3A8A)],
      },
      {
        'title': 'Baby Care',
        'icon': Icons.child_care,
        'gradient': [Color(0xFFFB923C), Color(0xFFF97316)],
      },
      {
        'title': 'Rehabilitation',
        'icon': Icons.health_and_safety,
        'gradient': [Color(0xFF16A34A), Color(0xFF065F46)],
      },
      {
        'title': 'Vaccination',
        'icon': Icons.vaccines,
        'gradient': [Color(0xFF0284C7), Color(0xFF0369A1)],
      },
      {
        'title': 'Lab Tests',
        'icon': Icons.science,
        'gradient': [Color(0xFF6366F1), Color(0xFF4338CA)],
      },
    ];

    return Container(
      color: const Color(0xFFE0E7FF),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header
          const Text(
            "Healthcare Services",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF312E81),
            ),
          ),
          const SizedBox(height: 16),

          // 🔹 Horizontal scroll list
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: services.map((service) {
                return Container(
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
