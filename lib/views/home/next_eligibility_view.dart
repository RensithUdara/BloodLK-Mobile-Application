import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donor.dart';
import '../../data/repositories/donor_repository.dart';
import '../../widgets/custom_app_dialog.dart';

class NextEligibilityView extends StatelessWidget {
  NextEligibilityView({super.key, DonorRepository? donorRepository})
      : _donorRepository = donorRepository ?? DonorRepository();

  static const int _recoveryDays = 150;

  final DonorRepository _donorRepository;
  final _dateFormat = DateFormat('dd MMM yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _EligibilityBackdrop())),
          SafeArea(
            child: Column(
              children: [
                const _EligibilityAppBar(),
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
                      final details = _EligibilityDetails.fromLastDonation(
                        donor?.lastDonationDate,
                      );

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                        children: [
                          _EligibilityHero(
                            details: details,
                            dateFormat: _dateFormat,
                            onAddReminder: () => _addCalendarReminder(
                              context,
                              details.reminderDate,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _EligibilityInfoTile(
                            icon: Icons.bloodtype_rounded,
                            label: 'Last donation',
                            value: donor?.lastDonationDate == null
                                ? 'No donation saved yet'
                                : _dateFormat.format(donor!.lastDonationDate!),
                          ),
                          _EligibilityInfoTile(
                            icon: Icons.event_available_rounded,
                            label: 'Next eligible date',
                            value: _dateFormat.format(details.eligibleDate),
                          ),
                          _EligibilityInfoTile(
                            icon: Icons.hourglass_bottom_rounded,
                            label: 'Recovery window',
                            value: '$_recoveryDays days from last donation',
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

  Future<void> _addCalendarReminder(
    BuildContext context,
    DateTime reminderDate,
  ) async {
    final start = _calendarDate(reminderDate);
    final end = _calendarDate(reminderDate.add(const Duration(days: 1)));
    final uri = Uri.https('calendar.google.com', '/calendar/render', {
      'action': 'TEMPLATE',
      'text': 'BloodLK: You can donate blood again',
      'dates': '$start/$end',
      'details':
          'BloodLK reminder: your donor recovery window is complete. Please follow your local blood bank or hospital guidance before donating.',
      'location': 'Blood donation center',
    });

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (opened || !context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => CustomAppDialog(
        icon: Icons.calendar_month_rounded,
        title: 'Calendar unavailable',
        message:
            'Unable to open your calendar app right now. Please add the reminder manually for ${_dateFormat.format(reminderDate)}.',
        primaryText: 'OK',
        onPrimary: () => Navigator.pop(context),
      ),
    );
  }

  String _calendarDate(DateTime date) {
    return DateFormat('yyyyMMdd').format(date);
  }
}

class _EligibilityDetails {
  const _EligibilityDetails({
    required this.eligibleDate,
    required this.reminderDate,
    required this.daysLeft,
    required this.isEligible,
  });

  final DateTime eligibleDate;
  final DateTime reminderDate;
  final int daysLeft;
  final bool isEligible;

  factory _EligibilityDetails.fromLastDonation(DateTime? lastDonationDate) {
    final today = _dateOnly(DateTime.now());
    final eligibleDate = lastDonationDate == null
        ? today
        : _dateOnly(lastDonationDate).add(
            const Duration(days: NextEligibilityView._recoveryDays),
          );
    final daysLeft = eligibleDate.difference(today).inDays;

    return _EligibilityDetails(
      eligibleDate: eligibleDate,
      reminderDate: daysLeft <= 0 ? today : eligibleDate,
      daysLeft: daysLeft <= 0 ? 0 : daysLeft,
      isEligible: daysLeft <= 0,
    );
  }

  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class _EligibilityHero extends StatelessWidget {
  const _EligibilityHero({
    required this.details,
    required this.dateFormat,
    required this.onAddReminder,
  });

  final _EligibilityDetails details;
  final DateFormat dateFormat;
  final VoidCallback onAddReminder;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFECEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  details.isEligible
                      ? Icons.verified_rounded
                      : Icons.calendar_month_rounded,
                  color: AppColors.bloodRed,
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      details.isEligible
                          ? 'Eligible to donate'
                          : '${details.daysLeft} days left',
                      style: const TextStyle(
                        color: Color(0xFF171D24),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Next date: ${dateFormat.format(details.eligibleDate)}',
                      style: const TextStyle(
                        color: Color(0xFF5D6673),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: details.isEligible
                  ? 1
                  : (NextEligibilityView._recoveryDays - details.daysLeft) /
                      NextEligibilityView._recoveryDays,
              backgroundColor: const Color(0xFFFFECEE),
              color: AppColors.bloodRed,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onAddReminder,
            icon: const Icon(Icons.event_rounded),
            label: Text(
              details.isEligible ? 'Add reminder for today' : 'Add to calendar',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.bloodRed,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EligibilityInfoTile extends StatelessWidget {
  const _EligibilityInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightRed.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFFFECEE),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.bloodRed, size: 20),
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
                  value,
                  style: const TextStyle(
                    color: Color(0xFF171D24),
                    fontSize: 15,
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

class _EligibilityAppBar extends StatelessWidget {
  const _EligibilityAppBar();

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
              'Next Eligibility',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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

class _EligibilityBackdrop extends CustomPainter {
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
