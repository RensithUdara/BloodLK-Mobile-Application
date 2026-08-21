import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodels/admin_view_model.dart';
import 'admin_donation_centers_view.dart';
import 'admin_donors_view.dart';
import 'admin_emergency_requests_view.dart';
import 'admin_group_notifications_view.dart';
import 'admin_post_request_view.dart';

class AdminPanelView extends StatelessWidget {
  const AdminPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _AdminHomeAction(
        title: 'Post Request',
        icon: Icons.add_circle_rounded,
        onTap: () => _open(context, const AdminPostRequestView()),
      ),
      _AdminHomeAction(
        title: 'Requests',
        icon: Icons.emergency_share_rounded,
        onTap: () => _open(context, const AdminEmergencyRequestsView()),
      ),
      _AdminHomeAction(
        title: 'Donors',
        icon: Icons.groups_rounded,
        onTap: () => _open(context, const AdminDonorsView()),
      ),
      _AdminHomeAction(
        title: 'Group Alerts',
        icon: Icons.notifications_active_rounded,
        onTap: () => _open(context, const AdminGroupNotificationsView()),
      ),
      _AdminHomeAction(
        title: 'Donation Centers',
        icon: Icons.local_hospital_rounded,
        onTap: () => _open(context, const AdminDonationCentersView()),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _AdminHomeBackdrop())),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: _AdminHomeHeader()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 11,
                      childAspectRatio: 1.02,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _AdminHomeTile(action: actions[index]),
                      childCount: actions.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, Widget view) {
    final adminViewModel = context.read<AdminViewModel>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<AdminViewModel>.value(
          value: adminViewModel,
          child: view,
        ),
      ),
    );
  }
}

class _AdminHomeAction {
  const _AdminHomeAction({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
}

class _AdminHomeHeader extends StatelessWidget {
  const _AdminHomeHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 144,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: AppColors.bloodRed,
                size: 36,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin Panel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Manage requests, donors, and alerts',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminHomeTile extends StatelessWidget {
  const _AdminHomeTile({required this.action});

  final _AdminHomeAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFE6E8)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFECEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: AppColors.bloodRed, size: 26),
              ),
              const SizedBox(height: 9),
              Text(
                action.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF171D24),
                  fontSize: 12.5,
                  height: 1.04,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminHomeBackdrop extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    final rect = Offset.zero & Size(size.width, 144);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE71920), Color(0xFFC9000B), Color(0xFF8F0008)],
        ).createShader(rect),
    );

    final wave = Path()
      ..moveTo(0, 112)
      ..cubicTo(size.width * 0.18, 92, size.width * 0.46, 128, size.width, 104)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wave, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
