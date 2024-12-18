import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saraka_foto_box/app/pages/features/form_page/form_page_controller.dart';

class KodeProdukTextfield extends StatelessWidget {
  final formController = Get.put(FormPageController());

  KodeProdukTextfield({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: formController.kodeProdukController,
      decoration: InputDecoration(labelText: 'Product Code'),
    );
  }
}
