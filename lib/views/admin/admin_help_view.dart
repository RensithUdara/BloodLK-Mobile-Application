import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'admin_page_shell.dart';

class AdminHelpView extends StatelessWidget {
  const AdminHelpView({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _HelpItem(
        icon: Icons.emergency_share_rounded,
        title: 'Emergency requests',
        text: 'Post only verified hospital or patient requests.',
      ),
      _HelpItem(
        icon: Icons.notifications_active_rounded,
        title: 'Group alerts',
        text: 'Send alerts to matching blood groups after confirming details.',
      ),
      _HelpItem(
        icon: Icons.local_hospital_rounded,
        title: 'Donation centers',
        text: 'Keep center phone numbers, addresses, and districts updated.',
      ),
      _HelpItem(
        icon: Icons.groups_rounded,
        title: 'Donor data',
        text: 'Use donor records only for blood donation coordination.',
      ),
    ];

    return AdminPageShell(
      title: 'Help Center',
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) => AdminSectionCard(
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFECEE),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  items[index].icon,
                  color: AppColors.bloodRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      items[index].title,
                      style: const TextStyle(
                        color: Color(0xFF171D24),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index].text,
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
  });

  final IconData icon;
  final String title;
  final String text;
}
