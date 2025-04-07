import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import 'settings/settings_screen.dart';
import 'help/help_screen.dart';
import 'about/about_screen.dart';

class NavScreen extends StatelessWidget {
  const NavScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Menü',
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuItem(
            context,
            'Einstellungen',
            Icons.settings,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ),
          ),
          _buildMenuItem(
            context,
            'Hilfe',
            Icons.help,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HelpScreen()),
            ),
          ),
          _buildMenuItem(
            context,
            'Über',
            Icons.info,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
} 