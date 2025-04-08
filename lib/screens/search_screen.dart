import 'package:flutter/material.dart';
import '../../models/inventory_entry.dart';
import '../../services/inventory_service.dart';
import 'home/home-screen.dart';
import 'article_info/article_info_screen.dart';
import '../../main.dart';

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
  String? _selectedLocation;
  String? _selectedCategory;
  Set<String> _uniqueLocation = {};
  Set<String> _uniqueCategory = {};

  String convertUmlauts(String text) {
    return text
        .replaceAll('ae', 'ä')
        .replaceAll('oe', 'ö')
        .replaceAll('ue', 'ü')
        .replaceAll('AE', 'Ä')
        .replaceAll('OE', 'Ö')
        .replaceAll('UE', 'Ü');
  }

  String convertUmlautsForSearch(String text) {
    return text
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('Ä', 'AE')
        .replaceAll('Ö', 'OE')
        .replaceAll('Ü', 'UE');
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
        _uniqueLocation = inventory
            .map((e) => e.type.location)
            .where((location) => location.isNotEmpty && RegExp(r'^[A-Za-zÄäÖöÜü]').hasMatch(location))
            .toSet();
        _uniqueCategory = inventory
            .map((e) => e.type.category)
            .where((category) => category.isNotEmpty)
            .toSet();
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
      if (query.isEmpty && _selectedLocation == null && _selectedCategory == null) {
        _filteredInventory = _allInventory;
      } else {
        final searchTerm = convertUmlautsForSearch(query.toLowerCase());
        _filteredInventory = _allInventory.where((entry) {
          final articleName = convertUmlautsForSearch(entry.type.name.toLowerCase());
          final matchesSearch = query.isEmpty || articleName.contains(searchTerm);
          final matchesLocation = _selectedLocation == null || 
            entry.type.location.toLowerCase() == _selectedLocation!.toLowerCase();
          final matchesCategory = _selectedCategory == null || 
            entry.type.category.toLowerCase() == _selectedCategory!.toLowerCase();
          return matchesSearch && matchesLocation && matchesCategory;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedLocation = _uniqueLocation.toList()..sort();
    final sortedCategory = _uniqueCategory.toList()..sort();

    final uniqueFirstLetters = sortedLocation
        .where((location) => location.isNotEmpty && RegExp(r'^[A-Za-zÄäÖöÜü]').hasMatch(location))
        .map((location) => location[0].toUpperCase())
        .toSet()
        .toList()
      ..sort();

    if (_selectedLocation != null && !uniqueFirstLetters.contains(_selectedLocation)) {
      _selectedLocation = null;
    }
    if (_selectedCategory != null && !sortedCategory.contains(_selectedCategory)) {
      _selectedCategory = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Suche'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search articles...',
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterInventory('');
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  _filterInventory(value);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  if (uniqueFirstLetters.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 2),
                            child: Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Container(
                            height: 56,
                            margin: EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedLocation == null ? 'hint' : _selectedLocation,
                              isExpanded: true,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              underline: SizedBox(),
                              hint: Text('Sorted', textAlign: TextAlign.center),
                              menuMaxHeight: 200,
                              icon: Icon(Icons.arrow_drop_down),
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              isDense: false,
                              alignment: AlignmentDirectional.center,
                              items: [
                                DropdownMenuItem(value: 'hint', child: Text('Sorted', textAlign: TextAlign.center)),
                                for (final letter in uniqueFirstLetters)
                                  DropdownMenuItem<String>(
                                    value: letter,
                                    child: Text(letter, textAlign: TextAlign.center),
                                  ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedLocation = value == 'hint' ? null : value;
                                  _filterInventory(_searchController.text);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (uniqueFirstLetters.isNotEmpty && sortedCategory.isNotEmpty)
                    SizedBox(width: 16),
                  if (sortedCategory.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 2),
                            child: Text(
                              'Category',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Container(
                            height: 56,
                            margin: EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedCategory == null ? 'hint' : _selectedCategory,
                              isExpanded: true,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              underline: SizedBox(),
                              hint: Text('Sorted', textAlign: TextAlign.center),
                              menuMaxHeight: 200,
                              icon: Icon(Icons.arrow_drop_down),
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              isDense: false,
                              alignment: AlignmentDirectional.center,
                              items: [
                                DropdownMenuItem(value: 'hint', child: Text('Sorted', textAlign: TextAlign.center)),
                                for (final category in sortedCategory)
                                  DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(convertUmlauts(category), textAlign: TextAlign.center),
                                  ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value == 'hint' ? null : value;
                                  _filterInventory(_searchController.text);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),
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
                                _searchController.text.isEmpty && _selectedLocation == null && _selectedCategory == null
                                    ? Icons.inventory_2_outlined
                                    : Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty && _selectedLocation == null && _selectedCategory == null
                                    ? 'Enter a search term'
                                    : 'No articles found',
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArticleInfoScreen(entry: entry),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
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
                                                convertUmlauts(entry.type.name)[0].toUpperCase(),
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
                                              convertUmlauts(entry.type.name),
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
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.warehouse, size: 16, color: Colors.grey[600]),
                                          SizedBox(width: 4),
                                          Text(
                                            convertUmlauts(entry.type.location),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Icon(Icons.category, size: 16, color: Colors.grey[600]),
                                          SizedBox(width: 4),
                                          Text(
                                            convertUmlauts(entry.type.category),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
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
      ),
    );
  }
}