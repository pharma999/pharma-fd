import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Controller/service_controller.dart';
import 'package:home_care/Controller/service_professionals_controller.dart';
import 'package:home_care/Model/service_model.dart';
import 'package:home_care/Pages/Services/all_services_page.dart';
import 'package:home_care/Pages/Services/service_detail_page.dart';

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

  static const List<List<Color>> _gradients = [
    [kPrimary, kPrimaryMid],
    [Color(0xFF0EA5E9), kTeal],
    [kError, kPink],
    [kSuccess, Color(0xFF059669)],
    [kWarning, kOrange],
    [kPurple, kPink],
    [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
    [kTeal, Color(0xFF0D9488)],
    [kOrange, kError],
    [kPurple, Color(0xFF4338CA)],
  ];

  List<Color> _gradientFor(int idx) => _gradients[idx % _gradients.length];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: kPrimaryGradientV,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Healthcare Services',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: kTextDark)),
              ),
              GestureDetector(
                onTap: () => Get.to(() => const AllServicesPage()),
                child: Row(children: const [
                  Text('See all',
                      style: TextStyle(
                          fontSize: 13,
                          color: kPrimary,
                          fontWeight: FontWeight.w600)),
                  SizedBox(width: 2),
                  Icon(Icons.arrow_forward_ios, size: 11, color: kPrimary),
                ]),
              ),
            ],
          ),
        ),

        // ── Category chips ──────────────────────────────────────────────
        Obx(() {
          if (_ctrl.isLoadingCategories.value) {
            return SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 5,
                itemBuilder: (_, __) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: _ShimmerBox(
                      width: 76, height: 36, borderRadius: BorderRadius.circular(20)),
                ),
              ),
            );
          }
          if (_ctrl.categories.isEmpty) return const SizedBox.shrink();
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
              height: 152,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => const _ServiceCardSkeleton(),
              ),
            );
          }

          final list = _ctrl.services.isNotEmpty ? _ctrl.services : <ServiceModel>[];

          if (list.isEmpty) {
            final err = _ctrl.errorMessage.value;
            return _buildEmpty(
              err.isNotEmpty ? err : 'No services available',
              err.isNotEmpty ? Icons.wifi_off_rounded : Icons.medical_services_outlined,
              onRetry: err.isNotEmpty ? _ctrl.fetchAllServices : null,
            );
          }

          return SizedBox(
            height: 152,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final svc = list[i];
                return TweenAnimationBuilder<double>(
                  key: ValueKey('svc_${svc.id}'),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 280 + i * 60),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, child) => Opacity(
                    opacity: v,
                    child: Transform.translate(
                      offset: Offset(22 * (1 - v), 0),
                      child: child,
                    ),
                  ),
                  child: _ServiceCard(
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
                  ),
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: kPrimary.withValues(alpha: 0.35)),
            ),
            const SizedBox(height: 12),
            Text(msg,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kTextMedium, fontSize: 13)),
            if (onRetry != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Retry', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: kPrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Shimmer box ───────────────────────────────────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    BorderRadius? borderRadius,
  }) : borderRadius = borderRadius ?? const BorderRadius.all(Radius.circular(8));

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _color = ColorTween(
      begin: const Color(0xFFE4E7EF),
      end: const Color(0xFFF2F4FF),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _color,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _color.value,
          borderRadius: widget.borderRadius,
        ),
      ),
    );
  }
}

// ── Category Chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<_CategoryChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? kPrimaryGradient : null,
            color: widget.isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? kPrimary.withValues(alpha: 0.38)
                    : Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: widget.isSelected ? Colors.white : kTextMedium,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Service Card ──────────────────────────────────────────────────────────────

class _ServiceCard extends StatefulWidget {
  final ServiceModel service;
  final List<Color> gradient;
  final IconData icon;
  final VoidCallback onTap;
  const _ServiceCard({
    required this.service,
    required this.gradient,
    required this.icon,
    required this.onTap,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 110),
        child: Container(
          width: 116,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: widget.gradient.first.withValues(alpha: 0.15),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: widget.gradient.first.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.service.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: kTextDark,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: widget.gradient.first.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '₹${widget.service.basePrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 10,
                    color: widget.gradient.first,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Skeleton loader ───────────────────────────────────────────────────────────

class _ServiceCardSkeleton extends StatelessWidget {
  const _ServiceCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          _ShimmerBox(
              width: 58,
              height: 58,
              borderRadius: BorderRadius.circular(16)),
          const SizedBox(height: 10),
          _ShimmerBox(
              width: 72,
              height: 10,
              borderRadius: BorderRadius.circular(4)),
          const SizedBox(height: 6),
          _ShimmerBox(
              width: 44,
              height: 18,
              borderRadius: BorderRadius.circular(10)),
        ],
      ),
    );
  }
}
