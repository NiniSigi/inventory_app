import 'package:flutter/material.dart';
import '../home/home-screen.dart';
import '../search_screen.dart';
import '../../widgets/custom_bottom_nav.dart';

class ScannerScreen extends StatefulWidget {
  // ... (existing code)
}

class _ScannerScreenState extends State<ScannerScreen> {
  // ... (existing code)

  @override
  Widget build(BuildContext context) {
    // ... (existing code)

    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner Screen'),
      ),
      body: Center(
        child: Text('Scanner Screen Content'),
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