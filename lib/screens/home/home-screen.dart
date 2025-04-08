import 'package:flutter/material.dart';
import '../../models/inventory_entry.dart';
import '../../services/inventory_service.dart';
import '../detail/detail_screen.dart';
import '../scanner/qr_scanner_screen.dart';
import '../article_details/article_details_screen.dart';
import '../search_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<InventoryEntry>> _itemsFuture;
  String? selectedTeam;

  final List<String> teams = ['SPAEHER', 'AMEISLI', ''];

  @override
  void initState() {
    super.initState();
    _itemsFuture = fetchItems();
  }

  Future<void> _refreshItems() async {
    setState(() {
      _itemsFuture = fetchItems(teamName: selectedTeam);
    });
  }

  Future<void> _returnItem(String entryId) async {
    try {
      print('Attempting to return item: $entryId'); // Debug log
      final success = await returnItem(entryId);

      if (success) {
        _refreshItems();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Item returned successfully')));
      } else {
        throw Exception('Return failed');
      }
    } catch (e) {
      print('Error in return handler: $e'); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to return item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxListHeight = screenHeight * 0.5;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Inventory Items'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedTeam,
                isExpanded: true,
                padding: EdgeInsets.symmetric(horizontal: 8),
                underline: SizedBox(),
                hint: Text('Select Team'),
                menuMaxHeight: 200,
                icon: Icon(Icons.arrow_drop_down),
                dropdownColor: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                isDense: false,
                alignment: AlignmentDirectional.centerStart,
                items:
                    teams.map((String team) {
                      return DropdownMenuItem<String>(
                        value: team,
                        child: Text(
                          team.isEmpty ? 'Kein Team' : convertUmlauts(team),
                        ),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTeam = newValue;
                    _refreshItems();
                  });
                },
              ),
            ),
            SizedBox(
              height: maxListHeight,
              child: FutureBuilder<List<InventoryEntry>>(
                future: _itemsFuture,
                builder: (context, snapshot) {
                  return Container(
                    margin: EdgeInsets.all(16),
                    decoration:
                        (!snapshot.hasData &&
                                    snapshot.connectionState ==
                                        ConnectionState.waiting) ||
                                (snapshot.hasData && snapshot.data!.isNotEmpty)
                            ? BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            )
                            : null,
                    child:
                        snapshot.connectionState == ConnectionState.waiting
                            ? Center(child: CircularProgressIndicator())
                            : snapshot.hasError
                            ? Center(child: Text('Error: ${snapshot.error}'))
                            : !snapshot.hasData || snapshot.data!.isEmpty
                            ? Center(child: Text('No items available'))
                            : RefreshIndicator(
                              onRefresh: () async {
                                await _refreshItems();
                              },
                              child: ListView.builder(
                                padding: EdgeInsets.all(16),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final entry = snapshot.data![index];
                                  return Card(
                                    elevation: 2,
                                    margin: EdgeInsets.only(bottom: 16),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.all(16),
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        child: Text(
                                          convertUmlauts(
                                            entry.type.name[0].toUpperCase(),
                                          ),
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onPrimary,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        convertUmlauts(entry.type.name),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed:
                                            entry.returnedAt == null
                                                ? () => _returnItem(
                                                  entry.id.toString(),
                                                )
                                                : null,
                                        style: ElevatedButton.styleFrom(
                                          side: BorderSide(
                                            color: Colors.green,
                                            width: 2,
                                          ),
                                          foregroundColor: Colors.green,
                                        ),
                                        child: Text('Return'),
                                      ),
                                      onTap: () async {
                                        final needsRefresh =
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => DetailScreen(
                                                      entry: entry,
                                                    ),
                                              ),
                                            );
                                        if (needsRefresh == true) {
                                          _refreshItems();
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _scanQR,
                icon: Icon(Icons.add),
                label: Text('Add New Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanQR() async {
    final scannedCode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => QRScannerScreen()),
    );

    if (scannedCode != null && mounted) {
      final needsRefresh = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ArticleDetailsScreen(
            articleId: scannedCode,
            defaultTeam: selectedTeam == '' ? null : selectedTeam,
          ),
        ),
      );

      if (needsRefresh == true) {
        _refreshItems();
      }
    }
  }
}
