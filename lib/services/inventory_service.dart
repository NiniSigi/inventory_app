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

class InventoryService {
  Future<List<InventoryEntry>> getInventory() async {
    try {
      final response = await http.get(
        Uri.parse('https://inventory-backend-pink.vercel.app/api/types'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) {
          final artikel = Artikel.fromJson(item);
          return InventoryEntry(
            id: artikel.id,
            startedAt: DateTime.now(),
            teamName: Team.SPAEHER,
            typeId: artikel.id,
            amountOfItem: artikel.menge,
            type: artikel,
          );
        }).toList();
      } else {
        throw Exception('Failed to load inventory items');
      }
    } catch (e) {
      throw Exception('Error loading inventory: $e');
    }
  }

  Future<Artikel> getArticleById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('https://inventory-backend-pink.vercel.app/api/types/$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Artikel.fromJson(data);
      } else {
        throw Exception('Failed to load article');
      }
    } catch (e) {
      throw Exception('Error loading article: $e');
    }
  }

  Future<bool> createEntry({
    required String teamName,
    required int amountOfItem,
    required String typeId,
  }) async {
    try {
      print('Creating entry with typeId: $typeId'); // Debug log
      final response = await http.post(
        Uri.parse('https://inventory-backend-pink.vercel.app/api/entries'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'teamName': teamName,
          'amountOfItem': amountOfItem,
          'typeId': typeId,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
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
}
