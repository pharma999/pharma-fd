import 'package:flutter/material.dart';

class HealthCareServicesUi extends StatefulWidget {
  const HealthCareServicesUi({super.key});

  @override
  State<HealthCareServicesUi> createState() => _HealthCareServicesUiState();
}

class _HealthCareServicesUiState extends State<HealthCareServicesUi> {
  bool showAll = false;

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
        'title': 'Therapy Support',
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

    // ✅ Limit to 6 if not showing all
    final visibleServices = showAll ? services : services.take(6).toList();

    return Container(
      color: const Color(0xFFE0E7FF),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header Row
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
                onTap: () {
                  setState(() => showAll = !showAll);
                },
                child: Row(
                  children: [
                    Text(
                      showAll ? "Show Less" : "View All",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      showAll
                          ? Icons.keyboard_arrow_up
                          : Icons.arrow_forward_ios,
                      color: const Color(0xFF4F46E5),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 🔹 Grid with optional scrolling
          SizedBox(
            height: showAll
                ? 300
                : null, // ⬅ Limit height only in expanded mode
            child: GridView.builder(
              shrinkWrap: !showAll, // ✅ Only let it expand when collapsed
              physics: showAll
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.9,
              ),
              itemCount: visibleServices.length,
              itemBuilder: (context, index) {
                final service = visibleServices[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
