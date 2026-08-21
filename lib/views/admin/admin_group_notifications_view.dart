import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodels/admin_view_model.dart';
import '../../widgets/custom_app_dialog.dart';
import 'admin_page_shell.dart';

class AdminGroupNotificationsView extends StatefulWidget {
  const AdminGroupNotificationsView({super.key});

  @override
  State<AdminGroupNotificationsView> createState() =>
      _AdminGroupNotificationsViewState();
}

class _AdminGroupNotificationsViewState
    extends State<AdminGroupNotificationsView> {
  final Set<String> _selectedGroups = <String>{};
  bool _isSending = false;

  Future<void> _confirmAndSend() async {
    if (_selectedGroups.isEmpty || _isSending) return;

    final groups = _selectedGroups.toList();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => CustomAppDialog(
        icon: Icons.notifications_active_rounded,
        title: 'Send group alert?',
        message:
            'This will send urgent blood request notifications to ${groups.join(', ')} donors.',
        primaryText: 'Send',
        secondaryText: 'Cancel',
        onPrimary: () => Navigator.pop(context, true),
        onSecondary: () => Navigator.pop(context, false),
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSending = true);
    try {
      var totalCount = 0;
      final viewModel = context.read<AdminViewModel>();

      for (final group in groups) {
        totalCount += await viewModel.sendGroupNotification(group);
      }

      if (!mounted) return;
      setState(() => _selectedGroups.clear());

      await showDialog<void>(
        context: context,
        builder: (context) => CustomAppDialog(
          icon: Icons.check_circle_rounded,
          title: 'Alerts sent',
          message:
              'Notifications were sent for ${groups.join(', ')}. Total donors notified: $totalCount.',
          primaryText: 'OK',
          onPrimary: () => Navigator.pop(context),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => CustomAppDialog(
          icon: Icons.error_outline_rounded,
          title: 'Unable to send',
          message: error.toString(),
          primaryText: 'OK',
          destructive: true,
          onPrimary: () => Navigator.pop(context),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _toggleGroup(String group) {
    if (_isSending) return;
    setState(() {
      if (_selectedGroups.contains(group)) {
        _selectedGroups.remove(group);
      } else {
        _selectedGroups.add(group);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedGroups = _selectedGroups.toList();

    return AdminPageShell(
      title: 'Group Alerts',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
        children: [
          AdminSectionCard(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Send group notification',
                  style: TextStyle(
                    color: Color(0xFF2B171A),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select one or more blood groups before sending.',
                  style: TextStyle(
                    color: Color(0xFF6A7380),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppConstants.bloodGroups.map((type) {
                    final selected = _selectedGroups.contains(type);
                    return _BloodGroupChip(
                      label: type,
                      selected: selected,
                      onTap: () => _toggleGroup(type),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                _SelectedGroupList(groups: selectedGroups),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _selectedGroups.isEmpty || _isSending
                      ? null
                      : _confirmAndSend,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.bloodRed,
                    disabledBackgroundColor: const Color(0xFFFFC9CE),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    _isSending ? 'Sending...' : 'Send Notification',
                    style: const TextStyle(fontWeight: FontWeight.w900),
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

class _BloodGroupChip extends StatelessWidget {
  const _BloodGroupChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.bloodRed : Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 58,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppColors.bloodRed : const Color(0xFFFFD9D9),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.bloodRed,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectedGroupList extends StatelessWidget {
  const _SelectedGroupList({required this.groups});

  final List<String> groups;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAFA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFFE1E1)),
        ),
        child: const Text(
          'No blood groups selected',
          style: TextStyle(
            color: Color(0xFF7B6670),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selected groups',
          style: TextStyle(
            color: Color(0xFF2B171A),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        ...groups.map(
          (group) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFE1E1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.bloodtype_rounded,
                    color: AppColors.bloodRed,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$group donors',
                      style: const TextStyle(
                        color: Color(0xFF2B171A),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.bloodRed,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
