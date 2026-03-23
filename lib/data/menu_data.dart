import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../models/variant.dart';
import '../models/add_on.dart';
import '../models/category.dart';

final List<Category> categories = [
  Category(id: '1', name: 'All', icon: '🍽️'),
  Category(id: '2', name: 'Burgers', icon: '🍔'),
  Category(id: '3', name: 'Pizza', icon: '🍕'),
  Category(id: '4', name: 'Pasta', icon: '🍝'),
  Category(id: '5', name: 'Salads', icon: '🥗'),
  Category(id: '6', name: 'Appetizers', icon: '🍟'),
  Category(id: '7', name: 'Desserts', icon: '🍰'),
  Category(id: '8', name: 'Beverages', icon: '🥤'),
];

final List<FoodItem> foodItems = [
  // Burgers & Sandwiches
  FoodItem(id: '1', name: 'Classic Burger', basePrice: 8.99, icon: Icons.lunch_dining),
  FoodItem(id: '2', name: 'Cheeseburger', basePrice: 9.99, icon: Icons.lunch_dining),
  FoodItem(id: '3', name: 'BBQ Bacon Burger', basePrice: 11.99, icon: Icons.lunch_dining),
  FoodItem(id: '4', name: 'Chicken Sandwich', basePrice: 7.99, icon: Icons.lunch_dining),
  FoodItem(id: '5', name: 'Veggie Burger', basePrice: 8.49, icon: Icons.lunch_dining),
  
  // Pizza
  FoodItem(id: '6', name: 'Margherita Pizza', basePrice: 10.99, icon: Icons.local_pizza),
  FoodItem(id: '7', name: 'Pepperoni Pizza', basePrice: 12.99, icon: Icons.local_pizza),
  FoodItem(id: '8', name: 'Hawaiian Pizza', basePrice: 11.99, icon: Icons.local_pizza),
  FoodItem(id: '9', name: 'Veggie Pizza', basePrice: 10.49, icon: Icons.local_pizza),
  
  // Pasta
  FoodItem(id: '10', name: 'Spaghetti Carbonara', basePrice: 9.99, icon: Icons.restaurant),
  FoodItem(id: '11', name: 'Penne Alfredo', basePrice: 8.99, icon: Icons.restaurant),
  FoodItem(id: '12', name: 'Pasta Marinara', basePrice: 7.99, icon: Icons.restaurant),
  
  // Salads
  FoodItem(id: '13', name: 'Caesar Salad', basePrice: 6.99, icon: Icons.ramen_dining),
  FoodItem(id: '14', name: 'Greek Salad', basePrice: 7.49, icon: Icons.ramen_dining),
  FoodItem(id: '15', name: 'Garden Salad', basePrice: 5.99, icon: Icons.ramen_dining),
  
  // Appetizers
  FoodItem(id: '16', name: 'French Fries', basePrice: 3.99, icon: Icons.tapas),
  FoodItem(id: '17', name: 'Mozzarella Sticks', basePrice: 5.99, icon: Icons.tapas),
  FoodItem(id: '18', name: 'Chicken Wings', basePrice: 8.99, icon: Icons.tapas),
  FoodItem(id: '19', name: 'Onion Rings', basePrice: 4.99, icon: Icons.tapas),
  
  // Desserts
  FoodItem(id: '20', name: 'Chocolate Cake', basePrice: 4.99, icon: Icons.cake),
  FoodItem(id: '21', name: 'Ice Cream', basePrice: 3.99, icon: Icons.icecream),
  FoodItem(id: '22', name: 'Apple Pie', basePrice: 4.49, icon: Icons.cake),
  
  // Beverages
  FoodItem(id: '23', name: 'Soda', basePrice: 1.99, icon: Icons.local_drink),
  FoodItem(id: '24', name: 'Fresh Juice', basePrice: 3.99, icon: Icons.local_cafe),
  FoodItem(id: '25', name: 'Coffee', basePrice: 2.49, icon: Icons.coffee),
];

final List<Variant> variants = const [
  Variant('Small', 0),
  Variant('Medium', 2.0),
  Variant('Large', 4.0),
  Variant('Extra Large', 6.0),
  Variant('Family Size', 12.0),
];

final List<AddOn> availableAddOns = const [
  AddOn('Extra Cheese', 1.0),
  AddOn('Extra Sauce', 0.5),
  AddOn('Bacon', 1.5),
  AddOn('Mushrooms', 0.75),
  AddOn('Olives', 0.75),
  AddOn('Peppers', 0.5),
  AddOn('Onions', 0.5),
  AddOn('Extra Meat', 2.0),
  AddOn('Garlic Bread', 2.5),
  AddOn('Side Salad', 3.0),
  AddOn('Extra Fries', 2.0),
  AddOn('Dipping Sauce', 0.75),
];