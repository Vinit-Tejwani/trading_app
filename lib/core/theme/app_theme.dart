import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final inter = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
    );
    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surfaceDark,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textPrimaryDark,
        primary: AppColors.accent,
        onPrimary: AppColors.accentInk,
        secondary: AppColors.blue,
        error: AppColors.negative,
      ),
      textTheme: inter,
      dividerTheme: const DividerThemeData(
          color: AppColors.dividerDark, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: .3),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardDark,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8))),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        indicatorColor: AppColors.accent.withValues(alpha: .14),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? AppColors.accent : AppColors.textSecondaryDark);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
              color: selected ? AppColors.accent : AppColors.textSecondaryDark,
              size: 22);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.outlineDark)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.outlineDark)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.2)),
        hintStyle: const TextStyle(color: AppColors.textMutedDark),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accentStrong,
          foregroundColor: AppColors.accentInk,
          minimumSize: const Size(44, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final inter = GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textPrimaryLight,
        displayColor: AppColors.textPrimaryLight);
    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.surfaceLight,
      colorScheme: const ColorScheme.light(
          surface: AppColors.surfaceLight,
          onSurface: AppColors.textPrimaryLight,
          primary: Color(0xFF087F3E),
          onPrimary: Colors.white,
          error: Color(0xFFB3261E)),
      textTheme: inter,
      dividerTheme: const DividerThemeData(
          color: AppColors.dividerLight, thickness: 1, space: 1),
      cardTheme: const CardThemeData(
          color: AppColors.cardLight,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)))),
      appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfaceLight,
          foregroundColor: AppColors.textPrimaryLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle:
              GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
      navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.cardLight,
          indicatorColor: const Color(0xFF087F3E).withValues(alpha: .12),
          height: 72),
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardLight,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.dividerLight)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.dividerLight)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF087F3E), width: 1.2))),
    );
  }
}
