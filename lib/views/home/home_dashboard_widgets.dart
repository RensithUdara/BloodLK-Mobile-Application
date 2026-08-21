import 'dart:async';

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
      height: compact ? 144 : 166,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _HomeHeaderPainter())),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 20 : 24,
                compact ? 10 : 18,
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

class DonorHomeBannerCarousel extends StatefulWidget {
  const DonorHomeBannerCarousel({super.key});

  @override
  State<DonorHomeBannerCarousel> createState() =>
      _DonorHomeBannerCarouselState();
}

class _DonorHomeBannerCarouselState extends State<DonorHomeBannerCarousel> {
  static const _banners = [
    'assets/banners/banner1.png',
    'assets/banners/banner2.png',
    'assets/banners/banner3.png',
  ];

  final _controller = PageController();
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;

      final nextIndex = (_currentIndex + 1) % _banners.length;
      _controller.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 390;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, compact ? 6 : 8, 16, compact ? 10 : 12),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index % _banners.length);
                },
                itemCount: _banners.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                    _banners[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFFFECEE),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_rounded,
                          color: AppColors.bloodRed,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_banners.length, (index) {
              final selected = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: selected ? 18 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.bloodRed
                      : AppColors.bloodRed.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }),
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
        compact ? 8 : 12,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 6,
        vertical: compact ? 5 : 7,
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
            icon: Icons.local_hospital_rounded,
            label: 'Centers',
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _AddDonationNavItem(
            selected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
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
    final size = compact ? 56.0 : 66.0;
    return Container(
      width: size,
      height: size,
      decoration:
          const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Icon(
        Icons.person_rounded,
        color: AppColors.bloodRed,
        size: compact ? 37 : 44,
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
          height: compact ? 48 : 54,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: compact ? 22 : 25),
              const SizedBox(height: 2),
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

class _AddDonationNavItem extends StatelessWidget {
  const _AddDonationNavItem({required this.selected, required this.onTap});

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
          height: compact ? 56 : 62,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: compact ? 38 : 44,
                height: compact ? 38 : 44,
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
                child: Icon(
                  Icons.bloodtype_rounded,
                  color: Colors.white,
                  size: compact ? 22 : 25,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Add',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF686E79),
                  fontSize: compact ? 9 : 10,
                  height: 1,
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
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.72,
        size.width * 0.48,
        size.height * 0.78,
        size.width * 0.72,
        size.height * 0.76,
      )
      ..cubicTo(
        size.width * 0.86,
        size.height * 0.75,
        size.width * 0.93,
        size.height * 0.82,
        size.width,
        size.height * 0.76,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      darkWave,
      Paint()..color = const Color(0xFFB0000A).withValues(alpha: 0.38),
    );

    final whiteWave = Path()
      ..moveTo(0, size.height * 0.87)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.81,
        size.width * 0.44,
        size.height * 0.87,
        size.width * 0.64,
        size.height * 0.92,
      )
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.98,
        size.width * 0.94,
        size.height * 0.93,
        size.width,
        size.height * 0.88,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(whiteWave, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
