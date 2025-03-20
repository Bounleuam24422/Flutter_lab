import 'package:flutter/material.dart';
import 'package:fnt_back/api_service.dart';
import 'package:fnt_back/category_api.dart';
import 'package:fnt_back/model/product_model.dart';
import 'package:fnt_back/screens/category_screen.dart';
import 'package:fnt_back/screens/unit_screen.dart';
import 'package:fnt_back/unit_api.dart'; // Import the ApiService

class Product {
  String id;
  String productName;
  int quatity;
  double salePrice;
  double imprice;
  int level;
  double price;
  // String cateName;
  String? cateID;
  String? unitID;

  Product({
    required this.id,
    required this.productName,
    required this.quatity,
    required this.salePrice,
    required this.imprice,
    required this.level,
    required this.price,
    required this.cateID,
    // required this.cateName,
    required this.unitID,
  });

  // Convert JSON to a Product object
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: json['_id'],
        productName: json['productName'],
        quatity: json['quatity'],
        salePrice: json['sale_price'].toDouble(),
        imprice: json['imprice'].toDouble(),
        level: json['level'],
        // cateName: json['cateName'],
        price: json['price'].toDouble(),
        cateID: json['cateID'].toString(),
        unitID: json['unitID'].toString());
  }

  // Convert a Product object to JSON
  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'quatity': quatity,
      'sale_price': salePrice,
      'imprice': imprice,
      'level': level,
      'price': price,
      // 'cateName': cateName,
      'cateID': cateID,
      'unitID': unitID
    };
  }
}

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> products = [];
  ProductResponse? _productResponse;
  List<Unit> units = [];
  List<Category> categories = [];
  final ApiService apiService = ApiService();
  final UnitService unitService = UnitService();
  final ApiServiceCategory cateService = ApiServiceCategory();
  // final
  String? cateID;
  String? unitID;
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadProducts();
    loadCategories();
    loadUnits();
  }

  Future<void> loadProducts() async {
    try {
      ProductResponse fetchedProducts = await apiService.fetchProducts();
      setState(() {
        _productResponse = fetchedProducts;
      });
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  Future<void> loadUnits() async {
    try {
      // loadCategories();
      if (units.isEmpty) {
        List<Unit> fetchedUnits = await unitService.fetchUnits();
        setState(() {
          units = fetchedUnits;
        });
      }
    } catch (e) {
      debugPrint('Error loading units: $e');
    }
  }

  Future<void> loadCategories() async {
    try {
      if (categories.isEmpty) {
        List<Category> fetchedCategories = await cateService.fetchCategories();
        setState(() {
          categories = fetchedCategories;
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  void _addProduct(Product product) async {
    await apiService.addProduct(product);

    loadProducts();
  }

  void _updateProduct(String id, Product updatedProduct) async {
    bool update = await apiService.updateProduct(id, updatedProduct);
    if (update) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Update Success...',
            textAlign: TextAlign.center,
          ),
        ),
      );
      loadProducts();
    }
  }

  void _deleteProduct(String id) async {
    bool deleteProduct = await apiService.deleteProduct(id);
    if (deleteProduct) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Delete Success...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      await loadProducts();
    }
  }

  void searchData(value) {}

  void _showAddEditDialog({ProductData? product}) {
    final TextEditingController productNameController =
        TextEditingController(text: product?.productName ?? '');
    final TextEditingController qualityController =
        TextEditingController(text: product?.quantity.toString() ?? '');
    final TextEditingController salePriceController =
        TextEditingController(text: product?.salePrice.toString() ?? '');
    final TextEditingController impriceController =
        TextEditingController(text: product?.importPrice.toString() ?? '');
    final TextEditingController levelController =
        TextEditingController(text: product?.level.toString() ?? '');
    final TextEditingController priceController =
        TextEditingController(text: product?.price.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product == null ? 'Add Product' : 'Edit Product'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: productNameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                TextField(
                  controller: qualityController,
                  decoration: const InputDecoration(labelText: 'Quatity'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: salePriceController,
                  decoration: const InputDecoration(labelText: 'Sale Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: impriceController,
                  decoration: const InputDecoration(labelText: 'Imprice'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: levelController,
                  decoration: const InputDecoration(labelText: 'Level'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField(
                  hint: Text('Categorys'),
                  decoration: InputDecoration(),
                  items: categories.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(item.cateName),
                    );
                  }).toList(),
                  value: product?.category!.id,
                  onChanged: (value) {
                    cateID = value;
                  },
                ),
                DropdownButtonFormField(
                  hint: Text('Units'),
                  decoration: InputDecoration(),
                  items: units.map((item) {
                    return DropdownMenuItem<String>(
                      value: item.id,
                      child: Text(item.unitName),
                    );
                  }).toList(),
                  value: product?.unit?.id,
                  onChanged: (value) {
                    unitID = value;
                  },
                )
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
                    price > 0) {
                  final Product newProduct = Product(
                      id: product?.id ?? '',
                      productName: productName,
                      quatity: quality,
                      salePrice: salePrice,
                      imprice: imprice,
                      level: level,
                      price: price,
                      // cateName: cateName,
                      cateID: cateID,
                      unitID: unitID);

                  if (product == null) {
                    _addProduct(newProduct);
                  } else {
                    _updateProduct(product.id, newProduct);
                  }
                }
                Navigator.pop(context);
              },
              child: Text(product == null ? 'Add' : 'Edit'),
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
      body: _productResponse == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _productResponse!.products.isEmpty
              ? const Center(child: Text('No products added yet!'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 40),
                      child: TextField(
                        controller: _controller,
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _productResponse!.products.length,
                        itemBuilder: (context, index) {
                          final item = _productResponse!.products[index];
                          return _controller.text.isEmpty ||
                                  item.productName
                                      .toUpperCase()
                                      .contains(_controller.text.toUpperCase())
                              ? Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Product Name: ${item.productName}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text('Quality: ${item.quantity}'),
                                        Text(
                                            'Sale Price:  ${item.salePrice.toStringAsFixed(2)}\kip'),
                                        Text(
                                            'Imprice:  ${item.importPrice.toStringAsFixed(2)}\kip'),
                                        Text('Level: ${item.level}'),
                                        Text(
                                            'Price:  ${item.price.toStringAsFixed(2)} \kip'),
                                        item.category == null
                                            ? Text('Not Cate')
                                            : Text(
                                                'ປະເພດ: ${item.category!.categoryName}'),
                                        item.unit == null
                                            ? Text('Not Cate')
                                            : Text(
                                                'ຫົວໜ່ວຍ: ${item.unit!.unitName}'),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () {
                                                _showAddEditDialog(
                                                    product: item);
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () =>
                                                  _deleteProduct(item.id),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : const SizedBox();
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          loadUnits();
          _showAddEditDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
