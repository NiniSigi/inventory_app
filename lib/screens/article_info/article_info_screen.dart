import 'package:flutter/material.dart';
import '../../models/inventory_entry.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../search_screen.dart';
import '../home/home-screen.dart';

class ArticleInfoScreen extends StatelessWidget {
  final InventoryEntry entry;

  const ArticleInfoScreen({Key? key, required this.entry}) : super(key: key);

  String convertUmlauts(String text) {
    return text
        .replaceAll('ae', 'ä')
        .replaceAll('oe', 'ö')
        .replaceAll('ue', 'ü')
        .replaceAll('AE', 'Ä')
        .replaceAll('OE', 'Ö')
        .replaceAll('UE', 'Ü');
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Row(
      children: [
        Expanded(child: _buildInfoCard(label1, value1)),
        SizedBox(width: 16),
        Expanded(child: _buildInfoCard(label2, value2)),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Artikel Information'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                convertUmlauts(entry.type.artikel),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),

              // Article Information Section
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                      child: Text(
                        'Artikel Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            context,
                            'Lager',
                            convertUmlauts(entry.type.lager),
                            'Einheit',
                            convertUmlauts(entry.type.einheit.name),
                          ),
                          SizedBox(height: 16),
                          _buildInfoRow(
                            context,
                            'Total Menge',
                            entry.type.menge.toString(),
                            'Rubrik',
                            convertUmlauts(entry.type.rubrik),
                          ),
                          if (entry.type.groesse != null) ...[
                            SizedBox(height: 16),
                            _buildInfoCard(
                              'Größe',
                              convertUmlauts(entry.type.groesse!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: -1,
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
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => SearchScreen(),
                settings: RouteSettings(name: '/search'),
              ),
              (route) => false,
            );
          } else if (index == 2) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
      ),
    );
  }
} 