import 'package:flutter/material.dart';

class TimeUtils {
  static String fmtTOD(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  static int toMin(TimeOfDay t) => t.hour * 60 + t.minute;
}
