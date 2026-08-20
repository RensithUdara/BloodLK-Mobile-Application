import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodels/login_view_model.dart';

class AdminLoginView extends StatelessWidget {
  const AdminLoginView({super.key});

  Future<void> _signInAdmin(BuildContext context) async {
    final viewModel = context.read<LoginViewModel>();
    try {
      await viewModel.signInAdmin();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.admin);
      }
    } catch (error) {
      _showError(context, error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.bloodRed),
    );
  }

  static void goBackToLogin(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
      return;
    }

    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      backgroundColor: AppColors.warmSurface,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _AdminBackdropPainter())),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 760;
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    compact ? 72 : 104,
                    24,
                    10,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (compact ? 82 : 124),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          _HeaderText(compact: compact),
                          SizedBox(height: compact ? 14 : 24),
                          _AdminBadge(compact: compact),
                          SizedBox(height: compact ? 14 : 22),
                          Text(
                            'Sign in with your admin email\nand password.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF6A7078),
                              fontSize: compact ? 13 : 16,
                              height: 1.28,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: compact ? 14 : 22),
                          _AdminFields(
                            viewModel: viewModel,
                            compact: compact,
                          ),
                          SizedBox(height: compact ? 12 : 18),
                          _AdminButton(
                            isLoading: viewModel.isLoading,
                            compact: compact,
                            onTap: viewModel.isLoading
                                ? null
                                : () => _signInAdmin(context),
                          ),
                          SizedBox(height: compact ? 14 : 22),
                          _SecurityPanel(compact: compact),
                          const Spacer(),
                        ],
                      ),
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
                padding: const EdgeInsets.only(left: 18, top: 18),
                child: IconButton.filled(
                  tooltip: 'Back',
                  onPressed: () => AdminLoginView.goBackToLogin(context),
                  icon: const Icon(Icons.arrow_back_rounded, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.bloodRed,
                    fixedSize: const Size(54, 54),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  const _HeaderText({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Admin Login',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 24 : 34,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: compact ? 4 : 8),
        Text(
          'Staff access only',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 13 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AdminBadge extends StatelessWidget {
  const _AdminBadge({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 88.0 : 118.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.bloodRed.withValues(alpha: 0.16),
            blurRadius: 20,
            spreadRadius: 6,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.shield_rounded,
            color: AppColors.bloodRed,
            size: compact ? 50 : 68,
          ),
          Positioned(
            right: compact ? 18 : 24,
            bottom: compact ? 20 : 26,
            child: Icon(
              Icons.account_circle_rounded,
              color: AppColors.bloodRed,
              size: compact ? 26 : 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminFields extends StatelessWidget {
  const _AdminFields({required this.viewModel, required this.compact});

  final LoginViewModel viewModel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AdminField(
          controller: viewModel.adminEmailController,
          hint: 'Admin Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          compact: compact,
        ),
        SizedBox(height: compact ? 10 : 14),
        _AdminField(
          controller: viewModel.adminPasswordController,
          hint: 'Admin Password',
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          suffixIcon: Icons.visibility_off_outlined,
          compact: compact,
        ),
      ],
    );
  }
}

class _AdminField extends StatelessWidget {
  const _AdminField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.compact,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool compact;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 54 : 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        style: TextStyle(
          color: const Color(0xFF17232B),
          fontSize: compact ? 13 : 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF6F7177),
            fontSize: compact ? 13 : 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.fromLTRB(
              10,
              compact ? 7 : 8,
              10,
              compact ? 7 : 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: compact ? 38 : 46,
                  height: compact ? 38 : 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEF0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.bloodRed,
                    size: compact ? 19 : 23,
                  ),
                ),
                Container(
                  width: 1,
                  height: compact ? 26 : 32,
                  margin: const EdgeInsets.only(left: 12, right: 10),
                  color: Colors.black.withValues(alpha: 0.12),
                ),
              ],
            ),
          ),
          suffixIcon: suffixIcon == null
              ? null
              : Icon(suffixIcon, color: const Color(0xFF6F7177), size: 21),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4,
            vertical: compact ? 16 : 21,
          ),
        ),
      ),
    );
  }
}

class _AdminButton extends StatelessWidget {
  const _AdminButton({
    required this.isLoading,
    required this.compact,
    required this.onTap,
  });

  final bool isLoading;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      child: Ink(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD8141D), Color(0xFFB8000D)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.bloodRed.withValues(alpha: 0.22),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            width: double.infinity,
            height: compact ? 54 : 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.4,
                    ),
                  )
                else
                  Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: compact ? 21 : 26,
                  ),
                const SizedBox(width: 14),
                Text(
                  'ADMIN SIGN IN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 14 : 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecurityPanel extends StatelessWidget {
  const _SecurityPanel({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 10 : 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightRed),
        boxShadow: [
          BoxShadow(
            color: AppColors.bloodRed.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SecurityItem(
              icon: Icons.lock_rounded,
              title: 'Secure Access',
              subtitle: 'Protected admin dashboard',
              compact: compact,
            ),
          ),
          _PanelDivider(compact: compact),
          Expanded(
            child: _SecurityItem(
              icon: Icons.groups_rounded,
              title: 'Staff Only',
              subtitle: 'Authorized personnel access only',
              compact: compact,
            ),
          ),
          _PanelDivider(compact: compact),
          Expanded(
            child: _SecurityItem(
              icon: Icons.verified_user_rounded,
              title: 'Data Protection',
              subtitle: 'Your data is safe with us',
              compact: compact,
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityItem extends StatelessWidget {
  const _SecurityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.compact,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: compact ? 36 : 48,
          height: compact ? 36 : 48,
          decoration: const BoxDecoration(
            color: Color(0xFFFFDDE0),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.bloodRed, size: compact ? 18 : 24),
        ),
        SizedBox(height: compact ? 6 : 10),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF17232B),
            fontSize: compact ? 9 : 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: compact ? 3 : 5),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: const Color(0xFF6A7078),
            fontSize: compact ? 8 : 11,
            height: 1.3,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _PanelDivider extends StatelessWidget {
  const _PanelDivider({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: compact ? 62 : 86,
      margin: EdgeInsets.symmetric(horizontal: compact ? 5 : 8),
      color: AppColors.lightRed,
    );
  }
}

class _AdminBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _paintBase(canvas, size);
    _paintHeader(canvas, size);
    _paintDots(canvas, size);
    _paintWhiteWave(canvas, size);
  }

  void _paintBase(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFFFF), AppColors.warmSurface],
        ).createShader(rect),
    );
  }

  void _paintHeader(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.36);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD61A23), Color(0xFF98000D)],
        ).createShader(rect),
    );
  }

  void _paintWhiteWave(Canvas canvas, Size size) {
    final wave = Path()
      ..moveTo(0, size.height * 0.28)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.24,
        size.width * 0.31,
        size.height * 0.37,
        size.width * 0.5,
        size.height * 0.33,
      )
      ..cubicTo(
        size.width * 0.69,
        size.height * 0.3,
        size.width * 0.82,
        size.height * 0.24,
        size.width,
        size.height * 0.28,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(wave, Paint()..color = Colors.white);
  }

  void _paintDots(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.1);
    for (var i = 0; i < 13; i++) {
      for (var j = 0; j < 8; j++) {
        canvas.drawCircle(
          Offset(size.width - 102 + i * 8, size.height * 0.14 + j * 8),
          1.7,
          paint,
        );
        canvas.drawCircle(
          Offset(-6 + i * 8, size.height * 0.14 + j * 8),
          1.7,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
