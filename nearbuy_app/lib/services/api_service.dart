import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api/v1";

  Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "full_name": name,
        "email": email,
        "password": password,
        "role": role,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
        "full_name": "Login", // Backend expects this in UserCreate
        "role": "customer" // Placeholder for role
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createShop(int ownerId, String name, String type, double lat, double lng, String address) async {
    final response = await http.post(
      Uri.parse("$baseUrl/shops/shops?owner_id=$ownerId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "shop_type": type,
        "latitude": lat,
        "longitude": lng,
        "address": address,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getMyShop(int ownerId) async {
    final response = await http.get(Uri.parse("$baseUrl/shops/my-shop/$ownerId"));
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getShopProducts(int shopId) async {
    final response = await http.get(Uri.parse("$baseUrl/shops/shop/$shopId/products"));
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getNearbyShops({String? type}) async {
    String url = "$baseUrl/customer/shops";
    if (type != null) url += "?shop_type=$type";
    final response = await http.get(Uri.parse(url));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> placeOrder(int customerId, int shopId, double total, String type, List<Map<String, dynamic>> items, {String? address}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/customer/orders?customer_id=$customerId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "shop_id": shopId,
        "total_amount": total,
        "status": "pending",
        "order_type": type,
        "items": items,
        "delivery_address": address,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> rateShop(int orderId, int stars, String comment) async {
    final response = await http.post(
      Uri.parse("$baseUrl/customer/ratings?order_id=$orderId&stars=$stars&comment=$comment"),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createProduct(int shopId, String name, String description, double price, String imageUrl, {String category = "All", String unit = "unit"}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/shops/products?shop_id=$shopId"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "name": name,
        "description": description,
        "price": price,
        "image_url": imageUrl,
        "category": category,
        "unit": unit,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getShopOrders(int shopId, {String? status}) async {
    String url = "$baseUrl/shops/shop/$shopId/orders";
    if (status != null) url += "?status=$status";
    final response = await http.get(Uri.parse(url));
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateOrderStatus(int orderId, String status) async {
    final response = await http.patch(
      Uri.parse("$baseUrl/shops/orders/$orderId/status?status=$status"),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getShopStats(int shopId) async {
    final response = await http.get(Uri.parse("$baseUrl/shops/shop/$shopId/stats"));
    return jsonDecode(response.body);
  }
}
