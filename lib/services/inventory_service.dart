import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/inventory_entry.dart';

Future<List<String>> fetchItems() async {
  final response = await http.get(
    Uri.parse('https://inventory-backend-pink.vercel.app/api/entries'),
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonList = json.decode(response.body);
    List<InventoryEntry> entries =
        jsonList.map((json) => InventoryEntry.fromJson(json)).toList();

    return entries.map((entry) => entry.type.artikel).toList();
  } else {
    throw Exception('Failed to load items');
  }
}
