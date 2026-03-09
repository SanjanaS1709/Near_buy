import 'package:flutter/material.dart';
import 'package:nearbuy_app/services/api_service.dart';
import 'package:nearbuy_app/widgets/custom_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  
  // Shop owner specific
  final _shopNameController = TextEditingController();
  final _shopTypeController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _selectedRole = 'customer';
  final _apiService = ApiService();
  bool _isLoading = false;
  int _currentStep = 1;
  final int _totalSteps = 2;

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep--;
    });
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        final userResult = await _apiService.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
          _selectedRole,
        );

        if (userResult.containsKey('id')) {
          if (_selectedRole == 'shop_owner') {
            final userId = userResult['id'];
            final shopResult = await _apiService.createShop(
              userId,
              _shopNameController.text,
              _shopTypeController.text,
              0.0,
              0.0,
              _addressController.text,
            );

            if (!shopResult.containsKey('id')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(shopResult['detail'] ?? "Shop registration failed")),
              );
              return;
            }
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${_selectedRole == 'customer' ? 'User' : 'Shop'} Registered Successfully")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(userResult['detail'] ?? "Registration failed")),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("An error occurred: $e")),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "Join Local Bazaar",
          style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Progress Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Step $_currentStep of $_totalSteps",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "${(_currentStep / _totalSteps * 100).toInt()}% Complete",
                    style: const TextStyle(color: Color(0xFFA50000), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: _currentStep / _totalSteps,
                backgroundColor: const Color(0xFFF2E8E8),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFA50000)),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 30),
              
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Register as",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Choose how you want to use the Local Bazaar",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              RoleSelector(
                selectedRole: _selectedRole,
                onRoleChanged: (role) => setState(() => _selectedRole = role),
              ),
              
              const SizedBox(height: 30),

              if (_currentStep == 1) ...[
                AppTextField(
                  controller: _nameController,
                  label: "Full Name",
                  hintText: "e.g. Rahul Sharma",
                  prefixIcon: Icons.person_outline,
                  validator: (value) => value == null || value.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _phoneController,
                  label: "Phone Number",
                  hintText: "98765 43210",
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _emailController,
                  label: "Email Address",
                  hintText: "rahul@example.com",
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value == null || !value.contains('@') ? "Invalid email" : null,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  controller: _locationController,
                  label: "Current Location",
                  hintText: "Select your locality",
                  prefixIcon: Icons.location_on_outlined,
                  suffixIcon: const Icon(Icons.my_location, color: Color(0xFFA50000)),
                ),
                const SizedBox(height: 30),
                AppButton(
                  text: "Continue",
                  icon: const Icon(Icons.arrow_forward, color: Colors.white),
                  onPressed: _nextStep,
                ),
              ] else ...[
                AppTextField(
                  controller: _passwordController,
                  label: "Create Password",
                  hintText: "********",
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (value) => value == null || value.length < 6 ? "Min 6 characters" : null,
                ),
                
                if (_selectedRole == 'shop_owner') ...[
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F5F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE0E0E0), style: BorderStyle.solid),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.storefront, color: Color(0xFFA50000)),
                            const SizedBox(width: 8),
                            const Text(
                              "Shopkeeper Details",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFA50000),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "FOR MERCHANTS",
                                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          controller: _shopNameController,
                          label: "Shop Name",
                          hintText: "Enter shop name",
                          prefixIcon: Icons.business_outlined,
                          validator: (value) => _selectedRole == 'shop_owner' && (value == null || value.isEmpty) ? "Required" : null,
                        ),
                        const SizedBox(height: 15),
                        AppTextField(
                          controller: _shopTypeController,
                          label: "Shop Category",
                          hintText: "Select category",
                          prefixIcon: Icons.category_outlined,
                          validator: (value) => _selectedRole == 'shop_owner' && (value == null || value.isEmpty) ? "Required" : null,
                        ),
                      ],
                    ),
                  ),
                ],
                
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFFA50000)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Back", style: TextStyle(color: Color(0xFFA50000), fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        text: _selectedRole == 'customer' ? "Complete Registration" : "Register Shop",
                        isLoading: _isLoading,
                        onPressed: _register,
                      ),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 30),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "Log in",
                        style: TextStyle(color: Color(0xFFA50000), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              // Map Preview Placeholder
              if (_currentStep == 1)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      Image.network(
                        'https://api.mapbox.com/styles/v1/mapbox/dark-v10/static/77.5946,12.9716,12/600x200?access_token=placeholder', // Placeholder map image
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 120,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Icon(Icons.map_outlined, color: Colors.grey),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.near_me, size: 12, color: Color(0xFFA50000)),
                              SizedBox(width: 4),
                              Text("Verifying location...", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
