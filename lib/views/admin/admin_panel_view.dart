import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donor.dart';
import '../../data/models/emergency_request.dart';
import '../../viewmodels/admin_view_model.dart';
import '../../widgets/custom_app_dialog.dart';
import '../donor/donor_details_view.dart';
import '../home/donation_centers_view.dart';

class AdminPanelView extends StatefulWidget {
  const AdminPanelView({super.key});

  @override
  State<AdminPanelView> createState() => _AdminPanelViewState();
}

class _AdminPanelViewState extends State<AdminPanelView> {
  final _postRequestKey = GlobalKey();
  final _groupAlertsKey = GlobalKey();
  final _donorsKey = GlobalKey();

  Future<void> _sendNotification(
    BuildContext context,
    String bloodType,
  ) async {
    final viewModel = context.read<AdminViewModel>();

    try {
      final count = await viewModel.sendGroupNotification(bloodType);
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.bloodRed,
          content: Text('$bloodType: notification sent to $count donors'),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.bloodRed,
          content: Text('Error: $error'),
        ),
      );
    }
  }

  void _scrollTo(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext == null) return;

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  void _openDonationCenters() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DonationCentersView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AdminViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _AdminBackdrop())),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: _AdminHeader()),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        _AdminFunctionGrid(
                          onPostRequest: () => _scrollTo(_postRequestKey),
                          onGroupAlerts: () => _scrollTo(_groupAlertsKey),
                          onDonors: () => _scrollTo(_donorsKey),
                          onCenters: _openDonationCenters,
                        ),
                        const SizedBox(height: 16),
                        KeyedSubtree(
                          key: _postRequestKey,
                          child: const _EmergencyRequestForm(),
                        ),
                        const SizedBox(height: 18),
                        KeyedSubtree(
                          key: _groupAlertsKey,
                          child: const _SectionTitle(
                            'Send group notification',
                          ),
                        ),
                        const SizedBox(height: 10),
                        _BloodGroupActions(onTap: (type) {
                          _sendNotification(context, type);
                        }),
                        const SizedBox(height: 18),
                        KeyedSubtree(
                          key: _donorsKey,
                          child: const _SectionTitle('Donors'),
                        ),
                      ],
                    ),
                  ),
                ),
                StreamBuilder<List<Donor>>(
                  stream: viewModel.watchDonors(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _AdminState(
                          icon: Icons.error_outline_rounded,
                          title: 'Unable to load donors',
                          message: snapshot.error.toString(),
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.bloodRed,
                          ),
                        ),
                      );
                    }

                    final donors = snapshot.data!;
                    if (donors.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: _AdminState(
                          icon: Icons.groups_rounded,
                          title: 'No donors found',
                          message: 'Registered donors will appear here.',
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      sliver: SliverList.separated(
                        itemCount: donors.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          return _DonorListTile(donor: donors[index]);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 18, 0),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Back',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Admin Panel',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }
}

class _AdminFunctionGrid extends StatelessWidget {
  const _AdminFunctionGrid({
    required this.onPostRequest,
    required this.onGroupAlerts,
    required this.onDonors,
    required this.onCenters,
  });

  final VoidCallback onPostRequest;
  final VoidCallback onGroupAlerts;
  final VoidCallback onDonors;
  final VoidCallback onCenters;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _AdminFunctionAction(
        title: 'Post Request',
        icon: Icons.add_circle_rounded,
        onTap: onPostRequest,
      ),
      _AdminFunctionAction(
        title: 'Group Alerts',
        icon: Icons.notifications_active_rounded,
        onTap: onGroupAlerts,
      ),
      _AdminFunctionAction(
        title: 'Donors',
        icon: Icons.groups_rounded,
        onTap: onDonors,
      ),
      _AdminFunctionAction(
        title: 'Centers',
        icon: Icons.local_hospital_rounded,
        onTap: onCenters,
      ),
      _AdminFunctionAction(
        title: 'Emergency',
        icon: Icons.emergency_share_rounded,
        onTap: onPostRequest,
      ),
      _AdminFunctionAction(
        title: 'Blood Types',
        icon: Icons.bloodtype_rounded,
        onTap: onGroupAlerts,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: compact ? 8 : 10,
            mainAxisSpacing: compact ? 9 : 11,
            childAspectRatio: compact ? 0.95 : 1.03,
          ),
          itemBuilder: (context, index) {
            return _AdminFunctionTile(action: actions[index]);
          },
        );
      },
    );
  }
}

class _AdminFunctionAction {
  const _AdminFunctionAction({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
}

class _AdminFunctionTile extends StatelessWidget {
  const _AdminFunctionTile({required this.action});

  final _AdminFunctionAction action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: action.onTap,
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
                child: Icon(
                  action.icon,
                  color: AppColors.bloodRed,
                  size: 26,
                ),
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

class _EmergencyRequestForm extends StatefulWidget {
  const _EmergencyRequestForm();

  @override
  State<_EmergencyRequestForm> createState() => _EmergencyRequestFormState();
}

class _EmergencyRequestFormState extends State<_EmergencyRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _patientController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _noteController = TextEditingController();

  String _bloodGroup = AppConstants.bloodGroups.first;
  bool _isPosting = false;

  @override
  void dispose() {
    _patientController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _postRequest() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isPosting = true);
    try {
      await context.read<AdminViewModel>().postEmergencyRequest(
            EmergencyRequest(
              bloodGroup: _bloodGroup,
              patientName: _patientController.text,
              location: _locationController.text,
              contactNumber: _contactController.text,
              note: _noteController.text,
              createdAt: DateTime.now(),
            ),
          );

      if (!mounted) return;
      _patientController.clear();
      _locationController.clear();
      _contactController.clear();
      _noteController.clear();

      await showDialog<void>(
        context: context,
        builder: (context) => CustomAppDialog(
          icon: Icons.emergency_share_rounded,
          title: 'Request posted',
          message:
              'Emergency request for $_bloodGroup blood donors was saved successfully.',
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
          title: 'Unable to post',
          message: error.toString(),
          primaryText: 'OK',
          destructive: true,
          onPrimary: () => Navigator.pop(context),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Post emergency request',
              style: TextStyle(
                color: Color(0xFF2B171A),
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 154,
                  child: DropdownButtonFormField<String>(
                    initialValue: _bloodGroup,
                    isExpanded: true,
                    decoration: _inputDecoration('Blood group'),
                    borderRadius: BorderRadius.circular(14),
                    items: AppConstants.bloodGroups
                        .map(
                          (group) => DropdownMenuItem(
                            value: group,
                            child: Text(group),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _bloodGroup = value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _patientController,
                    decoration: _inputDecoration('Patient name'),
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _locationController,
              decoration: _inputDecoration('Hospital or location'),
              validator: _required,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _contactController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Contact number'),
              validator: _required,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _noteController,
              minLines: 2,
              maxLines: 3,
              decoration: _inputDecoration('Note'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isPosting ? null : _postRequest,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.bloodRed,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _isPosting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.upload_rounded),
              label: Text(
                _isPosting ? 'Posting...' : 'Post Request',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      filled: true,
      fillColor: const Color(0xFFFFFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: _fieldBorder(),
      enabledBorder: _fieldBorder(),
      focusedBorder: _fieldBorder(color: AppColors.bloodRed),
      errorBorder: _fieldBorder(color: AppColors.bloodRed),
      focusedErrorBorder: _fieldBorder(color: AppColors.bloodRed),
    );
  }

  OutlineInputBorder _fieldBorder({Color color = const Color(0xFFFFD9D9)}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
  }
}

class _BloodGroupActions extends StatelessWidget {
  const _BloodGroupActions({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 10,
      children: AppConstants.bloodGroups.map((type) {
        return Material(
          color: AppColors.bloodRed,
          borderRadius: BorderRadius.circular(22),
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => onTap(type),
            child: Container(
              width: 48,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.bloodRed.withValues(alpha: 0.22),
                    blurRadius: 9,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                type,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DonorListTile extends StatelessWidget {
  const _DonorListTile({required this.donor});

  final Donor donor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DonorDetailsView(donor: donor),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFECEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.bloodRed,
                  size: 28,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donor.name.isEmpty ? 'Unnamed donor' : donor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF171D24),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.bloodtype_rounded,
                          color: AppColors.bloodRed,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Blood group: ${donor.bloodGroup}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF7B5960),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFD49AA0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF2B171A),
        fontSize: 14,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _AdminState extends StatelessWidget {
  const _AdminState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFFFECEE),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.bloodRed, size: 34),
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
    );
  }
}

class _AdminBackdrop extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFF7F7),
    );

    final rect = Rect.fromLTWH(0, 0, size.width, 120);
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
      ..moveTo(0, 86)
      ..cubicTo(size.width * 0.18, 68, size.width * 0.46, 100, size.width, 76)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wave, Paint()..color = const Color(0xFFFFF7F7));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
