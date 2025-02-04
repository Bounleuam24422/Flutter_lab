import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:fnt_back/screens/unit_screen.dart'; // Import the Unit model

class ApiService {
  final String baseUrl = '192.168.95.194'; // Replace with your API endpoint
  final int port = 9000;

  // Fetch all units
  Future<List<Unit>> fetchUnits() async {
    try {
      // Define the URI for the API endpoint
      final Uri uri = Uri(
        scheme: 'http',
        host: baseUrl,
        path: '/api/getUnits',
        port: port,
      );

      log('GET $uri'); // Log the URI being called
      final response = await http.get(uri);

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> categoriesData = responseData['units'];

        // Return a list of Category objects
        return categoriesData.map((item) => Unit.fromJson(item)).toList();
      } else {
        throw Exception(
            'Failed to load units. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching units: $e');
      rethrow; // Rethrow the error after logging it
    }
  }

  // Add a new unit
  Future<void> addUnit(Unit unit) async {
    try {
      final Uri uri = Uri(
        host: baseUrl,
        path: "/api/unitCreate",
        port: port,
        scheme: 'http',
      );

      log('POST $uri');
      log('Request Body: ${json.encode(unit.toJson())}');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(unit.toJson()),
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to add unit');
      }
    } catch (e) {
      throw Exception('Failed to add unit: $e');
    }
  }

  // Update an existing unit
  Future<void> updateUnit(String id, Unit unit) async {
    try {
      final Uri uri = Uri(
        host: baseUrl,
        path: "/api/updateUnit/$id",
        port: port,
        scheme: 'http',
      );

      log('PUT $uri');
      log('Request Body: ${json.encode(unit.toJson())}');

      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(unit.toJson()),
      );

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to update unit. Server returned: ${response.body}');
      }
    } catch (e) {
      log('Error updating unit: $e');
      rethrow;
    }
  }

  // Delete a unit
  Future<void> deleteUnit(String id) async {
    try {
      final Uri uri = Uri(
        host: baseUrl,
        path: "/api/deleteUnit/$id",
        port: port,
        scheme: 'http',
      );

      log('DELETE $uri');
      final response = await http.delete(uri);

      log('Response Status: ${response.statusCode}');
      log('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete unit. Server returned: ${response.body}');
      }
    } catch (e) {
      log('Error deleting unit: $e');
      rethrow;
    }
  }
}
