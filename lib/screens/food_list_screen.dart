import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../data/menu_data.dart';
import '../models/category.dart';
import '../models/food_item.dart';
import 'item_detail_screen.dart';
import 'cart_screen.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double>_fadeAnimation;

  // Sky blue theme colors (same as dashboard)
  static const Color skyPrimary = Color(0xFF64B5F6);
  static const Color skyPrimaryDark = Color(0xFF1E88E5);
  static const Color skyPrimaryLight = Color(0xFFBBDEFB);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<FoodItem> get _filteredItems {
    List<FoodItem> items = foodItems;

    // Filter by category
    if (_selectedCategory != 'All') {
      items = items.where((item) {
        if (_selectedCategory == 'Burgers') {
          return item.name.contains('Burger') || item.name.contains('Sandwich');
        } else if (_selectedCategory == 'Pizza') {
          return item.name.contains('Pizza');
        } else if (_selectedCategory == 'Pasta') {
          return item.name.contains('Pasta') ||
              item.name.contains('Spaghetti') ||
              item.name.contains('Penne');
        } else if (_selectedCategory == 'Salads') {
          return item.name.contains('Salad');
        } else if (_selectedCategory == 'Appetizers') {
          return item.name.contains('Fries') ||
              item.name.contains('Sticks') ||
              item.name.contains('Wings') ||
              item.name.contains('Rings');
        } else if (_selectedCategory == 'Desserts') {
          return item.name.contains('Cake') ||
              item.name.contains('Ice Cream') ||
              item.name.contains('Pie');
        } else if (_selectedCategory == 'Beverages') {
          return item.name.contains('Soda') ||
              item.name.contains('Juice') ||
              item.name.contains('Coffee');
        }
        return true;
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) =>
          item.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: skyPrimaryLight,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Sky blue themed App Bar
SliverAppBar(
  floating: true,
  snap: true,
  pinned: false,
  backgroundColor: skyPrimary,
  surfaceTintColor: Colors.transparent,
  foregroundColor: Colors.white,
  expandedHeight: MediaQuery.of(context).size.width > 600 ? 140 : 120,
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
    title: LayoutBuilder(
      builder: (context, constraints) {
        final isLarge = constraints.maxWidth > 600;
        return Text(
          'Menu',
          style: TextStyle(
            fontSize: isLarge ? 28 : 24,
            fontWeight: FontWeight.w600,
          ),
        );
      },
    ),
    titlePadding: EdgeInsetsDirectional.only(
      start: MediaQuery.of(context).size.width > 600 ? 24 : 16,
      bottom: 16,
    ),
  ),
  actions: [
    // Cart badge
    Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
        ),
        if (cartProvider.itemCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Badge(
              label: Text('${cartProvider.itemCount}'),
              child: const SizedBox(),
            ),
          ),
      ],
    ),
  ],
  bottom: PreferredSize(
    preferredSize: Size.fromHeight(MediaQuery.of(context).size.width > 600 ? 72 : 56),
    child: Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 16,
        vertical: 8,
      ),
      color: Colors.transparent,
      child: _buildSearchField(),
    ),
  ),
),

          // Categories with Material Design 3 chips (sky blue theme)
          SliverToBoxAdapter(
            child: _buildCategories(isTablet),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // Food items with fade-in
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isTablet ? 0.85 : 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _filteredItems[index];
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildFoodItemCard(item, isTablet),
                  );
                },
                childCount: _filteredItems.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search menu...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: skyPrimary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategories(bool isTablet) {
    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category.name == _selectedCategory;

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(category.name),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category.name;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: skyPrimary.withOpacity(0.2),
              checkmarkColor: skyPrimaryDark,
              labelStyle: TextStyle(
                color: isSelected ? skyPrimaryDark : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? skyPrimary : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodItemCard(FoodItem item, bool isTablet) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: skyPrimary.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  ItemDetailScreen(foodItem: item),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: animation.drive(
                    Tween(begin: const Offset(1.0, 0.0), end: Offset.zero),
                  ),
                  child: child,
                );
              },
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder with sky blue gradient
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [skyPrimaryLight, skyPrimary.withOpacity(0.3)],
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        item.icon,
                        size: isTablet ? 48 : 40,
                        color: skyPrimaryDark,
                      ),
                    ),
                    // Favorite button overlay
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
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
                          icon: Icon(
                            Icons.favorite_border,
                            color: skyPrimary,
                            size: 18,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Added ${item.name} to favorites'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: skyPrimary,
                              ),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: isTablet ? 18 : 16,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${item.basePrice.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: skyPrimaryDark,
                                fontWeight: FontWeight.w700,
                                fontSize: isTablet ? 20 : 18,
                              ),
                        ),
                        // Add button with sky blue theme
                        FilledButton.tonal(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ItemDetailScreen(foodItem: item),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: skyPrimary.withOpacity(0.1),
                            foregroundColor: skyPrimaryDark,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Icon(Icons.add, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}