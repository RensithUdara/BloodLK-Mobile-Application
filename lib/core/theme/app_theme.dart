import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.bloodRed,
        primary: AppColors.bloodRed,
        secondary: AppColors.deepMaroon,
        surface: AppColors.warmSurface,
      ),
      useMaterial3: true,
    );
  }
}
