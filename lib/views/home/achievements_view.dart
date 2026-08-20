import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donor.dart';
import '../../data/repositories/donor_repository.dart';

class AchievementsView extends StatelessWidget {
  AchievementsView({super.key, DonorRepository? donorRepository})
      : _donorRepository = donorRepository ?? DonorRepository();

  final DonorRepository _donorRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _AchievementsBackdrop())),
          SafeArea(
            child: Column(
              children: [
                const _AchievementsAppBar(),
                Expanded(
                  child: StreamBuilder<Donor?>(
                    stream: _donorRepository.watchCurrentDonor(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.bloodRed,
                          ),
                        );
                      }

                      final donor = snapshot.data;
                      final badges = _buildBadges(donor);
                      final earnedCount =
                          badges.where((badge) => badge.isEarned).length;

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                        children: [
                          _ProgressSummary(
                            earnedCount: earnedCount,
                            totalCount: badges.length,
                          ),
                          const SizedBox(height: 16),
                          ...badges.map(
                            (badge) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _AchievementCard(badge: badge),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<_AchievementBadge> _buildBadges(Donor? donor) {
    final hasProfile = donor != null;
    final hasDonation = donor?.lastDonationDate != null;
    final isEligible = _isEligible(donor?.lastDonationDate);
    final isCompleteProfile = hasProfile &&
        donor.name.trim().isNotEmpty &&
        donor.nic.trim().isNotEmpty &&
        donor.phone.trim().isNotEmpty &&
        donor.city.trim().isNotEmpty &&
        donor.bloodGroup.trim().isNotEmpty;

    return [
      _AchievementBadge(
        title: 'First Donation',
        subtitle: hasDonation
            ? 'Your first recorded donation is saved.'
            : 'Add your first donation date to unlock this badge.',
        icon: Icons.bloodtype_rounded,
        isEarned: hasDonation,
        progress: hasDonation ? 1 : 0,
      ),
      _AchievementBadge(
        title: 'Life Saver',
        subtitle: isCompleteProfile
            ? 'Your complete profile can help requesters reach you.'
            : 'Complete your donor profile details to unlock this badge.',
        icon: Icons.favorite_rounded,
        isEarned: isCompleteProfile,
        progress: _profileProgress(donor),
      ),
      _AchievementBadge(
        title: 'Emergency Hero',
        subtitle: isEligible
            ? 'You are eligible and ready for urgent blood requests.'
            : 'This unlocks when your donation recovery period is complete.',
        icon: Icons.emergency_share_rounded,
        isEarned: isEligible,
        progress:
            isEligible ? 1 : _eligibilityProgress(donor?.lastDonationDate),
      ),
      _AchievementBadge(
        title: 'Regular Donor',
        subtitle: hasDonation && isEligible
            ? 'You have a recorded donation and are ready to donate again.'
            : 'Record donations and keep your eligibility updated.',
        icon: Icons.emoji_events_rounded,
        isEarned: hasDonation && isEligible,
        progress: hasDonation ? (isEligible ? 1 : 0.5) : 0,
      ),
    ];
  }

  bool _isEligible(DateTime? lastDonationDate) {
    if (lastDonationDate == null) return true;
    return !DateTime.now().isBefore(
      lastDonationDate.add(const Duration(days: 150)),
    );
  }

  double _profileProgress(Donor? donor) {
    if (donor == null) return 0;
    final fields = [
      donor.name,
      donor.nic,
      donor.phone,
      donor.city,
      donor.bloodGroup,
    ];
    final completed = fields.where((field) => field.trim().isNotEmpty).length;
    return completed / fields.length;
  }

  double _eligibilityProgress(DateTime? lastDonationDate) {
    if (lastDonationDate == null) return 1;
    final elapsed = DateTime.now().difference(lastDonationDate).inDays;
    return (elapsed / 150).clamp(0, 1).toDouble();
  }
}

class _AchievementBadge {
  const _AchievementBadge({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isEarned,
    required this.progress,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isEarned;
  final double progress;
}

class _AchievementsAppBar extends StatelessWidget {
  const _AchievementsAppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 18, 8),
      child: Row(
        children: [
          IconButton.filled(
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.bloodRed,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Achievements',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({
    required this.earnedCount,
    required this.totalCount,
  });

  final int earnedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount == 0 ? 0.0 : earnedCount / totalCount;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              color: Color(0xFFFFECEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.bloodRed,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$earnedCount of $totalCount unlocked',
                  style: const TextStyle(
                    color: Color(0xFF171D24),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 9,
                    backgroundColor: const Color(0xFFFFECEE),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.bloodRed,
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Keep your donor profile and donation history updated.',
                  style: TextStyle(
                    color: Color(0xFF6A7380),
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.badge});

  final _AchievementBadge badge;

  @override
  Widget build(BuildContext context) {
    final color = badge.isEarned ? AppColors.bloodRed : const Color(0xFF9AA1AB);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: badge.isEarned ? AppColors.lightRed : const Color(0xFFE6E8EB),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: badge.isEarned
                  ? const Color(0xFFFFECEE)
                  : const Color(0xFFF1F2F4),
              shape: BoxShape.circle,
            ),
            child: Icon(badge.icon, color: color, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        badge.title,
                        style: const TextStyle(
                          color: Color(0xFF303942),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Icon(
                      badge.isEarned
                          ? Icons.check_circle_rounded
                          : Icons.lock_rounded,
                      color: color,
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  badge.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6A7380),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: badge.progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFF1F2F4),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsBackdrop extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    final rect = Rect.fromLTWH(0, 0, size.width, 160);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE71920), Color(0xFFC9000B)],
        ).createShader(rect),
    );

    final wave = Path()
      ..moveTo(0, 118)
      ..cubicTo(size.width * 0.18, 94, size.width * 0.46, 134, size.width, 106)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wave, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
