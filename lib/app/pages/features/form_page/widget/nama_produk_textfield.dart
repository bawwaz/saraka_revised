import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saraka_foto_box/app/pages/features/form_page/form_page_controller.dart';

class NamaProdukTextfield extends StatelessWidget {
  final formController = Get.put(FormPageController());

  NamaProdukTextfield({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      controller: formController.namaProdukController,
      decoration: InputDecoration(labelText: 'Product Name'),
    );
  }
}
