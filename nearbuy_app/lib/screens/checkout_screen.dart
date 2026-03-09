import 'package:flutter/material.dart';
import 'package:nearbuy_app/services/api_service.dart';
import 'package:nearbuy_app/screens/order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final Map<String, dynamic> shop;
  final int userId;
  final double total;
  final String orderType;
  final String? deliveryAddress;

  const CheckoutScreen({
    super.key,
    required this.cart,
    required this.shop,
    required this.userId,
    required this.total,
    required this.orderType,
    this.deliveryAddress,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late String _orderType;
  late TextEditingController _addressController;
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _orderType = widget.orderType;
    _addressController = TextEditingController(text: widget.deliveryAddress);
  }

  void _placeOrder() async {
    final items = widget.cart.map((item) => {"product_id": item['id'], "quantity": 1}).toList();
    final result = await _apiService.placeOrder(
      widget.userId,
      widget.shop['id'],
      widget.total,
      _orderType,
      items,
      address: _orderType == 'delivery' ? _addressController.text : null,
    );

    if (result.containsKey('id')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Placed Successfully")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OrderTrackingScreen(order: result)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['detail'] ?? "Failed to place order")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Order Type", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ListTile(
              title: const Text("Self Takeaway"),
              leading: Radio<String>(
                value: 'takeaway',
                groupValue: _orderType,
                onChanged: (value) => setState(() => _orderType = value!),
              ),
            ),
            ListTile(
              title: const Text("Home Delivery"),
              leading: Radio<String>(
                value: 'delivery',
                groupValue: _orderType,
                onChanged: (value) => setState(() => _orderType = value!),
              ),
            ),
            if (_orderType == 'delivery')
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Delivery Address"),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: _placeOrder,
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text("Place Order"),
            ),
          ],
        ),
      ),
    );
  }
}
