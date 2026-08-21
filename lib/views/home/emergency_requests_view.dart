import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/emergency_request.dart';
import '../../data/repositories/emergency_request_repository.dart';
import '../../services/contact_service.dart';

class EmergencyRequestsView extends StatelessWidget {
  EmergencyRequestsView({
    super.key,
    EmergencyRequestRepository? repository,
    ContactService? contactService,
  })  : _repository = repository ?? EmergencyRequestRepository(),
        _contactService = contactService ?? ContactService();

  final EmergencyRequestRepository _repository;
  final ContactService _contactService;
  final _dateFormat = DateFormat('dd MMM yyyy, h:mm a');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _EmergencyBackdrop())),
          SafeArea(
            child: Column(
              children: [
                const _EmergencyAppBar(),
                Expanded(
                  child: StreamBuilder<List<EmergencyRequest>>(
                    stream: _repository.watchOpenRequests(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.bloodRed,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _EmergencyState(
                          icon: Icons.error_outline_rounded,
                          title: 'Unable to load requests',
                          message: snapshot.error.toString(),
                        );
                      }

                      final requests =
                          snapshot.data ?? const <EmergencyRequest>[];
                      if (requests.isEmpty) {
                        return const _EmergencyState(
                          icon: Icons.favorite_rounded,
                          title: 'No emergency requests',
                          message:
                              'New admin-posted blood requests will appear here.',
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                        itemCount: requests.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final request = requests[index];
                          return _EmergencyRequestCard(
                            request: request,
                            dateText: request.createdAt == null
                                ? 'Just now'
                                : _dateFormat.format(request.createdAt!),
                            onCall: request.contactNumber.trim().isEmpty
                                ? null
                                : () => _contactService
                                    .makeCall(request.contactNumber),
                            onSms: request.contactNumber.trim().isEmpty
                                ? null
                                : () => _contactService.sendSms(
                                      phoneNumber: request.contactNumber,
                                      message:
                                          'Hello, I saw the ${request.bloodGroup} emergency blood request in BloodLK. I may be able to help.',
                                    ),
                          );
                        },
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
}

class _EmergencyRequestCard extends StatelessWidget {
  const _EmergencyRequestCard({
    required this.request,
    required this.dateText,
    required this.onCall,
    required this.onSms,
  });

  final EmergencyRequest request;
  final String dateText;
  final VoidCallback? onCall;
  final VoidCallback? onSms;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightRed.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.bloodRed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  request.bloodGroup,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.patientName.trim().isEmpty
                          ? 'Emergency blood request'
                          : request.patientName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF171D24),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateText,
                      style: const TextStyle(
                        color: Color(0xFF6A7380),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _RequestDetail(
            icon: Icons.location_on_rounded,
            text: request.location.trim().isEmpty
                ? 'Location not provided'
                : request.location,
          ),
          const SizedBox(height: 8),
          _RequestDetail(
            icon: Icons.call_rounded,
            text: request.contactNumber.trim().isEmpty
                ? 'Contact not provided'
                : request.contactNumber,
          ),
          if (request.note.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _RequestDetail(icon: Icons.notes_rounded, text: request.note),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSms,
                  icon: const Icon(Icons.sms_rounded, size: 18),
                  label: const Text('SMS'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.bloodRed,
                    side: const BorderSide(color: Color(0xFFFFE6E8)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onCall,
                  icon: const Icon(Icons.call_rounded, size: 18),
                  label: const Text('Call'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.bloodRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestDetail extends StatelessWidget {
  const _RequestDetail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.bloodRed, size: 18),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF303942),
              fontSize: 13,
              height: 1.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmergencyState extends StatelessWidget {
  const _EmergencyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECEE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.bloodRed, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF171D24),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF5D6673),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyAppBar extends StatelessWidget {
  const _EmergencyAppBar();

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
              'Emergency Requests',
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

class _EmergencyBackdrop extends CustomPainter {
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
