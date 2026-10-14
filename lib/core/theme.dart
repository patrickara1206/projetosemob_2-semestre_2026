import 'package:flutter/material.dart';

class AppColors {
  static const sidebar = Color(0xFF0A2351);
  static const sidebarLogo = Color(0xFF1B3A78);
  static const primary = Color(0xFF1976D2);
  static const navy = Color(0xFF0D1B5E);
  static const background = Color(0xFFF8F9FC);
  static const card = Colors.white;
  static const border = Color(0xFFE5E7EB);
  static const muted = Color(0xFF6B7280);
  static const text = Color(0xFF1F2937);
  static const green = Color(0xFF2E7D32);
  static const greenSoft = Color(0xFFE8F5E9);
  static const red = Color(0xFFD32F2F);
  static const redSoft = Color(0xFFFDECEC);
  static const orange = Color(0xFFF59E0B);
  static const orangeSoft = Color(0xFFFFF3D6);
  static const cyan = Color(0xFF00BCD4);
}

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  );
}

BoxDecoration cardDecoration() => BoxDecoration(
  color: AppColors.card,
  borderRadius: BorderRadius.circular(12),
  boxShadow: const [
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
  ],
);
