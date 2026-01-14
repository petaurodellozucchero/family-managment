import 'package:flutter/material.dart';

/// Utility functions for color conversion
class ColorUtils {
  /// Convert a hex color string to a Color object
  static Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Convert a Color object to a hex color string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Get the list of available color options for family members
  static List<Color> getColorOptions() {
    return [
      const Color(0xFFFFEB3B), // Yellow
      const Color(0xFFE91E63), // Pink
      const Color(0xFFF44336), // Red
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFFF9800), // Orange
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFFFFEB38), // Lime
      const Color(0xFFFF5722), // Deep Orange
    ];
  }
}
