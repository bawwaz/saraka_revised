import 'package:flutter/material.dart';
import 'package:saraka_foto_box/app/pages/features/form_page_detail/form_page_detail_controller.dart';
import 'package:get/get.dart';

class CameraTextfield extends StatelessWidget {
  final formDetailController = Get.put(FormPageDetailController());

  CameraTextfield({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Capture Image',
        border: const OutlineInputBorder(),
        suffixIcon: formDetailController.pickedImage != null
            ? const Icon(Icons.check)
            : const Icon(Icons.camera_alt),
      ),
    );
  }
}
