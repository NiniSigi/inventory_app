import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Über',
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            context,
            'App-Informationen',
            [
              ListTile(
                title: const Text('Version'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Build'),
                subtitle: const Text('2024.1'),
              ),
              ListTile(
                title: const Text('Entwickelt von'),
                subtitle: const Text('Ihr Unternehmen'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Lizenz',
            [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '© 2024 Ihr Unternehmen. Alle Rechte vorbehalten.',
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Diese App wurde entwickelt, um die Verwaltung von Artikeln und Inventar zu erleichtern.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSection(
            context,
            'Entwickler-Team',
            [
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: const Text('Entwickler Name'),
                subtitle: const Text('Hauptentwickler'),
              ),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: const Text('Designer Name'),
                subtitle: const Text('UI/UX Designer'),
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
} 