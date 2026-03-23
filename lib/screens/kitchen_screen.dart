import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class KitchenScreen extends StatefulWidget {
  final List<CartItem> orderItems;
  const KitchenScreen({super.key, required this.orderItems});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  Map<String, bool> _completedItems = {};
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Sky blue theme colors
  static const Color skyPrimary = Color(0xFF64B5F6);
  static const Color skyPrimaryDark = Color(0xFF1E88E5);
  static const Color skyPrimaryLight = Color(0xFFBBDEFB);

  @override
  void initState() {
    super.initState();
    // Initialize completed items map
    for (var item in widget.orderItems) {
      _completedItems[item.foodItem.id] = false;
    }
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

  void _toggleItemCompletion(String itemId) {
    setState(() {
      _completedItems[itemId] = !(_completedItems[itemId] ?? false);
    });
  }

  bool _areAllItemsCompleted() {
    return _completedItems.values.every((completed) => completed);
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
          // Sky blue themed App Bar
          SliverAppBar.large(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: skyPrimary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [skyPrimary, skyPrimaryDark],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant,
                        size: isTablet ? 80 : 60,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${widget.orderItems.length} Orders',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              if (_areAllItemsCompleted())
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
                      _showCompletionDialog(context);
                    },
                    icon: const Icon(Icons.check_circle),
                    color: skyPrimary,
                    tooltip: 'All orders completed',
                  ),
                ),
            ],
          ),

          // Order Content with fade animation
          if (widget.orderItems.isEmpty)
            SliverFillRemaining(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildEmptyOrders(isTablet),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = widget.orderItems[index];
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildOrderItem(item, isTablet, index),
                    );
                  },
                  childCount: widget.orderItems.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildEmptyOrders(bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 32 : 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state illustration with gradient
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
                Icons.no_food,
                size: isTablet ? 120 : 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No orders yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: skyPrimaryDark,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Waiting for new orders to come in...',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(CartItem item, bool isTablet, int index) {
    final isCompleted = _completedItems[item.foodItem.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isCompleted ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: skyPrimary.withOpacity(isCompleted ? 0.2 : 0.3),
        ),
      ),
      color: isCompleted ? Colors.white.withOpacity(0.8) : Colors.white,
      child: InkWell(
        onTap: () => _toggleItemCompletion(item.foodItem.id),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Checkbox with sky blue accent
                  Checkbox(
                    value: isCompleted,
                    onChanged: (value) {
                      _toggleItemCompletion(item.foodItem.id);
                    },
                    activeColor: skyPrimary,
                    checkColor: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  // Food icon with gradient background
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          skyPrimaryLight,
                          skyPrimary.withOpacity(0.3),
                        ],
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
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isCompleted
                                    ? Colors.grey[500]
                                    : Colors.grey[800],
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Size: ${item.variant.name}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        if (item.addOns.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Add-ons: ${item.addOns.map((a) => a.name).join(', ')}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Quantity and price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Quantity badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? skyPrimary.withOpacity(0.1)
                              : skyPrimary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Qty: ${item.quantity}',
                          style: TextStyle(
                            color: isCompleted ? Colors.grey[600] : skyPrimaryDark,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              color: isCompleted ? Colors.grey[600] : skyPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              if (isCompleted) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: skyPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: skyPrimary,
                        size: isTablet ? 20 : 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Completed',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              color: skyPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Icon(
          Icons.check_circle,
          color: skyPrimary,
          size: 48,
        ),
        title: const Text('All Orders Completed!'),
        content: const Text(
            'Great job! All orders have been prepared and are ready for serving.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Continue Working',
              style: TextStyle(color: skyPrimary),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: skyPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Close Kitchen'),
          ),
        ],
      ),
    );
  }
}