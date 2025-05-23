import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../models/inventory_entry.dart';

Future<List<InventoryEntry>> fetchItems({String? teamName}) async {
  final baseUrl = 'https://inventory-backend-pink.vercel.app/api/entries/unreturned';
  final url = _buildUrl(baseUrl, teamName);
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    return _parseResponse(response.body);
  } else {
    throw Exception('Failed to load items: ${response.statusCode}');
  }
}

String _buildUrl(String baseUrl, String? teamName) {
  if (teamName == null || teamName.isEmpty) {
    return baseUrl;
  }
  
  final apiTeamName = _convertTeamName(teamName);
  return '$baseUrl?teamName=$apiTeamName';
}

String _convertTeamName(String teamName) {
  return teamName
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('Ä', 'AE')
      .replaceAll('Ö', 'OE')
      .replaceAll('Ü', 'UE');
}

List<InventoryEntry> _parseResponse(String responseBody) {
  List<dynamic> jsonList = json.decode(responseBody);
  List<InventoryEntry> entries = [];

  for (var json in jsonList) {
    try {
      entries.add(_createEntryFromJson(json));
    } catch (e) {
      print('Error processing entry: $e');
      continue;
    }
  }

  return entries;
}

InventoryEntry _createEntryFromJson(Map<String, dynamic> json) {
  final article = _createMinimalArticle(json);
  
  return InventoryEntry(
    id: int.parse(json['id']),
    startedAt: DateTime.parse(json['date']),
    returnedAt: null,
    teamName: Team.values.firstWhere(
      (t) => t.toString() == 'Team.${json['name']}',
      orElse: () => throw Exception('Invalid team name: ${json['name']}'),
    ),
    typeId: int.parse(json['id']),
    amountOfItem: 1,
    type: article,
  );
}

Article _createMinimalArticle(Map<String, dynamic> json) {
  return Article(
    id: int.parse(json['id']),
    name: json['artikel'],
    location: '',
    quantity: 1,
    unit: Unit.STUECK,
    category: '',
  );
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
          final article = Article.fromJson(item);
          return InventoryEntry(
            id: article.id,
            startedAt: DateTime.now(),
            teamName: Team.SPAEHER,
            typeId: article.id,
            amountOfItem: article.quantity,
            type: article,
          );
        }).toList();
      } else {
        throw Exception('Failed to load inventory items');
      }
    } catch (e) {
      throw Exception('Error loading inventory: $e');
    }
  }

  Future<Article> getArticleById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('https://inventory-backend-pink.vercel.app/api/types/$id'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Article.fromJson(data);
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
