import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Config/colors_coning.dart';
import 'package:home_care/Helper/logger_service.dart';
import 'package:home_care/Pages/Booking/confirm_booking_page.dart';

/// Full professional profile screen.
///
/// Accepts the same named parameters as before for backward compatibility.
/// Also accepts optional rich-data params (bio, qualification, skills,
/// totalReviews) that are populated when coming from a [ProfessionalModel].
class ProfessionalDetailPage extends StatelessWidget {
  final String professionalId;
  final String serviceId;
  final String name;
  final String role;
  final String serviceName;
  final double rating;
  final bool available;
  final int yearsExperience;
  final String distance;
  final int estimatedDuration;
  final String availableTimeStart;
  final String availableTimeEnd;
  final double price;
  // Optional rich-data (from ProfessionalModel)
  final String bio;
  final String qualification;
  final List<String> skills;
  final int totalReviews;
  final String profileImageUrl;

  const ProfessionalDetailPage({
    super.key,
    required this.professionalId,
    required this.serviceId,
    required this.name,
    required this.role,
    required this.serviceName,
    required this.rating,
    required this.available,
    required this.yearsExperience,
    required this.distance,
    this.estimatedDuration = 60,
    this.availableTimeStart = '',
    this.availableTimeEnd = '',
    this.price = 0,
    this.bio = '',
    this.qualification = '',
    this.skills = const [],
    this.totalReviews = 0,
    this.profileImageUrl = '',
  });

  // Derive avatar initial from name
  String get _initial =>
      name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'P';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 20),
                  if (bio.isNotEmpty) ...[
                    _buildSection('About', Icons.info_outline_rounded,
                        child: Text(bio,
                            style: const TextStyle(
                                fontSize: 13,
                                color: kTextMedium,
                                height: 1.6))),
                    const SizedBox(height: 16),
                  ],
                  _buildServicesSection(),
                  const SizedBox(height: 16),
                  if (qualification.isNotEmpty || skills.isNotEmpty)
                    _buildQualificationsSection(),
                  if (qualification.isNotEmpty || skills.isNotEmpty)
                    const SizedBox(height: 16),
                  if (availableTimeStart.isNotEmpty || availableTimeEnd.isNotEmpty)
                    _buildAvailabilitySection(),
                  if (availableTimeStart.isNotEmpty || availableTimeEnd.isNotEmpty)
                    const SizedBox(height: 16),
                  _buildReviewsPlaceholder(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBookButton(),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: kPrimary,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Get.back(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimary, kPrimaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                right: -40, top: -30,
                child: Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                left: -30, bottom: -20,
                child: Container(
                  width: 130, height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.05),
                  ),
                ),
              ),
              // Content
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    // Avatar
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                            colors: [kPrimaryLight, kAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6))
                        ],
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.5),
                            width: 3),
                      ),
                      child: profileImageUrl.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                profileImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _avatarText(),
                              ),
                            )
                          : _avatarText(),
                    ),
                    const SizedBox(height: 12),
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(role.isNotEmpty ? role : serviceName,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14)),
                    const SizedBox(height: 10),
                    // Rating + availability chips
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _HeaderChip(
                          icon: Icons.star_rounded,
                          label:
                              '${rating.toStringAsFixed(1)}${totalReviews > 0 ? ' ($totalReviews)' : ''}',
                          color: kWarning,
                        ),
                        const SizedBox(width: 8),
                        _HeaderChip(
                          icon: available
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          label: available ? 'Available' : 'Unavailable',
                          color:
                              available ? kSuccess : kError,
                        ),
                        if (distance.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _HeaderChip(
                            icon: Icons.near_me_rounded,
                            label: distance,
                            color: kAccent,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _avatarText() => Center(
        child: Text(_initial,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.bold)),
      );

  // ── Stats row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          _StatCell(
            icon: Icons.work_history_rounded,
            value:
                yearsExperience > 0 ? '${yearsExperience}y' : 'New',
            label: 'Experience',
            color: kPrimary,
          ),
          _divider(),
          _StatCell(
            icon: Icons.timer_rounded,
            value: estimatedDuration > 0
                ? '${estimatedDuration}m'
                : '—',
            label: 'Duration',
            color: kTeal,
          ),
          _divider(),
          _StatCell(
            icon: Icons.currency_rupee_rounded,
            value: price > 0 ? '₹${price.toStringAsFixed(0)}' : 'Free',
            label: 'Per Visit',
            color: kSuccess,
          ),
          _divider(),
          _StatCell(
            icon: Icons.star_rounded,
            value: rating > 0 ? rating.toStringAsFixed(1) : '—',
            label: 'Rating',
            color: kWarning,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
      width: 1, height: 40, color: kDivider);

  // ── Services section ───────────────────────────────────────────────────────

  Widget _buildServicesSection() {
    final servicesList = <String>[];
    if (serviceName.isNotEmpty) servicesList.add(serviceName);
    // Add skills as additional service tags if available
    for (final s in skills) {
      if (!servicesList.contains(s)) servicesList.add(s);
    }

    return _buildSection(
      'Services Offered',
      Icons.medical_services_rounded,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: servicesList.map((s) => _ServiceTag(label: s)).toList(),
      ),
    );
  }

  // ── Qualifications section ─────────────────────────────────────────────────

  Widget _buildQualificationsSection() {
    final items = <String>[];
    if (qualification.isNotEmpty) items.add(qualification);

    return _buildSection(
      'Qualification',
      Icons.school_rounded,
      child: Column(
        children: items
            .map((q) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: kSuccess, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(q,
                            style: const TextStyle(
                                fontSize: 13,
                                color: kTextDark,
                                height: 1.4)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ── Availability section ───────────────────────────────────────────────────

  Widget _buildAvailabilitySection() {
    return _buildSection(
      'Availability',
      Icons.access_time_rounded,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: kPrimary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kPrimary.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          const Icon(Icons.schedule_rounded, color: kPrimary, size: 18),
          const SizedBox(width: 10),
          Text(
            availableTimeStart.isNotEmpty && availableTimeEnd.isNotEmpty
                ? '$availableTimeStart – $availableTimeEnd'
                : availableTimeStart.isNotEmpty
                    ? 'From $availableTimeStart'
                    : availableTimeEnd.isNotEmpty
                        ? 'Until $availableTimeEnd'
                        : 'On request',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kPrimary),
          ),
        ]),
      ),
    );
  }

  // ── Reviews placeholder ────────────────────────────────────────────────────

  Widget _buildReviewsPlaceholder() {
    return _buildSection(
      'Reviews',
      Icons.reviews_rounded,
      child: totalReviews == 0
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Center(
                child: Text(
                  'No reviews yet. Be the first to review!',
                  style: TextStyle(color: kTextMedium, fontSize: 13),
                ),
              ),
            )
          : Row(children: [
              // Star summary
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text(rating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: kTextDark)),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < rating.round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: kWarning, size: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text('$totalReviews reviews',
                    style: const TextStyle(
                        fontSize: 11, color: kTextMedium)),
              ]),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Tap to see all reviews',
                  style: TextStyle(color: kTextMedium, fontSize: 12),
                ),
              ),
            ]),
    );
  }

  // ── Section wrapper ────────────────────────────────────────────────────────

  Widget _buildSection(String title, IconData icon, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 4, height: 18,
              decoration: BoxDecoration(
                  gradient: kPrimaryGradientV,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 8),
            Icon(icon, size: 16, color: kPrimary),
            const SizedBox(width: 6),
            Text(title,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: kTextDark)),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1, color: kDivider),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ── Book Now sticky bottom button ──────────────────────────────────────────

  Widget _buildBookButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: available ? kPrimary : Colors.grey.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: available ? 4 : 0,
              shadowColor: available
                  ? kPrimary.withValues(alpha: 0.4)
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: available
                ? () {
                    LoggerService.info('Booking with $name');
                    Get.to(() => ConfirmBookingPage(
                          professionalId: professionalId,
                          serviceId: serviceId,
                          professionalName: name,
                          professionalRole: role,
                          serviceName: serviceName,
                          rating: rating,
                          yearsExperience: yearsExperience,
                          distance: distance,
                          estimatedDuration: estimatedDuration,
                          availableTimeStart: availableTimeStart,
                          availableTimeEnd: availableTimeEnd,
                          price: price,
                        ));
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(available
                    ? Icons.calendar_today_rounded
                    : Icons.block_rounded, size: 18),
                const SizedBox(width: 10),
                Text(
                  available ? 'Book Now' : 'Currently Unavailable',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _HeaderChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _HeaderChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 13),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCell(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 10, color: kTextLight)),
      ]),
    );
  }
}

class _ServiceTag extends StatelessWidget {
  final String label;
  const _ServiceTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: kPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimary.withValues(alpha: 0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.check_rounded, color: kPrimary, size: 13),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kPrimary)),
      ]),
    );
  }
}
