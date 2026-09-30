import 'package:flutter/material.dart';

class AppCategories {
  static const String food = 'Food';
  static const String transport = 'Transport';
  static const String shopping = 'Shopping';
  static const String bills = 'Bills';
  static const String entertainment = 'Entertainment';
  static const String health = 'Health';
  static const String others = 'Others';

  static const List<String> categories = [
    food,
    transport,
    shopping,
    bills,
    entertainment,
    health,
    others,
  ];

  static IconData getCategoryIcon(String category) {
    switch (category) {
      case food:
        return Icons.restaurant;
      case transport:
        return Icons.directions_bus;
      case shopping:
        return Icons.shopping_bag;
      case bills:
        return Icons.receipt_long;
      case entertainment:
        return Icons.sports_esports;
      case health:
        return Icons.medical_services;
      case others:
      default:
        return Icons.category;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category) {
      case food:
        return const Color(0xFFF97316); // Orange
      case transport:
        return const Color(0xFF0EA5E9); // Cyan/Blue
      case shopping:
        return const Color(0xFFEC4899); // Pink
      case bills:
        return const Color(0xFF8B5CF6); // Purple
      case entertainment:
        return const Color(0xFFF59E0B); // Amber
      case health:
        return const Color(0xFF10B981); // Emerald Green
      case others:
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }
}
