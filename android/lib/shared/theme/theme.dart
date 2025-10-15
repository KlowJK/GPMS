import 'package:flutter/material.dart';

class ThemeConfig {
  // AppBar color
  static const Color appBarColor = Color(0xFF2563EB);

  // Main colors
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFFFFA000);

  // Responsive content width
  static double maxContentWidth(double w) {
    if (w >= 1200) return 1100;
    if (w >= 900) return 900;
    if (w >= 600) return 600;
    return w;
  }

  // Responsive padding
  static double pad(double w) => w >= 900 ? 24 : 16;

  // Responsive gap
  static double gap(double w) => w >= 900 ? 16 : 12;

  // Text styles
  static const TextStyle appBarTitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Add more shared configs as needed...
}
