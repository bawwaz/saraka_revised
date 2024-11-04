import 'package:flutter/material.dart';
import 'package:saraka_foto_box/app/pages/features/form_page_detail/form_page_detail_controller.dart';
import 'package:get/get.dart';
import 'package:saraka_foto_box/app/pages/features/form_page_detail/widget/qr_dialog.dart';

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
      readOnly: false,
      decoration: InputDecoration(
        labelText: 'Scan QR Code',
        border: const OutlineInputBorder(),
        suffixIcon: InkWell(
            onTap: () => showScanQRDialog(context),
            child: const Icon(Icons.qr_code_scanner)),
      ),
      controller: qrController,
      onChanged: (value) {
        formDetailController.scannedQR.value = value;
      },
    );
  }
}
