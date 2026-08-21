import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donation_center.dart';
import '../../data/models/donor.dart';
import '../../data/models/emergency_request.dart';
import '../../viewmodels/admin_view_model.dart';
import 'admin_blood_summary_view.dart';
import 'admin_donation_centers_view.dart';
import 'admin_donors_view.dart';
import 'admin_eligibility_view.dart';
import 'admin_emergency_requests_view.dart';
import 'admin_group_notifications_view.dart';
import 'admin_help_view.dart';
import 'admin_post_request_view.dart';
import 'admin_settings_view.dart';

class AdminPanelView extends StatelessWidget {
  const AdminPanelView({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _AdminHomeAction(
        title: 'Post Request',
        icon: Icons.add_rounded,
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
      _AdminHomeAction(
        title: 'Eligibility',
        icon: Icons.event_available_rounded,
        onTap: () => _open(context, const AdminEligibilityView()),
      ),
      _AdminHomeAction(
        title: 'Blood Summary',
        icon: Icons.bloodtype_rounded,
        onTap: () => _open(context, const AdminBloodSummaryView()),
      ),
      _AdminHomeAction(
        title: 'Settings',
        icon: Icons.settings_rounded,
        onTap: () => _open(context, const AdminSettingsView()),
      ),
      _AdminHomeAction(
        title: 'Help Center',
        icon: Icons.support_agent_rounded,
        onTap: () => _open(context, const AdminHelpView()),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      body: Stack(
        children: [
          Positioned.fill(
              child: CustomPaint(painter: _AdminDashboardBackdrop())),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const _AdminDashboardHeader(),
                      _OverviewCard(onReportsTap: () {
                        _open(context, const AdminBloodSummaryView());
                      }),
                      const SizedBox(height: 24),
                      const _SectionHeading('Quick Actions'),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _AdminActionTile(action: actions[index]),
                      childCount: actions.length,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 104),
                  sliver: SliverToBoxAdapter(
                    child: _RecentActivityCard(
                      onTap: () => _open(
                        context,
                        const AdminEmergencyRequestsView(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 18,
            child: SafeArea(
              top: false,
              child: _AdminBottomNav(
                onDashboard: () {},
                onRequests: () => _open(
                  context,
                  const AdminEmergencyRequestsView(),
                ),
                onPost: () => _open(context, const AdminPostRequestView()),
                onDonors: () => _open(context, const AdminDonorsView()),
                onMore: () => _open(context, const AdminHelpView()),
              ),
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

class _AdminDashboardHeader extends StatelessWidget {
  const _AdminDashboardHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.admin_panel_settings_rounded,
                color: AppColors.bloodRed,
                size: 46,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Admin Panel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 7),
                    Text(
                      'Manage donor app operations',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const _NotificationBadge(),
          ],
        ),
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  const _NotificationBadge();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EmergencyRequest>>(
      stream: context.watch<AdminViewModel>().watchEmergencyRequests(),
      builder: (context, snapshot) {
        final count = snapshot.data?.length ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            if (count > 0)
              Positioned(
                right: -2,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.bloodRed,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    count > 9 ? '9+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.onReportsTap});

  final VoidCallback onReportsTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Overview',
                  style: TextStyle(
                    color: Color(0xFF171D24),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onReportsTap,
                icon: const Icon(Icons.insights_rounded, size: 18),
                label: const Text('View Reports'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.bloodRed,
                  backgroundColor: const Color(0xFFFFECEE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatTile<List<EmergencyRequest>>(
                  stream:
                      context.watch<AdminViewModel>().watchEmergencyRequests(),
                  icon: Icons.bloodtype_rounded,
                  label: 'Requests',
                  valueBuilder: (requests) => requests.length.toString(),
                ),
              ),
              const _StatDivider(),
              Expanded(
                child: _StatTile<List<Donor>>(
                  stream: context.watch<AdminViewModel>().watchDonors(),
                  icon: Icons.groups_rounded,
                  label: 'Donors',
                  valueBuilder: (donors) => donors.length.toString(),
                ),
              ),
              const _StatDivider(),
              Expanded(
                child: _StatTile<int>(
                  stream:
                      context.watch<AdminViewModel>().watchTotalDonationUnits(),
                  icon: Icons.bloodtype_outlined,
                  label: 'Units',
                  valueBuilder: (units) => units.toString(),
                ),
              ),
              const _StatDivider(),
              Expanded(
                child: _StatTile<List<DonationCenter>>(
                  stream:
                      context.watch<AdminViewModel>().watchDonationCenters(),
                  icon: Icons.apartment_rounded,
                  label: 'Centers',
                  valueBuilder: (centers) => centers.length.toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile<T> extends StatelessWidget {
  const _StatTile({
    required this.stream,
    required this.icon,
    required this.label,
    required this.valueBuilder,
  });

  final Stream<T> stream;
  final IconData icon;
  final String label;
  final String Function(T data) valueBuilder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<T>(
      stream: stream,
      builder: (context, snapshot) {
        final value =
            snapshot.hasData ? valueBuilder(snapshot.data as T) : '--';
        return Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECEE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.bloodRed, size: 27),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF384150),
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF171D24),
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 86,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: const Color(0xFFE7E0E0),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF171D24),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  const _AdminActionTile({required this.action});

  final _AdminHomeAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFE5E5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.045),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFECEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: AppColors.bloodRed, size: 29),
              ),
              const SizedBox(height: 10),
              Text(
                action.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF171D24),
                  fontSize: 11.5,
                  height: 1.05,
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

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EmergencyRequest>>(
      stream: context.watch<AdminViewModel>().watchEmergencyRequests(),
      builder: (context, snapshot) {
        final request = (snapshot.data ?? const <EmergencyRequest>[]).isEmpty
            ? null
            : snapshot.data!.first;
        return Material(
          color: const Color(0xFFFFECEE),
          borderRadius: BorderRadius.circular(22),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFFFDEDE)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.bloodRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.monitor_heart_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            color: Color(0xFF171D24),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          request == null
                              ? 'No emergency requests yet'
                              : 'New ${request.bloodGroup} request from',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF6A7380),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (request != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            request.location.isEmpty
                                ? request.patientName
                                : request.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.bloodRed,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.bloodRed,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AdminBottomNav extends StatelessWidget {
  const _AdminBottomNav({
    required this.onDashboard,
    required this.onRequests,
    required this.onPost,
    required this.onDonors,
    required this.onMore,
  });

  final VoidCallback onDashboard;
  final VoidCallback onRequests;
  final VoidCallback onPost;
  final VoidCallback onDonors;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _NavItem(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              active: true,
              onTap: onDashboard,
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.location_on_rounded,
              label: 'Requests',
              onTap: onRequests,
            ),
          ),
          Expanded(
            child: _NavCenterButton(onTap: onPost),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.groups_rounded,
              label: 'Donors',
              onTap: onDonors,
            ),
          ),
          Expanded(
            child: _NavItem(
              icon: Icons.more_horiz_rounded,
              label: 'More',
              onTap: onMore,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.bloodRed : const Color(0xFF737B86);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 9.8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: active ? 34 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavCenterButton extends StatelessWidget {
  const _NavCenterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: AppColors.bloodRed,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.bloodRed.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.bloodtype_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}

class _AdminDashboardBackdrop extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFF7F7),
    );

    final headerRect = Rect.fromLTWH(0, 0, size.width, 250);
    canvas.drawRect(
      headerRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF01820), Color(0xFFC9000B), Color(0xFF8E0008)],
        ).createShader(headerRect),
    );

    final softWave = Path()
      ..moveTo(0, 144)
      ..cubicTo(size.width * 0.28, 206, size.width * 0.62, 72, size.width, 130)
      ..lineTo(size.width, 252)
      ..cubicTo(size.width * 0.62, 222, size.width * 0.32, 298, 0, 220)
      ..close();
    canvas.drawPath(
      softWave,
      Paint()..color = Colors.white.withValues(alpha: 0.10),
    );

    final wave = Path()
      ..moveTo(0, 214)
      ..cubicTo(size.width * 0.22, 248, size.width * 0.46, 178, size.width, 208)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave, Paint()..color = const Color(0xFFFFF7F7));

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.08);
    for (var row = 0; row < 8; row++) {
      for (var col = 0; col < 9; col++) {
        canvas.drawCircle(
          Offset(size.width - 72 + col * 8, 54 + row * 8),
          1.5,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
