import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _inter => GoogleFonts.inter();
  static TextStyle get mono => GoogleFonts.jetBrainsMono();

  static TextStyle get priceHero => mono.copyWith(
      fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -1.0);
  static TextStyle get priceLarge => mono.copyWith(
      fontSize: 21, fontWeight: FontWeight.w700, letterSpacing: -.5);
  static TextStyle get priceMedium =>
      mono.copyWith(fontSize: 15, fontWeight: FontWeight.w600);
  static TextStyle get priceSmall =>
      mono.copyWith(fontSize: 12, fontWeight: FontWeight.w600);
  static TextStyle get symbol => _inter.copyWith(
      fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: .2);
  static TextStyle get symbolSub => _inter.copyWith(
      fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: .3);
  static TextStyle get change =>
      mono.copyWith(fontSize: 12, fontWeight: FontWeight.w700);
  static TextStyle get label => _inter.copyWith(
      fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0);
  static TextStyle get headline => _inter.copyWith(
      fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -.7);
  static TextStyle get body =>
      _inter.copyWith(fontSize: 13, fontWeight: FontWeight.w500);
  static TextStyle get button =>
      _inter.copyWith(fontSize: 14, fontWeight: FontWeight.w800);
}
