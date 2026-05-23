import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';
import 'package:home_care/Model/service_model.dart';
import 'package:home_care/Pages/Professionals/professional_detail_page.dart';

/// Dynamic professionals list — data from API via ServiceProfessionalsController.
class AvailableProfessionalsUi extends StatelessWidget {
  const AvailableProfessionalsUi({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ServiceProfessionalsController>();

    return Obx(() {
      if (ctrl.isLoading.value) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: List.generate(
                3, (_) => const _ProfessionalCardSkeleton()),
          ),
        );
      }

      final list = ctrl.filtered;

      if (list.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.person_search,
                    size: 52, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  ctrl.searchQuery.isNotEmpty
                      ? 'No results for "${ctrl.searchQuery.value}"'
                      : 'No professionals available',
                  style:
                      TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                if (ctrl.selectedCategoryId.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: ctrl.clearFilter,
                    child: const Text('Clear filter'),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: list.length,
        itemBuilder: (_, i) => _ProfessionalCard(pro: list[i]),
      );
    });
  }
}

// ── Professional Card ─────────────────────────────────────────────────────────

class _ProfessionalCard extends StatelessWidget {
  final ProfessionalModel pro;
  const _ProfessionalCard({required this.pro});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ProfessionalDetailPage(
            professionalId: pro.id,
            serviceId: pro.serviceId,
            name: pro.name,
            role: pro.experience,
            serviceName: pro.serviceName,
            rating: pro.rating,
            available: pro.isAvailable,
            yearsExperience: pro.yearsExperience,
            distance: pro.distance,
            estimatedDuration: pro.estimatedDuration,
            availableTimeStart: pro.availableTimeStart,
            availableTimeEnd: pro.availableTimeEnd,
            price: pro.price,
          )),
      child: Opacity(
        opacity: pro.isAvailable ? 1.0 : 0.55,
        child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: pro.isAvailable ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18),
          boxShadow: pro.isAvailable ? [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ] : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              _Avatar(name: pro.name, imageUrl: pro.profileImage),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(pro.name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1F36))),
                        ),
                        _RatingBadge(pro.rating),
                      ],
                    ),
                    const SizedBox(height: 3),
                    if (pro.experience.isNotEmpty)
                      Text(pro.experience,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(height: 8),
                    // Skills chips
                    if (pro.skills.isNotEmpty)
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: pro.skills
                            .take(3)
                            .map((s) => _SkillChip(s))
                            .toList(),
                      ),
                    const SizedBox(height: 10),
                    // Footer row
                    Row(
                      children: [
                        _AvailBadge(pro.isAvailable),
                        const Spacer(),
                        Text(
                          '₹${pro.price.toStringAsFixed(0)}/visit',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A56DB)),
                        ),
                        const SizedBox(width: 10),
                        _BookButton(
                          enabled: pro.isAvailable,
                          onTap: () => Get.to(() => ProfessionalDetailPage(
                                professionalId: pro.id,
                                serviceId: pro.serviceId,
                                name: pro.name,
                                role: pro.experience,
                                serviceName: pro.serviceName,
                                rating: pro.rating,
                                available: pro.isAvailable,
                                yearsExperience: pro.yearsExperience,
                                distance: pro.distance,
                                estimatedDuration: pro.estimatedDuration,
                                availableTimeStart: pro.availableTimeStart,
                                availableTimeEnd: pro.availableTimeEnd,
                                price: pro.price,
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final String name;
  final String imageUrl;
  const _Avatar({required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join()
        : 'P';
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A56DB), Color(0xFF6EE7F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _InitialsText(initials)))
          : _InitialsText(initials),
    );
  }
}

class _InitialsText extends StatelessWidget {
  final String text;
  const _InitialsText(this.text);

  @override
  Widget build(BuildContext context) => Center(
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
      );
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge(this.rating);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7E0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
            const SizedBox(width: 2),
            Text(rating.toStringAsFixed(1),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF92400E))),
          ],
        ),
      );
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip(this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF1A56DB),
                fontWeight: FontWeight.w600)),
      );
}

class _AvailBadge extends StatelessWidget {
  final bool available;
  const _AvailBadge(this.available);

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: available
                  ? const Color(0xFF10B981)
                  : Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 4),
          Text(available ? 'Available' : 'Unavailable',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: available
                      ? const Color(0xFF10B981)
                      : Colors.grey.shade500)),
        ],
      );
}

class _BookButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;
  const _BookButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: enabled
                ? const LinearGradient(
                    colors: [Color(0xFF1A56DB), Color(0xFF3B82F6)])
                : null,
            color: enabled ? null : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
            boxShadow: enabled
                ? [
                    BoxShadow(
                        color: const Color(0xFF1A56DB).withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3))
                  ]
                : null,
          ),
          child: Text('Book',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: enabled ? Colors.white : Colors.grey.shade500)),
        ),
      );
}

// ── Skeleton loader ───────────────────────────────────────────────────────────

class _ProfessionalCardSkeleton extends StatelessWidget {
  const _ProfessionalCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(
                    width: 80,
                    height: 10,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                        width: 60,
                        height: 22,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6))),
                    const SizedBox(width: 8),
                    Container(
                        width: 50,
                        height: 22,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
