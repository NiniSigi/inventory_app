import 'package:flutter/material.dart';
import '../../services/inventory_service.dart';
import '../detail/detail_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ItemData>> _itemsFuture;
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

  Future<void> _returnItem(int itemId) async {
    try {
      final success = await returnItem(itemId);
      if (success) {
        _refreshItems();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Item returned successfully')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to return item')));
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory Items'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.symmetric(horizontal: 16),
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
                hint: Text('Select Team'),
                items:
                    teams.map((String team) {
                      return DropdownMenuItem<String>(
                        value: team,
                        child: Text(
                          team.isEmpty ? 'None' : convertUmlauts(team),
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
            FutureBuilder<List<ItemData>>(
              future: _itemsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                return Container(
                  height: screenHeight * 0.5, // Takes up half the screen
                  margin: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: RefreshIndicator(
                      onRefresh: _refreshItems,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data![index];
                          return Card(
                            elevation: 2,
                            margin: EdgeInsets.only(bottom: 16),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                child: Text(
                                  item.name[0].toUpperCase(),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              title: Text(
                                convertUmlauts(item.name),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _returnItem(item.id),
                                style: ElevatedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.green,
                                    width: 2,
                                  ),
                                  foregroundColor: Colors.green,
                                ),
                                child: Text('Return'),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            DetailScreen(item: item.name),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
