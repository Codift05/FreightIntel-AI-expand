import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Token warna brand FreightIntel AI (lihat app/DESIGN.md).
class AppColors {
  // Surface / netral (abu dingin, ikut Reference Design)
  static const bg = Color(0xFFEFF1F3);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF6F7F9);
  static const line = Color(0xFFE8EAED);

  // Teks (near-black, bukan navy)
  static const ink = Color(0xFF141414); // 18.4:1 di putih
  static const inkDeep = Color(0xFF141414); // kartu hero gelap
  static const inkSoft = Color(0xFF5B6066); // 6.3:1 di putih
  static const muted = Color(0xFF6B7280); // 4.8:1 di putih (label kecil)
  static const onDark = Color(0xFF9CA3AF); // label di atas kartu gelap (7.3:1)

  // Aksen interaktif (lime, ikut referensi) — teks di atasnya = ink
  static const lime = Color(0xFFD3F85A);

  // Hijau = data positif (bukan aksen UI)
  static const green = Color(0xFF17A55B);
  static const greenSoft = Color(0xFFE7F6EE);
  static const greenInk = Color(0xFF0E7A42);
  static const greenBright = Color(0xFF3FD98A); // positif di atas kartu gelap

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

/// Angka tabular (uang/KPI).
///
/// Bobot w700, bukan w800: di Onest w800 terbaca terlalu padat untuk nominal
/// besar. Tracking dirapatkan seiring ukuran naik — angka besar dengan jarak
/// huruf normal terlihat renggang dan kurang rapi.
TextStyle numStyle({
  double size = 20,
  FontWeight weight = FontWeight.w700,
  Color? color,
}) =>
    GoogleFonts.onest(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.ink,
      height: 1.1,
      letterSpacing: size >= 26
          ? -0.8
          : size >= 20
              ? -0.4
              : -0.2,
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
