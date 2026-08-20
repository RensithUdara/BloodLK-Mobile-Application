import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodels/login_view_model.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  Future<void> _signInDonor(BuildContext context) async {
    final viewModel = context.read<LoginViewModel>();
    try {
      final destination = await viewModel.signInDonor();
      if (!context.mounted) return;

      Navigator.pushReplacementNamed(
        context,
        destination == LoginDestination.donorSearch
            ? AppRoutes.home
            : AppRoutes.donorRegistration,
      );
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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final isBusy = viewModel.isLoading;

    return Scaffold(
      backgroundColor: AppColors.warmSurface,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _LoginBackdropPainter())),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 760;
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 36,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          SizedBox(height: compact ? 38 : 58),
                          const _LogoCard(),
                          SizedBox(height: compact ? 10 : 14),
                          _BrandTitle(compact: compact),
                          SizedBox(height: compact ? 12 : 16),
                          const _FeatureStrip(),
                          SizedBox(height: compact ? 10 : 14),
                          _DonorAuthFields(
                            viewModel: viewModel,
                            compact: compact,
                          ),
                          const SizedBox(height: 10),
                          _GradientActionButton(
                            onTap: isBusy ? null : () => _signInDonor(context),
                            icon: Icons.person_rounded,
                            badgeIcon: Icons.favorite_rounded,
                            title: 'DONOR SIGN IN',
                            subtitle: 'Access your donor account',
                            isLoading: isBusy,
                            colors: const [
                              Color(0xFFEF161F),
                              Color(0xFFC9000B),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _CreateAccountButton(
                            onTap: isBusy
                                ? null
                                : () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.donorCreateAccount,
                                    ),
                          ),
                          SizedBox(height: compact ? 10 : 14),
                          const _PrivacyNotice(),
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
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, right: 18),
                child: IconButton.filled(
                  tooltip: 'Admin login',
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.adminLogin,
                  ),
                  icon: const Icon(Icons.admin_panel_settings_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.92),
                    foregroundColor: AppColors.deepMaroon,
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
  const _LogoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 106,
      height: 106,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(AppConstants.logoAsset, fit: BoxFit.contain),
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: compact ? 28 : 34,
              height: 1,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF17232B),
            ),
            children: const [
              TextSpan(text: 'Blood'),
              TextSpan(text: 'LK', style: TextStyle(color: AppColors.bloodRed)),
            ],
          ),
        ),
        SizedBox(height: compact ? 6 : 8),
        Text(
          'Donate Blood  .  Save Lives',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF5E6872),
            fontSize: compact ? 12 : 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FeatureStrip extends StatelessWidget {
  const _FeatureStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          Expanded(
            child: _FeatureItem(
              icon: Icons.water_drop_outlined,
              label: 'Donate\nBlood',
            ),
          ),
          _FeatureDivider(),
          Expanded(
            child: _FeatureItem(
              icon: Icons.groups_rounded,
              label: 'Find\nDonors',
            ),
          ),
          _FeatureDivider(),
          Expanded(
            child: _FeatureItem(
              icon: Icons.verified_user_rounded,
              label: 'Save\nLives',
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.bloodRed, size: 24),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF17232B),
              fontSize: 12,
              height: 1.32,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureDivider extends StatelessWidget {
  const _FeatureDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      color: AppColors.lightRed,
    );
  }
}

class _DonorAuthFields extends StatelessWidget {
  const _DonorAuthFields({required this.viewModel, required this.compact});

  final LoginViewModel viewModel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _LoginAuthField(
          controller: viewModel.donorEmailController,
          hint: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          compact: compact,
        ),
        const SizedBox(height: 10),
        _LoginAuthField(
          controller: viewModel.donorPasswordController,
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

class _LoginAuthField extends StatefulWidget {
  const _LoginAuthField({
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
  State<_LoginAuthField> createState() => _LoginAuthFieldState();
}

class _LoginAuthFieldState extends State<_LoginAuthField> {
  late bool _obscureText = widget.obscureText;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;

    return Container(
      height: compact ? 58 : 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightRed),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: _obscureText,
        style: TextStyle(
          color: const Color(0xFF17232B),
          fontSize: compact ? 14 : 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: const Color(0xFF6F7177),
            fontSize: compact ? 14 : 16,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.fromLTRB(
              10,
              compact ? 7 : 8,
              10,
              compact ? 7 : 8,
            ),
            child: Container(
              width: compact ? 42 : 46,
              height: compact ? 42 : 46,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEF0),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                widget.icon,
                color: AppColors.bloodRed,
                size: compact ? 21 : 23,
              ),
            ),
          ),
          suffixIcon: widget.suffixIcon == null
              ? null
              : IconButton(
                  onPressed: _togglePasswordVisibility,
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF6F7177),
                    size: 22,
                  ),
                ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4,
            vertical: compact ? 18 : 21,
          ),
        ),
      ),
    );
  }
}

class _CreateAccountButton extends StatelessWidget {
  const _CreateAccountButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.lightRed),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_alt_1_rounded,
                  color: AppColors.bloodRed, size: 20),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Create donor account',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.bloodRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.onTap,
    required this.icon,
    required this.badgeIcon,
    required this.title,
    required this.subtitle,
    required this.colors,
    this.isLoading = false,
  });

  final VoidCallback? onTap;
  final IconData icon;
  final IconData badgeIcon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.24),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            constraints: const BoxConstraints(minHeight: 58),
            padding: const EdgeInsets.fromLTRB(18, 9, 16, 9),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      if (isLoading)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      else ...[
                        Icon(icon, color: Colors.white, size: 34),
                        Positioned(
                          right: 2,
                          bottom: 4,
                          child: Icon(badgeIcon, color: Colors.white, size: 16),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyNotice extends StatelessWidget {
  const _PrivacyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightRed),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.bloodRed.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.privacy_tip_rounded,
              color: AppColors.bloodRed,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your privacy is important',
                  style: TextStyle(
                    color: AppColors.bloodRed,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'We ensure your data is safe and secure with us.',
                  style: TextStyle(
                    color: Color(0xFF5E6872),
                    fontSize: 11,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
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

class _LoginBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _paintBase(canvas, size);
    _paintDropPattern(canvas, size);
    _paintTopWave(canvas, size);
    _paintBottomWave(canvas, size);
  }

  void _paintBase(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFFFFF), AppColors.warmSurface],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  void _paintTopWave(Canvas canvas, Size size) {
    final path = Path()
      ..lineTo(0, size.height * 0.13)
      ..cubicTo(
        size.width * 0.1,
        size.height * 0.23,
        size.width * 0.25,
        size.height * 0.18,
        size.width * 0.39,
        size.height * 0.22,
      )
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.27,
        size.width * 0.73,
        size.height * 0.24,
        size.width,
        size.height * 0.3,
      )
      ..lineTo(size.width, 0)
      ..close();

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF51C25), Color(0xFFC9000B)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.32));

    canvas.drawPath(path, paint);
  }

  void _paintBottomWave(Canvas canvas, Size size) {
    final paleWave = Path()
      ..moveTo(0, size.height * 0.8)
      ..cubicTo(
        size.width * 0.14,
        size.height * 0.88,
        size.width * 0.25,
        size.height * 0.86,
        size.width * 0.43,
        size.height * 0.84,
      )
      ..cubicTo(
        size.width * 0.64,
        size.height * 0.81,
        size.width * 0.78,
        size.height * 0.89,
        size.width,
        size.height * 0.86,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      paleWave,
      Paint()..color = AppColors.lightRed.withValues(alpha: 0.55),
    );

    final redWave = Path()
      ..moveTo(0, size.height * 0.86)
      ..cubicTo(
        size.width * 0.13,
        size.height * 0.83,
        size.width * 0.21,
        size.height * 0.92,
        size.width * 0.37,
        size.height * 0.9,
      )
      ..cubicTo(
        size.width * 0.55,
        size.height * 0.87,
        size.width * 0.61,
        size.height * 0.87,
        size.width * 0.75,
        size.height * 0.9,
      )
      ..cubicTo(
        size.width * 0.86,
        size.height * 0.93,
        size.width * 0.95,
        size.height * 0.9,
        size.width,
        size.height * 0.93,
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
    final redStroke = Paint()
      ..color = AppColors.bloodRed.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    final whiteStroke = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    final drops = <Offset>[
      Offset(size.width * 0.12, size.height * 0.25),
      Offset(size.width * 0.76, size.height * 0.08),
      Offset(size.width * 0.88, size.height * 0.16),
      Offset(size.width * 0.09, size.height * 0.37),
      Offset(size.width * 0.92, size.height * 0.42),
      Offset(size.width * 0.88, size.height * 0.74),
      Offset(size.width * 0.38, size.height * 0.06),
      Offset(size.width * 0.78, size.height * 0.32),
    ];

    for (final drop in drops) {
      final inRedArea = drop.dy < size.height * 0.23;
      _drawDrop(
        canvas,
        drop,
        size.width * 0.11,
        inRedArea ? whiteStroke : redStroke,
      );
    }

    final heartPaint = Paint()
      ..color = AppColors.bloodRed.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    _drawHeart(
      canvas,
      Offset(size.width * 0.18, size.height * 0.31),
      18,
      heartPaint,
    );
  }

  void _drawDrop(Canvas canvas, Offset top, double size, Paint paint) {
    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..cubicTo(
        top.dx - size * 0.5,
        top.dy + size * 0.55,
        top.dx - size * 0.42,
        top.dy + size,
        top.dx,
        top.dy + size,
      )
      ..cubicTo(
        top.dx + size * 0.42,
        top.dy + size,
        top.dx + size * 0.5,
        top.dy + size * 0.55,
        top.dx,
        top.dy,
      );

    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy + size * 0.48)
      ..cubicTo(
        center.dx - size * 1.2,
        center.dy - size * 0.2,
        center.dx - size * 0.55,
        center.dy - size * 1.08,
        center.dx,
        center.dy - size * 0.45,
      )
      ..cubicTo(
        center.dx + size * 0.55,
        center.dy - size * 1.08,
        center.dx + size * 1.2,
        center.dy - size * 0.2,
        center.dx,
        center.dy + size * 0.48,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
