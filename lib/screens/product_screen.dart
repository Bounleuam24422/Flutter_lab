import 'package:flutter/material.dart';
import 'package:fnt_back/api_service.dart';
import 'package:fnt_back/category_api.dart';

class Product {
  String id;
  String productName;
  int quality;
  double salePrice;
  double imprice;
  int level;
  double price;
  String categoryId;

  Product({
    required this.id,
    required this.productName,
    required this.quality,
    required this.salePrice,
    required this.imprice,
    required this.level,
    required this.price,
    required this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'],
      productName: json['productName'],
      quality: json['quality'],
      salePrice: json['sale_price'].toDouble(),
      imprice: json['imprice'].toDouble(),
      level: json['level'],
      price: json['price'].toDouble(),
      categoryId: json['categoryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'quality': quality,
      'sale_price': salePrice,
      'imprice': imprice,
      'level': level,
      'price': price,
      'categoryId': categoryId,
    };
  }
}

class Category {
  String id;
  String cateName;

  Category({
    required this.id,
    required this.cateName,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      cateName: json['cateName'],
    );
  }
}

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> products = [];
  List<Category> categories = [];
  final ApiService apiService = ApiService();
  final ApiServiceCategory apiServiceCategory = ApiServiceCategory();

  @override
  void initState() {
    super.initState();
    loadProducts();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final List<dynamic> fetchedData =
          await apiServiceCategory.fetchCategories();
      List<Category> fetchedCategories =
          fetchedData.map((data) => Category.fromJson(data)).toList();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> loadProducts() async {
    try {
      List<Product> fetchedProducts = await apiService.fetchProducts();
      setState(() {
        products = fetchedProducts;
      });
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  void _addProduct(Product product) async {
    await apiService.addProduct(product);
    loadProducts();
  }

  void _updateProduct(String id, Product updatedProduct) async {
    await apiService.updateProduct(id, updatedProduct);
    loadProducts();
  }

  void _deleteProduct(String id) async {
    await apiService.deleteProduct(id);
    await loadProducts();
  }

  void _showAddEditDialog({Product? product}) {
    final TextEditingController productNameController =
        TextEditingController(text: product?.productName ?? '');
    final TextEditingController qualityController =
        TextEditingController(text: product?.quality.toString() ?? '');
    final TextEditingController salePriceController =
        TextEditingController(text: product?.salePrice.toString() ?? '');
    final TextEditingController impriceController =
        TextEditingController(text: product?.imprice.toString() ?? '');
    final TextEditingController levelController =
        TextEditingController(text: product?.level.toString() ?? '');
    final TextEditingController priceController =
        TextEditingController(text: product?.price.toString() ?? '');

    String? selectedCategoryId = product?.categoryId ??
        (categories.isNotEmpty ? categories.first.id : null);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Dropdown for Category
                if (categories.isNotEmpty)
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Select Category'),
                    value: selectedCategoryId,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategoryId = newValue;
                      });
                    },
                    items: categories.map((Category category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.cateName),
                      );
                    }).toList(),
                  ),
                // Product Name
                TextField(
                  controller: productNameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                // Quality
                TextField(
                  controller: qualityController,
                  decoration: const InputDecoration(labelText: 'Quality'),
                  keyboardType: TextInputType.number,
                ),
                // Sale Price
                TextField(
                  controller: salePriceController,
                  decoration: const InputDecoration(labelText: 'Sale Price'),
                  keyboardType: TextInputType.number,
                ),
                // Imprice
                TextField(
                  controller: impriceController,
                  decoration: const InputDecoration(labelText: 'Imprice'),
                  keyboardType: TextInputType.number,
                ),
                // Level
                TextField(
                  controller: levelController,
                  decoration: const InputDecoration(labelText: 'Level'),
                  keyboardType: TextInputType.number,
                ),
                // Price
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String productName = productNameController.text.trim();
                final int quality =
                    int.tryParse(qualityController.text.trim()) ?? 0;
                final double salePrice =
                    double.tryParse(salePriceController.text.trim()) ?? 0.0;
                final double imprice =
                    double.tryParse(impriceController.text.trim()) ?? 0.0;
                final int level =
                    int.tryParse(levelController.text.trim()) ?? 0;
                final double price =
                    double.tryParse(priceController.text.trim()) ?? 0.0;

                if (productName.isNotEmpty &&
                    quality > 0 &&
                    salePrice > 0 &&
                    imprice > 0 &&
                    level > 0 &&
                    price > 0 &&
                    selectedCategoryId != null) {
                  final Product newProduct = Product(
                    id: product?.id ?? '',
                    productName: productName,
                    quality: quality,
                    salePrice: salePrice,
                    imprice: imprice,
                    level: level,
                    price: price,
                    categoryId: selectedCategoryId!,
                  );

                  if (product == null) {
                    _addProduct(newProduct);
                  } else {
                    _updateProduct(product.id, newProduct);
                  }
                }
                Navigator.pop(context);
              },
              child: Text(product == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product List')),
      body: products.isEmpty
          ? const Center(child: Text('No products added yet!'))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.productName),
                  subtitle:
                      Text('Price: \$${product.price.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAddEditDialog(product: product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteProduct(product.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
