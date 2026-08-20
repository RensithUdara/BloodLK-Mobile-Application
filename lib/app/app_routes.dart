import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/admin_view_model.dart';
import '../viewmodels/donor_registration_view_model.dart';
import '../viewmodels/donor_search_view_model.dart';
import '../viewmodels/login_view_model.dart';
import '../views/admin/admin_panel_view.dart';
import '../views/auth/admin_login_view.dart';
import '../views/auth/donor_create_account_view.dart';
import '../views/auth/login_view.dart';
import '../views/donor/donor_registration_view.dart';
import '../views/donor/donor_search_view.dart';
import '../views/home/home_view.dart';
import '../views/splash/splash_view.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String donorCreateAccount = '/donor-create-account';
  static const String adminLogin = '/admin-login';
  static const String home = '/home';
  static const String donorRegistration = '/donor-registration';
  static const String donorSearch = '/donor-search';
  static const String admin = '/admin';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashView(),
      login: (context) => ChangeNotifierProvider(
            create: (_) => LoginViewModel(),
            child: const LoginView(),
          ),
      donorCreateAccount: (context) => ChangeNotifierProvider(
            create: (_) => LoginViewModel(),
            child: const DonorCreateAccountView(),
          ),
      adminLogin: (context) => ChangeNotifierProvider(
            create: (_) => LoginViewModel(),
            child: const AdminLoginView(),
          ),
      home: (context) => const HomeView(),
      donorRegistration: (context) => ChangeNotifierProvider(
            create: (_) => DonorRegistrationViewModel(),
            child: const DonorRegistrationView(),
          ),
      donorSearch: (context) => ChangeNotifierProvider(
            create: (_) => DonorSearchViewModel(),
            child: const DonorSearchView(),
          ),
      admin: (context) => ChangeNotifierProvider(
            create: (_) => AdminViewModel(),
            child: const AdminPanelView(),
          ),
    };
  }
}
