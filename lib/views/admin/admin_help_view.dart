import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodels/admin_view_model.dart';
import 'admin_blood_summary_view.dart';
import 'admin_donation_centers_view.dart';
import 'admin_donors_view.dart';
import 'admin_eligibility_view.dart';
import 'admin_emergency_requests_view.dart';
import 'admin_group_notifications_view.dart';
import 'admin_page_shell.dart';
import 'admin_post_request_view.dart';
import 'admin_settings_view.dart';

class AdminHelpView extends StatelessWidget {
  const AdminHelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _HelpItem(
        icon: Icons.add_circle_rounded,
        title: 'Post Request',
        text:
            'Create an urgent blood request with patient, hospital, contact, and note details.',
        page: const AdminPostRequestView(),
      ),
      _HelpItem(
        icon: Icons.emergency_share_rounded,
        title: 'Requests',
        text: 'Review all open emergency requests posted by admins.',
        page: const AdminEmergencyRequestsView(),
      ),
      _HelpItem(
        icon: Icons.groups_rounded,
        title: 'Donors',
        text:
            'Search donors, filter by district, and open donor contact details.',
        page: const AdminDonorsView(),
      ),
      _HelpItem(
        icon: Icons.notifications_active_rounded,
        title: 'Group Alerts',
        text:
            'Select one or more blood groups, confirm, and send Firebase push alerts.',
        page: const AdminGroupNotificationsView(),
      ),
      _HelpItem(
        icon: Icons.local_hospital_rounded,
        title: 'Donation Centers',
        text:
            'Add center name, contact number, address, and district to Firebase.',
        page: const AdminDonationCentersView(),
      ),
      _HelpItem(
        icon: Icons.event_available_rounded,
        title: 'Eligibility',
        text:
            'View donors who are eligible again after the five-month recovery window.',
        page: const AdminEligibilityView(),
      ),
      _HelpItem(
        icon: Icons.bloodtype_rounded,
        title: 'Blood Summary',
        text: 'Check donor counts grouped by blood type.',
        page: const AdminBloodSummaryView(),
      ),
      _HelpItem(
        icon: Icons.settings_rounded,
        title: 'Settings',
        text:
            'Manage admin preferences and check device push notification status.',
        page: const AdminSettingsView(),
      ),
      const _HelpItem(
        icon: Icons.support_agent_rounded,
        title: 'Help Center',
        text:
            'Browse the complete admin function list and open each tool quickly.',
      ),
    ];

    return AdminPageShell(
      title: 'Help Center',
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return _HelpFunctionCard(
            item: item,
            onTap: item.page == null ? null : () => _open(context, item.page!),
          );
        },
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

class _HelpFunctionCard extends StatelessWidget {
  const _HelpFunctionCard({
    required this.item,
    required this.onTap,
  });

  final _HelpItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AdminSectionCard(
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFECEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: AppColors.bloodRed, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF171D24),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6A7380),
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFD9A1A4),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpItem {
  const _HelpItem({
    required this.icon,
    required this.title,
    required this.text,
    this.page,
  });

  final IconData icon;
  final String title;
  final String text;
  final Widget? page;
}
