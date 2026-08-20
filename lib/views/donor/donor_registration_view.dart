import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodels/donor_registration_view_model.dart';
import '../../widgets/custom_app_dialog.dart';

class DonorRegistrationView extends StatelessWidget {
  const DonorRegistrationView({super.key});

  Future<void> _startRegistration(
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {
    if (!formKey.currentState!.validate()) return;

    final viewModel = context.read<DonorRegistrationViewModel>();
    final daysLeft = viewModel.daysUntilEligible();

    if (daysLeft != null) {
      await showDialog<void>(
        context: context,
        builder: (context) => CustomAppDialog(
          icon: Icons.calendar_month_rounded,
          title: 'Not eligible yet',
          message:
              'Five months have not passed since your last donation. You can register in $daysLeft days.',
          primaryText: 'OK',
          onPrimary: () => Navigator.pop(context),
        ),
      );
      return;
    }

    viewModel.generateOtp();
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _OtpVerificationDialog(
        viewModel: viewModel,
        onVerify: () => _verifyOtpAndRegister(context),
      ),
    );
  }

  Future<void> _verifyOtpAndRegister(BuildContext context) async {
    final viewModel = context.read<DonorRegistrationViewModel>();

    if (!viewModel.isOtpValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP'),
          backgroundColor: AppColors.bloodRed,
        ),
      );
      return;
    }

    Navigator.pop(context);

    try {
      await viewModel.registerDonor();
      if (!context.mounted) return;

      await showDialog<void>(
        context: context,
        builder: (context) => CustomAppDialog(
          icon: Icons.verified_rounded,
          title: 'Registered successfully',
          message:
              'Thank you for joining BloodLK. Your donor profile is ready.',
          primaryText: 'Continue',
          onPrimary: () => Navigator.pop(context),
        ),
      );
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } catch (error) {
      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        builder: (context) => CustomAppDialog(
          icon: Icons.error_outline_rounded,
          title: 'Registration failed',
          message: error.toString(),
          primaryText: 'OK',
          destructive: true,
          onPrimary: () => Navigator.pop(context),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final viewModel = context.read<DonorRegistrationViewModel>();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      viewModel.updateLastDonationDate(picked);
    }
  }

  void _goBackToLogin(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DonorRegistrationViewModel>();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.warmSurface,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _DonorRegistrationBackdrop()),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 760;
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 18 : 22,
                    compact ? 130 : 152,
                    compact ? 18 : 22,
                    14,
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        _RegistrationField(
                          controller: viewModel.nameController,
                          hint: 'Full Name',
                          icon: Icons.person_rounded,
                          validator: _required('Name is required'),
                          compact: compact,
                        ),
                        _RegistrationField(
                          controller: viewModel.ageController,
                          hint: 'Age',
                          icon: Icons.calendar_month_rounded,
                          keyboardType: TextInputType.number,
                          validator: _required('Age is required'),
                          compact: compact,
                        ),
                        _RegistrationField(
                          controller: viewModel.phoneController,
                          hint: 'Phone Number',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: _required('Phone number is required'),
                          compact: compact,
                        ),
                        _RegistrationField(
                          controller: viewModel.nicController,
                          hint: 'NIC Number',
                          icon: Icons.badge_rounded,
                          validator: _required('NIC number is required'),
                          compact: compact,
                        ),
                        _RegistrationField(
                          controller: viewModel.cityController,
                          hint: 'Your City',
                          icon: Icons.location_on_rounded,
                          validator: _required('City is required'),
                          compact: compact,
                        ),
                        _BloodGroupField(
                          viewModel: viewModel,
                          compact: compact,
                        ),
                        SizedBox(height: compact ? 4 : 8),
                        _FirstTimeDonorCard(
                          value: viewModel.neverDonated,
                          compact: compact,
                          onChanged: (value) =>
                              viewModel.updateNeverDonated(value),
                        ),
                        if (!viewModel.neverDonated) ...[
                          SizedBox(height: compact ? 8 : 12),
                          _LastDonationDateTile(
                            date: viewModel.lastDonationDate,
                            compact: compact,
                            onTap: () => _selectDate(context),
                          ),
                        ],
                        SizedBox(height: compact ? 12 : 18),
                        _RegisterButton(
                          compact: compact,
                          onTap: () => _startRegistration(context, formKey),
                        ),
                        SizedBox(height: compact ? 10 : 14),
                        const _SafetyNote(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 18, top: 14),
                child: IconButton.filled(
                  tooltip: 'Back',
                  onPressed: () => _goBackToLogin(context),
                  icon: const Icon(Icons.arrow_back_rounded, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.bloodRed,
                    fixedSize: const Size(48, 48),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: IgnorePointer(
              child: Padding(
                padding: EdgeInsets.only(top: compactHeaderTop(context)),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Become a Donor',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compactHeaderFont(context),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Join us and help save lives',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: compactHeaderSubFont(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  FormFieldValidator<String> _required(String message) {
    return (value) => value == null || value.trim().isEmpty ? message : null;
  }

  double compactHeaderTop(BuildContext context) {
    return MediaQuery.sizeOf(context).height < 760 ? 50 : 60;
  }

  double compactHeaderFont(BuildContext context) {
    return MediaQuery.sizeOf(context).height < 760 ? 23 : 28;
  }

  double compactHeaderSubFont(BuildContext context) {
    return MediaQuery.sizeOf(context).height < 760 ? 12 : 14;
  }
}

class _OtpVerificationDialog extends StatefulWidget {
  const _OtpVerificationDialog({
    required this.viewModel,
    required this.onVerify,
  });

  final DonorRegistrationViewModel viewModel;
  final Future<void> Function() onVerify;

  @override
  State<_OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<_OtpVerificationDialog> {
  static const int _resendSeconds = 45;

  late final List<TextEditingController> _digitControllers;
  late final List<FocusNode> _focusNodes;
  Timer? _timer;
  int _secondsLeft = _resendSeconds;

  @override
  void initState() {
    super.initState();
    _digitControllers = List.generate(
      4,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(4, (index) => FocusNode());
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _digitControllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = _resendSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
        return;
      }

      setState(() => _secondsLeft--);
    });
  }

  void _onDigitChanged(String value, int index) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '').split('');
      for (var i = 0; i < _digitControllers.length; i++) {
        _digitControllers[i].text = i < digits.length ? digits[i] : '';
      }
      final nextIndex = digits.length.clamp(0, _focusNodes.length - 1);
      _focusNodes[nextIndex].requestFocus();
    } else if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    _syncOtpController();
  }

  void _onDigitKey(KeyEvent event, int index) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey != LogicalKeyboardKey.backspace) return;
    if (_digitControllers[index].text.isNotEmpty || index == 0) return;

    _focusNodes[index - 1].requestFocus();
  }

  void _syncOtpController() {
    widget.viewModel.otpController.text =
        _digitControllers.map((controller) => controller.text).join();
  }

  void _resendOtp() {
    if (_secondsLeft > 0) return;

    widget.viewModel.generateOtp();
    for (final controller in _digitControllers) {
      controller.clear();
    }
    widget.viewModel.otpController.clear();
    _focusNodes.first.requestFocus();
    setState(() => _secondsLeft = _resendSeconds);
    _startTimer();
  }

  String get _countdown {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 380 || size.height < 720;

    return Dialog(
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 26 : 34,
        vertical: 20,
      ),
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              compact ? 18 : 24,
              compact ? 24 : 28,
              compact ? 18 : 24,
              compact ? 18 : 24,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 36,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -2,
                  top: -2,
                  child: _OtpCloseButton(
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _OtpShieldIcon(compact: compact),
                    SizedBox(height: compact ? 12 : 16),
                    Text(
                      'OTP Verification',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF13282B),
                        fontSize: compact ? 21 : 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "We've sent a 4-digit OTP to your\nregistered phone number",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF68707A),
                        fontSize: compact ? 12.5 : 14,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: compact ? 12 : 14),
                    _GeneratedOtpBadge(otp: widget.viewModel.generatedOtp),
                    SizedBox(height: compact ? 16 : 20),
                    _OtpDigitFields(
                      controllers: _digitControllers,
                      focusNodes: _focusNodes,
                      compact: compact,
                      onChanged: _onDigitChanged,
                      onKeyEvent: _onDigitKey,
                    ),
                    SizedBox(height: compact ? 14 : 18),
                    _ResendTimerRow(
                      secondsLeft: _secondsLeft,
                      countdown: _countdown,
                      onResend: _resendOtp,
                    ),
                    SizedBox(height: compact ? 18 : 22),
                    _OtpActionButtons(
                      compact: compact,
                      onCancel: () => Navigator.pop(context),
                      onVerify: widget.onVerify,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpShieldIcon extends StatelessWidget {
  const _OtpShieldIcon({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final outerSize = compact ? 82.0 : 100.0;
    final innerSize = compact ? 52.0 : 64.0;

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: outerSize,
            height: outerSize,
            decoration: BoxDecoration(
              color: AppColors.bloodRed.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: outerSize * 0.72,
            height: outerSize * 0.72,
            decoration: BoxDecoration(
              color: AppColors.bloodRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
          ),
          CustomPaint(
            size: Size(outerSize, outerSize),
            painter: _OtpDotsPainter(),
          ),
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFF4C63), Color(0xFFE30620)],
              ),
              borderRadius: BorderRadius.circular(compact ? 16 : 20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.bloodRed.withValues(alpha: 0.26),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(
              Icons.lock_rounded,
              color: Colors.white,
              size: compact ? 24 : 30,
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpDotsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.bloodRed.withValues(alpha: 0.16);
    final center = Offset(size.width / 2, size.height / 2);
    const dots = 14;

    for (var index = 0; index < dots; index++) {
      final angle = (index / dots) * 6.28318;
      final radius = size.width * 0.43;
      final dotCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawCircle(dotCenter, index.isEven ? 3.4 : 2.4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GeneratedOtpBadge extends StatelessWidget {
  const _GeneratedOtpBadge({required this.otp});

  final String otp;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 380;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 18 : 22,
        vertical: compact ? 9 : 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: const Color(0xFF596067),
            fontSize: compact ? 18 : 21,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
          children: [
            const TextSpan(text: 'OTP: '),
            TextSpan(
              text: otp,
              style: const TextStyle(
                color: AppColors.bloodRed,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpDigitFields extends StatelessWidget {
  const _OtpDigitFields({
    required this.controllers,
    required this.focusNodes,
    required this.compact,
    required this.onChanged,
    required this.onKeyEvent,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool compact;
  final void Function(String value, int index) onChanged;
  final void Function(KeyEvent event, int index) onKeyEvent;

  @override
  Widget build(BuildContext context) {
    final boxSize = compact ? 42.0 : 52.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(controllers.length, (index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 5),
          child: Focus(
            onKeyEvent: (node, event) {
              onKeyEvent(event, index);
              return KeyEventResult.ignored;
            },
            child: SizedBox(
              width: boxSize,
              height: boxSize,
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                textInputAction: index == controllers.length - 1
                    ? TextInputAction.done
                    : TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                style: TextStyle(
                  color: const Color(0xFF13282B),
                  fontSize: compact ? 18 : 22,
                  fontWeight: FontWeight.w900,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.bloodRed,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.bloodRed,
                      width: 1.8,
                    ),
                  ),
                ),
                onChanged: (value) => onChanged(value, index),
                onSubmitted: (_) {
                  if (index == controllers.length - 1) {
                    FocusScope.of(context).unfocus();
                  }
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ResendTimerRow extends StatelessWidget {
  const _ResendTimerRow({
    required this.secondsLeft,
    required this.countdown,
    required this.onResend,
  });

  final int secondsLeft;
  final String countdown;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    if (secondsLeft == 0) {
      return TextButton.icon(
        onPressed: onResend,
        icon: const Icon(Icons.refresh_rounded, size: 19),
        label: const Text('Resend OTP'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.bloodRed,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.access_time_rounded,
          color: AppColors.bloodRed,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          'Resend OTP in ',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          countdown,
          style: const TextStyle(
            color: AppColors.bloodRed,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _OtpActionButtons extends StatelessWidget {
  const _OtpActionButtons({
    required this.compact,
    required this.onCancel,
    required this.onVerify,
  });

  final bool compact;
  final VoidCallback onCancel;
  final Future<void> Function() onVerify;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: compact ? 10 : 9,
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF68707A),
              side: BorderSide(color: Colors.grey.shade300, width: 1.3),
              minimumSize: Size(0, compact ? 46 : 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: TextStyle(
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        SizedBox(width: compact ? 10 : 12),
        Expanded(
          flex: compact ? 15 : 16,
          child: FilledButton(
            onPressed: onVerify,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.bloodRed,
              foregroundColor: Colors.white,
              minimumSize: Size(0, compact ? 46 : 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: TextStyle(
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Register',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: compact ? 12 : 14),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: compact ? 18 : 21),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OtpCloseButton extends StatelessWidget {
  const _OtpCloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Close',
      onPressed: onTap,
      icon: const Icon(Icons.close_rounded, size: 24),
      style: IconButton.styleFrom(
        foregroundColor: AppColors.bloodRed,
        backgroundColor: Colors.white,
        fixedSize: const Size(44, 44),
        side: BorderSide(color: AppColors.lightRed.withValues(alpha: 0.9)),
      ),
    );
  }
}

class _RegistrationField extends StatelessWidget {
  const _RegistrationField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.validator,
    required this.compact,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final bool compact;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? 8 : 10),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          color: const Color(0xFF17232B),
          fontSize: compact ? 13 : 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: _fieldDecoration(hint, icon, compact: compact),
      ),
    );
  }
}

class _BloodGroupField extends StatelessWidget {
  const _BloodGroupField({required this.viewModel, required this.compact});

  final DonorRegistrationViewModel viewModel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: viewModel.selectedBloodGroup,
      decoration: _fieldDecoration(
        'Blood Group',
        Icons.water_drop_rounded,
        compact: compact,
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      items: AppConstants.bloodGroups
          .map(
            (group) => DropdownMenuItem(
              value: group,
              child: Text(
                group,
                style: TextStyle(
                  color: const Color(0xFF17232B),
                  fontSize: compact ? 14 : 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) viewModel.updateBloodGroup(value);
      },
    );
  }
}

class _FirstTimeDonorCard extends StatelessWidget {
  const _FirstTimeDonorCard({
    required this.value,
    required this.compact,
    required this.onChanged,
  });

  final bool value;
  final bool compact;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBED),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 42 : 48,
            height: compact ? 42 : 48,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD1D6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.monitor_heart_rounded,
              color: AppColors.bloodRed,
              size: compact ? 23 : 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'First time donor',
                  style: TextStyle(
                    color: const Color(0xFF17232B),
                    fontSize: compact ? 14 : 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Help us serve you better',
                  style: TextStyle(
                    color: const Color(0xFF5E6872),
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.bloodRed,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade300,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _LastDonationDateTile extends StatelessWidget {
  const _LastDonationDateTile({
    required this.date,
    required this.compact,
    required this.onTap,
  });

  final DateTime? date;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.lightRed),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded, color: AppColors.bloodRed),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                date == null
                    ? 'Select last donation date'
                    : DateFormat('yyyy-MM-dd').format(date!),
                style: TextStyle(
                  color: const Color(0xFF17232B),
                  fontSize: compact ? 13 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.edit_rounded, color: Color(0xFF5E6872)),
          ],
        ),
      ),
    );
  }
}

class _RegisterButton extends StatelessWidget {
  const _RegisterButton({required this.compact, required this.onTap});

  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEF161F), Color(0xFFC9000B)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.bloodRed.withValues(alpha: 0.22),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            width: double.infinity,
            height: compact ? 48 : 54,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Register as a Donor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 14 : 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SafetyNote extends StatelessWidget {
  const _SafetyNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user_outlined, color: AppColors.bloodRed, size: 18),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            'Your information is safe and secure with us.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF5E6872),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

InputDecoration _fieldDecoration(
  String hint,
  IconData icon, {
  required bool compact,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: const Color(0xFF6F7177),
      fontSize: compact ? 13 : 14,
      fontWeight: FontWeight.w500,
    ),
    prefixIcon: Padding(
      padding: EdgeInsets.fromLTRB(12, compact ? 7 : 8, 10, compact ? 7 : 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.bloodRed, size: compact ? 20 : 22),
          Container(
            width: 1,
            height: compact ? 24 : 28,
            margin: EdgeInsets.only(
              left: compact ? 12 : 14,
              right: compact ? 8 : 10,
            ),
            color: Colors.black.withValues(alpha: 0.12),
          ),
        ],
      ),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: EdgeInsets.symmetric(
      horizontal: 16,
      vertical: compact ? 12 : 15,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: AppColors.lightRed.withValues(alpha: 0.6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: AppColors.bloodRed, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: AppColors.bloodRed),
    ),
  );
}

class _DonorRegistrationBackdrop extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _paintBase(canvas, size);
    _paintHeader(canvas, size);
    _paintHeaderDrops(canvas, size);
    _paintWhiteWave(canvas, size);
  }

  void _paintBase(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
  }

  void _paintHeader(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.31);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD61A23), Color(0xFF98000D)],
        ).createShader(rect),
    );

    final wave = Path()
      ..moveTo(0, size.height * 0.17)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.13,
        size.width * 0.28,
        size.height * 0.25,
        size.width * 0.48,
        size.height * 0.22,
      )
      ..cubicTo(
        size.width * 0.69,
        size.height * 0.18,
        size.width * 0.78,
        size.height * 0.32,
        size.width,
        size.height * 0.23,
      )
      ..lineTo(size.width, size.height * 0.31)
      ..lineTo(0, size.height * 0.31)
      ..close();

    canvas.drawPath(wave, Paint()..color = const Color(0xFFEF1C26));
  }

  void _paintWhiteWave(Canvas canvas, Size size) {
    final wave = Path()
      ..moveTo(0, size.height * 0.24)
      ..cubicTo(
        size.width * 0.16,
        size.height * 0.2,
        size.width * 0.32,
        size.height * 0.27,
        size.width * 0.5,
        size.height * 0.27,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.27,
        size.width * 0.84,
        size.height * 0.33,
        size.width,
        size.height * 0.25,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wave, Paint()..color = Colors.white);
  }

  void _paintHeaderDrops(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    _drawDrop(canvas, Offset(size.width * 0.78, size.height * 0.08), 42, paint);
    _drawDrop(canvas, Offset(size.width * 0.88, size.height * 0.12), 66, paint);
    _drawDrop(canvas, Offset(size.width * 0.72, size.height * 0.14), 50, paint);
  }

  void _drawDrop(Canvas canvas, Offset top, double size, Paint paint) {
    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..cubicTo(
        top.dx - size * 0.5,
        top.dy + size * 0.58,
        top.dx - size * 0.38,
        top.dy + size,
        top.dx,
        top.dy + size,
      )
      ..cubicTo(
        top.dx + size * 0.38,
        top.dy + size,
        top.dx + size * 0.5,
        top.dy + size * 0.58,
        top.dx,
        top.dy,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
