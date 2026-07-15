import 'package:flutter/material.dart';

class _AppColorsData {
  final Color primary;
  final Color primaryLight;
  final Color primaryGlow;
  final Color secondary;
  final Color accent;
  final Color success;
  final Color warning;
  final Color bgDark;
  final Color bgDarker;
  final Color textMain;
  final Color textMuted;
  final Color textDim;
  final Color glassFill;
  final Color glassHover;
  final Color glassBorder;
  final Color glassBorderHover;

  const _AppColorsData({
    required this.primary,
    required this.primaryLight,
    required this.primaryGlow,
    required this.secondary,
    required this.accent,
    required this.success,
    required this.warning,
    required this.bgDark,
    required this.bgDarker,
    required this.textMain,
    required this.textMuted,
    required this.textDim,
    required this.glassFill,
    required this.glassHover,
    required this.glassBorder,
    required this.glassBorderHover,
  });

  Gradient get gradientPrimary => LinearGradient(
        colors: [primary, primaryGlow],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  Gradient get gradientAccent => LinearGradient(
        colors: [primaryLight, secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  Gradient get gradientSurface => LinearGradient(
        colors: [bgDarker, bgDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
}

class AppColors {
  static _AppColorsData _current = _light;

  static void setMode(ThemeMode mode) {
    _current = mode == ThemeMode.light ? _light : _dark;
  }

  static const _AppColorsData _light = _AppColorsData(
    primary: Color(0xFF5B7CED),
    primaryLight: Color(0xFF85A4F5),
    primaryGlow: Color(0xFF6D8CEE),
    secondary: Color(0xFFF5846B),
    accent: Color(0xFF4DB6AC),
    success: Color(0xFF5BC87A),
    warning: Color(0xFFF0C050),
    bgDark: Color(0xFFF7F5F2),
    bgDarker: Color(0xFFFEFDFB),
    textMain: Color(0xFF2D2D2D),
    textMuted: Color(0xFF8A8A8A),
    textDim: Color(0xFFB0B0B0),
    glassFill: Color(0x06000000),
    glassHover: Color(0x0C000000),
    glassBorder: Color(0x14000000),
    glassBorderHover: Color(0x1E000000),
  );

  static const _AppColorsData _dark = _AppColorsData(
    primary: Color(0xFF85A4F5),
    primaryLight: Color(0xFFA6BCFF),
    primaryGlow: Color(0xFF93AFF5),
    secondary: Color(0xFFFD9B8A),
    accent: Color(0xFF6EE7D8),
    success: Color(0xFF6EE7A0),
    warning: Color(0xFFFCD34D),
    bgDark: Color(0xFF1E1E20),
    bgDarker: Color(0xFF151517),
    textMain: Color(0xFFEDEAE6),
    textMuted: Color(0xFFA8A29E),
    textDim: Color(0xFF78716C),
    glassFill: Color(0x06FFFFFF),
    glassHover: Color(0x0CFFFFFF),
    glassBorder: Color(0x12FFFFFF),
    glassBorderHover: Color(0x1EFFFFFF),
  );

  static Color get primary => _current.primary;
  static Color get primaryLight => _current.primaryLight;
  static Color get primaryGlow => _current.primaryGlow;
  static Color get secondary => _current.secondary;
  static Color get accent => _current.accent;
  static Color get success => _current.success;
  static Color get warning => _current.warning;
  static Color get bgDark => _current.bgDark;
  static Color get bgDarker => _current.bgDarker;
  static Color get textMain => _current.textMain;
  static Color get textMuted => _current.textMuted;
  static Color get textDim => _current.textDim;
  static Color get glassFill => _current.glassFill;
  static Color get glassHover => _current.glassHover;
  static Color get glassBorder => _current.glassBorder;
  static Color get glassBorderHover => _current.glassBorderHover;

  static Gradient get gradientPrimary => _current.gradientPrimary;
  static Gradient get gradientAccent => _current.gradientAccent;
  static Gradient get gradientSurface => _current.gradientSurface;
}

class AppTheme {
  static ThemeData get lightTheme =>
      _buildTheme(Brightness.light, AppColors._light);
  static ThemeData get darkTheme =>
      _buildTheme(Brightness.dark, AppColors._dark);

  static ThemeData _buildTheme(
      Brightness brightness, _AppColorsData colors) {
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: colors.bgDarker,
      colorScheme: brightness == Brightness.dark
          ? ColorScheme.dark(
              primary: colors.primary,
              secondary: colors.secondary,
              surface: colors.bgDark,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: colors.textMain,
            )
          : ColorScheme.light(
              primary: colors.primary,
              secondary: colors.secondary,
              surface: colors.bgDark,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: colors.textMain,
            ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textMain,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.textMain,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.bgDark.withValues(alpha: 0.6),
        elevation: 0,
        shadowColor: colors.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.glassBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.glassFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        labelStyle: TextStyle(color: colors.textMuted, fontSize: 14),
        hintStyle: TextStyle(color: colors.textDim, fontSize: 14),
        prefixIconColor: colors.textMuted,
        suffixIconColor: colors.textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textMain,
          side: BorderSide(color: colors.glassBorder),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.bgDarker.withValues(alpha: 0.8),
        indicatorColor: colors.primary.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (_) => TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.textMuted),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colors.primary, size: 24);
          }
          return IconThemeData(color: colors.textMuted, size: 24);
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.bgDarker,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.glassBorder,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.bgDark,
        contentTextStyle: TextStyle(color: colors.textMain),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.bgDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: colors.glassBorder),
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: colors.textMain,
        ),
        contentTextStyle: TextStyle(
          fontSize: 14,
          color: colors.textMuted,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.bgDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: colors.glassBorder),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: colors.textMain),
        headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: colors.textMain),
        headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colors.textMain),
        titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.textMain),
        titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colors.textMain),
        titleSmall: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textMain),
        bodyLarge: TextStyle(
            fontSize: 16, height: 1.7, color: colors.textMain),
        bodyMedium: TextStyle(
            fontSize: 15, height: 1.7, color: colors.textMain),
        bodySmall: TextStyle(fontSize: 13, color: colors.textMuted),
        labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.textMain),
        labelSmall: TextStyle(fontSize: 11, color: colors.textDim),
      ),
    );
  }
}
