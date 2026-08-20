import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import 'home_feature_data.dart';

class DonorHomeHeader extends StatelessWidget {
  const DonorHomeHeader({
    super.key,
    required this.name,
    required this.bloodGroup,
    required this.donorId,
  });

  final String name;
  final String bloodGroup;
  final String donorId;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 390;

    return SizedBox(
      height: compact ? 196 : 236,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _HomeHeaderPainter())),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 16 : 24,
                compact ? 18 : 30,
                compact ? 16 : 24,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AvatarBadge(compact: compact),
                  SizedBox(width: compact ? 12 : 18),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: compact ? 2 : 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $name',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 16.5 : 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: compact ? 5 : 7),
                          Text(
                            'Thank you for being a life saver!',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: compact ? 9.5 : 13,
                              height: 1.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: compact ? 12 : 12),
                  _BloodGroupCard(
                    bloodGroup: bloodGroup,
                    donorId: donorId,
                    compact: compact,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: compact ? 178 : 220,
            right: compact ? 96 : 120,
            bottom: compact ? 42 : 42,
            child: IgnorePointer(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: Colors.red.shade800.withValues(alpha: 0.2),
                    size: compact ? 28 : 42,
                  ),
                  Positioned(
                    left: 4,
                    top: 0,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Colors.red.shade800.withValues(alpha: 0.14),
                      size: compact ? 17 : 24,
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
        final iconSize = compact ? 50.0 : 64.0;

        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 7 : 10,
                vertical: compact ? 10 : 14,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
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
                      size: compact ? 26 : 32,
                    ),
                  ),
                  SizedBox(height: compact ? 9 : 12),
                  Text(
                    feature.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF171D24),
                      fontSize: compact ? 12 : 14,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: compact ? 5 : 7),
                  Text(
                    feature.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF5D6673),
                      fontSize: compact ? 10 : 11.5,
                      height: 1.25,
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

class EveryDropBanner extends StatelessWidget {
  const EveryDropBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF0F0),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volunteer_activism_rounded,
                  color: AppColors.bloodRed,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Every Drop Counts!',
                      style: TextStyle(
                        color: Color(0xFF171D24),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your donation can save up to 3 lives.',
                      style: TextStyle(
                        color: Color(0xFF5D6673),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.bloodRed,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
      ),
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
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
    final size = compact ? 58.0 : 78.0;
    return Container(
      width: size,
      height: size,
      decoration:
          const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.bloodRed,
        size: compact ? 40 : 52,
      ),
    );
  }
}

class _BloodGroupCard extends StatelessWidget {
  const _BloodGroupCard({
    required this.bloodGroup,
    required this.donorId,
    required this.compact,
  });

  final String bloodGroup;
  final String donorId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 96 : 142,
      padding: EdgeInsets.fromLTRB(
        compact ? 10 : 14,
        compact ? 12 : 13,
        compact ? 10 : 14,
        compact ? 12 : 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          if (!compact) ...[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF6A2D), Color(0xFFE71920)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.bloodtype_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 11),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Blood Group',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: compact ? 8.5 : 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  bloodGroup,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 24 : 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 7),
                  Text(
                    donorId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 27),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
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
            const Text(
              'Request',
              style: TextStyle(
                color: Color(0xFF686E79),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
      ..moveTo(0, size.height * 0.66)
      ..cubicTo(
        size.width * 0.23,
        size.height * 0.58,
        size.width * 0.47,
        size.height * 0.66,
        size.width * 0.7,
        size.height * 0.64,
      )
      ..cubicTo(
        size.width * 0.86,
        size.height * 0.63,
        size.width * 0.93,
        size.height * 0.72,
        size.width,
        size.height * 0.66,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      darkWave,
      Paint()..color = const Color(0xFFB0000A).withValues(alpha: 0.38),
    );

    final whiteWave = Path()
      ..moveTo(0, size.height * 0.76)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.68,
        size.width * 0.44,
        size.height * 0.76,
        size.width * 0.64,
        size.height * 0.82,
      )
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.88,
        size.width * 0.94,
        size.height * 0.83,
        size.width,
        size.height * 0.78,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(whiteWave, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
