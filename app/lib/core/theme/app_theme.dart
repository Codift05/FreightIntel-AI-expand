import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Token warna brand FreightIntel AI (lihat app/DESIGN.md).
class AppColors {
  // Surface / netral
  static const bg = Color(0xFFF4F6F8);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF8FAFC);
  static const line = Color(0xFFEDF1F5);

  // Teks
  static const ink = Color(0xFF16365C);
  static const inkSoft = Color(0xFF3A4B66);
  static const muted = Color(0xFF64748B);

  // Aksen (SATU)
  static const green = Color(0xFF17A55B);
  static const greenSoft = Color(0xFFE7F6EE);
  static const greenInk = Color(0xFF0E7A42);

  // Semantik finansial
  static const loss = Color(0xFFE0523D);
  static const lossSoft = Color(0xFFFCEAE6);
  static const warning = Color(0xFFE0A33E);
  static const warningSoft = Color(0xFFFCF3E2);

  // shortcut: alias token lama agar layar yang belum di-redesign tetap kompilasi; hapus saat layar diperbarui
  static const navy = ink;
  static const border = line;
}

class AppRadii {
  static const card = 20.0;
  static const tile = 18.0;
  static const input = 14.0;
  static const pill = 999.0;
}

class AppShadows {
  static const card = [
    BoxShadow(
      color: Color(0x1416365C),
      blurRadius: 24,
      offset: Offset(0, 10),
      spreadRadius: -6,
    ),
  ];
  static const soft = [
    BoxShadow(
      color: Color(0x0F16365C),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: -4,
    ),
  ];
}

/// Angka tabular tebal (uang/KPI = hero).
TextStyle numStyle({
  double size = 20,
  FontWeight weight = FontWeight.w800,
  Color? color,
}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.ink,
      height: 1.1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

/// Label kapital kecil (muted).
TextStyle labelStyle({Color? color}) => GoogleFonts.plusJakartaSans(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.8,
      color: color ?? AppColors.muted,
    );

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.green,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.ink,
    secondary: AppColors.green,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
    error: AppColors.loss,
  );

  final text = GoogleFonts.plusJakartaSansTextTheme().apply(
    bodyColor: AppColors.inkSoft,
    displayColor: AppColors.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: text,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
  );
}
