import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donor.dart';
import '../../viewmodels/donor_search_view_model.dart';

class DonorSearchView extends StatelessWidget {
  const DonorSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<DonorSearchViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: _SearchBackdrop()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const _SearchHeader(),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, -18),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        children: [
                          _SearchPanel(viewModel: viewModel),
                          const SizedBox(height: 16),
                          Expanded(
                            child: !viewModel.hasSearch
                                ? const _EmptySearchPrompt()
                                : _SearchResults(viewModel: viewModel),
                          ),
                        ],
                      ),
                    ),
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

class _SearchHeader extends StatelessWidget {
  const _SearchHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 30, 22, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Find Blood Donors',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Search and connect with donors\nin your area.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const _HeaderBloodDrop(),
          ],
        ),
      ),
    );
  }
}

class _HeaderBloodDrop extends StatelessWidget {
  const _HeaderBloodDrop();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      height: 108,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(88, 104),
            painter: _BloodDropPainter(
              fillColor: Colors.white.withValues(alpha: 0.04),
              strokeColor: Colors.white,
              glowColor: Colors.white.withValues(alpha: 0.35),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.bloodRed.withValues(alpha: 0.45),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(
              Icons.monitor_heart_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const Positioned(left: 1, top: 42, child: _Sparkle(size: 5)),
          const Positioned(right: 1, bottom: 24, child: _Sparkle(size: 7)),
          Positioned(
            left: 8,
            top: 28,
            child: Icon(
              Icons.water_drop,
              color: Colors.white.withValues(alpha: 0.35),
              size: 15,
            ),
          ),
          Positioned(
            right: 10,
            top: 22,
            child: Icon(
              Icons.water_drop,
              color: Colors.white.withValues(alpha: 0.3),
              size: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchPanel extends StatelessWidget {
  const _SearchPanel({required this.viewModel});

  final DonorSearchViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const _FieldLabel('Blood Group'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: viewModel.selectedBloodGroup,
            decoration: _inputDecoration(
              hint: 'Blood Group',
              icon: Icons.bloodtype_rounded,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF46525C),
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(14),
            style: const TextStyle(
              color: Color(0xFF17232B),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
            items: AppConstants.bloodGroups
                .map((group) =>
                    DropdownMenuItem(value: group, child: Text(group)))
                .toList(),
            onChanged: (value) {
              if (value != null) viewModel.updateBloodGroup(value);
            },
          ),
          const SizedBox(height: 14),
          const _FieldLabel('City'),
          const SizedBox(height: 8),
          TextField(
            controller: viewModel.cityController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => viewModel.search(),
            style: const TextStyle(
              color: Color(0xFF17232B),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            decoration: _inputDecoration(
              hint: 'Enter city',
              icon: Icons.location_on_rounded,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: viewModel.search,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.bloodRed,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            icon: const Icon(Icons.search_rounded, size: 21),
            label: const Text('Search Donors'),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF8A929B),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
        child: Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFFFFECEE),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.bloodRed, size: 18),
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 48),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppColors.lightRed.withValues(alpha: 0.9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.bloodRed, width: 1.4),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: AppColors.lightRed.withValues(alpha: 0.9)),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF26323A),
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.viewModel});

  final DonorSearchViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Donor>>(
      stream: viewModel.watchDonors(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.bloodRed),
          );
        }

        final donors = snapshot.data ?? const <Donor>[];
        if (donors.isEmpty) return const _NoResultsFound();

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 20),
          itemCount: donors.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final donor = donors[index];
            return _DonorCard(
              donor: donor,
              onCall: () => viewModel.callDonor(donor.phone),
              onMessage: () => viewModel.messageDonor(donor),
            );
          },
        );
      },
    );
  }
}

class _EmptySearchPrompt extends StatelessWidget {
  const _EmptySearchPrompt();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: _EmptyStateContent(
        title: 'No donors found yet',
        subtitle: 'Enter the details above to find\nblood donors near you.',
      ),
    );
  }
}

class _NoResultsFound extends StatelessWidget {
  const _NoResultsFound();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: _EmptyStateContent(
        title: 'No eligible donors found',
        subtitle: 'Try another blood group or city\nto continue your search.',
      ),
    );
  }
}

class _EmptyStateContent extends StatelessWidget {
  const _EmptyStateContent({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _EmptySearchIllustration(),
        const SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF26323A),
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF69727C),
            fontSize: 12,
            height: 1.35,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _EmptySearchIllustration extends StatelessWidget {
  const _EmptySearchIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      height: 132,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 18,
            child: CustomPaint(
              size: const Size(176, 58),
              painter: _CitySilhouettePainter(),
            ),
          ),
          Positioned(
            top: 2,
            child: Transform.rotate(
              angle: -0.15,
              child: Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bloodRed, width: 3),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.bloodRed,
                  size: 39,
                ),
              ),
            ),
          ),
          Positioned(
            right: 40,
            top: 68,
            child: Transform.rotate(
              angle: -0.75,
              child: Container(
                width: 18,
                height: 58,
                decoration: BoxDecoration(
                  color: AppColors.bloodRed,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.bloodRed.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 45,
            bottom: 18,
            child: Icon(
              Icons.water_drop,
              color: AppColors.bloodRed.withValues(alpha: 0.95),
              size: 31,
            ),
          ),
          Positioned(
            left: 47,
            top: 25,
            child: Icon(
              Icons.favorite,
              color: AppColors.bloodRed.withValues(alpha: 0.11),
              size: 15,
            ),
          ),
          Positioned(
            right: 62,
            top: 25,
            child: Icon(
              Icons.favorite,
              color: AppColors.bloodRed.withValues(alpha: 0.12),
              size: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonorCard extends StatelessWidget {
  const _DonorCard({
    required this.donor,
    required this.onCall,
    required this.onMessage,
  });

  final Donor donor;
  final VoidCallback onCall;
  final VoidCallback onMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightRed.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Color(0xFFFFECEE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                donor.bloodGroup,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.bloodRed,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  donor.name.isEmpty ? 'Unnamed donor' : donor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF17232B),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Age ${donor.age} - ${donor.city.toUpperCase()}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF69727C),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Call donor',
            onPressed: onCall,
            icon: const Icon(Icons.phone_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFEAF8EE),
              foregroundColor: const Color(0xFF159947),
            ),
          ),
          const SizedBox(width: 4),
          IconButton.filledTonal(
            tooltip: 'Message donor',
            onPressed: onMessage,
            icon: const Icon(Icons.message_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFFFECEE),
              foregroundColor: AppColors.bloodRed,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBackdrop extends CustomPainter {
  const _SearchBackdrop();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    _paintHeader(canvas, size);
  }

  void _paintHeader(Canvas canvas, Size size) {
    final headerHeight = size.height < 720 ? 172.0 : 188.0;
    final rect = Rect.fromLTWH(0, 0, size.width, headerHeight);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE71820), Color(0xFFB9000B)],
        ).createShader(rect),
    );

    final darkWave = Path()
      ..moveTo(0, headerHeight * 0.68)
      ..cubicTo(
        size.width * 0.18,
        headerHeight * 0.55,
        size.width * 0.32,
        headerHeight * 0.88,
        size.width * 0.55,
        headerHeight * 0.74,
      )
      ..cubicTo(
        size.width * 0.76,
        headerHeight * 0.62,
        size.width * 0.86,
        headerHeight * 0.79,
        size.width,
        headerHeight * 0.64,
      )
      ..lineTo(size.width, headerHeight)
      ..lineTo(0, headerHeight)
      ..close();

    canvas.drawPath(
      darkWave,
      Paint()..color = const Color(0xFFC9000B).withValues(alpha: 0.5),
    );

    final whiteWave = Path()
      ..moveTo(0, headerHeight * 0.82)
      ..cubicTo(
        size.width * 0.18,
        headerHeight * 0.62,
        size.width * 0.44,
        headerHeight * 0.83,
        size.width * 0.62,
        headerHeight * 0.88,
      )
      ..cubicTo(
        size.width * 0.78,
        headerHeight * 0.93,
        size.width * 0.9,
        headerHeight * 0.79,
        size.width,
        headerHeight * 0.78,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(whiteWave, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BloodDropPainter extends CustomPainter {
  const _BloodDropPainter({
    required this.fillColor,
    required this.strokeColor,
    required this.glowColor,
  });

  final Color fillColor;
  final Color strokeColor;
  final Color glowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.5, 4)
      ..cubicTo(
        size.width * 0.08,
        size.height * 0.48,
        size.width * 0.1,
        size.height * 0.96,
        size.width * 0.5,
        size.height * 0.96,
      )
      ..cubicTo(
        size.width * 0.9,
        size.height * 0.96,
        size.width * 0.92,
        size.height * 0.48,
        size.width * 0.5,
        4,
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = glowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawPath(path, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CitySilhouettePainter extends CustomPainter {
  const _CitySilhouettePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.bloodRed.withValues(alpha: 0.06);
    final linePaint = Paint()
      ..color = AppColors.bloodRed.withValues(alpha: 0.09)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(0, size.height - 2),
      Offset(size.width, size.height - 2),
      linePaint,
    );

    final buildings = [
      Rect.fromLTWH(14, 26, 22, 30),
      Rect.fromLTWH(44, 18, 28, 38),
      Rect.fromLTWH(106, 20, 26, 36),
      Rect.fromLTWH(140, 27, 22, 29),
    ];

    for (final building in buildings) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(building, const Radius.circular(2)),
        paint,
      );
      for (var x = building.left + 5; x < building.right - 4; x += 9) {
        for (var y = building.top + 6; y < building.bottom - 5; y += 10) {
          canvas.drawRect(
            Rect.fromLTWH(x, y, 3, 3),
            Paint()..color = Colors.white.withValues(alpha: 0.8),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.add, color: Colors.white, size: size);
  }
}
