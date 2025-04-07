import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/inventory_entry.dart';
import '../../services/inventory_service.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../search_screen.dart';
import '../../main.dart';
import '../../widgets/custom_app_bar.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController controller = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Scan QR Code',
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Icon(
              controller.torchEnabled ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () {
              controller.toggleTorch();
              setState(() {}); // Ensure UI updates after toggling the torch
            },
          ),
          IconButton(
            icon: Icon(
              controller.facing == CameraFacing.front
                  ? Icons.camera_front
                  : Icons.camera_rear,
            ),
            onPressed: () {
              controller.switchCamera();
              setState(() {}); // Ensure UI updates after switching the camera
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: controller,
                      onDetect: (BarcodeCapture capture) {
                        if (capture.barcodes.isNotEmpty) {
                          final scannedBarcode = capture.barcodes.first;
                          if (scannedBarcode.rawValue != null) {
                            String scannedValue = scannedBarcode.rawValue!;
                            try {
                              // Validate if it's a number
                              int.parse(scannedValue);
                              // Stop scanning before navigating
                              controller.stop();
                              Navigator.pop(context, scannedValue);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please scan a valid number'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                    ),
                    CustomPaint(painter: ScannerOverlay(), child: Container()),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    final double scanAreaSize = size.width * 0.7;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final Rect scanRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    canvas.drawRect(scanRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
