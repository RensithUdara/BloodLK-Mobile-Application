import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../viewmodels/donor_registration_view_model.dart';
import '../../viewmodels/donor_search_view_model.dart';
import '../donor/donor_registration_view.dart';
import '../donor/donor_search_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      ChangeNotifierProvider(
        create: (_) => DonorRegistrationViewModel(),
        child: const DonorRegistrationView(),
      ),
      ChangeNotifierProvider(
        create: (_) => DonorSearchViewModel(),
        child: const DonorSearchView(),
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.bloodRed,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Register',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search Donors',
          ),
        ],
      ),
    );
  }
}
