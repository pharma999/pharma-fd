import 'package:flutter/material.dart';
import 'package:home_care/Controller/professnals_controller.dart';

class AvailableProfessionalsUi extends StatefulWidget {
  const AvailableProfessionalsUi({super.key});

  @override
  State<AvailableProfessionalsUi> createState() =>
      _AvailableProfessionalsUiState();
}

class _AvailableProfessionalsUiState extends State<AvailableProfessionalsUi> {
  bool showAll = false;

  final List<Map<String, dynamic>> professionals = [
    {
      'name': 'Nurse Sharma',
      'role': 'Senior Nurse',
      'distance': '2.5 km away',
      'rating': 4.8,
      'available': true,
    },
    {
      'name': 'Dr. Patel',
      'role': 'Physiotherapist',
      'distance': '3.2 km away',
      'rating': 4.6,
      'available': true,
    },
    {
      'name': 'Dr. Singh',
      'role': 'General Physician',
      'distance': '1.9 km away',
      'rating': 4.9,
      'available': false,
    },
    {
      'name': 'Nurse Riya',
      'role': 'Staff Nurse',
      'distance': '4.2 km away',
      'rating': 4.7,
      'available': true,
    },
    {
      'name': 'Dr. Mehta',
      'role': 'Dentist',
      'distance': '2.0 km away',
      'rating': 4.5,
      'available': true,
    },
    {
      'name': 'Dr. Kapoor',
      'role': 'Dermatologist',
      'distance': '5.0 km away',
      'rating': 4.4,
      'available': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // 🔹 Limit to 4 unless "See All" clicked
    final ProfessnalsController controller = ProfessnalsController();

    final visibleProfessionals = showAll
        ? professionals
        : professionals.take(4).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Available Professionals",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF312E81),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showAll = !showAll;
                  });
                },
                child: Row(
                  children: [
                    Text(
                      showAll ? "Show Less" : "See All",
                      style: const TextStyle(
                        color: Color(0xFF4F46E5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFF4F46E5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 🔹 Scrollable Professional List
          SizedBox(
            height: showAll ? 350 : 300, // set reasonable height
            child: ListView.builder(
              itemCount: visibleProfessionals.length,
              itemBuilder: (context, index) {
                final pro = visibleProfessionals[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile placeholder
                      GestureDetector(
                        onTap: () => controller.profilePage(),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3E8FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Info column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name + rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  pro['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF312E81),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFC107),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        pro['rating'].toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pro['role'],
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Color(0xFF4F46E5),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  pro['distance'],
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Availability + Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: pro['available']
                                          ? Colors.green
                                          : Colors.grey,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      pro['available']
                                          ? 'Available'
                                          : 'Unavailable',
                                      style: TextStyle(
                                        color: pro['available']
                                            ? Colors.green
                                            : Colors.grey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () => controller.bookNow(),
                                  style: TextButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFF4F46E5,
                                    ).withValues(alpha: 0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "Book Now",
                                    style: TextStyle(
                                      color: Color(0xFF4F46E5),
                                      fontWeight: FontWeight.bold,
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
