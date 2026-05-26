import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_colors.dart';

part 'app_theme.g.dart';

const _lightColors = AppColors(
  primary: Color(0xFF2563EB), 
  secondary: Color(0xFF475569), 
  background: Color(0xFFF8FAFC), 
  surface: Color(0xFFFFFFFF), 
  textPrimary: Color(0xFF0F172A), 
  textSecondary: Color(0xFF64748B), 
  success: Color(0xFF10B981), 
  error: Color(0xFFEF4444), 
  warning: Color(0xFFF59E0B), 
  divider: Color(0xFFE2E8F0), 
);

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _lightColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightColors.primary,
        surface: _lightColors.surface,
        error: _lightColors.error,
      ),
      extensions: const <ThemeExtension<dynamic>>[
        _lightColors,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: _lightColors.surface,
        foregroundColor: _lightColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

// 2. เปลี่ยน AppThemeRef เป็น Ref
@riverpod
ThemeData appTheme(Ref ref) {
  return AppTheme.lightTheme;
}