import 'package:flutter/material.dart';
import 'package:nearbuy_app/services/api_service.dart';
import 'package:nearbuy_app/widgets/custom_widgets.dart';
import 'package:nearbuy_app/screens/add_product_screen.dart';

class ShopDashboardScreen extends StatefulWidget {
  final int ownerId;
  const ShopDashboardScreen({super.key, required this.ownerId});

  @override
  State<ShopDashboardScreen> createState() => _ShopDashboardScreenState();
}

class _ShopDashboardScreenState extends State<ShopDashboardScreen> {
  final _apiService = ApiService();
  int _currentIndex = 0;
  Map<String, dynamic>? _shop;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() async {
    final shopData = await _apiService.getMyShop(widget.ownerId);
    if (shopData.containsKey('id')) {
      final stats = await _apiService.getShopStats(shopData['id']);
      setState(() {
        _shop = shopData;
        _stats = stats;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F5),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          InventoryTab(shopId: _shop!['id'], apiService: _apiService, stats: _stats),
          OrdersTab(shopId: _shop!['id'], apiService: _apiService),
          HistoryTab(shopId: _shop!['id'], apiService: _apiService),
          const Center(child: Text("Profile Settings")), // Placeholder for Profile
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFA50000),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2), label: "Inventory"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), activeIcon: Icon(Icons.shopping_bag), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// INVENTORY TAB
class InventoryTab extends StatefulWidget {
  final int shopId;
  final ApiService apiService;
  final Map<String, dynamic>? stats;
  const InventoryTab({super.key, required this.shopId, required this.apiService, this.stats});

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> {
  List<dynamic> _products = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    final products = await widget.apiService.getShopProducts(widget.shopId);
    setState(() {
      _products = products;
      _isLoadingProducts = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Local Bazaar", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Color(0xFFA50000)), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: StatCard(title: "Total Products", value: "${_products.length}", titleColor: const Color(0xFFA50000))),
                const SizedBox(width: 16),
                Expanded(child: StatCard(title: "Active Orders", value: "${widget.stats?['active_orders'] ?? 0}")),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.add_circle_outline, color: Color(0xFFA50000)),
                      const SizedBox(width: 8),
                      const Text("Add New Product", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: "Launch Add Wizard", 
                    onPressed: () => Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => AddProductScreen(shopId: widget.shopId))
                    ).then((_) => _loadProducts()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Your Inventory", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                TextButton(onPressed: () {}, child: const Text("View All", style: TextStyle(color: Color(0xFFA50000)))),
              ],
            ),
            if (_isLoadingProducts) 
              const Center(child: CircularProgressIndicator())
            else
              ..._products.map((p) => InventoryCard(
                product: p, 
                onEdit: () {}, 
                onDelete: () {}
              )),
          ],
        ),
      ),
    );
  }
}

// ORDERS TAB
class OrdersTab extends StatefulWidget {
  final int shopId;
  final ApiService apiService;
  const OrdersTab({super.key, required this.shopId, required this.apiService});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _loadOrders();
    });
  }

  void _loadOrders() async {
    setState(() => _isLoading = true);
    String? status;
    if (_tabController.index == 0) status = "pending";
    if (_tabController.index == 1) status = "preparing";
    if (_tabController.index == 2) status = "ready";
    
    final orders = await widget.apiService.getShopOrders(widget.shopId, status: status);
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  void _updateStatus(int orderId, String newStatus) async {
    await widget.apiService.updateOrderStatus(orderId, newStatus);
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Active Orders", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFA50000),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFA50000),
          tabs: const [
            Tab(text: "New"),
            Tab(text: "Preparing"),
            Tab(text: "Ready"),
          ],
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                String nextAction = "Prepare Order";
                String nextStatus = "preparing";
                if (_tabController.index == 1) { nextAction = "Mark as Ready"; nextStatus = "ready"; }
                if (_tabController.index == 2) { nextAction = "Dispatch Order"; nextStatus = "completed"; }

                return OrderPreparationCard(
                  order: order,
                  actionLabel: nextAction,
                  onAction: () => _updateStatus(order['id'], nextStatus),
                );
              },
            ),
    );
  }
}

// HISTORY TAB
class HistoryTab extends StatefulWidget {
  final int shopId;
  final ApiService apiService;
  const HistoryTab({super.key, required this.shopId, required this.apiService});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  Map<String, dynamic>? _stats;
  List<dynamic> _pastOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    final stats = await widget.apiService.getShopStats(widget.shopId);
    final orders = await widget.apiService.getShopOrders(widget.shopId, status: "completed");
    setState(() {
      _stats = stats;
      _pastOrders = orders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Order History", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: StatCard(
                        title: "TOTAL EARNINGS", 
                        value: "₹${_stats?['total_earnings'] ?? 0}", 
                        subtitle: "+12% vs last month",
                        titleColor: const Color(0xFFA50000),
                      )),
                      const SizedBox(width: 16),
                      Expanded(child: StatCard(
                        title: "TOTAL ORDERS", 
                        value: "${_stats?['total_orders'] ?? 0}", 
                        subtitle: "+5%",
                      )),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("Recent Orders", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  ..._pastOrders.map((o) => HistoryOrderCard(order: o, onTap: () {})),
                ],
              ),
            ),
    );
  }
}
