import 'package:flutter/material.dart';
import 'package:nearbuy_app/services/api_service.dart';
import 'package:nearbuy_app/screens/register_screen.dart';
import 'package:nearbuy_app/screens/customer_home_screen.dart';
import 'package:nearbuy_app/widgets/custom_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  String _selectedRole = 'customer';
  bool _obscurePassword = true;

  void _login() async {
    setState(() => _isLoading = true);
    try {
      final result = await _apiService.login(_emailController.text, _passwordController.text);
      if (result.containsKey('access_token')) {
        final role = result['role'];
        
        if (role == 'shop_owner') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful (Shop Owner)")));
          // Navigation to shop dashboard...
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful (Customer)")));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CustomerHomeScreen(userId: 1)),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['detail'] ?? "Login Failed")));
      }
    } finally {
      setState(() => _isLoading = false);
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
          "Local Bazaar",
          style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Hero Image Section
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1000&auto=format&fit=crop'), // Placeholder bazaar image
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    bottom: 20,
                    left: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Access your local neighborhood market",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            RoleSelector(
              selectedRole: _selectedRole,
              onRoleChanged: (role) => setState(() => _selectedRole = role),
            ),
            
            const SizedBox(height: 25),
            
            AppTextField(
              controller: _emailController,
              label: "Phone Number or Email",
              hintText: "Enter your details",
              prefixIcon: Icons.person_outline,
            ),
            
            const SizedBox(height: 20),
            
            AppTextField(
              controller: _passwordController,
              label: "Password",
              hintText: "********",
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  "Forgot Password?",
                  style: TextStyle(color: Color(0xFFA50000), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            AppButton(
              text: "Login",
              isLoading: _isLoading,
              onPressed: _login,
            ),
            
            const SizedBox(height: 25),
            
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text("OR CONTINUE WITH", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ),
                Expanded(child: Divider()),
              ],
            ),
            
            const SizedBox(height: 25),
            
            Row(
              children: [
                SocialButton(text: "Google", iconPath: "", onTap: () {}),
                const SizedBox(width: 16),
                SocialButton(text: "Facebook", iconPath: "", onTap: () {}),
              ],
            ),
            
            const SizedBox(height: 30),
            
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterScreen()),
                    ),
                    child: const Text(
                      "Register Now",
                      style: TextStyle(color: Color(0xFFA50000), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
