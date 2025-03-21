import 'dart:convert';
import 'package:fnt_back/model/product_model.dart';
import 'package:fnt_back/screens/product_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

class ApiService {
  static const String baseUrl = "192.168.9.194"; // Replace with your server IP

  final int port = 9000; // Replace with your server port

  // Fetch all products
  Future<ProductResponse> fetchProducts() async {
    try {
      final Uri uri = Uri(
        host: baseUrl,
        path: "/api/getAll",
        port: port,
        scheme: 'http',
      );

      log('GET $uri'); // Log the URI being called
      final response = await http.get(uri);

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // final Map<String, dynamic> responseData = json.decode(response.body);
        // final List<dynamic> productsData = responseData['products'];
        return ProductResponse.fromJson(response.body);
      } else {
        throw Exception(
            'Failed to load products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching products: $e');
      rethrow;
    }
  }

  // Add a new product
  Future<void> addProduct(Product product) async {
    try {
      final Uri uri = Uri(
        host: baseUrl,
        path: "/api/create",
        port: port,
        scheme: 'http',
      );

      log('POST $uri');
      print('Request Body: ${json.encode(product.toJson())}');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');
      print('Add product ${response.statusCode} == ${response.body}');
      if (response.statusCode != 201) {
        throw Exception(
            'Failed to add product. Server returned: ${response.body}');
      }
    } catch (e) {
      log('Error adding product: $e');
      rethrow;
    }
  }

  // Update a product
  Future<bool> updateProduct(String id, Product product) async {
    try {
      final Uri uri = Uri(
        host: baseUrl,
        path: "/api/update/$id",
        port: port,
        scheme: 'http',
      );

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toJson()),
      );

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Delete a product
  Future<bool> deleteProduct(String id) async {
    try {
      final Uri uri = Uri(
        host: baseUrl,
        path: "/api/delete/$id",
        port: port,
        scheme: 'http',
      );

      log('DELETE $uri');
      final response = await http.delete(uri);

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
