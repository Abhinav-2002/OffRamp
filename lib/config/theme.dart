import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ═════════════════════════════════════════════════════════════════════════════
// OFFRAMP DESIGN SYSTEM - EXACT SPECIFICATIONS
// ═════════════════════════════════════════════════════════════════════════════

/// Core color palette - exact hex values from spec
class AppColors {
  // Primary backgrounds
  static const Color deepNavy = Color(0xFF1A1F2E);
  static const Color creamWhite = Color(0xFFF5F1E8);
  static const Color charcoal = Color(0xFF2D3142);

  // Accents
  static const Color warmCoral = Color(0xFFE88D7D);
  static const Color softSage = Color(0xFF7D9D8B);
  static const Color mutedLavender = Color(0xFF9B8FB9);
  static const Color mutedGray = Color(0xFF8B92A5);

  // Semantic
  static const Color success = Color(0xFF7D9D8B);
  static const Color warning = Color(0xFFE8C87D);
  static const Color error = Color(0xFFE88D7D);

  // Text (on different backgrounds)
  static const Color textOnDark = Color(0xFFF5F1E8);
  static const Color textOnLight = Color(0xFF2D3142);
  static const Color textMuted = Color(0xFF8B92A5);

  // Overlay
  static const Color overlayBg = Color(0xE61A1F2E); // 90% opacity deep navy

  // Sleep mode
  static const Color sleepBg = Color(0xFF1A1730);
  static const Color sleepAccent = Color(0xFF9B8FB9);
}

// ═════════════════════════════════════════════════════════════════════════════
// TYPOGRAPHY - Inter font family, exact sizes
// ═════════════════════════════════════════════════════════════════════════════
class AppText {
  // Display - for titles/headlines
  static TextStyle display = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnDark,
    height: 1.2,
  );

  static TextStyle displayLight = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnDark,
    height: 1.2,
  );

  // Title - for section headers
  static TextStyle title = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnDark,
    height: 1.3,
  );

  static TextStyle titleLight = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnDark,
    height: 1.3,
  );

  // Body - primary reading text
  static TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textOnDark,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textOnDark,
    height: 1.5,
  );

  // Caption - secondary text
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  // Button text
  static TextStyle button = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.creamWhite,
    height: 1.0,
  );

  // Timer digits
  static TextStyle timerDigits = GoogleFonts.inter(
    fontSize: 56,
    fontWeight: FontWeight.w300,
    color: AppColors.textOnDark,
    height: 1.0,
    letterSpacing: 2,
  );

  // Quote/Tagline
  static TextStyle quote = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.textMuted,
    height: 1.6,
  );

  // Label - small uppercase labels
  static TextStyle label = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.textMuted,
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// BUTTON STYLES - Consistent across app
// ═════════════════════════════════════════════════════════════════════════════
class AppButtons {
  // Primary action - Warm Coral
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.warmCoral,
    foregroundColor: AppColors.creamWhite,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppText.button,
    minimumSize: const Size(200, 48),
  );

  // Secondary action - Soft Sage
  static ButtonStyle secondary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.softSage,
    foregroundColor: AppColors.creamWhite,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppText.button,
    minimumSize: const Size(200, 48),
  );

  // Tertiary - Muted Gray
  static ButtonStyle tertiary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.mutedGray,
    foregroundColor: AppColors.creamWhite,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppText.button,
    minimumSize: const Size(200, 48),
  );

  // Ghost/Outline button
  static ButtonStyle ghost = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textOnDark,
    side: BorderSide(color: AppColors.mutedGray, width: 1),
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppText.button.copyWith(color: AppColors.textOnDark),
    minimumSize: const Size(200, 48),
  );

  // Small button variant
  static ButtonStyle smallPrimary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.warmCoral,
    foregroundColor: AppColors.creamWhite,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    textStyle: AppText.bodyMedium.copyWith(color: AppColors.creamWhite),
  );

  // Text button
  static ButtonStyle text = TextButton.styleFrom(
    foregroundColor: AppColors.warmCoral,
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    textStyle: AppText.bodyMedium,
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// CARD DECORATIONS - Consistent card styling
// ═════════════════════════════════════════════════════════════════════════════
class AppDecorations {
  // Standard card on dark background
  static BoxDecoration card = BoxDecoration(
    color: AppColors.charcoal,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Card with subtle border
  static BoxDecoration cardOutlined = BoxDecoration(
    color: AppColors.charcoal,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.mutedGray.withOpacity(0.3), width: 1),
  );

  // Input field decoration
  static BoxDecoration input = BoxDecoration(
    color: AppColors.deepNavy,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.mutedGray.withOpacity(0.3), width: 1),
  );

  // Progress indicator decoration
  static BoxDecoration progressBg = BoxDecoration(
    color: AppColors.charcoal,
    borderRadius: BorderRadius.circular(8),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// INPUT DECORATION - Text fields
// ═════════════════════════════════════════════════════════════════════════════
class AppInputDecoration {
  static InputDecoration textField({String? hint, String? label, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      labelText: label,
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.charcoal,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.softSage, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: AppText.body.copyWith(color: AppColors.textMuted),
      labelStyle: AppText.caption.copyWith(color: AppColors.textMuted),
      counterStyle: AppText.caption,
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ANIMATION DURATIONS - Consistent timing
// ═════════════════════════════════════════════════════════════════════════════
class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration mascotAnimation = Duration(milliseconds: 2000);
}

// ═════════════════════════════════════════════════════════════════════════════
// SPACING - Consistent layout values
// ═════════════════════════════════════════════════════════════════════════════
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.all(24);

  // Card max width
  static const double cardMaxWidth = 400;
}
