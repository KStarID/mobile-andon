import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../asesment/asesment_controller.dart';

class QRScannerView extends StatefulWidget {
  final bool isFromAsesment;
  const QRScannerView({super.key, required this.isFromAsesment});

  @override
  State<QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<QRScannerView> {
  final AsesmentController asesmentController = Get.find<AsesmentController>();
  MobileScannerController cameraController = MobileScannerController();

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    final String? code = barcodes.barcodes.firstOrNull?.rawValue;
    if (code != null) {
      _processQRCode(code);
    }
  }

  void _processQRCode(String code) {
    if (widget.isFromAsesment) {
      final assessment = asesmentController.findAssessmentByQRCode(code);
      if (assessment != null) {
        Get.back(result: assessment);
      } else {
        Get.snackbar('Error', 'Data not found, please add new assessment');
      }
    } else {
      Get.back(result: code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _handleBarcode,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 100,
              color: Colors.black.withOpacity(0.4),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Scan QR Code',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
