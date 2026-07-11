import 'package:flutter/material.dart';

// Utility class for time formatting and conversion operations
class TimeUtils {
  // Converts TimeOfDay into HH:mm string format
  static String fmtTOD(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  // Converts TimeOfDay into total minutes from midnight
  static int toMin(TimeOfDay t) => t.hour * 60 + t.minute;
}
