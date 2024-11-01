import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saraka_foto_box/app/pages/features/form_page/form_page_controller.dart';

class BatchTextfield extends StatelessWidget {
  final formController = Get.put(FormPageController());

  BatchTextfield({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: formController.batchController,
      decoration: InputDecoration(
        labelText: 'Batch Product',
        suffixIcon: IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            formController.searchBatchProduct(context);
          },
        ),
      ),
    );
  }
}
