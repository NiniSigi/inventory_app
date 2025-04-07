import 'package:flutter/material.dart';
import '../../models/inventory_entry.dart';
import '../../services/inventory_service.dart';
import '../../widgets/custom_bottom_nav.dart';

class DetailScreen extends StatefulWidget {
  final InventoryEntry entry;

  const DetailScreen({Key? key, required this.entry}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isReturning = false;

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

  Future<void> _handleReturn(BuildContext context) async {
    try {
      print(
        'Attempting to return item with entry ID: ${widget.entry.id}',
      ); // Debug log
      final success = await returnItem(widget.entry.id.toString());

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Item returned successfully')));
        Navigator.pop(context, true);
      } else {
        throw Exception('Return failed');
      }
    } catch (e) {
      print('Error in return handler: $e'); // Debug log
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to return item: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Artikel Details'),
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
                convertUmlauts(widget.entry.type.artikel),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),

              // First Section: Entry Details
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
                        'Ausleih Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            context,
                            'Team',
                            convertUmlauts(widget.entry.teamName.name),
                            'Menge',
                            '${widget.entry.amountOfItem} ${convertUmlauts(widget.entry.type.einheit.name)}',
                          ),
                          SizedBox(height: 16),
                          _buildInfoCard(
                            'Ausgeliehen am',
                            formatDate(widget.entry.startedAt),
                          ),
                          if (widget.entry.returnedAt != null) ...[
                            SizedBox(height: 16),
                            _buildInfoCard(
                              'Zurückgegeben am',
                              formatDate(widget.entry.returnedAt!),
                            ),
                          ] else ...[
                            SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () => _handleReturn(context),
                                style: ElevatedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.green,
                                    width: 2,
                                  ),
                                  foregroundColor: Colors.green,
                                ),
                                child: Text('Return Item'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Second Section: Article Details
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
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
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
                            convertUmlauts(widget.entry.type.lager),
                            'Einheit',
                            convertUmlauts(widget.entry.type.einheit.name),
                          ),
                          SizedBox(height: 16),
                          _buildInfoRow(
                            context,
                            'Total Menge',
                            widget.entry.type.menge.toString(),
                            'Rubrik',
                            convertUmlauts(widget.entry.type.rubrik),
                          ),
                          if (widget.entry.type.groesse != null) ...[
                            SizedBox(height: 16),
                            _buildInfoCard(
                              'Größe',
                              convertUmlauts(widget.entry.type.groesse!),
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
        currentIndex: -1, // No active item since this is a detail screen
        onTap: (index) {
          if (index == 0 || index == 1 || index == 2) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
      ),
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
}
