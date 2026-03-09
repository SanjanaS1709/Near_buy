import 'package:flutter/material.dart';
import 'package:nearbuy_app/services/api_service.dart';
import 'package:nearbuy_app/widgets/custom_widgets.dart';

class AddProductScreen extends StatefulWidget {
  final int shopId;
  const AddProductScreen({super.key, required this.shopId});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController(text: "unit");
  String _selectedCategory = "Textiles";
  final List<String> _categories = ["Textiles", "Pottery", "Spices", "Fruits", "Vegetables"];
  
  final _apiService = ApiService();
  bool _isLoading = false;

  void _addProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill required fields")));
      return;
    }

    setState(() => _isLoading = true);
    final result = await _apiService.createProduct(
      widget.shopId,
      _nameController.text,
      _descriptionController.text,
      double.parse(_priceController.text),
      "https://images.unsplash.com/photo-1584949514123-474cfa705df2?q=80&w=1000", // Default beautiful placeholder
      category: _selectedCategory,
      unit: _unitController.text,
    );

    setState(() => _isLoading = false);
    if (result.containsKey('id')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product Added Successfully")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['detail'] ?? "Failed to add product")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Add New Product", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _nameController, 
              label: "Product Name", 
              hintText: "e.g. Silk Banarasi Scarf", 
              prefixIcon: Icons.shopping_bag_outlined
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _priceController, 
                    label: "Price (₹)", 
                    hintText: "0.00", 
                    prefixIcon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Category", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A))),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) => setState(() => _selectedCategory = val!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Description", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A))),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Tell customers about the craft...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              ),
            ),
            const SizedBox(height: 24),
            const Text("Upload Product Image", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A))),
            const SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF9F5F5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFA50000).withOpacity(0.2), style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_upload_outlined, color: Color(0xFFA50000), size: 32),
                  const SizedBox(height: 8),
                  Text("Upload Product Image", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            AppButton(
              text: "Save Product", 
              isLoading: _isLoading,
              onPressed: _addProduct,
            ),
          ],
        ),
      ),
    );
  }
}
