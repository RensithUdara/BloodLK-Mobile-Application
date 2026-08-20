import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/donor.dart';
import '../../data/repositories/donor_repository.dart';
import '../../viewmodels/donor_search_view_model.dart';
import '../donor/donor_search_view.dart';
import 'donor_feature_detail_view.dart';
import 'donor_profile_view.dart';
import 'home_dashboard_widgets.dart';
import 'home_feature_data.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _donorRepository = DonorRepository();
  String _availability = 'Available';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<Donor?>(
        stream: _donorRepository.watchCurrentDonor(),
        builder: (context, snapshot) {
          final donor = snapshot.data;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: DonorHomeHeader(
                      name: _firstName(donor),
                      bloodGroup: donor?.bloodGroup ?? '--',
                      donorId: _donorId(donor),
                      status: _availability,
                      onStatusTap: _showAvailabilitySheet,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 124),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final compact = constraints.maxWidth < 360;
                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: donorHomeFeatures.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: compact ? 8 : 12,
                                  mainAxisSpacing: compact ? 10 : 14,
                                  childAspectRatio: compact ? 0.58 : 0.62,
                                ),
                                itemBuilder: (context, index) {
                                  final feature = donorHomeFeatures[index];
                                  return DonorFeatureCard(
                                    feature: feature,
                                    onTap: () => _openFeature(feature),
                                  );
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          EveryDropBanner(
                            onTap: () => _openFeature(donorHomeFeatures[8]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: DonorHomeBottomNav(
                    currentIndex: 0,
                    onTap: _handleBottomNav,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _firstName(Donor? donor) {
    final name = donor?.name.trim();
    if (name == null || name.isEmpty) return 'Donor';
    return name.split(RegExp(r'\s+')).first;
  }

  String _donorId(Donor? donor) {
    final nic = donor?.nic.trim();
    if (nic == null || nic.isEmpty) return 'Donor ID: BD123456';
    final suffix = nic.length <= 6 ? nic : nic.substring(nic.length - 6);
    return 'Donor ID: BD$suffix';
  }

  void _openFeature(DonorHomeFeature feature) {
    if (feature.title == 'My Profile') {
      _openProfile();
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DonorFeatureDetailView(feature: feature),
      ),
    );
  }

  void _handleBottomNav(int index) {
    if (index == 0) return;

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (_) => DonorSearchViewModel(),
            child: const DonorSearchView(),
          ),
        ),
      );
      return;
    }

    final featureIndex = switch (index) {
      2 => 4,
      3 => 1,
      4 => -1,
      _ => 0,
    };
    if (featureIndex == -1) {
      _openProfile();
      return;
    }
    _openFeature(donorHomeFeatures[featureIndex]);
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DonorProfileView()),
    );
  }

  void _showAvailabilitySheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Availability Status',
                  style: TextStyle(
                    color: Color(0xFF171D24),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                _AvailabilityOption(
                  label: 'Available',
                  icon: Icons.check_circle_rounded,
                  selected: _availability == 'Available',
                  onTap: () => _updateAvailability('Available'),
                ),
                _AvailabilityOption(
                  label: 'Busy',
                  icon: Icons.pause_circle_rounded,
                  selected: _availability == 'Busy',
                  onTap: () => _updateAvailability('Busy'),
                ),
                _AvailabilityOption(
                  label: 'Resting',
                  icon: Icons.hotel_rounded,
                  selected: _availability == 'Resting',
                  onTap: () => _updateAvailability('Resting'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateAvailability(String value) {
    setState(() => _availability = value);
    Navigator.pop(context);
  }
}

class _AvailabilityOption extends StatelessWidget {
  const _AvailabilityOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.bloodRed),
      title: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF171D24),
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.done_rounded, color: AppColors.bloodRed)
          : null,
    );
  }
}
