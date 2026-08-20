import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../app/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_app_dialog.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _urgentAlerts = true;
  bool _eligibilityReminders = true;
  bool _cityAlerts = true;
  bool _showPhone = true;
  bool _showCity = true;
  bool _compactCards = false;
  String _language = 'English';
  String _displayMode = 'System';
  AuthorizationStatus? _permissionStatus;

  DocumentReference<Map<String, dynamic>>? get _settingsDoc {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('donorSettings').doc(uid);
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settingsDoc = _settingsDoc;
    final permission =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (settingsDoc == null) {
      if (!mounted) return;
      setState(() {
        _permissionStatus = permission.authorizationStatus;
        _isLoading = false;
      });
      return;
    }

    final snapshot = await settingsDoc.get();
    final data = snapshot.data() ?? const <String, dynamic>{};

    if (!mounted) return;
    setState(() {
      _urgentAlerts = data['urgentAlerts'] as bool? ?? true;
      _eligibilityReminders = data['eligibilityReminders'] as bool? ?? true;
      _cityAlerts = data['cityAlerts'] as bool? ?? true;
      _showPhone = data['showPhone'] as bool? ?? true;
      _showCity = data['showCity'] as bool? ?? true;
      _compactCards = data['compactCards'] as bool? ?? false;
      _language = data['language']?.toString() ?? 'English';
      _displayMode = data['displayMode']?.toString() ?? 'System';
      _permissionStatus = permission.authorizationStatus;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, Object value) async {
    final settingsDoc = _settingsDoc;
    if (settingsDoc == null) return;

    setState(() => _isSaving = true);
    try {
      await settingsDoc.set(
        {
          key: value,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _requestNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (!mounted) return;
    setState(() => _permissionStatus = settings.authorizationStatus);
    await _saveSetting(
      'notificationPermission',
      settings.authorizationStatus.name,
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => CustomAppDialog(
        icon: Icons.logout_rounded,
        title: 'Sign out?',
        message: 'You will need to sign in again to use your donor account.',
        primaryText: 'Sign out',
        secondaryText: 'Cancel',
        destructive: true,
        onPrimary: () => Navigator.pop(context, true),
        onSecondary: () => Navigator.pop(context, false),
      ),
    );

    if (confirmed != true) return;
    await _auth.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _SettingsBackdrop())),
          SafeArea(
            child: Column(
              children: [
                const _SettingsAppBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.bloodRed,
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
                          children: [
                            _SavingIndicator(isSaving: _isSaving),
                            _SettingsSection(
                              title: 'Notifications',
                              subtitle: _permissionLabel,
                              children: [
                                _ActionTile(
                                  icon: Icons.notifications_active_rounded,
                                  title: 'Notification permission',
                                  subtitle:
                                      'Allow BloodLK to send urgent donor alerts.',
                                  actionText: _permissionActionText,
                                  onTap: _requestNotificationPermission,
                                ),
                                _SwitchTile(
                                  icon: Icons.emergency_share_rounded,
                                  title: 'Urgent blood requests',
                                  subtitle:
                                      'Receive emergency alerts for matching blood needs.',
                                  value: _urgentAlerts,
                                  onChanged: (value) {
                                    setState(() => _urgentAlerts = value);
                                    _saveSetting('urgentAlerts', value);
                                  },
                                ),
                                _SwitchTile(
                                  icon: Icons.calendar_month_rounded,
                                  title: 'Eligibility reminders',
                                  subtitle:
                                      'Remind me when I can donate blood again.',
                                  value: _eligibilityReminders,
                                  onChanged: (value) {
                                    setState(
                                        () => _eligibilityReminders = value);
                                    _saveSetting('eligibilityReminders', value);
                                  },
                                ),
                                _SwitchTile(
                                  icon: Icons.location_on_rounded,
                                  title: 'City based alerts',
                                  subtitle: 'Prioritize requests near my city.',
                                  value: _cityAlerts,
                                  onChanged: (value) {
                                    setState(() => _cityAlerts = value);
                                    _saveSetting('cityAlerts', value);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _SettingsSection(
                              title: 'Language & Display',
                              subtitle: 'Choose how BloodLK feels for you.',
                              children: [
                                _DropdownTile(
                                  icon: Icons.language_rounded,
                                  title: 'Language',
                                  value: _language,
                                  values: const ['English', 'Sinhala', 'Tamil'],
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _language = value);
                                    _saveSetting('language', value);
                                  },
                                ),
                                _DropdownTile(
                                  icon: Icons.contrast_rounded,
                                  title: 'Display mode',
                                  value: _displayMode,
                                  values: const ['System', 'Light', 'Comfort'],
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _displayMode = value);
                                    _saveSetting('displayMode', value);
                                  },
                                ),
                                _SwitchTile(
                                  icon: Icons.dashboard_customize_rounded,
                                  title: 'Compact home cards',
                                  subtitle:
                                      'Use smaller dashboard cards on this device.',
                                  value: _compactCards,
                                  onChanged: (value) {
                                    setState(() => _compactCards = value);
                                    _saveSetting('compactCards', value);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _SettingsSection(
                              title: 'Privacy & Account',
                              subtitle:
                                  'Control what is visible when donors are searched.',
                              children: [
                                _SwitchTile(
                                  icon: Icons.phone_rounded,
                                  title: 'Show phone number',
                                  subtitle:
                                      'Allow requesters to call or message you.',
                                  value: _showPhone,
                                  onChanged: (value) {
                                    setState(() => _showPhone = value);
                                    _saveSetting('showPhone', value);
                                  },
                                ),
                                _SwitchTile(
                                  icon: Icons.location_city_rounded,
                                  title: 'Show city',
                                  subtitle:
                                      'Allow your city to appear in donor results.',
                                  value: _showCity,
                                  onChanged: (value) {
                                    setState(() => _showCity = value);
                                    _saveSetting('showCity', value);
                                  },
                                ),
                                _ActionTile(
                                  icon: Icons.privacy_tip_rounded,
                                  title: 'Privacy note',
                                  subtitle:
                                      'See how your donor details are used.',
                                  actionText: 'View',
                                  onTap: _showPrivacyNote,
                                ),
                                _ActionTile(
                                  icon: Icons.logout_rounded,
                                  title: 'Sign out',
                                  subtitle: 'Leave this donor account safely.',
                                  actionText: 'Sign out',
                                  destructive: true,
                                  onTap: _signOut,
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _permissionLabel {
    return switch (_permissionStatus) {
      AuthorizationStatus.authorized => 'Notifications are enabled.',
      AuthorizationStatus.provisional =>
        'Notifications are provisionally enabled.',
      AuthorizationStatus.denied => 'Notifications are currently blocked.',
      AuthorizationStatus.notDetermined =>
        'Notification permission is not set.',
      null => 'Checking notification permission...',
    };
  }

  String get _permissionActionText {
    return _permissionStatus == AuthorizationStatus.authorized
        ? 'Refresh'
        : 'Allow';
  }

  void _showPrivacyNote() {
    showDialog<void>(
      context: context,
      builder: (context) => CustomAppDialog(
        icon: Icons.privacy_tip_rounded,
        title: 'Privacy note',
        message:
            'BloodLK uses your donor details to help match urgent blood requests. Your phone number and city help requesters contact suitable donors quickly. You can change visibility preferences here.',
        primaryText: 'OK',
        onPrimary: () => Navigator.pop(context),
      ),
    );
  }
}

class _SettingsAppBar extends StatelessWidget {
  const _SettingsAppBar();

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
              'Settings',
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

class _SavingIndicator extends StatelessWidget {
  const _SavingIndicator({required this.isSaving});

  final bool isSaving;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: isSaving
          ? Container(
              key: const ValueKey('saving'),
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
                    'Saving settings...',
                    style: TextStyle(
                      color: AppColors.bloodRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('idle')),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF171D24),
                    fontSize: 17,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...children,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      value: value,
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.bloodRed,
      inactiveThumbColor: Colors.white,
      secondary: _TileIcon(icon),
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 10, 0),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF303942),
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF6A7380),
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w500,
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _DropdownTile extends StatelessWidget {
  const _DropdownTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          _TileIcon(icon),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF303942),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          DropdownButton<String>(
            value: values.contains(value) ? value : values.first,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(14),
            items: values
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(item),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.bloodRed : const Color(0xFF303942);

    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 2, 14, 2),
      leading: _TileIcon(icon),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF6A7380),
          fontSize: 12,
          height: 1.3,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: TextButton(
        onPressed: onTap,
        child: Text(actionText),
      ),
    );
  }
}

class _TileIcon extends StatelessWidget {
  const _TileIcon(this.icon);

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

class _SettingsBackdrop extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

    final rect = Rect.fromLTWH(0, 0, size.width, 180);
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
      ..moveTo(0, 132)
      ..cubicTo(size.width * 0.18, 112, size.width * 0.46, 146, size.width, 120)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wave, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
