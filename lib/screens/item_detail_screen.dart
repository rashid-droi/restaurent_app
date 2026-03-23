import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/food_item.dart';
import '../models/variant.dart';
import '../models/add_on.dart';
import '../models/cart_item.dart';
import '../providers/cart_provider.dart';
import '../data/menu_data.dart';

class ItemDetailScreen extends StatefulWidget {
  final FoodItem foodItem;
  const ItemDetailScreen({super.key, required this.foodItem});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen>
    with SingleTickerProviderStateMixin {
  late Variant selectedVariant;
  List<AddOn> selectedAddOns = [];
  int quantity = 1;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Sky blue theme colors (consistent with other screens)
  static const Color skyPrimary = Color(0xFF64B5F6);
  static const Color skyPrimaryDark = Color(0xFF1E88E5);
  static const Color skyPrimaryLight = Color(0xFFBBDEFB);

  @override
  void initState() {
    super.initState();
    selectedVariant = variants[0]; // Small
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  double get _itemTotalPrice {
    double base = widget.foodItem.basePrice + selectedVariant.priceModifier;
    double addOnsTotal = selectedAddOns.fold(0, (sum, addon) => sum + addon.price);
    return (base + addOnsTotal) * quantity;
  }

  void _addToCart() {
    final cartItem = CartItem(
      foodItem: widget.foodItem,
      variant: selectedVariant,
      addOns: List.from(selectedAddOns),
      quantity: quantity,
    );
    Provider.of<CartProvider>(context, listen: false).addItem(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('${widget.foodItem.name} added to cart!')),
          ],
        ),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            Navigator.pop(context);
            // Navigate to cart if needed
          },
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: skyPrimary,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: skyPrimaryLight,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Sky blue themed App Bar with Hero
          SliverAppBar.large(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: skyPrimary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient background
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [skyPrimary, skyPrimaryDark],
                      ),
                    ),
                  ),
                  // Food icon
                  Center(
                    child: Hero(
                      tag: 'food_item_${widget.foodItem.id}',
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.foodItem.icon,
                          size: isTablet ? 80 : 60,
                          color: skyPrimaryDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Favorite button
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Added to favorites'),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: skyPrimary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.favorite_border),
                  color: skyPrimaryDark,
                ),
              ),
            ],
          ),

          // Content with fade animation
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.foodItem.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: skyPrimaryDark,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Base price: \$${widget.foodItem.basePrice.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.grey[700],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // Price chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [skyPrimary, skyPrimaryDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '\$${_itemTotalPrice.toStringAsFixed(2)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Size Selection
                    _buildSection(
                      'Select Size',
                      Icons.format_size,
                      _buildSizeSelection(),
                    ),

                    const SizedBox(height: 32),

                    // Add-ons
                    _buildSection(
                      'Customize Your Order',
                      Icons.add_circle_outline,
                      _buildAddOnSelection(),
                    ),

                    const SizedBox(height: 32),

                    // Quantity
                    _buildSection(
                      'Quantity',
                      Icons.add_shopping_cart,
                      _buildQuantitySelector(isTablet),
                    ),

                    const SizedBox(height: 40),

                    // Add to Cart Button
                    _buildAddToCartButton(isTablet),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: skyPrimaryDark),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: skyPrimaryDark,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildSizeSelection() {
    return SegmentedButton<Variant>(
      segments: variants.map((variant) {
        return ButtonSegment<Variant>(
          value: variant,
          label: Text(
            variant.name,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
          icon: variant.priceModifier > 0
              ? Text(
                  '+\$${variant.priceModifier.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 10),
                )
              : null,
        );
      }).toList(),
      selected: {selectedVariant},
      onSelectionChanged: (Set<Variant> newSelection) {
        setState(() {
          selectedVariant = newSelection.first;
        });
      },
      style: SegmentedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[700],
        selectedForegroundColor: skyPrimaryDark,
        selectedBackgroundColor: skyPrimary.withOpacity(0.2),
        side: BorderSide(color: Colors.grey[300]!),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
    );
  }

  Widget _buildAddOnSelection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: availableAddOns.map((addon) {
        final isSelected = selectedAddOns.contains(addon);
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(addon.name),
              const SizedBox(width: 4),
              Text(
                '+\$${addon.price.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? skyPrimaryDark : Colors.grey[600],
                ),
              ),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedAddOns.add(addon);
              } else {
                selectedAddOns.remove(addon);
              }
            });
          },
          backgroundColor: Colors.white,
          selectedColor: skyPrimary.withOpacity(0.2),
          checkmarkColor: skyPrimaryDark,
          labelStyle: TextStyle(
            color: isSelected ? skyPrimaryDark : Colors.grey[700],
          ),
          side: BorderSide(
            color: isSelected ? skyPrimary : Colors.grey[300]!,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuantitySelector(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Select Quantity',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
        ),
        Row(
          children: [
            // Decrease button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: quantity > 1
                    ? () {
                        setState(() {
                          quantity--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove),
                color: skyPrimaryDark,
              ),
            ),
            const SizedBox(width: 16),
            // Quantity display
            Container(
              width: isTablet ? 80 : 60,
              height: isTablet ? 56 : 48,
              decoration: BoxDecoration(
                color: skyPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: skyPrimary.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  '$quantity',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: skyPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Increase button
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [skyPrimary, skyPrimaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: skyPrimary.withOpacity(0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    quantity++;
                  });
                },
                icon: const Icon(Icons.add),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(bool isTablet) {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 56 : 48,
      child: ElevatedButton(
        onPressed: _addToCart,
        style: ElevatedButton.styleFrom(
          backgroundColor: skyPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_cart),
            const SizedBox(width: 8),
            Text(
              'Add to Cart - \$${_itemTotalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}