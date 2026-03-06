import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── DESIGN TOKENS ───────────────────────────────────────────────
class AppColors {
  // Primary backgrounds
  static const Color bgPrimary = Color(0xFFF7F9F7);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgDark = Color(0xFF1A1F2E);

  // Accents
  static const Color accentTeal = Color(0xFFB8DDD4);
  static const Color accentGreen = Color(0xFFD4EDCC);
  static const Color accentYellow = Color(0xFFF5E9A0);

  // Semantic
  static const Color coral = Color(0xFFE88D7D);
  static const Color coralDark = Color(0xFFD4796A);
  static const Color sage = Color(0xFF7D9D8B);
  static const Color sageDark = Color(0xFF5E8070);
  static const Color lavender = Color(0xFF9B8FB9);
  static const Color warning = Color(0xFFE8C87D);
  static const Color info = Color(0xFF7D9DE8);

  // Text
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF8A8A9A);
  static const Color textMuted = Color(0xFFB0B0BC);

  // Misc
  static const Color cardBorder = Color(0xFFEEEEF0);
  static const Color divider = Color(0xFFF0F0F2);
  static const Color overlay = Color(0xEB1A1F2E);

  // Sleep mode
  static const Color sleepBg1 = Color(0xFF1A1730);
  static const Color sleepBg2 = Color(0xFF2A2545);
  static const Color sleepBg3 = Color(0xFF1A1F2E);
}

// ─── CARD DECORATION ─────────────────────────────────────────────
class AppDecorations {
  static BoxDecoration card = BoxDecoration(
    color: AppColors.bgCard,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration cardSubtle = BoxDecoration(
    color: AppColors.bgPrimary,
    borderRadius: BorderRadius.circular(14),
  );

  static BoxDecoration cardTeal = BoxDecoration(
    color: AppColors.accentTeal.withValues(alpha: 0.2),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 12,
        offset: const Offset(0, 3),
      ),
    ],
  );
}

// ─── BUTTON STYLES ───────────────────────────────────────────────
class AppButtons {
  static ButtonStyle coral = ElevatedButton.styleFrom(
    backgroundColor: AppColors.coral,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
  );

  static ButtonStyle sage = ElevatedButton.styleFrom(
    backgroundColor: AppColors.sage,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
  );

  static ButtonStyle yellow = ElevatedButton.styleFrom(
    backgroundColor: AppColors.accentYellow,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
  );

  static ButtonStyle ghost = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textSecondary,
    side: BorderSide(color: AppColors.cardBorder),
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
  );

  static ButtonStyle ghostSmall = OutlinedButton.styleFrom(
    foregroundColor: AppColors.textSecondary,
    side: BorderSide(color: AppColors.cardBorder),
    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
  );

  static ButtonStyle coralSmall = ElevatedButton.styleFrom(
    backgroundColor: AppColors.coral,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600),
  );

  static ButtonStyle sageSmall = ElevatedButton.styleFrom(
    backgroundColor: AppColors.sage,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    textStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600),
  );
}

// ─── TYPOGRAPHY ──────────────────────────────────────────────────
class AppText {
  static TextStyle display = GoogleFonts.lora(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  static TextStyle displaySm = GoogleFonts.lora(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle title = GoogleFonts.dmSans(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle body = GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle caption = GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle label = GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
    color: AppColors.textMuted,
  );

  static TextStyle cardTitle = GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    color: AppColors.textSecondary,
  );

  static TextStyle button = GoogleFonts.dmSans(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  static TextStyle timerDigits = GoogleFonts.lora(
    fontSize: 56,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static TextStyle quote = GoogleFonts.lora(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    color: AppColors.textSecondary,
    height: 1.6,
  );
}

// ─── PILL DECORATIONS ────────────────────────────────────────────
class AppPills {
  static BoxDecoration sage = BoxDecoration(
    color: AppColors.sage.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.sage.withValues(alpha: 0.25)),
  );

  static BoxDecoration coral = BoxDecoration(
    color: AppColors.coral.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.coral.withValues(alpha: 0.25)),
  );

  static BoxDecoration warning = BoxDecoration(
    color: AppColors.warning.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
  );
}
