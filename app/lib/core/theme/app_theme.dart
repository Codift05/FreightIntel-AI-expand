import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
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
  static const muted = Color(0xFF5C6B7D); // AA: 5.45:1 di white, 5.03:1 di bg

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

/// Kurva gerak bersama. Ease-out kuat (punchy) untuk elemen masuk/keluar,
/// lebih tegas dari Curves.easeOutCubic bawaan. Rujukan: Emil Kowalski.
const Curve kEaseOut = Cubic(0.22, 1, 0.36, 1);

class AppRadii {
  static const card = 24.0;
  static const tile = 20.0;
  static const input = 14.0;
  static const pill = 999.0;
}

class AppShadows {
  static const card = [
    BoxShadow(
      color: Color(0x12141F33),
      blurRadius: 28,
      offset: Offset(0, 14),
      spreadRadius: -12,
    ),
  ];
  static const soft = [
    BoxShadow(
      color: Color(0x0D141F33),
      blurRadius: 18,
      offset: Offset(0, 8),
      spreadRadius: -8,
    ),
  ];
}

/// Angka tabular tebal (uang/KPI = hero).
TextStyle numStyle({
  double size = 20,
  FontWeight weight = FontWeight.w800,
  Color? color,
}) =>
    GoogleFonts.onest(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.ink,
      height: 1.1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

/// Caption/label (sentence case, bukan eyebrow all-caps). Tenang, mudah dibaca.
TextStyle labelStyle({Color? color}) => GoogleFonts.onest(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
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

  final text = GoogleFonts.onestTextTheme().apply(
    bodyColor: AppColors.inkSoft,
    displayColor: AppColors.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: text,
    splashFactory: InkSparkle.splashFactory,
    // Transisi pindah layar: slide horizontal + swipe-back (ala iOS), konsisten.
    pageTransitionsTheme: PageTransitionsTheme(builders: {
      for (final p in TargetPlatform.values)
        p: const CupertinoPageTransitionsBuilder(),
    }),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
  );
}
