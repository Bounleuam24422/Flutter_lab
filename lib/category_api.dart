import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:fnt_back/screens/category_screen.dart'; // Import the Category model class

class ApiServiceCategory {
  // Replace this with your API URL
  final String baseUrl = '192.168.95.194';
  final int port = 9000;

  // Fetch categories from the API
  Future<List<Category>> fetchCategories() async {
    try {
      // Define the URI for the API endpoint
      final Uri categoryUri = Uri(
        scheme: 'http',
        host: baseUrl,
        path: '/api/getGetAlls',
        port: port,
      );

      log('GET $categoryUri'); // Log the URI being called
      final response = await http.get(categoryUri);

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> categoriesData = responseData['categories'];

        // Return a list of Category objects
        return categoriesData.map((item) => Category.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching categories: $e');
      rethrow; // Rethrow the error after logging it
    }
  }

  // Add a new category
  Future<void> addCategory(Category category) async {
    try {
      final Uri uri = Uri(
        host: baseUrl,
        path: "/api/cateCreate",
        port: port,
        scheme: 'http',
      );

      log('POST $uri');
      log('Request Body: ${json.encode(category.toJson())}');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(category.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add category');
      }
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  // Update an existing category
  Future<void> updateCategory(String id, Category category) async {
    try {
      final Uri uri = Uri(
        host: baseUrl,
        path: "/api/updateCategory/$id",
        port: port,
        scheme: 'http',
      );

      log('PUT $uri');
      log('Request Body: ${json.encode(category.toJson())}');

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(category.toJson()),
      );

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update product. Server returned: ${response.body}');
      }
    } catch (e) {
      log('Error updating product: $e');
      rethrow;
    }
  }

  // Delete a category by ID

  Future<void> deleteCategory(String id) async {
    try {
      final Uri uri = Uri(
        host: baseUrl,
        path: "/api/deleteCategory/$id",
        port: port,
        scheme: 'http',
      );

      log('DELETE $uri');
      final response = await http.delete(uri);

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete product. Server returned: ${response.body}');
      }
    } catch (e) {
      log('Error deleting product: $e');
      rethrow;
    }
  }
}
