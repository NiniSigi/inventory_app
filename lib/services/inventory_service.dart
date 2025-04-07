import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory_entry.dart';

class ItemData {
  final int id;
  final String name;

  ItemData({required this.id, required this.name});
}

Future<List<ItemData>> fetchItems({String? teamName}) async {
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

    return entries
        .map((entry) => ItemData(id: entry.id, name: entry.type.artikel))
        .toList();
  } else {
    throw Exception('Failed to load items');
  }
}

Future<bool> returnItem(int itemId) async {
  final url =
      'https://inventory-backend-pink.vercel.app/api/entries/$itemId/return';

  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    return response.statusCode == 200;
  } catch (e) {
    print('Error returning item: $e');
    throw Exception('Failed to return item');
  }
}
