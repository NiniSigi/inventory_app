import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/inventory_entry.dart';

Future<List<InventoryEntry>> fetchItems({String? teamName}) async {
  final baseUrl =
      'https://inventory-backend-pink.vercel.app/api/entries/unreturned';
  final url =
      teamName != null && teamName.isNotEmpty
          ? '$baseUrl?teamName=$teamName'
          : baseUrl;

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    List<dynamic> jsonList = json.decode(response.body);
    List<InventoryEntry> entries =
        jsonList.map((json) => InventoryEntry.fromJson(json)).toList();

    return entries;
  } else {
    throw Exception('Failed to load items');
  }
}

Future<bool> returnItem(String entryId) async {
  try {
    final url =
        'https://inventory-backend-pink.vercel.app/api/entries/$entryId/return';
    print('Calling return API: $url'); // Debug log

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    print('Response status: ${response.statusCode}'); // Debug log
    print('Response body: ${response.body}'); // Debug log

    return response.statusCode == 200;
  } catch (e, stackTrace) {
    print('Error returning item: $e');
    print('Stack trace: $stackTrace');
    rethrow; // Rethrow to handle in UI
  }
}

String formatDate(DateTime date) {
  return DateFormat('dd.MM.yyyy HH:mm').format(date);
}
