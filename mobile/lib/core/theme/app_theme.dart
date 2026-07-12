import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Vibrant Sakura Pink & Indigo (Japanese Module)
  static const Color sakuraPink = Color(0xFFFF85A2);
  static const Color deepIndigo = Color(0xFF1A1E36);
  static const Color softIndigo = Color(0xFF2E3459);

  // Sleek Academic Navy & Gold Accent (IELTS Module)
  static const Color academicNavy = Color(0xFF0F172A);
  static const Color goldAccent = Color(0xFFF59E0B);
  static const Color slateGray = Color(0xFF475569);

  // Common UI Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceWhite = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B);

  // Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color crimsonRed = Color(0xFFE11D48);
  static const Color warningOrange = Color(0xFFF97316);

  // Duolingo-Inspired Gamified & Clean UI Colors (Tham chiếu Duolingo)
  static const Color duoGreen =
      Color(0xFF58CC02); // Feather Green (Primary Success & Continue)
  static const Color duoGreenShadow =
      Color(0xFF58A700); // Chunky 3D Button Bottom Shadow
  static const Color duoBlue = Color(0xFF1CB0F6); // Macaw Blue (Grammar & Tips)
  static const Color duoBlueShadow =
      Color(0xFF1899D6); // Blue Button Bottom Shadow
  static const Color duoYellow =
      Color(0xFFFFC800); // Bee Yellow (Streaks, Stars, Rewards)
  static const Color duoYellowShadow =
      Color(0xFFE5B400); // Yellow Button Bottom Shadow
  static const Color duoRed =
      Color(0xFFFF4B4B); // Cardinal Red (Errors & Heart Loss)
  static const Color duoRedShadow =
      Color(0xFFD03838); // Red Button Bottom Shadow
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.duoGreen,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.duoGreen,
        secondary: AppColors.duoBlue,
        surface: AppColors.surfaceWhite,
        error: AppColors.duoRed,
      ),
      textTheme: GoogleFonts.outfitTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.outfit(
          color: const Color(0xFF3C3C3C),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF3C3C3C)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.duoGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.duoGreenShadow, width: 2),
          ),
          textStyle:
              GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE5E5E5), width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: GoogleFonts.outfit(color: const Color(0xFFAFAFAF)),
        labelStyle: GoogleFonts.outfit(
            color: const Color(0xFF3C3C3C), fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 2)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E5E5), width: 2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.duoBlue, width: 2)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        labelStyle: GoogleFonts.outfit(
            color: const Color(0xFF3C3C3C),
            fontSize: 13,
            fontWeight: FontWeight.bold),
        secondaryLabelStyle: GoogleFonts.outfit(color: AppColors.duoGreen),
        brightness: Brightness.light,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.duoGreen.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
                color: AppColors.duoGreen,
                fontWeight: FontWeight.bold,
                fontSize: 13);
          }
          return GoogleFonts.outfit(
              color: const Color(0xFFAFAFAF),
              fontWeight: FontWeight.w600,
              fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.duoGreen);
          }
          return const IconThemeData(color: Color(0xFFAFAFAF));
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return lightTheme; // Luôn sử dụng giao diện trắng sáng, không dùng màu tối
  }
}
