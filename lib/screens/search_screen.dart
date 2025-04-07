import 'package:flutter/material.dart';
import '../../models/inventory_entry.dart';
import '../../services/inventory_service.dart';
import '../../widgets/custom_bottom_nav.dart';
import 'article_info/article_info_screen.dart';
import 'home/home-screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final InventoryService _inventoryService = InventoryService();
  List<InventoryEntry> _allInventory = [];
  List<InventoryEntry> _filteredInventory = [];
  bool _isLoading = false;

  String convertUmlauts(String text) {
    return text
        .replaceAll('ae', 'ä')
        .replaceAll('oe', 'ö')
        .replaceAll('ue', 'ü')
        .replaceAll('AE', 'Ä')
        .replaceAll('OE', 'Ö')
        .replaceAll('UE', 'Ü');
  }

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInventory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final inventory = await _inventoryService.getInventory();
      setState(() {
        _allInventory = inventory;
        _filteredInventory = inventory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler beim Laden der Daten: $e')),
      );
    }
  }

  void _filterInventory(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredInventory = _allInventory;
      } else {
        final searchTerm = convertUmlauts(query.toLowerCase());
        _filteredInventory = _allInventory.where((entry) {
          final articleName = convertUmlauts(entry.type.artikel.toLowerCase());
          return articleName.contains(searchTerm);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suche'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Artikel suchen...',
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                _filterInventory(value);
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : _filteredInventory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchController.text.isEmpty
                                  ? Icons.inventory_2_outlined
                                  : Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Geben Sie einen Suchbegriff ein'
                                  : 'Keine Artikel gefunden',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredInventory.length,
                        itemBuilder: (context, index) {
                          final entry = _filteredInventory[index];
                          return Card(
                            margin: EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArticleInfoScreen(entry: entry),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          convertUmlauts(entry.type.artikel)[0].toUpperCase(),
                                          style: TextStyle(
                                            color: Theme.of(context).colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        convertUmlauts(entry.type.artikel),
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
                settings: RouteSettings(name: '/home'),
              ),
              (route) => false,
            );
          } else if (index == 1) {
            // Already on search screen
          } else if (index == 2) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
      ),
    );
  }
} 