import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'kitchen_screen.dart';
import '../models/cart_item.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Sky blue theme colors
  static const Color skyPrimary = Color(0xFF64B5F6);
  static const Color skyPrimaryDark = Color(0xFF1E88E5);
  static const Color skyPrimaryLight = Color(0xFFBBDEFB);

  @override
  void initState() {
    super.initState();
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

  void _saveOrder(BuildContext context, List<CartItem> items) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Your cart is empty'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Copy items for kitchen display
    final orderItems = List<CartItem>.from(items);
    // Clear cart
    Provider.of<CartProvider>(context, listen: false).clearCart();

    // Show notification and navigate
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Order sent to Kitchen!'),
          ],
        ),
        backgroundColor: skyPrimary,
        action: SnackBarAction(
          label: 'View Kitchen',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => KitchenScreen(orderItems: orderItems),
              ),
            );
          },
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KitchenScreen(orderItems: orderItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: skyPrimaryLight,
      body: Consumer<CartProvider>(
        builder: (ctx, cart, _) {
          if (cart.items.isEmpty) {
            return _buildEmptyCart(isTablet);
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Sky blue themed App Bar
              SliverAppBar(
                title: Text('Cart (${cart.itemCount})'),
                backgroundColor: skyPrimary,
                foregroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [skyPrimary, skyPrimaryDark],
                      ),
                    ),
                  ),
                ),
                actions: [
                  if (cart.itemCount > 0)
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_outlined),
                      onPressed: () {
                        _showClearCartDialog(ctx, cart);
                      },
                      tooltip: 'Clear cart',
                    ),
                ],
              ),

              // Cart Items with fade animation
              SliverPadding(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = cart.items[index];
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildCartItem(item, cart, isTablet),
                      );
                    },
                    childCount: cart.items.length,
                  ),
                ),
              ),

              // Order Summary
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: _buildOrderSummary(cart, isTablet),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty cart illustration with gradient
              Container(
                padding: const EdgeInsets.all(48),
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
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: isTablet ? 120 : 80,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Your cart is empty',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: skyPrimaryDark,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Add some delicious items to get started!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.restaurant_menu),
                label: const Text('Browse Menu'),
                style: FilledButton.styleFrom(
                  backgroundColor: skyPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cart, bool isTablet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: skyPrimary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food icon with gradient background
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [skyPrimaryLight, skyPrimary.withOpacity(0.3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.foodItem.icon,
                    size: isTablet ? 32 : 24,
                    color: skyPrimaryDark,
                  ),
                ),
                const SizedBox(width: 16),
                // Item details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.foodItem.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Size: ${item.variant.name}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      if (item.addOns.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Add-ons: ${item.addOns.map((a) => a.name).join(', ')}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                // Delete button
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
                    onPressed: () {
                      _showDeleteItemDialog(context, cart, item);
                    },
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quantity and price row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Quantity controls
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
                        onPressed: item.quantity > 1
                            ? () {
                                cart.updateQuantity(item, item.quantity - 1);
                              }
                            : null,
                        icon: const Icon(Icons.remove),
                        color: skyPrimaryDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Quantity display
                    Container(
                      width: isTablet ? 60 : 50,
                      height: isTablet ? 60 : 50,
                      decoration: BoxDecoration(
                        color: skyPrimary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: skyPrimary.withOpacity(0.3)),
                      ),
                      child: Center(
                        child: Text(
                          '${item.quantity}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                          cart.updateQuantity(item, item.quantity + 1);
                        },
                        icon: const Icon(Icons.add),
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                // Item price
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: skyPrimaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cart, bool isTablet) {
    final subtotal = cart.totalCartPrice;
    final tax = subtotal * 0.1;
    final total = subtotal + tax;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: skyPrimary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal (${cart.itemCount} items)',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tax (10%)',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              Text(
                '\$${tax.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: skyPrimaryDark,
                    ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: skyPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: isTablet ? 56 : 48,
            child: FilledButton.icon(
              onPressed: () => _saveOrder(context, cart.items),
              icon: const Icon(Icons.check_circle),
              label: const Text('Place Order'),
              style: FilledButton.styleFrom(
                backgroundColor: skyPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteItemDialog(BuildContext context, CartProvider cart, CartItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Item'),
        content: Text('Remove ${item.foodItem.name} from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cart.removeItem(item);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.foodItem.name} removed from cart'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: skyPrimary,
                ),
              );
            },
            child: Text(
              'Remove',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, CartProvider cart) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to clear your entire cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              cart.clearCart();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cart cleared'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: skyPrimary,
                ),
              );
            },
            child: Text(
              'Clear',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}