import 'package:flutter/material.dart';
import 'package:saraka_revised/app/pages/features/form_page_detail/form_page_detail_controller.dart';
import 'package:get/get.dart';

class QrTextfield extends StatelessWidget {
  final FormPageDetailController formDetailController =
      Get.put(FormPageDetailController());
  final TextEditingController qrController = TextEditingController();

  QrTextfield({super.key}) {
    qrController.text = formDetailController.scannedQR.value;

    ever(formDetailController.scannedQR, (callback) {
      qrController.text =
          callback; // Update the text field when the QR code changes
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Scan QR Code',
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.qr_code_scanner),
      ),
      controller: qrController,
      onChanged: (value) {
        // Update the observable variable whenever the text changes
        formDetailController.scannedQR.value = value;
      },
    );
  }
}
