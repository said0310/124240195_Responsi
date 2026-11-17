import 'package:flutter/material.dart';

class AppColors {
  static const navy = Color(0xFF0A1F2E);
  static const teal = Color(0xFF1A7F8C);
  static const mint = Color(0xFFB5E3E9);
  static const gray = Color(0xFFEEEEEE);
  static const white = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF5B6B75);

  static const alive = Color(0xFF2E9E6B);
  static const dead = Color(0xFFD64545);
  static const unknown = Color(0xFF7A8A94);
  static const favorite = Color(0xFFE5484D);
}

Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'alive':
      return AppColors.alive;
    case 'dead':
      return AppColors.dead;
    default:
      return AppColors.unknown;
  }
}

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.teal,
    primary: AppColors.teal,
    secondary: AppColors.mint,
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: AppColors.gray,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.navy,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: false,
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 1,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.teal,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.gray,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: AppColors.mint,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: AppColors.teal);
      }
      return const IconThemeData(color: AppColors.textSecondary);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          color: AppColors.teal,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        );
      }
      return const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.normal,
        fontSize: 12,
      );
    }),
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.mint,
    selectedColor: AppColors.teal,
    labelStyle: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w500),
    secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    side: BorderSide.none,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: AppColors.navy,
    contentTextStyle: const TextStyle(color: Colors.white),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
