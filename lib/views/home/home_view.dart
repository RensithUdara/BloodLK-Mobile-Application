import 'package:flutter/material.dart';
import '../../data/models/donor.dart';
import '../../data/repositories/donor_repository.dart';
import 'achievements_view.dart';
import 'add_donation_view.dart';
import 'donor_feature_detail_view.dart';
import 'donor_profile_view.dart';
import 'emergency_requests_view.dart';
import 'help_center_view.dart';
import 'home_dashboard_widgets.dart';
import 'home_feature_data.dart';
import 'next_eligibility_view.dart';
import 'notifications_view.dart';
import 'past_donations_view.dart';
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
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 94),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.crossAxisExtent < 360;
                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: compact ? 8 : 10,
                            mainAxisSpacing: compact ? 9 : 11,
                            childAspectRatio: compact ? 0.94 : 1.02,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final feature = donorHomeFeatures[index];
                              return DonorFeatureCard(
                                feature: feature,
                                onTap: () => _openFeature(feature),
                              );
                            },
                            childCount: donorHomeFeatures.length,
                          ),
                        );
                      },
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

  void _openFeature(DonorHomeFeature feature) {
    if (feature.title == 'My Profile') {
      _openProfile();
      return;
    }
    if (feature.title == 'Add Donations') {
      _openAddDonation();
      return;
    }
    if (feature.title == 'Past Donations') {
      _openPastDonations();
      return;
    }
    if (feature.title == 'Next Eligibility') {
      _openNextEligibility();
      return;
    }
    if (feature.title == 'Emergency Requests') {
      _openEmergencyRequests();
      return;
    }
    if (feature.title == 'Notifications') {
      _openNotifications();
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
      _openFeature(_featureByTitle('Donation Centers'));
      return;
    }

    if (index == 2) {
      _openAddDonation();
      return;
    }

    if (index == 4) {
      _openProfile();
      return;
    }

    final featureTitle = switch (index) {
      3 => 'Donation Centers',
      _ => 'My Profile',
    };
    _openFeature(_featureByTitle(featureTitle));
  }

  DonorHomeFeature _featureByTitle(String title) {
    return donorHomeFeatures.firstWhere((feature) => feature.title == title);
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DonorProfileView()),
    );
  }

  void _openAddDonation() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddDonationView()),
    );
  }

  void _openPastDonations() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PastDonationsView()),
    );
  }

  void _openNextEligibility() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NextEligibilityView()),
    );
  }

  void _openEmergencyRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EmergencyRequestsView()),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsView()),
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
