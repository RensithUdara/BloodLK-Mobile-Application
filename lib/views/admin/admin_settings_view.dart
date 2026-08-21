import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_app_dialog.dart';
import 'admin_page_shell.dart';

class AdminSettingsView extends StatefulWidget {
  const AdminSettingsView({super.key});

  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  bool _emergencyConfirmations = true;
  bool _showDonorCounts = true;
  bool _compactTiles = false;
  AuthorizationStatus? _permissionStatus;

  Future<void> _checkPushStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    if (!mounted) return;
    setState(() => _permissionStatus = settings.authorizationStatus);

    await showDialog<void>(
      context: context,
      builder: (context) => CustomAppDialog(
        icon: Icons.notifications_active_rounded,
        title: 'Push status',
        message:
            'Admin device notification status: ${settings.authorizationStatus.name}.',
        primaryText: 'OK',
        onPrimary: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AdminPageShell(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          AdminSectionCard(
            child: Column(
              children: [
                _SettingsSwitch(
                  icon: Icons.verified_user_rounded,
                  title: 'Confirm before sending alerts',
                  value: _emergencyConfirmations,
                  onChanged: (value) {
                    setState(() => _emergencyConfirmations = value);
                  },
                ),
                const Divider(height: 20),
                _SettingsSwitch(
                  icon: Icons.groups_rounded,
                  title: 'Show donor counts',
                  value: _showDonorCounts,
                  onChanged: (value) {
                    setState(() => _showDonorCounts = value);
                  },
                ),
                const Divider(height: 20),
                _SettingsSwitch(
                  icon: Icons.grid_view_rounded,
                  title: 'Compact admin tiles',
                  value: _compactTiles,
                  onChanged: (value) {
                    setState(() => _compactTiles = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AdminSectionCard(
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFFFECEE),
                  child: Icon(
                    Icons.notifications_rounded,
                    color: AppColors.bloodRed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notification permission',
                        style: TextStyle(
                          color: Color(0xFF171D24),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _permissionStatus == null
                            ? 'Check admin device push status'
                            : _permissionStatus!.name,
                        style: const TextStyle(
                          color: Color(0xFF6A7380),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  tooltip: 'Check status',
                  onPressed: _checkPushStatus,
                  icon: const Icon(Icons.refresh_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.bloodRed,
                    foregroundColor: Colors.white,
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

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.bloodRed, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF171D24),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AppColors.bloodRed,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
