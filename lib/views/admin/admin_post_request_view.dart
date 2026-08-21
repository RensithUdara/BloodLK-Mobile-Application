import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/emergency_request.dart';
import '../../viewmodels/admin_view_model.dart';
import '../../widgets/custom_app_dialog.dart';

class AdminPostRequestView extends StatefulWidget {
  const AdminPostRequestView({super.key});

  @override
  State<AdminPostRequestView> createState() => _AdminPostRequestViewState();
}

class _AdminPostRequestViewState extends State<AdminPostRequestView> {
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
    return _AdminFunctionScaffold(
      title: 'Post Request',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            _SectionCard(
              child: Column(
                children: [
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
                    minLines: 3,
                    maxLines: 5,
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
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    return null;
  }
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

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
      child: child,
    );
  }
}

class _AdminFunctionScaffold extends StatelessWidget {
  const _AdminFunctionScaffold({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F7),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _AdminPageBackdrop())),
          SafeArea(
            child: Column(
              children: [
                _AdminPageAppBar(title: title),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminPageAppBar extends StatelessWidget {
  const _AdminPageAppBar({required this.title});

  final String title;

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
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
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

class _AdminPageBackdrop extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFFFF7F7),
    );

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

    canvas.drawPath(wave, Paint()..color = const Color(0xFFFFF7F7));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
