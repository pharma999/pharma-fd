import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';
import 'package:home_care/Pages/Professionals/professional_detail_page.dart';

class ProfessionalsListPage extends StatelessWidget {
  final String serviceId;
  final String serviceTitle;

  const ProfessionalsListPage({
    super.key,
    required this.serviceId,
    required this.serviceTitle,
  });

  @override
  Widget build(BuildContext context) {
    final profController = Get.find<ServiceProfessionalsController>();

    // Filter professionals for this service on page load
    profController.selectService(serviceId, serviceTitle);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(serviceTitle),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF6BC4FF),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final filteredProfessionals = profController.filteredProfessionals;

        if (filteredProfessionals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No professionals available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'for $serviceTitle',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: filteredProfessionals.length,
          itemBuilder: (context, index) {
            final professional = filteredProfessionals[index];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: InkWell(
                onTap: () {
                  Get.to(
                    () => ProfessionalDetailPage(
                      professionalId: professional.id,
                      name: professional.name,
                      role: professional.role,
                      serviceName: professional.serviceName,
                      rating: professional.rating,
                      available: professional.available,
                      yearsExperience: professional.yearsExperience,
                      distance: professional.distance,
                      estimatedDuration: professional.estimatedDuration,
                      availableTimeStart: professional.availableTimeStart,
                      availableTimeEnd: professional.availableTimeEnd,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Professional Header
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.indigo.shade600,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 35,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Professional Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  professional.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF312E81),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  professional.role,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: Colors.amber.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${professional.rating} (${professional.yearsExperience}y exp)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: professional.available
                                  ? Colors.green.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: professional.available
                                    ? Colors.green.shade200
                                    : Colors.red.shade200,
                              ),
                            ),
                            child: Text(
                              professional.available
                                  ? 'Available'
                                  : 'Unavailable',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: professional.available
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Distance and Time Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                professional.distance,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_outlined,
                                size: 16,
                                color: Colors.orange.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Today: ${professional.availableTimeStart}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 16,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${professional.estimatedDuration} min consultation',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
