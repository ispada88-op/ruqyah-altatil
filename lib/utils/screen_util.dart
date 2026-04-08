import 'package:flutter/material.dart';

/// Screen utility for responsive design
class ScreenUtil {
  static late double _width;
  static late double _height;
  static late double _pixelRatio;
  static late bool _isTablet;
  
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _width = mediaQuery.size.width;
    _height = mediaQuery.size.height;
    _pixelRatio = mediaQuery.devicePixelRatio;
    _isTablet = _width >= 600;
  }
  
  static double get width => _width;
  static double get height => _height;
  static double get pixelRatio => _pixelRatio;
  static bool get isTablet => _isTablet;
  static bool get isPhone => !_isTablet;
  
  /// Responsive font size
  static double sp(double fontSize) {
    if (_isTablet) return fontSize * 1.2;
    return fontSize;
  }
  
  /// Responsive width
  static double w(double width) {
    return width * (_width / 375);
  }
  
  /// Responsive height
  static double h(double height) {
    return height * (_height / 812);
  }
  
  /// Responsive padding
  static EdgeInsets padding(double all) {
    return EdgeInsets.all(w(all));
  }
  
  /// Responsive horizontal spacing
  static double horizontalSpacing(double spacing) {
    if (_isTablet) return spacing * 1.5;
    return spacing;
  }
  
  /// Responsive vertical spacing
  static double verticalSpacing(double spacing) {
    if (_isTablet) return spacing * 1.3;
    return spacing;
  }
  
  /// Grid cross axis count based on screen width
  static int gridColumns({double itemWidth = 160}) {
    return (_width / itemWidth).floor().clamp(2, 6);
  }
}
