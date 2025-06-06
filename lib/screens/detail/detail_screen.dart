import 'package:flutter/material.dart';
import '../../models/inventory_entry.dart';
import '../../services/inventory_service.dart';
import '../../main.dart';
import '../search_screen.dart';
import '../home/home-screen.dart';
import '../../widgets/custom_app_bar.dart';

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
      appBar: CustomAppBar(
        title: 'Article Details',
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      convertUmlauts(widget.entry.type.name),
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
                              'Borrow Details',
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
                                  'Team',
                                  convertUmlauts(widget.entry.teamName.name),
                                  'Quantity',
                                  '${widget.entry.amountOfItem} ${convertUmlauts(widget.entry.type.unit.name)}',
                                ),
                                SizedBox(height: 16),
                                _buildInfoCard(
                                  'Borrowed on',
                                  formatDate(widget.entry.startedAt),
                                ),
                                if (widget.entry.returnedAt != null) ...[
                                  SizedBox(height: 16),
                                  _buildInfoCard(
                                    'Returned on',
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
                              'Article Information',
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
                                  'Location',
                                  convertUmlauts(widget.entry.type.location),
                                  'Unit',
                                  convertUmlauts(widget.entry.type.unit.name),
                                ),
                                SizedBox(height: 16),
                                _buildInfoRow(
                                  context,
                                  'Total Quantity',
                                  widget.entry.type.quantity.toString(),
                                  'Category',
                                  convertUmlauts(widget.entry.type.category),
                                ),
                                if (widget.entry.type.size != null) ...[
                                  SizedBox(height: 16),
                                  _buildInfoCard('Size', convertUmlauts(widget.entry.type.size!)),
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
          ),
        ],
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
