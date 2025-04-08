import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory_entry.dart'; // Updated import

Future<Article> fetchArticleById(String id) async {
  // Changed return type to Article
  try {
    final response = await http.get(
      Uri.parse('https://inventory-backend-pink.vercel.app/api/types/$id'),
    );

    if (response.statusCode == 200) {
      return Article.fromJson(
        jsonDecode(response.body),
      ); // Using Article.fromJson
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
    print('Creating entry with typeId: $typeId'); // Debug log
    final response = await http.post(
      Uri.parse('https://inventory-backend-pink.vercel.app/api/entries'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'teamName': teamName,
        'amountOfItem': amountOfItem,
        'typeId': typeId,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print('Error response: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error creating entry: $e');
    return false;
  }
}
