import 'package:flutter/material.dart';

class AppleLiquidColors {
  // Deep Obsidian & Charcoal (Apple Liquid Glass)
  static const Color background = Color(0xFF07090D);
  static const Color obsidianSurface = Color(0xFF0B0E14);
  static const Color glassSurface = Color(0xFF10141D);
  
  // Organic Forest Greens (High-End Automotive - NO NEON PURPLE)
  static const Color forestPrimary = Color(0xFF00E676);
  static const Color forestEmerald = Color(0xFF10B981);
  static const Color forestDark = Color(0xFF059669);
  static const Color forestDeep = Color(0xFF022C22);
  static const Color forestGlow = Color(0x7310B981);
  
  // Metallic Silver & Platinum Accents
  static const Color platinum100 = Color(0xFFF8FAFC);
  static const Color silver200 = Color(0xFFE2E8F0);
  static const Color silver400 = Color(0xFF94A3B8);
  static const Color silver700 = Color(0xFF334155);
  
  // Status Colors
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color crimsonAlert = Color(0xFFEF4444);
  
  // Glass Borders & Sheens
  static const Color glassBorder = Color(0x1FFFFFFF);        // 0.5px subtle white
  static const Color glassBorderGreen = Color(0x4D10B981);   // Subtle green glow border
}

class AppleLiquidTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppleLiquidColors.background,
      primaryColor: AppleLiquidColors.forestPrimary,
      colorScheme: const ColorScheme.dark(
        primary: AppleLiquidColors.forestPrimary,
        secondary: AppleLiquidColors.forestEmerald,
        surface: AppleLiquidColors.obsidianSurface,
        background: AppleLiquidColors.background,
        error: AppleLiquidColors.crimsonAlert,
      ),
      fontFamily: 'SF Pro Display',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppleLiquidColors.platinum100,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}
