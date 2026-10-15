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

final temaNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void alternarTema() {
  temaNotifier.value = temaNotifier.value == ThemeMode.dark
      ? ThemeMode.light
      : ThemeMode.dark;
}

ThemeData buildTheme({
  Brightness brightness = Brightness.light,
}) {
  final escuro = brightness == Brightness.dark;

  final esquema = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: brightness,
  ).copyWith(
    surface: escuro ? const Color(0xFF1E293B) : Colors.white,
    surfaceContainerHighest: escuro
        ? const Color(0xFF293548)
        : const Color(0xFFF1F5F9),
    onSurface: escuro
        ? const Color(0xFFE2E8F0)
        : AppColors.text,
    onSurfaceVariant: escuro
        ? const Color(0xFFCBD5E1)
        : AppColors.muted,
    outlineVariant: escuro
        ? const Color(0xFF475569)
        : AppColors.border,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: esquema,
    scaffoldBackgroundColor: escuro
        ? const Color(0xFF0F172A)
        : AppColors.background,
    dividerColor: esquema.outlineVariant,
    iconTheme: IconThemeData(color: esquema.onSurfaceVariant),
  );
}

BoxDecoration cardDecoration([BuildContext? context]) {
  final esquema = context == null
      ? null
      : Theme.of(context).colorScheme;

  return BoxDecoration(
    color: esquema?.surface ?? AppColors.card,
    borderRadius: BorderRadius.circular(12),
    boxShadow: const [
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 8,
        offset: Offset(0, 2),
      ),
    ],
  );
}