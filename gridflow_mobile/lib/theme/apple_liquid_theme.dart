import 'package:flutter/material.dart';

class AppleLiquidColors {
  // Light Nature EV Background & Pearl White Palette
  static const Color background = Color(0xFFF1F5F9);
  static const Color pearlSurface = Color(0xFFFFFFFF);
  
  // Electric Sky Blue Accents (Modern EV Dashboard Palette)
  static const Color skyElectric = Color(0xFF00A3FF);
  static const Color skyVibrant = Color(0xFF0284C7);
  static const Color skySoft = Color(0xFF38BDF8);
  static const Color skyMist = Color(0xFFBAE6FD);
  static const Color skyAura = Color(0xFFE0F2FE);
  
  // Authentic Nature Greens (Apple Human Interface Standard)
  static const Color natureEmerald = Color(0xFF059669);
  static const Color natureLeaf = Color(0xFF10B981);
  static const Color natureMint = Color(0xFFD1FAE5);
  static const Color natureGlow = Color(0x4710B981);
  
  // Clean Human Typography & Accents
  static const Color textHeadline = Color(0xFF0F172A);
  static const Color textSub = Color(0xFF334155);
  static const Color textCaption = Color(0xFF64748B);
  
  // Status Colors
  static const Color amberWarning = Color(0xFFD97706);
  static const Color crimsonAlert = Color(0xFFDC2626);
  
  // Crystal Glass Refraction Borders & Sheens
  static const Color glassBorder = Color(0xE6FFFFFF);         // 90% pure crystal white
  static const Color glassBorderSubtle = Color(0x80FFFFFF);   // 50% white
  static const Color glassBorderSky = Color(0x6600A3FF);      // 40% electric sky
  static const Color glassBorderGreen = Color(0x6610B981);    // 40% emerald

  // Primary Gradient (Electric Sky to Emerald Green)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [skyElectric, skyVibrant, natureEmerald],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppleLiquidTheme {
  static ThemeData get lightNatureTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppleLiquidColors.background,
      primaryColor: AppleLiquidColors.skyVibrant,
      colorScheme: const ColorScheme.light(
        primary: AppleLiquidColors.skyVibrant,
        secondary: AppleLiquidColors.natureLeaf,
        surface: AppleLiquidColors.pearlSurface,
        background: AppleLiquidColors.background,
        error: AppleLiquidColors.crimsonAlert,
      ),
      fontFamily: 'SF Pro Display',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppleLiquidColors.textHeadline,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: AppleLiquidColors.textHeadline),
      ),
    );
  }

  // Backward compatibility alias
  static ThemeData get darkTheme => lightNatureTheme;
}
