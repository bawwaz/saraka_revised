import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:saraka_revised/app/pages/features/form_page_detail/form_page_detail_controller.dart';
import 'package:get/get.dart';

Future<void> ScanQRDialog(BuildContext context) async {
  final formDetailController = Get.put(FormPageDetailController());

  String qrResult = '';
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Scan QR Code'),
      content: SizedBox(
        width: 300,
        height: 300,
        child: MobileScanner(
          onDetect: (BarcodeCapture barcodeCapture) {
            if (barcodeCapture.barcodes.isNotEmpty) {
              qrResult = barcodeCapture.barcodes.first.rawValue ?? '';
              formDetailController.scannedQR.value = qrResult;
              Navigator.pop(context);
            }
          },
        ),
      ),
    ),
  );
}
