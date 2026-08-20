import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodels/login_view_model.dart';

class DonorCreateAccountView extends StatelessWidget {
  const DonorCreateAccountView({super.key});

  Future<void> _createAccount(BuildContext context) async {
    final viewModel = context.read<LoginViewModel>();
    try {
      await viewModel.createDonorAccount();
      if (!context.mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.donorRegistration);
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
          Positioned.fill(
              child: CustomPaint(painter: _CreateBackdropPainter())),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 720;
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    compact ? 62 : 82,
                    24,
                    8,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - (compact ? 70 : 94),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          _LogoCard(compact: compact),
                          SizedBox(height: compact ? 10 : 18),
                          _TitleBlock(compact: compact),
                          SizedBox(height: compact ? 12 : 18),
                          _AuthFields(
                            emailController: viewModel.donorEmailController,
                            passwordController:
                                viewModel.donorPasswordController,
                            compact: compact,
                          ),
                          SizedBox(height: compact ? 8 : 12),
                          _PasswordHint(compact: compact),
                          SizedBox(height: compact ? 10 : 16),
                          _PrimaryButton(
                            isLoading: viewModel.isLoading,
                            compact: compact,
                            onTap: viewModel.isLoading
                                ? null
                                : () => _createAccount(context),
                          ),
                          SizedBox(height: compact ? 12 : 18),
                          const _DividerDrop(),
                          SizedBox(height: compact ? 8 : 12),
                          const _SignInPrompt(),
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
                  onPressed: () =>
                      DonorCreateAccountView.goBackToLogin(context),
                  icon: const Icon(Icons.chevron_left_rounded, size: 32),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF17232B),
                    fixedSize: const Size(56, 56),
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

class _LogoCard extends StatelessWidget {
  const _LogoCard({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 92.0 : 112.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(compact ? 20 : 26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(compact ? 9 : 12),
        child: Image.asset(AppConstants.logoAsset, fit: BoxFit.contain),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Create Your',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF101820),
            fontSize: compact ? 24 : 30,
            height: 1.03,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Donor Account',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.bloodRed,
            fontSize: compact ? 25 : 31,
            height: 1.03,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: compact ? 8 : 12),
        Text(
          'Use this email and password to sign in later.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF3E4650),
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _AuthFields extends StatelessWidget {
  const _AuthFields({
    required this.emailController,
    required this.passwordController,
    required this.compact,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AuthField(
          controller: emailController,
          hint: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          compact: compact,
        ),
        SizedBox(height: compact ? 10 : 14),
        _AuthField(
          controller: passwordController,
          hint: 'Password',
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          suffixIcon: Icons.visibility_off_outlined,
          compact: compact,
        ),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
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
      height: compact ? 56 : 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightRed),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
          fontSize: compact ? 14 : 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF6F7177),
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding:
                EdgeInsets.fromLTRB(10, compact ? 7 : 8, 10, compact ? 7 : 8),
            child: Container(
              width: compact ? 40 : 46,
              height: compact ? 40 : 46,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEF0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: AppColors.bloodRed,
                size: compact ? 20 : 23,
              ),
            ),
          ),
          suffixIcon: suffixIcon == null
              ? null
              : Icon(suffixIcon, color: const Color(0xFF6F7177), size: 21),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4,
            vertical: compact ? 17 : 21,
          ),
        ),
      ),
    );
  }
}

class _PasswordHint extends StatelessWidget {
  const _PasswordHint({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: compact ? 30 : 36,
          height: compact ? 30 : 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.bloodRed.withValues(alpha: 0.12),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(
            Icons.verified_user_rounded,
            color: AppColors.bloodRed,
            size: compact ? 18 : 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Use 8+ characters with a mix of letters, numbers & symbols.',
            style: TextStyle(
              color: const Color(0xFF303942),
              fontSize: compact ? 10 : 12,
              height: 1.25,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
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
            colors: [Color(0xFFEF161F), Color(0xFFC9000B)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.bloodRed.withValues(alpha: 0.24),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            width: double.infinity,
            height: compact ? 54 : 62,
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
                    Icons.person_add_alt_1_rounded,
                    color: Colors.white,
                    size: compact ? 23 : 27,
                  ),
                const SizedBox(width: 12),
                Text(
                  'CREATE ACCOUNT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 14 : 16,
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

class _DividerDrop extends StatelessWidget {
  const _DividerDrop();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.lightRed)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Icon(Icons.water_drop_outlined, color: AppColors.bloodRed),
        ),
        Expanded(child: Container(height: 1, color: AppColors.lightRed)),
      ],
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => DonorCreateAccountView.goBackToLogin(context),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Already have an account?  ',
            style: TextStyle(
              color: Color(0xFF303942),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Sign in',
            style: TextStyle(
              color: AppColors.bloodRed,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, color: AppColors.bloodRed),
        ],
      ),
    );
  }
}

class _CreateBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _paintBase(canvas, size);
    _paintDropPattern(canvas, size);
    _paintTopWave(canvas, size);
    _paintBottomWave(canvas, size);
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

  void _paintTopWave(Canvas canvas, Size size) {
    final path = Path()
      ..lineTo(0, size.height * 0.2)
      ..cubicTo(
        size.width * 0.14,
        size.height * 0.29,
        size.width * 0.25,
        size.height * 0.18,
        size.width * 0.43,
        size.height * 0.22,
      )
      ..cubicTo(
        size.width * 0.64,
        size.height * 0.27,
        size.width * 0.82,
        size.height * 0.25,
        size.width,
        size.height * 0.16,
      )
      ..lineTo(size.width, 0)
      ..close();

    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.32);
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF51C25), Color(0xFFC9000B)],
        ).createShader(rect),
    );
  }

  void _paintBottomWave(Canvas canvas, Size size) {
    final paleWave = Path()
      ..moveTo(0, size.height * 0.83)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.88,
        size.width * 0.24,
        size.height * 0.88,
        size.width * 0.4,
        size.height * 0.84,
      )
      ..cubicTo(
        size.width * 0.62,
        size.height * 0.78,
        size.width * 0.72,
        size.height * 0.88,
        size.width,
        size.height * 0.78,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      paleWave,
      Paint()..color = AppColors.lightRed.withValues(alpha: 0.5),
    );

    final redWave = Path()
      ..moveTo(0, size.height * 0.89)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.94,
        size.width * 0.25,
        size.height * 0.93,
        size.width * 0.4,
        size.height * 0.88,
      )
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.82,
        size.width * 0.69,
        size.height * 0.94,
        size.width,
        size.height * 0.84,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final rect = Rect.fromLTWH(0, size.height * 0.82, size.width, size.height);
    canvas.drawPath(
      redWave,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF31520), Color(0xFFC4000B)],
        ).createShader(rect),
    );
  }

  void _paintDropPattern(Canvas canvas, Size size) {
    final redPaint = Paint()
      ..color = AppColors.bloodRed.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.3;
    final whitePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.3;

    final drops = <Offset>[
      Offset(size.width * 0.15, size.height * 0.05),
      Offset(size.width * 0.38, size.height * 0.09),
      Offset(size.width * 0.65, size.height * 0.07),
      Offset(size.width * 0.88, size.height * 0.04),
      Offset(size.width * 0.16, size.height * 0.31),
      Offset(size.width * 0.9, size.height * 0.32),
    ];

    for (final drop in drops) {
      _drawDrop(
        canvas,
        drop,
        size.width * 0.09,
        drop.dy < size.height * 0.2 ? whitePaint : redPaint,
      );
    }
  }

  void _drawDrop(Canvas canvas, Offset top, double size, Paint paint) {
    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..cubicTo(
        top.dx - size * 0.48,
        top.dy + size * 0.58,
        top.dx - size * 0.38,
        top.dy + size,
        top.dx,
        top.dy + size,
      )
      ..cubicTo(
        top.dx + size * 0.38,
        top.dy + size,
        top.dx + size * 0.48,
        top.dy + size * 0.58,
        top.dx,
        top.dy,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
