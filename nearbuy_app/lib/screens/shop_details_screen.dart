import 'package:flutter/material.dart';
import 'package:nearbuy_app/services/api_service.dart';
import 'package:nearbuy_app/screens/cart_screen.dart';
import 'package:nearbuy_app/widgets/custom_widgets.dart';

class ShopDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> shop;
  final int userId;
  const ShopDetailsScreen({super.key, required this.shop, required this.userId});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  final _apiService = ApiService();
  List<dynamic> _products = [];
  final List<Map<String, dynamic>> _cart = [];
  String _selectedCategory = "All";
  final List<String> _categories = ["All", "Vegetables", "Fruits", "Spices", "Textiles"];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    final products = await _apiService.getShopProducts(widget.shop['id']);
    setState(() {
      _products = products;
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final existingIndex = _cart.indexWhere((item) => item['id'] == product['id']);
      if (existingIndex != -1) {
        _cart[existingIndex]['quantity'] = (_cart[existingIndex]['quantity'] ?? 1) + 1;
      } else {
        final newProduct = Map<String, dynamic>.from(product);
        newProduct['quantity'] = 1;
        _cart.add(newProduct);
      }
    });
  }

  double get _cartTotal => _cart.fold(0, (sum, item) => sum + ((item['price'] ?? 0) * (item['quantity'] ?? 1)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Premium Header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.shop['image_url'] ?? 'https://images.unsplash.com/photo-1542838132-92c53300491e',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.6)],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(4)),
                          child: const Text("OPEN", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.shop['name'],
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(widget.shop['address'], style: const TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.shop['rating'] ?? 0.0} (${widget.shop['review_count'] ?? 0} reviews)",
                              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: const Color(0xFFA50000),
            leading: IconButton(
              icon: const CircleAvatar(backgroundColor: Colors.white30, child: Icon(Icons.arrow_back, color: Colors.white)),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const CircleAvatar(backgroundColor: Colors.white30, child: Icon(Icons.favorite_border, color: Colors.white)),
                onPressed: () {},
              ),
              IconButton(
                icon: const CircleAvatar(backgroundColor: Colors.white30, child: Icon(Icons.share, color: Colors.white)),
                onPressed: () {},
              ),
            ],
          ),

          // Category Chips
          SliverToBoxAdapter(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  return CategoryChip(
                    label: cat,
                    isSelected: _selectedCategory == cat,
                    onTap: () => setState(() => _selectedCategory = cat),
                  );
                },
              ),
            ),
          ),

          // Product Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = _products[index];
                  return ProductCard(
                    product: product,
                    onAdd: () => _addToCart(product),
                  );
                },
                childCount: _products.length,
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      
      // Floating Cart Bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _cart.isNotEmpty
          ? Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFA50000),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: const Color(0xFFA50000).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen(cart: List.from(_cart), shop: widget.shop, userId: widget.userId)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${_cart.length} Items", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          Text("\$${_cartTotal.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const Row(
                        children: [
                          Text("View Cart", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          SizedBox(width: 8),
                          Icon(Icons.shopping_bag_outlined, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}
