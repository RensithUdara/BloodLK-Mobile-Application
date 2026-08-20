import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'home_feature_data.dart';

class DonorHomeHeader extends StatelessWidget {
  const DonorHomeHeader({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 390;

    return SizedBox(
      height: compact ? 148 : 172,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _HomeHeaderPainter())),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 20 : 24,
                compact ? 14 : 20,
                compact ? 20 : 24,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _AvatarBadge(compact: compact),
                  SizedBox(width: compact ? 12 : 18),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $name',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: compact ? 17 : 21,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: compact ? 4 : 6),
                        Text(
                          'Thank you for being a life saver!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: compact ? 10.5 : 13,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: compact ? 8 : 10),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 10 : 12,
                            vertical: compact ? 5 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            'Ready to help today',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 10 : 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DonorFeatureCard extends StatelessWidget {
  const DonorFeatureCard({
    super.key,
    required this.feature,
    required this.onTap,
  });

  final DonorHomeFeature feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 112;
        final iconSize = compact ? 44.0 : 52.0;

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          elevation: 0,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 6 : 9,
                vertical: compact ? 8 : 10,
              ),
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
                    width: iconSize,
                    height: iconSize,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFECEE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      feature.icon,
                      color: AppColors.bloodRed,
                      size: compact ? 23 : 27,
                    ),
                  ),
                  SizedBox(height: compact ? 7 : 9),
                  Text(
                    feature.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF171D24),
                      fontSize: compact ? 11 : 12.5,
                      height: 1.04,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: compact ? 4 : 5),
                  Text(
                    feature.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF5D6673),
                      fontSize: compact ? 9.2 : 10.2,
                      height: 1.12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DonorHomeBottomNav extends StatelessWidget {
  const DonorHomeBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 390;

    return Container(
      margin: EdgeInsets.fromLTRB(
        compact ? 16 : 18,
        0,
        compact ? 16 : 18,
        compact ? 10 : 14,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 6,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            selected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.groups_rounded,
            label: 'Donors',
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _RequestNavItem(selected: currentIndex == 2, onTap: () => onTap(2)),
          _NavItem(
            icon: Icons.calendar_month_rounded,
            label: 'Appointments',
            selected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _NavItem(
            icon: Icons.account_circle_outlined,
            label: 'Profile',
            selected: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 70.0 : 76.0;
    return Container(
      width: size,
      height: size,
      decoration:
          const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.bloodRed,
        size: compact ? 45 : 50,
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.bloodRed : const Color(0xFF686E79);
    final compact = MediaQuery.sizeOf(context).width < 390;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          height: compact ? 52 : 58,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: compact ? 23 : 26),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: compact ? 9 : 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestNavItem extends StatelessWidget {
  const _RequestNavItem({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 390;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: SizedBox(
          height: compact ? 62 : 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: compact ? 52 : 58,
                height: compact ? 52 : 58,
                decoration: BoxDecoration(
                  color: AppColors.bloodRed,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.bloodRed.withValues(alpha: 0.24),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.bloodtype_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(height: 3),
              Text(
                'Request',
                style: TextStyle(
                  color: const Color(0xFF686E79),
                  fontSize: compact ? 9 : 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE71920), Color(0xFFC9000B), Color(0xFF8F0008)],
        ).createShader(rect),
    );

    final darkWave = Path()
      ..moveTo(0, size.height * 0.74)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.68,
        size.width * 0.48,
        size.height * 0.75,
        size.width * 0.72,
        size.height * 0.72,
      )
      ..cubicTo(
        size.width * 0.86,
        size.height * 0.71,
        size.width * 0.93,
        size.height * 0.78,
        size.width,
        size.height * 0.72,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      darkWave,
      Paint()..color = const Color(0xFFB0000A).withValues(alpha: 0.38),
    );

    final whiteWave = Path()
      ..moveTo(0, size.height * 0.83)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.77,
        size.width * 0.44,
        size.height * 0.83,
        size.width * 0.64,
        size.height * 0.88,
      )
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.94,
        size.width * 0.94,
        size.height * 0.89,
        size.width,
        size.height * 0.84,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(whiteWave, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
