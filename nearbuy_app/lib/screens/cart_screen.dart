import 'package:flutter/material.dart';
import 'package:nearbuy_app/screens/checkout_screen.dart';
import 'package:nearbuy_app/widgets/custom_widgets.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;
  final Map<String, dynamic> shop;
  final int userId;
  const CartScreen({super.key, required this.cart, required this.shop, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Map<String, dynamic>> _currentCart;
  bool _isDelivery = true;
  final TextEditingController _addressController = TextEditingController(text: "123 Bazaar Street, Old Town");

  @override
  void initState() {
    super.initState();
    _currentCart = List.from(widget.cart);
  }

  double get _subtotal => _currentCart.fold(0, (sum, item) => sum + ((item['price'] ?? 0) * (item['quantity'] ?? 1)));
  double get _deliveryFee => _isDelivery ? 2.50 : 0.0;
  double get _total => _subtotal + _deliveryFee;

  void _updateQuantity(int index, bool increase) {
    setState(() {
      if (increase) {
        _currentCart[index]['quantity'] = (_currentCart[index]['quantity'] ?? 1) + 1;
      } else {
        if ((_currentCart[index]['quantity'] ?? 1) > 1) {
          _currentCart[index]['quantity']--;
        } else {
          _currentCart.removeAt(index);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("My Shopping Cart", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFA50000)), onPressed: () => setState(() => _currentCart.clear())),
        ],
      ),
      body: _currentCart.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Toggle
                  DeliveryToggleWidget(
                    isDelivery: _isDelivery,
                    onChanged: (val) => setState(() => _isDelivery = val),
                  ),
                  const SizedBox(height: 24),
                  
                  // Delivery Address
                  if (_isDelivery) ...[
                    const Text("Delivery To", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF0F0F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFFA50000)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Home", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text(_addressController.text, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  ...List.generate(_currentCart.length, (index) {
                    return CartItemWidget(
                      item: _currentCart[index],
                      onAdd: () => _updateQuantity(index, true),
                      onRemove: () => _updateQuantity(index, false),
                    );
                  }),
                  
                  const SizedBox(height: 10),
                  
                  // Summary Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow("Subtotal", "\$${_subtotal.toStringAsFixed(2)}"),
                        const SizedBox(height: 8),
                        _buildSummaryRow("Delivery Fee", "\$${_deliveryFee.toStringAsFixed(2)}"),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        _buildSummaryRow("Total Amount", "\$${_total.toStringAsFixed(2)}", isTotal: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomSheet: _currentCart.isEmpty ? null : Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -4))],
        ),
        child: AppButton(
          text: "Proceed to Checkout",
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CheckoutScreen(
              cart: _currentCart, 
              shop: widget.shop, 
              userId: widget.userId, 
              total: _total,
              orderType: _isDelivery ? "delivery" : "takeaway",
              deliveryAddress: _isDelivery ? _addressController.text : null,
            )),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? Colors.black : Colors.grey[600], fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, fontSize: isTotal ? 18 : 14)),
        Text(value, style: TextStyle(color: isTotal ? const Color(0xFFA50000) : Colors.black, fontWeight: isTotal ? FontWeight.bold : FontWeight.bold, fontSize: isTotal ? 20 : 14)),
      ],
    );
  }
}
