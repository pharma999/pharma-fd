import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Controller/service_controller.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';
import 'package:home_care/Model/service_model.dart';
import 'package:home_care/Pages/Services/all_services_page.dart';
import 'package:home_care/Pages/Services/service_detail_page.dart';

/// Dynamic service categories + services fetched from the backend.
/// Categories are created by super-admin; services are managed by admin.
class HealthCareServicesUi extends StatefulWidget {
  const HealthCareServicesUi({super.key});

  @override
  State<HealthCareServicesUi> createState() => _HealthCareServicesUiState();
}

class _HealthCareServicesUiState extends State<HealthCareServicesUi> {
  final ServiceController _ctrl = Get.find<ServiceController>();
  final ServiceProfessionalsController _proCtrl =
      Get.find<ServiceProfessionalsController>();

  String? _selectedCategoryId;

  // Icon mapping for categories by name keyword
  static IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('nurs')) return Icons.health_and_safety;
    if (n.contains('physio') || n.contains('rehab')) return Icons.accessibility_new;
    if (n.contains('elder') || n.contains('senior')) return Icons.elderly;
    if (n.contains('mental') || n.contains('psych')) return Icons.psychology;
    if (n.contains('check') || n.contains('consul')) return Icons.medical_services;
    if (n.contains('emergency') || n.contains('sos')) return Icons.emergency;
    if (n.contains('therap')) return Icons.self_improvement;
    if (n.contains('baby') || n.contains('child') || n.contains('pedi')) return Icons.child_care;
    if (n.contains('lab') || n.contains('test')) return Icons.science;
    if (n.contains('vaccin') || n.contains('immun')) return Icons.vaccines;
    if (n.contains('diet') || n.contains('nutri')) return Icons.restaurant_menu;
    if (n.contains('dental')) return Icons.sentiment_satisfied;
    if (n.contains('cardio') || n.contains('heart')) return Icons.favorite;
    if (n.contains('eye') || n.contains('ophthal')) return Icons.remove_red_eye;
    return Icons.local_hospital;
  }

  // Gradient palette — cycles through categories
  static const _gradients = [
    [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
    [Color(0xFFEF4444), Color(0xFFEC4899)],
    [Color(0xFF10B981), Color(0xFF059669)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    [Color(0xFF14B8A6), Color(0xFF0D9488)],
    [Color(0xFFF97316), Color(0xFFEF4444)],
    [Color(0xFF6366F1), Color(0xFF4338CA)],
  ];

  List<Color> _gradientFor(int idx) {
    final g = _gradients[idx % _gradients.length];
    return g;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Healthcare Services',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F36))),
              GestureDetector(
                onTap: () => Get.to(() => const AllServicesPage()),
                child: Row(children: const [
                  Text('See all',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1A56DB),
                          fontWeight: FontWeight.w600)),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios,
                      size: 11, color: Color(0xFF1A56DB)),
                ]),
              ),
            ],
          ),
        ),

        // ── Category chips ──────────────────────────────────────────────
        Obx(() {
          if (_ctrl.isLoadingCategories.value) {
            return const SizedBox(
              height: 44,
              child: Center(
                  child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            );
          }
          if (_ctrl.categories.isEmpty) {
            return const SizedBox.shrink();
          }
          return SizedBox(
            height: 36,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _ctrl.categories.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) {
                  return _CategoryChip(
                    label: 'All',
                    isSelected: _selectedCategoryId == null,
                    onTap: () {
                      setState(() => _selectedCategoryId = null);
                      _ctrl.fetchAllServices();
                      _proCtrl.clearFilter();
                    },
                  );
                }
                final cat = _ctrl.categories[i - 1];
                return _CategoryChip(
                  label: cat.name,
                  isSelected: _selectedCategoryId == cat.id,
                  onTap: () {
                    setState(() => _selectedCategoryId = cat.id);
                    _ctrl.fetchCategoryServices(cat.id);
                    _proCtrl.filterByCategory(cat.id, cat.name);
                  },
                );
              },
            ),
          );
        }),

        const SizedBox(height: 16),

        // ── Services horizontal scroll ──────────────────────────────────
        Obx(() {
          if (_ctrl.isLoadingServices.value) {
            return SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => _ServiceCardSkeleton(),
              ),
            );
          }

          final list = _ctrl.services.isNotEmpty
              ? _ctrl.services
              : <ServiceModel>[];

          if (list.isEmpty) {
            final err = _ctrl.errorMessage.value;
            return _buildEmpty(
              err.isNotEmpty ? err : 'No services available',
              err.isNotEmpty ? Icons.wifi_off_rounded : Icons.medical_services_outlined,
              onRetry: err.isNotEmpty ? _ctrl.fetchAllServices : null,
            );
          }

          return SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final svc = list[i];
                return _ServiceCard(
                  service: svc,
                  gradient: _gradientFor(i),
                  icon: _iconFor(svc.name),
                  onTap: () {
                    _proCtrl.selectService(svc.id, svc.name);
                    Get.to(() => ServiceInfoPage(
                          service: svc,
                          gradient: _gradientFor(i),
                          icon: _iconFor(svc.name),
                        ));
                  },
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmpty(String msg, IconData icon, {VoidCallback? onRetry}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(msg,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry', style: TextStyle(fontSize: 12)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Category Chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryChip(
      {required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1A56DB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: isSelected
                    ? const Color(0xFF1A56DB).withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFF4B5563))),
      ),
    );
  }
}

// ── Service Card ──────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onTap;
  const _ServiceCard(
      {required this.service,
      required this.gradient,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(service.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1F36))),
            ),
            const SizedBox(height: 4),
            Text('₹${service.basePrice.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF1A56DB),
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton loader ───────────────────────────────────────────────────────────

class _ServiceCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14))),
          const SizedBox(height: 10),
          Container(
              width: 70,
              height: 10,
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 6),
          Container(
              width: 40,
              height: 8,
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4))),
        ],
      ),
    );
  }
}
