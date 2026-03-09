import 'package:flutter/material.dart';
import 'package:nearbuy_app/services/api_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final _apiService = ApiService();
  int _stars = 5;
  final _commentController = TextEditingController();

  void _submitRating() async {
    final result = await _apiService.rateShop(widget.order['id'], _stars, _commentController.text);
    if (result.containsKey('message')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Thank you for your rating!")));
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Track Order")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Order ID: #${widget.order['id']}", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Status: ${widget.order['status']}", style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 20),
            if (widget.order['order_type'] == 'delivery')
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.delivery_dining, size: 40, color: Colors.blue),
                      SizedBox(width: 20),
                      Text("Partner is on the way (Simulated)"),
                    ],
                  ),
                ),
              )
            else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.directions_walk, size: 40, color: Colors.orange),
                      SizedBox(width: 20),
                      Text("Shop is waiting for your arrival"),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            const Divider(),
            const Text("Rate your experience"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(Icons.star, color: index < _stars ? Colors.amber : Colors.grey),
                  onPressed: () => setState(() => _stars = index + 1),
                );
              }),
            ),
            TextField(controller: _commentController, decoration: const InputDecoration(labelText: "Comment (Optional)")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _submitRating, child: const Text("Submit Rating & Close Order")),
          ],
        ),
      ),
    );
  }
}
