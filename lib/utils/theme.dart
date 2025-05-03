import 'package:flutter/material.dart';

/// Main theme class that provides access to all app styling elements
class AppTheme {
  final BuildContext _context;

  AppTheme._(this._context);

  /// Get the AppTheme instance for the current context
  static AppTheme of(BuildContext context) {
    return AppTheme._(context);
  }

  /// Whether the current theme is in dark mode
  bool get isDarkMode => Theme.of(_context).brightness == Brightness.dark;

  /// Access to the color palette
  AppColors get colors => isDarkMode ? _darkColors : _lightColors;

  /// Primary color shorthand
  Color get primary => colors.primary;

  /// Access to text styles
  AppTextStyles get textStyle => AppTextStyles(_context);

  /// Access to spacing utilities
  AppSpacing get spacing => AppSpacing();

  /// Access to radius utilities
  AppRadius get radius => AppRadius();

  /// Access to animation presets
  AppAnimations get animations => AppAnimations();
}

final _lightColors = AppColors(
  primary: const Color(0xFF3498DB),
  secondary: const Color(0xFF2ECC71),
  background: const Color(
    0xFFF5F5F5,
  ),
  surface: Colors.white,
  error: const Color(0xFFE74C3C),
  onPrimary: Colors.white,
  onSecondary: Colors.black,
  onBackground: const Color(
    0xFF2C3E50,
  ),
  onSurface: const Color(
    0xFF2C3E50,
  ),
  onError: Colors.white,
);

final _darkColors = AppColors(
  primary: const Color(0xFF3498DB),
  secondary: const Color(0xFF2ECC71),
  background: const Color(0xFF121212),
  surface: const Color(0xFF121212),
  error: const Color(0xFFE74C3C),
  onPrimary: Colors.black,
  onSecondary: Colors.black,
  onBackground: Colors.white,
  onSurface: Colors.white,
  onError: Colors.black,
);

/// Color palette for the application
class AppColors {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color error;
  final Color onPrimary;
  final Color onSecondary;
  final Color onBackground;
  final Color onSurface;
  final Color onError;

  final Color grey = const Color(0xFF9E9E9E);
  final Color lightGrey = const Color(0xFFE0E0E0);
  final Color darkGrey = const Color(0xFF616161);
  final Color success = const Color(0xFF2ECC71);
  final Color info = const Color(0xFF3498DB);
  final Color warning = const Color(0xFFF39C12);
  final Color danger = const Color(0xFFE74C3C);

  final Color primaryTextColor = const Color(0xFF2C3E50);
  final Color secondaryTextColor = const Color(0xFF7F8C8D);
  final Color hintTextColor = const Color(0xFFBDC3C7);

  AppColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.error,
    required this.onPrimary,
    required this.onSecondary,
    required this.onBackground,
    required this.onSurface,
    required this.onError,
  });
}

/// Text styles for the application
class AppTextStyles {
  final BuildContext _context;

  AppTextStyles(this._context);

  TextTheme get _textTheme => Theme.of(_context).textTheme;

  TextStyle get headlineLarge => _textTheme.headlineLarge!;
  TextStyle get headlineMedium => _textTheme.headlineMedium!;
  TextStyle get headlineSmall => _textTheme.headlineSmall!;

  TextStyle get titleLarge => _textTheme.titleLarge!;
  TextStyle get titleMedium => _textTheme.titleMedium!;
  TextStyle get titleSmall => _textTheme.titleSmall!;

  TextStyle get bodyLarge => _textTheme.bodyLarge!;
  TextStyle get bodyMedium => _textTheme.bodyMedium!;
  TextStyle get bodySmall => _textTheme.bodySmall!;

  TextStyle get labelLarge => _textTheme.labelLarge!;
  TextStyle get labelMedium => _textTheme.labelMedium!;
  TextStyle get labelSmall => _textTheme.labelSmall!;

  TextStyle get buttonText =>
      _textTheme.labelLarge!.copyWith(fontWeight: FontWeight.bold);

  TextStyle get caption => _textTheme.bodySmall!.copyWith(
    color: AppTheme.of(_context).colors.secondaryTextColor,
  );

  // Add styles from original const.dart for backward compatibility
  TextStyle get heading1 => headlineLarge.copyWith(
    fontWeight: FontWeight.bold,
    color: AppTheme.of(_context).colors.primaryTextColor,
  );

  TextStyle get heading2 => headlineMedium.copyWith(
    fontWeight: FontWeight.bold,
    color: AppTheme.of(_context).colors.primaryTextColor,
  );

  TextStyle get bodyText =>
      bodyMedium.copyWith(color: AppTheme.of(_context).colors.primaryTextColor);
}

/// Spacing utilities for consistent padding and margins
class AppSpacing {
  final double xs = 4.0;
  final double sm = 8.0;
  final double md = 16.0;
  final double lg = 24.0;
  final double xl = 32.0;
  final double xxl = 48.0;

  // Map to old constants for compatibility
  double get paddingS => sm;
  double get paddingM => md;
  double get paddingL => lg;

  EdgeInsets all(double value) => EdgeInsets.all(value);
  EdgeInsets horizontal(double value) =>
      EdgeInsets.symmetric(horizontal: value);
  EdgeInsets vertical(double value) => EdgeInsets.symmetric(vertical: value);

  EdgeInsets get allXs => EdgeInsets.all(xs);
  EdgeInsets get allSm => EdgeInsets.all(sm);
  EdgeInsets get allMd => EdgeInsets.all(md);
  EdgeInsets get allLg => EdgeInsets.all(lg);
  EdgeInsets get allXl => EdgeInsets.all(xl);

  EdgeInsets get horizontalXs => EdgeInsets.symmetric(horizontal: xs);
  EdgeInsets get horizontalSm => EdgeInsets.symmetric(horizontal: sm);
  EdgeInsets get horizontalMd => EdgeInsets.symmetric(horizontal: md);
  EdgeInsets get horizontalLg => EdgeInsets.symmetric(horizontal: lg);
  EdgeInsets get horizontalXl => EdgeInsets.symmetric(horizontal: xl);

  EdgeInsets get verticalXs => EdgeInsets.symmetric(vertical: xs);
  EdgeInsets get verticalSm => EdgeInsets.symmetric(vertical: sm);
  EdgeInsets get verticalMd => EdgeInsets.symmetric(vertical: md);
  EdgeInsets get verticalLg => EdgeInsets.symmetric(vertical: lg);
  EdgeInsets get verticalXl => EdgeInsets.symmetric(vertical: xl);
}

/// Border radius utilities for consistent UI rounding
class AppRadius {
  final double xs = 4.0;
  final double sm = 8.0;
  final double md = 12.0;
  final double lg = 16.0;
  final double xl = 24.0;
  final double circular = 100.0;

  // Map to old constants for compatibility
  double get borderRadiusM => md;
  double get borderRadiusL => lg;

  BorderRadius all(double value) => BorderRadius.circular(value);

  BorderRadius get allXs => BorderRadius.circular(xs);
  BorderRadius get allSm => BorderRadius.circular(sm);
  BorderRadius get allMd => BorderRadius.circular(md);
  BorderRadius get allLg => BorderRadius.circular(lg);
  BorderRadius get allXl => BorderRadius.circular(xl);
  BorderRadius get allCircular => BorderRadius.circular(circular);
}

/// Animation presets for consistent motion design
class AppAnimations {
  final Duration short = const Duration(milliseconds: 200);
  final Duration medium = const Duration(milliseconds: 300);
  final Duration long = const Duration(milliseconds: 500);

  final Curve standard = Curves.easeInOut;
  final Curve decelerate = Curves.decelerate;
}
