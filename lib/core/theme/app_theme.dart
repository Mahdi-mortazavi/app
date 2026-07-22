import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _base(Brightness.light);
  static ThemeData get dark => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
        primaryColor: AppColors.accentBlue,
        fontFamily: GoogleFonts.vazirmatn().fontFamily,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accentBlue,
          brightness: brightness,
        ),
      );
}
