import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'Einstellungen',
            automaticallyImplyLeading: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSection(
                context,
                'Erscheinungsbild',
                [
                  SwitchListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Dunkles Erscheinungsbild aktivieren'),
                    value: themeProvider.isDarkMode,
                    onChanged: themeProvider.useSystemTheme
                        ? null
                        : (value) => themeProvider.setDarkMode(value),
                  ),
                  SwitchListTile(
                    title: const Text('System Theme'),
                    subtitle: const Text('Systemeinstellungen verwenden'),
                    value: themeProvider.useSystemTheme,
                    onChanged: (value) => themeProvider.setUseSystemTheme(value),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Benachrichtigungen',
                [
                  SwitchListTile(
                    title: const Text('Push-Benachrichtigungen'),
                    subtitle: const Text('Benachrichtigungen aktivieren'),
                    value: true, // TODO: Implement notification settings
                    onChanged: (value) {
                      // TODO: Implement notification toggle
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                'Daten',
                [
                  ListTile(
                    title: const Text('Cache leeren'),
                    subtitle: const Text('Temporäre Daten löschen'),
                    trailing: const Icon(Icons.delete_outline),
                    onTap: () {
                      // TODO: Implement cache clearing
                    },
                  ),
                  ListTile(
                    title: const Text('Daten exportieren'),
                    subtitle: const Text('Bestandsdaten exportieren'),
                    trailing: const Icon(Icons.download),
                    onTap: () {
                      // TODO: Implement data export
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
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