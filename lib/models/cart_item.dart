import 'food_item.dart';
import 'variant.dart';
import 'add_on.dart';

class CartItem {
  final FoodItem foodItem;
  final Variant variant;
  final List<AddOn> addOns;
  int quantity;

  CartItem({
    required this.foodItem,
    required this.variant,
    required this.addOns,
    required this.quantity,
  });

  double get totalPrice {
    double base = foodItem.basePrice + variant.priceModifier;
    double addOnsTotal = addOns.fold(0, (sum, addon) => sum + addon.price);
    return (base + addOnsTotal) * quantity;
  }

  CartItem copyWith({int? quantity}) {
    return CartItem(
      foodItem: foodItem,
      variant: variant,
      addOns: addOns,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItem &&
        other.foodItem.id == foodItem.id &&
        other.variant.name == variant.name &&
        _areAddOnsEqual(other.addOns);
  }

  bool _areAddOnsEqual(List<AddOn> otherAddOns) {
    if (addOns.length != otherAddOns.length) return false;
    final names = addOns.map((a) => a.name).toSet();
    final otherNames = otherAddOns.map((a) => a.name).toSet();
    return names.containsAll(otherNames);
  }

  @override
  int get hashCode => Object.hash(foodItem.id, variant.name, addOns.map((a) => a.name));
}