import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donor.dart';
import '../../data/repositories/donor_repository.dart';

class DonorProfileView extends StatelessWidget {
  DonorProfileView({super.key, DonorRepository? donorRepository})
      : _donorRepository = donorRepository ?? DonorRepository();

  final DonorRepository _donorRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _ProfileBackdrop())),
          SafeArea(
            child: Column(
              children: [
                const _ProfileAppBar(),
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
                      if (donor == null) return const _MissingProfileState();

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                        children: [
                          _ProfileHero(donor: donor),
                          const SizedBox(height: 18),
                          _ProfileSection(
                            title: 'Personal Details',
                            children: [
                              _ProfileInfoTile(
                                icon: Icons.person_rounded,
                                label: 'Full Name',
                                value: donor.name,
                              ),
                              _ProfileInfoTile(
                                icon: Icons.badge_rounded,
                                label: 'NIC Number',
                                value: donor.nic,
                              ),
                              _ProfileInfoTile(
                                icon: Icons.cake_rounded,
                                label: 'Age',
                                value: donor.age == 0
                                    ? 'Not provided'
                                    : '${donor.age} years',
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _ProfileSection(
                            title: 'Contact & Location',
                            children: [
                              _ProfileInfoTile(
                                icon: Icons.phone_rounded,
                                label: 'Phone Number',
                                value: donor.phone,
                              ),
                              _ProfileInfoTile(
                                icon: Icons.location_on_rounded,
                                label: 'City',
                                value: _titleCase(donor.city),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _ProfileSection(
                            title: 'Donation Details',
                            children: [
                              _ProfileInfoTile(
                                icon: Icons.bloodtype_rounded,
                                label: 'Blood Group',
                                value: donor.bloodGroup,
                                highlight: true,
                              ),
                              _ProfileInfoTile(
                                icon: Icons.calendar_month_rounded,
                                label: 'Last Donation Date',
                                value: _formatDate(donor.lastDonationDate),
                              ),
                              _ProfileInfoTile(
                                icon: Icons.verified_user_rounded,
                                label: 'Registered Date',
                                value: _formatDate(donor.registeredAt),
                              ),
                              _ProfileInfoTile(
                                icon: Icons.favorite_rounded,
                                label: 'Eligibility',
                                value: _eligibilityText(donor.lastDonationDate),
                              ),
                            ],
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

  static String _formatDate(DateTime? date) {
    if (date == null) return 'Not provided';
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String _titleCase(String value) {
    if (value.trim().isEmpty) return 'Not provided';
    return value
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ');
  }

  static String _eligibilityText(DateTime? lastDonationDate) {
    if (lastDonationDate == null) return 'Eligible to donate';

    final eligibleDate = lastDonationDate.add(const Duration(days: 150));
    final now = DateTime.now();
    if (!now.isBefore(eligibleDate)) return 'Eligible to donate';

    final daysLeft = eligibleDate.difference(now).inDays + 1;
    return 'Eligible in $daysLeft days';
  }
}

class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar();

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
              'Donor Profile',
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.donor});

  final Donor donor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              color: Color(0xFFFFECEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.bloodRed,
              size: 48,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donor.name.isEmpty ? 'Unnamed donor' : donor.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF171D24),
                    fontSize: 21,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _ProfileHero._subtitle(donor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF5D6673),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.bloodRed,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              donor.bloodGroup,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _subtitle(Donor donor) {
    final city = donor.city.trim().isEmpty ? 'No city' : donor.city;
    return '${city.toUpperCase()}  •  ${donor.phone.isEmpty ? 'No phone' : donor.phone}';
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightRed.withValues(alpha: 0.75)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 15, 16, 6),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF171D24),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileInfoTile extends StatelessWidget {
  const _ProfileInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty ? 'Not provided' : value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFFFECEE),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.bloodRed, size: 22),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6A7380),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  displayValue,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: highlight
                        ? AppColors.bloodRed
                        : const Color(0xFF171D24),
                    fontSize: highlight ? 17 : 15,
                    fontWeight: FontWeight.w900,
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

class _MissingProfileState extends StatelessWidget {
  const _MissingProfileState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: Text(
          'No donor profile found. Please complete donor registration first.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF5D6673),
            fontSize: 15,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ProfileBackdrop extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    final rect = Rect.fromLTWH(0, 0, size.width, 170);
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
      ..moveTo(0, 128)
      ..cubicTo(size.width * 0.18, 100, size.width * 0.42, 150, size.width, 116)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wave, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
