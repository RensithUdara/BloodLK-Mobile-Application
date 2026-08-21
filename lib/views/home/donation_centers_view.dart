import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donation_center.dart';
import '../../data/repositories/donation_center_repository.dart';
import '../../services/contact_service.dart';

class DonationCentersView extends StatefulWidget {
  DonationCentersView({
    super.key,
    DonationCenterRepository? repository,
    ContactService? contactService,
  })  : _repository = repository ?? DonationCenterRepository(),
        _contactService = contactService ?? ContactService();

  final DonationCenterRepository _repository;
  final ContactService _contactService;

  @override
  State<DonationCentersView> createState() => _DonationCentersViewState();
}

class _DonationCentersViewState extends State<DonationCentersView> {
  final _searchController = TextEditingController();
  String _selectedDistrict = DonationDistricts.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _CentersBackdrop())),
          SafeArea(
            child: Column(
              children: [
                const _CentersAppBar(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search donation centers',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.bloodRed,
                          ),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                ),
                          filled: true,
                          fillColor: Colors.white,
                          border: _inputBorder(),
                          enabledBorder: _inputBorder(),
                          focusedBorder: _inputBorder(
                            color: AppColors.bloodRed,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedDistrict,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.map_rounded,
                            color: AppColors.bloodRed,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: _inputBorder(),
                          enabledBorder: _inputBorder(),
                          focusedBorder: _inputBorder(
                            color: AppColors.bloodRed,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(14),
                        items: DonationDistricts.values
                            .map(
                              (district) => DropdownMenuItem(
                                value: district,
                                child: Text(district),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => _selectedDistrict = value);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<DonationCenter>>(
                    stream: widget._repository.watchCenters(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.bloodRed,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return _CenterState(
                          icon: Icons.error_outline_rounded,
                          title: 'Unable to load centers',
                          message: snapshot.error.toString(),
                        );
                      }

                      final centers = (snapshot.data ?? const <DonationCenter>[])
                          .where((center) =>
                              center.matchesSearch(_searchController.text) &&
                              center.matchesDistrict(_selectedDistrict))
                          .toList(growable: false);

                      if (centers.isEmpty) {
                        return const _CenterState(
                          icon: Icons.local_hospital_rounded,
                          title: 'No donation centers available',
                          message:
                              'Centers added in Firebase will appear here.',
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                        itemCount: centers.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final center = centers[index];
                          return _DonationCenterCard(
                            center: center,
                            onCall: center.contactNumber.trim().isEmpty
                                ? null
                                : () => widget._contactService.makeCall(
                                      center.contactNumber,
                                    ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder({Color color = const Color(0xFFFFE6E8)}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color),
    );
  }
}

class _DonationCenterCard extends StatelessWidget {
  const _DonationCenterCard({
    required this.center,
    required this.onCall,
  });

  final DonationCenter center;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.lightRed.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFFFECEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: AppColors.bloodRed,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  center.name.isEmpty ? 'Unnamed center' : center.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF171D24),
                    fontSize: 15,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                _CenterDetail(
                  icon: Icons.location_on_rounded,
                  text: center.address.isEmpty
                      ? 'Address not provided'
                      : center.address,
                ),
                const SizedBox(height: 5),
                _CenterDetail(
                  icon: Icons.map_rounded,
                  text: center.district.isEmpty
                      ? 'District not provided'
                      : center.district,
                ),
                const SizedBox(height: 5),
                _CenterDetail(
                  icon: Icons.call_rounded,
                  text: center.contactNumber.isEmpty
                      ? 'Contact not provided'
                      : center.contactNumber,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton.filled(
            tooltip: 'Call center',
            onPressed: onCall,
            icon: const Icon(Icons.call_rounded),
            style: IconButton.styleFrom(
              backgroundColor: onCall == null
                  ? const Color(0xFFE9ECEF)
                  : AppColors.bloodRed,
              foregroundColor:
                  onCall == null ? const Color(0xFF8A9099) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CenterDetail extends StatelessWidget {
  const _CenterDetail({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.bloodRed, size: 16),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF5D6673),
              fontSize: 12.5,
              height: 1.25,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _CenterState extends StatelessWidget {
  const _CenterState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: const BoxDecoration(
                color: Color(0xFFFFECEE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.bloodRed, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF171D24),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF5D6673),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CentersAppBar extends StatelessWidget {
  const _CentersAppBar();

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
          const Expanded(
            child: Text(
              'Donation Centers',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
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

class _CentersBackdrop extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);

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

    canvas.drawPath(wave, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
