import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:nearbuy_app/services/api_service.dart';
import 'package:nearbuy_app/screens/shop_details_screen.dart';
import 'package:nearbuy_app/widgets/custom_widgets.dart';

class CustomerHomeScreen extends StatefulWidget {
  final int userId;
  const CustomerHomeScreen({super.key, required this.userId});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final _apiService = ApiService();
  List<dynamic> _shops = [];
  String? _selectedType;
  final List<String> _shopTypes = ['Grocery', 'Spices', 'Textiles', 'Electronics', 'Bakery'];
  final MapController _mapController = MapController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  void _loadShops() async {
    final shops = await _apiService.getNearbyShops(type: _selectedType);
    setState(() {
      _shops = shops;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          const Center(child: Text("Shops Tab")), // Placeholder
          const Center(child: Text("Orders Tab")), // Placeholder
          const Center(child: Text("Profile Tab")), // Placeholder
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFA50000),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: "Discover"),
          BottomNavigationBarItem(icon: Icon(Icons.store_outlined), activeIcon: Icon(Icons.store), label: "Shops"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return Stack(
      children: [
        // Map Background
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(12.9716, 77.5946), // Bangalore
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
            ),
            MarkerLayer(
              markers: _shops.map((shop) {
                return Marker(
                  point: LatLng(shop['latitude'] ?? 12.9716, shop['longitude'] ?? 77.5946),
                  width: 40,
                  height: 40,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShopDetailsScreen(shop: shop, userId: widget.userId)),
                    ),
                    child: const Icon(Icons.location_on, color: Color(0xFFA50000), size: 40),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        
        // Header Section
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // Custom AppBar / Search Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.storefront, color: Color(0xFFA50000)),
                      SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search shops, spices, textiles...",
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      ),
                      Icon(Icons.tune, color: Color(0xFFA50000)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Categories
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _shopTypes.length,
                    itemBuilder: (context, index) {
                      final type = _shopTypes[index];
                      final isSelected = _selectedType == type;
                      return CategoryChip(
                        label: type,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            _selectedType = isSelected ? null : type;
                            _loadShops();
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Shop Carousel at Bottom
        Positioned(
          bottom: 30,
          left: 0,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Top Rated Near You",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _shops.length,
                  itemBuilder: (context, index) {
                    final shop = _shops[index];
                    return ShopCard(
                      shop: shop,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ShopDetailsScreen(shop: shop, userId: widget.userId)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

