import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color accent = Color(0xFF75FF9E);
  static const Color accentStrong = Color(0xFF00E676);
  static const Color accentInk = Color(0xFF00210B);
  static const Color blue = Color(0xFF4C8DFF);
  static const Color positive = Color(0xFF75FF9E);
  static const Color negative = Color(0xFFFFB4AB);
  static const Color neutral = Color(0xFF9AA39B);

  static const Color surfaceDark = Color(0xFF111317);
  static const Color surfaceDarkAlt = Color(0xFF16191E);
  static const Color cardDark = Color(0xFF1A1C20);
  static const Color cardDarkElevated = Color(0xFF202329);
  static const Color dividerDark = Color(0xFF354038);
  static const Color outlineDark = Color(0xFF3B4A3D);
  static const Color textPrimaryDark = Color(0xFFE2E2E8);
  static const Color textSecondaryDark = Color(0xFFBACBB9);
  static const Color textMutedDark = Color(0xFF859585);

  static const Color surfaceLight = Color(0xFFF4F7F4);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFDDE5DE);
  static const Color textPrimaryLight = Color(0xFF182019);
  static const Color textMutedLight = Color(0xFF667267);

  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color surfaceAlt(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? surfaceDarkAlt
          : const Color(0xFFEEF3EF);
  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cardDark : cardLight;
  static Color cardElevated(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? cardDarkElevated
          : const Color(0xFFF8FBF8);
  static Color divider(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? dividerDark
          : dividerLight;
  static Color outline(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? outlineDark
          : const Color(0xFFC7D5C9);
  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textPrimaryDark
          : textPrimaryLight;
  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textSecondaryDark
          : const Color(0xFF536257);
  static Color textMuted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? textMutedDark
          : textMutedLight;
}
