import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saraka_foto_box/app/pages/features/form_page_detail/form_page_detail_controller.dart';

class CameraTextfield extends StatelessWidget {
  final formDetailController = Get.find<FormPageDetailController>();

  CameraTextfield({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return TextField(
        readOnly: true, // Make text field read-only
        onTap: () async {
          await formDetailController.pickImage(); // Call pickImage on tap
        },
        decoration: InputDecoration(
          labelText: formDetailController.imageTitle.value.isNotEmpty
              ? formDetailController.imageTitle.value
              : 'Capture Image',
          border: const OutlineInputBorder(),
          suffixIcon: formDetailController.pickedImage.value != null
              ? const Icon(Icons.check)
              : const Icon(Icons.camera_alt),
        ),
      );
    });
  }
}
