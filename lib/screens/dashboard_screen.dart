import 'package:flutter/material.dart';
import 'food_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
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
      duration: const Duration(milliseconds: 800),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeScreen = screenWidth > 900;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: skyPrimaryLight,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Sky blue themed App Bar
          SliverAppBar.medium(
            expandedHeight: isTablet ? 280 : 220,
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
                      // Animated logo
                      ScaleTransition(
                        scale: _animationController.drive(
                          Tween<double>(begin: 0.8, end: 1.0)
                              .chain(CurveTween(curve: Curves.easeOutBack)),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.restaurant_menu,
                            size: isTablet ? 72 : 56,
                            color: skyPrimaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // App name
                      Text(
                        'Foodie Express',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      // Tagline
                      Text(
                        'Order delicious food with just a few taps',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main content with fade-in
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 32 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header

                    // Order options grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = isLargeScreen
                            ? 3
                            : isTablet
                                ? 2
                                : 1;
                        final childAspectRatio = isLargeScreen
                            ? 1.2
                            : isTablet
                                ? 1.1
                                : 1.3;

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: childAspectRatio,
                          children: [
                            _buildOrderOption(
                              context,
                              title: 'Dine-In',
                              subtitle: 'Enjoy your meal at our restaurant',
                              icon: Icons.dining,
                              color: skyPrimary,
                              onTap: () =>
                                  _navigateToMenu(context, 'Dine-In'),
                              isTablet: isTablet,
                            ),
                            _buildOrderOption(
                              context,
                              title: 'Takeaway',
                              subtitle: 'Order for pickup',
                              icon: Icons.shopping_bag,
                              color: skyPrimaryDark,
                              onTap: () =>
                                  _navigateToMenu(context, 'Takeaway'),
                              isTablet: isTablet,
                            ),
                            if (isLargeScreen)
                              _buildOrderOption(
                                context,
                                title: 'Delivery',
                                subtitle: 'Get food delivered to your door',
                                icon: Icons.delivery_dining,
                                color: skyPrimaryLight,
                                onTap: () =>
                                    _showComingSoon(context, 'Delivery'),
                                isTablet: isTablet,
                              ),
                          ],
                        );
                      },
                    ),

                    if (!isLargeScreen) ...[
                      const SizedBox(height: 16),
                      _buildOrderOption(
                        context,
                        title: 'Delivery',
                        subtitle: 'Get food delivered to your door',
                        icon: Icons.delivery_dining,
                        color: skyPrimaryLight,
                        onTap: () => _showComingSoon(context, 'Delivery'),
                        isTablet: isTablet,
                      ),
                    ],

                    const SizedBox(height: 48),

                    // Features section
                    _buildFeaturesSection(isTablet),

                    const SizedBox(height: 48),

                    // Stats section
                    _buildStatsSection(isTablet),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildOrderOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(isTablet ? 24 : 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with gradient background
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: isTablet ? 48 : 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(bool isTablet) {
    final features = [
      {'icon': Icons.star, 'title': 'Premium Quality', 'description': 'Fresh ingredients daily'},
      {'icon': Icons.speed, 'title': 'Fast Service', 'description': 'Quick preparation time'},
      {'icon': Icons.local_offer, 'title': 'Best Prices', 'description': 'Affordable and delicious'},
      {'icon': Icons.support_agent, 'title': '24/7 Support', 'description': 'Always here to help'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Choose Us?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: skyPrimaryDark,
              ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 4 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: skyPrimary.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      feature['icon'] as IconData,
                      size: isTablet ? 32 : 28,
                      color: skyPrimary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      feature['title'] as String,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatsSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [skyPrimary, skyPrimaryDark],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: skyPrimary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Numbers',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('10K+', 'Happy Customers', Colors.white, isTablet),
              _buildStatItem('50+', 'Menu Items', Colors.white, isTablet),
              _buildStatItem('4.8★', 'Average Rating', Colors.white, isTablet),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label, Color textColor, bool isTablet) {
    return Column(
      children: [
        Text(
          number,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 32 : 28,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor.withOpacity(0.9),
                fontSize: isTablet ? 14 : 12,
              ),
        ),
      ],
    );
  }

  void _navigateToMenu(BuildContext context, String orderType) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const FoodListScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text('$feature feature coming soon!'),
          ],
        ),
        backgroundColor: skyPrimary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}