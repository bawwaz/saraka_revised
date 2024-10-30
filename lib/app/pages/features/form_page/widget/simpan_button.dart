import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saraka_revised/app/pages/features/form_page/form_page_controller.dart';

class SimpanButton extends StatelessWidget {
  final formController = Get.put(FormPageController());

  SimpanButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        formController.addRow();
        formController.postData2();
      },
      child: Text('Simpan'),
    );
  }
}
