import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/donor.dart';
import '../../data/repositories/donor_repository.dart';
import '../../viewmodels/donor_search_view_model.dart';
import '../donor/donor_search_view.dart';
import 'achievements_view.dart';
import 'donor_feature_detail_view.dart';
import 'donor_profile_view.dart';
import 'help_center_view.dart';
import 'home_dashboard_widgets.dart';
import 'home_feature_data.dart';
import 'settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _donorRepository = DonorRepository();

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
    if (feature.title == 'Settings') {
      _openSettings();
      return;
    }
    if (feature.title == 'Achievements') {
      _openAchievements();
      return;
    }
    if (feature.title == 'Help Center') {
      _openHelpCenter();
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

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsView()),
    );
  }

  void _openAchievements() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AchievementsView()),
    );
  }

  void _openHelpCenter() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HelpCenterView()),
    );
  }
}
