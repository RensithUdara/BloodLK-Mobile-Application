import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_app_dialog.dart';
import 'admin_page_shell.dart';

class AdminSettingsView extends StatefulWidget {
  const AdminSettingsView({super.key});

  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  AuthorizationStatus? _permissionStatus;
  bool _isLoading = false;

  Future<void> _requestPushPermission() async {
    setState(() => _isLoading = true);
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (!mounted) return;
      setState(() => _permissionStatus = settings.authorizationStatus);

      await _showDialog(
        icon: Icons.notifications_active_rounded,
        title: 'Permission updated',
        message:
            'Notification permission is ${settings.authorizationStatus.name}.',
      );
    } catch (error) {
      if (!mounted) return;
      await _showError(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkPushStatus() async {
    setState(() => _isLoading = true);
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (!mounted) return;
      setState(() => _permissionStatus = settings.authorizationStatus);

      await _showDialog(
        icon: Icons.notifications_rounded,
        title: 'Push status',
        message:
            'Admin device notification status: ${settings.authorizationStatus.name}.',
      );
    } catch (error) {
      if (!mounted) return;
      await _showError(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showFcmToken() async {
    setState(() => _isLoading = true);
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (!mounted) return;

      if (token == null || token.trim().isEmpty) {
        await _showDialog(
          icon: Icons.vpn_key_rounded,
          title: 'No token available',
          message:
              'Firebase has not returned an FCM token for this device yet.',
        );
        return;
      }

      await Clipboard.setData(ClipboardData(text: token));
      if (!mounted) return;
      await _showDialog(
        icon: Icons.vpn_key_rounded,
        title: 'Token copied',
        message: 'The admin device FCM token was copied to the clipboard.',
      );
    } catch (error) {
      if (!mounted) return;
      await _showError(error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showFirebaseCollections() {
    return _showDialog(
      icon: Icons.storage_rounded,
      title: 'Firebase collections',
      message:
          'This admin app uses donors, emergency_request, donation_center, donorSettings, and donor notification subcollections.',
    );
  }

  Future<void> _showAdminRules() {
    return _showDialog(
      icon: Icons.verified_user_rounded,
      title: 'Admin rules',
      message:
          'Confirm request details before posting, keep center contact data updated, and use donor details only for blood donation coordination.',
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => CustomAppDialog(
        icon: Icons.logout_rounded,
        title: 'Sign out?',
        message: 'You will leave the admin panel and return to login.',
        primaryText: 'Sign Out',
        secondaryText: 'Cancel',
        destructive: true,
        onPrimary: () => Navigator.pop(context, true),
        onSecondary: () => Navigator.pop(context, false),
      ),
    );

    if (confirmed != true) return;

    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  Future<void> _showDialog({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => CustomAppDialog(
        icon: icon,
        title: title,
        message: message,
        primaryText: 'OK',
        onPrimary: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _showError(String message) {
    return showDialog<void>(
      context: context,
      builder: (context) => CustomAppDialog(
        icon: Icons.error_outline_rounded,
        title: 'Unable to complete',
        message: message,
        primaryText: 'OK',
        destructive: true,
        onPrimary: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _permissionStatus == null
        ? 'Check or request push access'
        : 'Current status: ${_permissionStatus!.name}';

    return AdminPageShell(
      title: 'Settings',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          AdminSectionCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFECEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: AppColors.bloodRed,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin controls',
                        style: TextStyle(
                          color: Color(0xFF171D24),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage device, Firebase, and access options',
                        style: TextStyle(
                          color: Color(0xFF6A7380),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingsActionCard(
            icon: Icons.notifications_active_rounded,
            title: 'Request push permission',
            subtitle: statusText,
            loading: _isLoading,
            onTap: _requestPushPermission,
          ),
          const SizedBox(height: 10),
          _SettingsActionCard(
            icon: Icons.refresh_rounded,
            title: 'Check push status',
            subtitle: statusText,
            loading: _isLoading,
            onTap: _checkPushStatus,
          ),
          const SizedBox(height: 10),
          _SettingsActionCard(
            icon: Icons.vpn_key_rounded,
            title: 'Copy FCM token',
            subtitle: 'Use for Firebase push notification testing',
            loading: _isLoading,
            onTap: _showFcmToken,
          ),
          const SizedBox(height: 10),
          _SettingsActionCard(
            icon: Icons.storage_rounded,
            title: 'Firebase collections',
            subtitle: 'View collection names used by admin features',
            onTap: _showFirebaseCollections,
          ),
          const SizedBox(height: 10),
          _SettingsActionCard(
            icon: Icons.verified_user_rounded,
            title: 'Admin rules',
            subtitle: 'Review safe donor-data handling rules',
            onTap: _showAdminRules,
          ),
          const SizedBox(height: 10),
          _SettingsActionCard(
            icon: Icons.logout_rounded,
            title: 'Sign out admin',
            subtitle: 'Return to login screen',
            destructive: true,
            onTap: _signOut,
          ),
        ],
      ),
    );
  }
}

class _SettingsActionCard extends StatelessWidget {
  const _SettingsActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.loading = false,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool loading;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final accent = destructive ? AppColors.deepMaroon : AppColors.bloodRed;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: loading ? null : onTap,
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
                child: Icon(icon, color: accent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
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
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6A7380),
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (loading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.bloodRed,
                    strokeWidth: 2.4,
                  ),
                )
              else
                Icon(Icons.chevron_right_rounded, color: accent),
            ],
          ),
        ),
      ),
    );
  }
}
