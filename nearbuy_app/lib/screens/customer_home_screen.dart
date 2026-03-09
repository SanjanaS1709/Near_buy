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
      body: Stack(
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
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront, color: Color(0xFFA50000)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: "Search shops, spices, textiles...",
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        ),
                        const Icon(Icons.tune, color: Color(0xFFA50000)),
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

          // Custom Bottom Nav Bar Placeholder
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavIcon(Icons.explore, "Discover", true),
                  _buildNavIcon(Icons.store, "Shops", false),
                  _buildNavIcon(Icons.assignment, "Orders", false),
                  _buildNavIcon(Icons.person, "Profile", false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? const Color(0xFFA50000) : Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFFA50000) : Colors.grey,
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
