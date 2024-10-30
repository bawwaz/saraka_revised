import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saraka_revised/app/pages/features/form_page/form_page_controller.dart';

class DropdownButtonWidget extends StatelessWidget {
  final formController = Get.put(FormPageController());

  DropdownButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (!['1', '2', '3'].contains(formController.selectedShift.value)) {
          formController.selectedShift.value = '1'; // Default to 1 if invalid
        }
        return DropdownButton<String>(
          value: formController.selectedShift.value.isNotEmpty
              ? formController.selectedShift.value
              : null,
          items: [
            DropdownMenuItem<String>(
              value: '1',
              child: Text('I'), // Roman numeral for 1
            ),
            DropdownMenuItem<String>(
              value: '2',
              child: Text('II'), // Roman numeral for 2
            ),
            DropdownMenuItem<String>(
              value: '3',
              child: Text('III'), // Roman numeral for 3
            ),
          ],
          hint: Text('Select Shift'),
          onChanged: (newValue) {
            if (newValue != null) {
              formController.selectedShift.value = newValue; // Set the integer value
            }
          },
        );
      },
    );
  }
}
