import 'package:flutter/material.dart';

class FoodItem {
  final String id;
  final String name;
  final double basePrice;
  final IconData icon;

  FoodItem({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.icon,
  });
}