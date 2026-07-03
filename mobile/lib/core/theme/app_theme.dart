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
    static const Color warningOrange = Color(0xFFF97316);
}

class AppTheme {
    static ThemeData get lightTheme {
        return ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: AppColors.sakuraPink,
            scaffoldBackgroundColor: AppColors.backgroundLight,
            colorScheme: const ColorScheme.light(
                primary: AppColors.sakuraPink,
                secondary: AppColors.goldAccent,
                surface: AppColors.surfaceWhite,
                error: AppColors.errorRed,
            ),
            textTheme: GoogleFonts.outfitTextTheme(),
            appBarTheme: AppBarTheme(
                backgroundColor: AppColors.surfaceWhite,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: GoogleFonts.outfit(
                    color: AppColors.deepIndigo,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                ),
                iconTheme: const IconThemeData(color: AppColors.deepIndigo),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.deepIndigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                ),
            ),
            cardTheme: CardThemeData(
                color: AppColors.surfaceWhite,
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.06),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                hintStyle: GoogleFonts.outfit(color: AppColors.slateGray),
                labelStyle: GoogleFonts.outfit(color: AppColors.deepIndigo),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.slateGray.withValues(alpha: 0.3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.slateGray.withValues(alpha: 0.3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.deepIndigo, width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            chipTheme: ChipThemeData(
                backgroundColor: Colors.white,
                labelStyle: GoogleFonts.outfit(color: AppColors.deepIndigo, fontSize: 13, fontWeight: FontWeight.w600),
                secondaryLabelStyle: GoogleFonts.outfit(color: AppColors.sakuraPink),
                brightness: Brightness.light,
            ),
            navigationBarTheme: NavigationBarThemeData(
                backgroundColor: Colors.white,
                indicatorColor: AppColors.sakuraPink.withValues(alpha: 0.25),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                        return GoogleFonts.outfit(color: AppColors.deepIndigo, fontWeight: FontWeight.bold, fontSize: 12);
                    }
                    return GoogleFonts.outfit(color: AppColors.slateGray, fontSize: 12);
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                        return const IconThemeData(color: AppColors.deepIndigo);
                    }
                    return const IconThemeData(color: AppColors.slateGray);
                }),
            ),
        );
    }

    static ThemeData get darkTheme {
        return ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: AppColors.sakuraPink,
            scaffoldBackgroundColor: AppColors.backgroundDark,
            colorScheme: const ColorScheme.dark(
                primary: AppColors.sakuraPink,
                secondary: AppColors.goldAccent,
                surface: AppColors.surfaceDark,
                error: AppColors.errorRed,
            ),
            textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
            appBarTheme: AppBarTheme(
                backgroundColor: AppColors.surfaceDark,
                elevation: 0,
                centerTitle: true,
                titleTextStyle: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                ),
                iconTheme: const IconThemeData(color: Colors.white),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.sakuraPink,
                    foregroundColor: AppColors.deepIndigo,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    textStyle: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                ),
            ),
            cardTheme: CardThemeData(
                color: AppColors.surfaceDark,
                elevation: 4,
                shadowColor: Colors.black.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.surfaceDark,
                hintStyle: GoogleFonts.outfit(color: AppColors.slateGray),
                labelStyle: GoogleFonts.outfit(color: AppColors.goldAccent),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.slateGray.withValues(alpha: 0.3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.slateGray.withValues(alpha: 0.3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.sakuraPink, width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            chipTheme: ChipThemeData(
                backgroundColor: AppColors.surfaceDark,
                labelStyle: GoogleFonts.outfit(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                secondaryLabelStyle: GoogleFonts.outfit(color: AppColors.sakuraPink),
                brightness: Brightness.dark,
            ),
            navigationBarTheme: NavigationBarThemeData(
                backgroundColor: AppColors.surfaceDark,
                indicatorColor: AppColors.sakuraPink.withValues(alpha: 0.25),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                        return GoogleFonts.outfit(color: AppColors.sakuraPink, fontWeight: FontWeight.bold, fontSize: 12);
                    }
                    return GoogleFonts.outfit(color: AppColors.slateGray, fontSize: 12);
                }),
                iconTheme: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                        return const IconThemeData(color: AppColors.sakuraPink);
                    }
                    return const IconThemeData(color: AppColors.slateGray);
                }),
            ),
        );
    }
}
