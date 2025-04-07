import 'package:flutter/material.dart';
import '../../services/article_service.dart';
import '../../models/inventory_entry.dart'; // Updated import
import '../../widgets/custom_bottom_nav.dart';
import '../search_screen.dart';
import '../../services/inventory_service.dart';
import '../home/home-screen.dart';
import '../../main.dart';
import '../../widgets/custom_app_bar.dart';

class ArticleDetailsScreen extends StatefulWidget {
  final String articleId;
  final String? defaultTeam;

  const ArticleDetailsScreen({
    Key? key,
    required this.articleId,
    this.defaultTeam,
  }) : super(key: key);

  @override
  State<ArticleDetailsScreen> createState() => _ArticleDetailsScreenState();
}

class _ArticleDetailsScreenState extends State<ArticleDetailsScreen> {
  final TextEditingController _amountController = TextEditingController();
  String? selectedTeam;
  final List<String> teams = ['SPAEHER', 'AMEISLI'];
  late Future<Artikel> articleFuture; // Changed from Article to Artikel

  @override
  void initState() {
    super.initState();
    articleFuture = fetchArticleById(widget.articleId);
    selectedTeam = widget.defaultTeam; // Will be null if no team was selected
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
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

  Widget _buildEntrySection(BuildContext context, Artikel article) {
    return Container(
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
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
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
                            child: Text(convertUmlauts(team)),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() => selectedTeam = newValue);
                    },
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Menge',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        _amountController.text.isNotEmpty &&
                                selectedTeam != null
                            ? () async {
                              try {
                                final amount = int.parse(
                                  _amountController.text,
                                );
                                if (amount <= 0) {
                                  throw Exception('Amount must be positive');
                                }

                                final success = await createEntry(
                                  teamName: selectedTeam ?? '',
                                  amountOfItem: amount,
                                  typeId: article.id,
                                );

                                if (!mounted) return;

                                // Always navigate back with success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Item borrowed successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context, true);
                              } catch (e) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Invalid amount entered'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: Text('Borrow Item'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleInformation(BuildContext context, Artikel article) {
    return Container(
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
                  convertUmlauts(article.lager),
                  'Einheit',
                  convertUmlauts(article.einheit.name),
                ),
                SizedBox(height: 16),
                _buildInfoRow(
                  context,
                  'Total Menge',
                  article.menge.toString(),
                  'Rubrik',
                  convertUmlauts(article.rubrik),
                ),
                if (article.groesse != null) ...[
                  SizedBox(height: 16),
                  _buildInfoCard('Größe', convertUmlauts(article.groesse!)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Artikel Details',
        automaticallyImplyLeading: true,
      ),
      body: FutureBuilder<Artikel>(
        future: articleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          final article = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          convertUmlauts(article.artikel),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 24),
                        _buildEntrySection(context, article),
                        SizedBox(height: 24),
                        _buildArticleInformation(context, article),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
