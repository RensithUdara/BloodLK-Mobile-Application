import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key, NotificationRepository? repository})
      : _repository = repository;

  final NotificationRepository? _repository;

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late final NotificationRepository _repository;
  final _dateFormat = DateFormat('dd MMM yyyy, h:mm a');

  @override
  void initState() {
    super.initState();
    _repository = widget._repository ?? NotificationRepository();
    _repository.syncCurrentToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
              child: CustomPaint(painter: _NotificationsBackdrop())),
          SafeArea(
            child: Column(
              children: [
                const _NotificationsAppBar(),
                Expanded(
                  child: StreamBuilder<List<DonorNotification>>(
                    stream: _repository.watchCurrentNotifications(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.bloodRed,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _NotificationState(
                          icon: Icons.error_outline_rounded,
                          title: 'Unable to load notifications',
                          message: snapshot.error.toString(),
                        );
                      }

                      final notifications =
                          snapshot.data ?? const <DonorNotification>[];
                      if (notifications.isEmpty) {
                        return const _NotificationState(
                          icon: Icons.notifications_none_rounded,
                          title: 'No notifications available',
                          message:
                              'Emergency alerts and reminders will appear here.',
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return _NotificationTile(
                            notification: notification,
                            dateText: notification.createdAt == null
                                ? 'Just now'
                                : _dateFormat.format(notification.createdAt!),
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.dateText,
  });

  final DonorNotification notification;
  final String dateText;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFFFECEE),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconForType(notification.type),
              color: AppColors.bloodRed,
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF171D24),
                    fontSize: 15,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  notification.body,
                  style: const TextStyle(
                    color: Color(0xFF5D6673),
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  dateText,
                  style: const TextStyle(
                    color: Color(0xFF8A9099),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (notification.bloodGroup != null &&
              notification.bloodGroup!.trim().isNotEmpty) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.bloodRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                notification.bloodGroup!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    return switch (type) {
      'emergency_request' => Icons.emergency_share_rounded,
      'eligibility_reminder' => Icons.calendar_month_rounded,
      'group_notification' => Icons.bloodtype_rounded,
      _ => Icons.notifications_rounded,
    };
  }
}

class _NotificationState extends StatelessWidget {
  const _NotificationState({
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

class _NotificationsAppBar extends StatelessWidget {
  const _NotificationsAppBar();

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
              'Notifications',
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

class _NotificationsBackdrop extends CustomPainter {
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
