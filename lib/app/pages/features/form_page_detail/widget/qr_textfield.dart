import 'package:flutter/material.dart';
import 'package:saraka_revised/app/pages/features/form_page_detail/form_page_detail_controller.dart';
import 'package:get/get.dart';

class QrTextfield extends StatelessWidget {
  final formDetailController = Get.put(FormPageDetailController());

  QrTextfield({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextField(
        decoration: InputDecoration(
          labelText: 'Scan QR Code',
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.qr_code_scanner),
        ),
        controller: TextEditingController(
          text: formDetailController.scannedQR.value,
        ),
      ),
    );
    // return
  }
}
