import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';
import 'package:home_care/Pages/Professionals/professional_detail_page.dart';

class AvailableProfessionalsUi extends StatefulWidget {
  const AvailableProfessionalsUi({super.key});

  @override
  State<AvailableProfessionalsUi> createState() =>
      _AvailableProfessionalsUiState();
}

class _AvailableProfessionalsUiState extends State<AvailableProfessionalsUi> {
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceProfessionalsController());

    return Container(
      margin: const EdgeInsets.all(16),
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
          // Header with Clear Filter button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Quick Service Professionals",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF312E81),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        controller.selectedServiceTitle.value,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => controller.selectedService.value.isNotEmpty
                      ? GestureDetector(
                          onTap: () => controller.clearServiceSelection(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          // Professionals List
          Obx(() {
            final allProfessionals = controller.filteredProfessionals;

            if (allProfessionals.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 40,
                  horizontal: 16,
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No professionals available',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Limit professionals based on showAll
            final visibleProfessionals = showAll
                ? allProfessionals
                : allProfessionals.take(3).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleProfessionals.length,
              itemBuilder: (context, index) {
                final pro = visibleProfessionals[index];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Top Row: Avatar + Name + Rating
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Avatar
                            GestureDetector(
                              onTap: () => Get.to(
                                () => ProfessionalDetailPage(
                                  professionalId: pro.id,
                                  name: pro.name,
                                  role: pro.role,
                                  serviceName: pro.serviceName,
                                  rating: pro.rating,
                                  available: pro.available,
                                  yearsExperience: pro.yearsExperience,
                                  distance: pro.distance,
                                  estimatedDuration: pro.estimatedDuration,
                                  availableTimeStart: pro.availableTimeStart,
                                  availableTimeEnd: pro.availableTimeEnd,
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
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Info Column
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Name + Rating
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              pro.name,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF312E81),
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
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade50,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
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
                                              pro.rating.toString(),
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

                                  // Experience + Distance + Duration
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.work_outline,
                                        size: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${pro.yearsExperience} yrs exp',
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
                                        pro.distance,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue.shade400,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        Icons.schedule,
                                        size: 12,
                                        color: Colors.green.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${pro.estimatedDuration} min',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.green.shade600,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Same-Day Available Time Slots
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 12,
                                        color: Colors.orange.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Today: ${pro.availableTimeStart} - ${pro.availableTimeEnd}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.orange.shade700,
                                          fontWeight: FontWeight.w600,
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
                        Divider(color: Colors.grey.shade200, height: 1),
                        const SizedBox(height: 12),

                        // Service Specialization Badge
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
                              width: 1,
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

                        // Availability + Buttons Row
                        Row(
                          children: [
                            // Availability Badge
                            Icon(
                              Icons.check_circle,
                              color: pro.available ? Colors.green : Colors.grey,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pro.available ? 'Available Now' : 'Unavailable',
                              style: TextStyle(
                                color: pro.available
                                    ? Colors.green
                                    : Colors.grey,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),

                            // View Profile Button
                            TextButton(
                              onPressed: () => Get.to(
                                () => ProfessionalDetailPage(
                                  professionalId: pro.id,
                                  name: pro.name,
                                  role: pro.role,
                                  serviceName: pro.serviceName,
                                  rating: pro.rating,
                                  available: pro.available,
                                  yearsExperience: pro.yearsExperience,
                                  distance: pro.distance,
                                  estimatedDuration: pro.estimatedDuration,
                                  availableTimeStart: pro.availableTimeStart,
                                  availableTimeEnd: pro.availableTimeEnd,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              child: Text(
                                'View',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            // Book Now Button
                            ElevatedButton(
                              onPressed: pro.available
                                  ? () => Get.to(
                                      () => ProfessionalDetailPage(
                                        professionalId: pro.id,
                                        name: pro.name,
                                        role: pro.role,
                                        serviceName: pro.serviceName,
                                        rating: pro.rating,
                                        available: pro.available,
                                        yearsExperience: pro.yearsExperience,
                                        distance: pro.distance,
                                        estimatedDuration:
                                            pro.estimatedDuration,
                                        availableTimeStart:
                                            pro.availableTimeStart,
                                        availableTimeEnd: pro.availableTimeEnd,
                                      ),
                                    )
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
                                  borderRadius: BorderRadius.circular(8),
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
              },
            );
          }),

          // Show More / Show Less Button
          Obx(() {
            final totalProfessionals = controller.filteredProfessionals.length;
            if (totalProfessionals <= 3) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      showAll = !showAll;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF4F46E5),
                    side: const BorderSide(
                      color: Color(0xFF4F46E5),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        showAll
                            ? 'Show Less'
                            : 'Show All (${totalProfessionals - 3} more)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        showAll ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
