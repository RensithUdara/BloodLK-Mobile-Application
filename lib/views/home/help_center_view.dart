import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donor.dart';
import '../../data/repositories/donor_repository.dart';
import '../../services/contact_service.dart';

class HelpCenterView extends StatefulWidget {
  HelpCenterView({
    super.key,
    DonorRepository? donorRepository,
    ContactService? contactService,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _donorRepository = donorRepository ?? DonorRepository(),
        _contactService = contactService ?? ContactService(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final DonorRepository _donorRepository;
  final ContactService _contactService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  State<HelpCenterView> createState() => _HelpCenterViewState();
}

class _HelpCenterViewState extends State<HelpCenterView> {
  static const String _adminPhone = '0761155638';

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _HelpBackdrop())),
          SafeArea(
            child: Column(
              children: [
                const _HelpAppBar(),
                Expanded(
                  child: StreamBuilder<Donor?>(
                    stream: widget._donorRepository.watchCurrentDonor(),
                    builder: (context, snapshot) {
                      final donor = snapshot.data;

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                        children: [
                          if (_isSubmitting) const _SubmittingBanner(),
                          _HelpActionCard(
                            icon: Icons.manage_accounts_rounded,
                            title: 'Report incorrect donor details',
                            subtitle:
                                'Tell admins what needs to be corrected in your profile.',
                            buttonText: 'Report',
                            onTap: () => _openRequestSheet(
                              type: 'incorrect_donor_details',
                              title: 'Report incorrect details',
                              donor: donor,
                              hint:
                                  'Example: My city is wrong, phone number changed, or blood group needs checking...',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _HelpActionCard(
                            icon: Icons.notifications_active_rounded,
                            title: 'Ask for help with notifications',
                            subtitle:
                                'Get support for alerts, permissions, or missing messages.',
                            buttonText: 'Ask',
                            onTap: () => _openRequestSheet(
                              type: 'notification_help',
                              title: 'Notification help',
                              donor: donor,
                              hint:
                                  'Example: I am not receiving emergency alerts, or notifications are delayed...',
                            ),
                          ),
                          const SizedBox(height: 12),
                          _HelpActionCard(
                            icon: Icons.emergency_rounded,
                            title: 'Contact admins for urgent issues',
                            subtitle:
                                'Call or SMS admin support for urgent blood-donation issues.',
                            buttonText: 'Contact',
                            onTap: () => _showUrgentContactSheet(donor),
                          ),
                          const SizedBox(height: 18),
                          const _HelpInfoPanel(),
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

  Future<void> _openRequestSheet({
    required String type,
    required String title,
    required Donor? donor,
    required String hint,
  }) async {
    final messageController = TextEditingController();
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 18,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF171D24),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Write a short message for the admin team.',
                style: TextStyle(
                  color: Color(0xFF6A7380),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                minLines: 4,
                maxLines: 6,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: const Color(0xFFFFFAFA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.lightRed),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.lightRed),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.bloodRed,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  final message = messageController.text.trim();
                  if (message.isEmpty) return;
                  Navigator.pop(context, true);
                  await _submitSupportRequest(
                    type: type,
                    message: message,
                    donor: donor,
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.bloodRed,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.send_rounded),
                label: const Text('Submit request'),
              ),
            ],
          ),
        );
      },
    );

    if (submitted != true) {
      messageController.dispose();
    }
  }

  Future<void> _submitSupportRequest({
    required String type,
    required String message,
    required Donor? donor,
  }) async {
    setState(() => _isSubmitting = true);
    try {
      await widget._firestore.collection('supportRequests').add({
        'type': type,
        'message': message,
        'status': 'open',
        'userId': widget._auth.currentUser?.uid,
        'email': widget._auth.currentUser?.email,
        'donorName': donor?.name,
        'donorPhone': donor?.phone,
        'donorBloodGroup': donor?.bloodGroup,
        'donorCity': donor?.city,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Support request submitted'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to submit request: $error'),
          backgroundColor: AppColors.bloodRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showUrgentContactSheet(Donor? donor) {
    final message =
        'Urgent BloodLK support needed. Donor: ${donor?.name ?? 'Unknown'}, Blood group: ${donor?.bloodGroup ?? 'N/A'}, City: ${donor?.city ?? 'N/A'}.';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Urgent admin contact',
                    style: TextStyle(
                      color: Color(0xFF171D24),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _ContactButton(
                  icon: Icons.call_rounded,
                  title: 'Call admin',
                  subtitle: _adminPhone,
                  onTap: () {
                    Navigator.pop(context);
                    widget._contactService.makeCall(_adminPhone);
                  },
                ),
                const SizedBox(height: 10),
                _ContactButton(
                  icon: Icons.sms_rounded,
                  title: 'Send SMS',
                  subtitle: 'Send urgent issue details',
                  onTap: () {
                    Navigator.pop(context);
                    widget._contactService.sendSms(
                      phoneNumber: _adminPhone,
                      message: message,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HelpAppBar extends StatelessWidget {
  const _HelpAppBar();

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
              'Help Center',
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

class _HelpActionCard extends StatelessWidget {
  const _HelpActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightRed.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: [
          _HelpIcon(icon),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF303942),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6A7380),
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TextButton(onPressed: onTap, child: Text(buttonText)),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.lightRed.withValues(alpha: 0.8)),
      ),
      leading: _HelpIcon(icon),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF303942),
          fontSize: 15,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
    );
  }
}

class _HelpIcon extends StatelessWidget {
  const _HelpIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFFFFECEE),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.bloodRed, size: 20),
    );
  }
}

class _SubmittingBanner extends StatelessWidget {
  const _SubmittingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECEE),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              color: AppColors.bloodRed,
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 10),
          Text(
            'Submitting request...',
            style: TextStyle(
              color: AppColors.bloodRed,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpInfoPanel extends StatelessWidget {
  const _HelpInfoPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAFA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.bloodRed),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Support requests are saved for admins to review. For urgent blood needs, contact the hospital or blood bank directly first.',
              style: TextStyle(
                color: Color(0xFF6A7380),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpBackdrop extends CustomPainter {
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
