import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF6C4DF6);
  static const primaryLight = Color(0xFFEEEAFF);
  static const background = Color(0xFFF7F7FC);
  static const text = Color(0xFF1B1B2F);
  static const muted = Color(0xFF8A8AA0);
  static const border = Color(0xFFE6E6F0);
  static const submitted = Color(0xFFF5A524);
  static const inProgress = Color(0xFF5B6CF9);
  static const resolved = Color(0xFF2FB36D);
  static const danger = Color(0xFFE5484D);
}

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary),
      scaffoldBackgroundColor: AppColors.background,
    );

BoxDecoration cardDecoration() => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border),
    );
