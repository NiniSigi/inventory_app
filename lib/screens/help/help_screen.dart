import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Hilfe',
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            context,
            'Häufig gestellte Fragen',
            [
              _buildFAQItem(
                'Wie scanne ich einen QR-Code?',
                'Öffnen Sie die App und tippen Sie auf das Scan-Symbol. Halten Sie die Kamera über den QR-Code und warten Sie, bis dieser erkannt wird.',
              ),
              _buildFAQItem(
                'Wie füge ich einen neuen Artikel hinzu?',
                'Tippen Sie auf das "+" Symbol auf der Startseite. Füllen Sie die erforderlichen Informationen aus und speichern Sie den Artikel.',
              ),
              _buildFAQItem(
                'Wie suche ich nach Artikeln?',
                'Verwenden Sie die Suchleiste auf der Suchseite. Sie können nach Artikelnamen, Kategorien oder anderen Eigenschaften suchen.',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Kontakt',
            [
              ListTile(
                leading: const Icon(Icons.email),
                title: const Text('E-Mail Support'),
                subtitle: const Text('support@example.com'),
                onTap: () {
                  // TODO: Implement email support
                },
              ),
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Telefon Support'),
                subtitle: const Text('+49 123 456789'),
                onTap: () {
                  // TODO: Implement phone support
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'App-Informationen',
            [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Entwickelt von'),
                subtitle: const Text('Ihr Unternehmen'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Card(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(answer),
        ),
      ],
    );
  }
} 