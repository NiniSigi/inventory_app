import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory_entry.dart'; // Updated import

Future<Artikel> fetchArticleById(String id) async {
  // Changed return type to Artikel
  try {
    final response = await http.get(
      Uri.parse('https://inventory-backend-pink.vercel.app/api/types/$id'),
    );

    if (response.statusCode == 200) {
      return Artikel.fromJson(
        jsonDecode(response.body),
      ); // Using Artikel.fromJson
    } else {
      throw Exception('Failed to load article: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}

Future<bool> createEntry({
  required String teamName,
  required int amountOfItem,
  required int typeId,
}) async {
  try {
    final response = await http.post(
      Uri.parse('https://inventory-backend-pink.vercel.app/api/entries'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'teamName': teamName,
        'amountOfItem': amountOfItem,
        'typeId': typeId,
      }),
    );

    // Status 201 means Created, 200 means OK - both are successful
    return response.statusCode == 201 || response.statusCode == 200;
  } catch (e) {
    print('Error creating entry: $e');
    return false;
  }
}
