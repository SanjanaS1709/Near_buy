class User {
  final int id;
  final String email;
  final String fullName;
  final String role;

  User({required this.id, required this.email, required this.fullName, required this.role});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
    );
  }
}

class Shop {
  final int id;
  final String name;
  final String shopType;
  final double latitude;
  final double longitude;
  final String address;

  Shop({required this.id, required this.name, required this.shopType, required this.latitude, required this.longitude, required this.address});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'],
      name: json['name'],
      shopType: json['shop_type'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
    );
  }
}
