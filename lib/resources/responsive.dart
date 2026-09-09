import 'package:flutter/material.dart';

/// Extension on BuildContext to provide comprehensive, clean responsive utilities
/// backed by MediaQuery for any screen size, aspect ratio, or tablet device.
extension ResponsiveContext on BuildContext {
  /// MediaQueryData for the current context
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Full size of the screen
  Size get screenSize => mediaQuery.size;

  /// Width of the screen in logical pixels
  double get screenWidth => screenSize.width;

  /// Height of the screen in logical pixels
  double get screenHeight => screenSize.height;

  /// Device pixel ratio
  double get devicePixelRatio => mediaQuery.devicePixelRatio;

  /// Orientation of the screen
  Orientation get orientation => mediaQuery.orientation;

  /// Check if device is in portrait
  bool get isPortrait => orientation == Orientation.portrait;

  /// Check if device is in landscape
  bool get isLandscape => orientation == Orientation.landscape;

  /// Device padding (notches, status bar, navigation bar)
  EdgeInsets get screenPadding => mediaQuery.padding;

  /// Top notch/status bar height
  double get statusBarHeight => screenPadding.top;

  /// Bottom home indicator/nav bar padding
  double get bottomBarPadding => screenPadding.bottom;

  /// Keyboard insets (height of software keyboard when open)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Current keyboard height
  double get keyboardHeight => viewInsets.bottom;

  /// Whether soft keyboard is currently visible
  bool get isKeyboardOpen => keyboardHeight > 0;

  /// Breakpoints
  bool get isSmallPhone => screenWidth < 360;
  bool get isStandardPhone => screenWidth >= 360 && screenWidth < 600;
  bool get isTabletDevice => screenWidth >= 600;

  /// Width percentage helper: returns screenWidth * (percent / 100)
  /// Example: context.wp(50) -> 50% of screen width
  double wp(double percent) => screenWidth * (percent / 100.0);

  /// Height percentage helper: returns screenHeight * (percent / 100)
  /// Example: context.hp(25) -> 25% of screen height
  double hp(double percent) => screenHeight * (percent / 100.0);

  /// Scalable text / font size helper
  /// Uses base reference width of 390 (standard modern phone), clamped between 0.85 and 1.25
  /// Also accounts for system text scaling accessibility settings safely
  double sp(double size) {
    final double scaleFactor = (screenWidth / 390.0).clamp(0.85, 1.25);
    final double systemScale = mediaQuery.textScaler.scale(1.0).clamp(0.85, 1.3);
    return size * scaleFactor * (systemScale > 1.15 ? 1.15 : systemScale);
  }

  /// Responsive padding helper: scales standard padding slightly on smaller or larger devices
  double r(double value) {
    final double scale = (screenWidth / 390.0).clamp(0.85, 1.2);
    return value * scale;
  }
}
