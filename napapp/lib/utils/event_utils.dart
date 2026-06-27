import 'package:flutter/material.dart';

class EventUtils {
  static IconData iconFromCategory(String cat) {
    switch (cat) {
      case 'Pranzo':
        return Icons.restaurant;
      case 'Studio':
        return Icons.menu_book;
      case 'Allenamento':
        return Icons.fitness_center;
      case 'Lezione':
        return Icons.school;
      default:
        return Icons.more_horiz;
    }
  }
}
