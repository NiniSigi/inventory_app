import 'package:flutter/material.dart';

class NavScreen extends StatelessWidget {
  const NavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menü'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
                    title: Text('Einstellungen', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    onTap: () {
                      // Navigate to settings
                    },
                  ),
                  Divider(color: Theme.of(context).colorScheme.primary),
                  ListTile(
                    leading: Icon(Icons.help, color: Theme.of(context).colorScheme.primary),
                    title: Text('Hilfe', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    onTap: () {
                      // Navigate to help
                    },
                  ),
                  Divider(color: Theme.of(context).colorScheme.primary),
                  ListTile(
                    leading: Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
                    title: Text('Über', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                    onTap: () {
                      // Navigate to about
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 