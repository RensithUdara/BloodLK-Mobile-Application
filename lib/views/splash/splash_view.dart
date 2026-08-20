import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/app_routes.dart';
import '../../core/constants/app_constants.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.88, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.warmSurface,
        body: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _SplashBackdrop())),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 720;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      compact ? 18 : 34,
                      24,
                      compact ? 18 : 28,
                    ),
                    child: Column(
                      children: [
                        const Spacer(),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Column(
                              children: [
                                _LogoGlow(compact: compact),
                                SizedBox(height: compact ? 14 : 22),
                                _BrandMark(compact: compact),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _FeatureRow(compact: compact),
                        ),
                        const Spacer(flex: 4),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoGlow extends StatelessWidget {
  const _LogoGlow({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final outerSize = compact ? 184.0 : 230.0;
    final innerSize = compact ? 132.0 : 164.0;

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.46)),
            ),
          ),
          Container(
            width: outerSize * 0.78,
            height: outerSize * 0.78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.48),
              boxShadow: [
                BoxShadow(
                  color: AppColors.bloodRed.withValues(alpha: 0.08),
                  blurRadius: 34,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          Container(
            width: innerSize,
            height: innerSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.all(compact ? 12 : 14),
              child: Image.asset(AppConstants.logoAsset, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: compact ? 38 : 46,
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
        SizedBox(height: compact ? 8 : 12),
        Text(
          'Donate Blood  .  Save Lives',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF70767C),
            fontSize: compact ? 14 : 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: _SplashFeature(
            icon: Icons.water_drop_outlined,
            label: 'Donate\nBlood',
          ),
        ),
        _FeatureDivider(compact: compact),
        const Expanded(
          child: _SplashFeature(
            icon: Icons.groups_rounded,
            label: 'Find\nDonors',
          ),
        ),
        _FeatureDivider(compact: compact),
        const Expanded(
          child: _SplashFeature(
            icon: Icons.verified_user_rounded,
            label: 'Save\nLives',
          ),
        ),
      ],
    );
  }
}

class _SplashFeature extends StatelessWidget {
  const _SplashFeature({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 40),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            height: 1.18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FeatureDivider extends StatelessWidget {
  const _FeatureDivider({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: compact ? 68 : 86,
      color: Colors.white.withValues(alpha: 0.42),
    );
  }
}

class _SplashBackdrop extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _paintBase(canvas, size);
    _paintDropPattern(canvas, size);
    _paintBottomWaves(canvas, size);
  }

  void _paintBase(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFFF4F4), Color(0xFFFFE9E7)],
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  void _paintDropPattern(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.bloodRed.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final drops = <Offset>[
      Offset(size.width * 0.07, size.height * 0.12),
      Offset(size.width * 0.29, size.height * 0.1),
      Offset(size.width * 0.75, size.height * 0.08),
      Offset(size.width * 0.93, size.height * 0.2),
      Offset(size.width * 0.1, size.height * 0.31),
      Offset(size.width * 0.88, size.height * 0.39),
      Offset(size.width * 0.08, size.height * 0.45),
    ];

    for (final drop in drops) {
      final sizeFactor = drop.dx > size.width * 0.7 ? 0.1 : 0.085;
      _drawDrop(canvas, drop, size.width * sizeFactor, paint);
    }
  }

  void _paintBottomWaves(Canvas canvas, Size size) {
    final palePath = Path()
      ..moveTo(0, size.height * 0.52)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.56,
        size.width * 0.22,
        size.height * 0.69,
        size.width * 0.48,
        size.height * 0.66,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.63,
        size.width * 0.79,
        size.height * 0.51,
        size.width,
        size.height * 0.48,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      palePath,
      Paint()..color = const Color(0xFFFFA6AC).withValues(alpha: 0.56),
    );

    final brightPath = Path()
      ..moveTo(0, size.height * 0.56)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.58,
        size.width * 0.24,
        size.height * 0.72,
        size.width * 0.5,
        size.height * 0.68,
      )
      ..cubicTo(
        size.width * 0.73,
        size.height * 0.64,
        size.width * 0.82,
        size.height * 0.58,
        size.width,
        size.height * 0.55,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      brightPath,
      Paint()..color = const Color(0xFFF6202B).withValues(alpha: 0.72),
    );

    final deepPath = Path()
      ..moveTo(0, size.height * 0.59)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.6,
        size.width * 0.29,
        size.height * 0.72,
        size.width * 0.55,
        size.height * 0.68,
      )
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.64,
        size.width * 0.81,
        size.height * 0.58,
        size.width,
        size.height * 0.57,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final rect = Rect.fromLTWH(0, size.height * 0.56, size.width, size.height);
    canvas.drawPath(
      deepPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4000C), Color(0xFF82000C)],
        ).createShader(rect),
    );
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
