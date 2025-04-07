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
  String? _selectedLager;
  String? _selectedRubrik;
  Set<String> _uniqueLager = {};
  Set<String> _uniqueRubrik = {};

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
        _uniqueLager = inventory
            .map((e) => e.type.lager)
            .where((lager) => lager.isNotEmpty && RegExp(r'^[A-Za-zÄäÖöÜü]').hasMatch(lager))
            .toSet();
        _uniqueRubrik = inventory
            .map((e) => e.type.rubrik)
            .where((rubrik) => rubrik.isNotEmpty)
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
      if (query.isEmpty && _selectedLager == null && _selectedRubrik == null) {
        _filteredInventory = _allInventory;
      } else {
        final searchTerm = convertUmlautsForSearch(query.toLowerCase());
        _filteredInventory = _allInventory.where((entry) {
          final articleName = convertUmlautsForSearch(entry.type.artikel.toLowerCase());
          final matchesSearch = query.isEmpty || articleName.contains(searchTerm);
          final matchesLager = _selectedLager == null || 
            (_selectedLager!.length == 1 && entry.type.lager.startsWith(_selectedLager!));
          final matchesRubrik = _selectedRubrik == null || entry.type.rubrik == _selectedRubrik;
          return matchesSearch && matchesLager && matchesRubrik;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedLager = _uniqueLager.toList()..sort();
    final sortedRubrik = _uniqueRubrik.toList()..sort();

    final uniqueFirstLetters = sortedLager
        .where((lager) => lager.isNotEmpty && RegExp(r'^[A-Za-zÄäÖöÜü]').hasMatch(lager))
        .map((lager) => lager[0].toUpperCase())
        .toSet()
        .toList()
      ..sort();

    if (_selectedLager != null && !uniqueFirstLetters.contains(_selectedLager)) {
      _selectedLager = null;
    }
    if (_selectedRubrik != null && !sortedRubrik.contains(_selectedRubrik)) {
      _selectedRubrik = null;
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
                              'Lager',
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
                              value: _selectedLager == null ? 'hint' : _selectedLager,
                              isExpanded: true,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              underline: SizedBox(),
                              hint: Text('Sortiert', textAlign: TextAlign.center),
                              menuMaxHeight: 200,
                              icon: Icon(Icons.arrow_drop_down),
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              isDense: false,
                              alignment: AlignmentDirectional.center,
                              items: [
                                DropdownMenuItem(value: 'hint', child: Text('Sortiert', textAlign: TextAlign.center)),
                                for (final letter in uniqueFirstLetters)
                                  DropdownMenuItem<String>(
                                    value: letter,
                                    child: Text(letter, textAlign: TextAlign.center),
                                  ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedLager = value == 'hint' ? null : value;
                                  _filterInventory(_searchController.text);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (uniqueFirstLetters.isNotEmpty && sortedRubrik.isNotEmpty)
                    SizedBox(width: 16),
                  if (sortedRubrik.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 2),
                            child: Text(
                              'Rubrik',
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
                              value: _selectedRubrik == null ? 'hint' : _selectedRubrik,
                              isExpanded: true,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              underline: SizedBox(),
                              hint: Text('Sortiert', textAlign: TextAlign.center),
                              menuMaxHeight: 200,
                              icon: Icon(Icons.arrow_drop_down),
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              isDense: false,
                              alignment: AlignmentDirectional.center,
                              items: [
                                DropdownMenuItem(value: 'hint', child: Text('Sortiert', textAlign: TextAlign.center)),
                                for (final rubrik in sortedRubrik)
                                  DropdownMenuItem<String>(
                                    value: rubrik,
                                    child: Text(convertUmlauts(rubrik), textAlign: TextAlign.center),
                                  ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedRubrik = value == 'hint' ? null : value;
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
                                _searchController.text.isEmpty && _selectedLager == null && _selectedRubrik == null
                                    ? Icons.inventory_2_outlined
                                    : Icons.search_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                _searchController.text.isEmpty && _selectedLager == null && _selectedRubrik == null
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
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.warehouse, size: 16, color: Colors.grey[600]),
                                          SizedBox(width: 4),
                                          Text(
                                            convertUmlauts(entry.type.lager),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Icon(Icons.category, size: 16, color: Colors.grey[600]),
                                          SizedBox(width: 4),
                                          Text(
                                            convertUmlauts(entry.type.rubrik),
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