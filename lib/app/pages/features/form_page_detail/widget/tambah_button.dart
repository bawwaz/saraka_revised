import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:saraka_revised/app/pages/features/form_page_detail/form_page_detail_controller.dart';

class TambahButton extends StatelessWidget {
  final formDetailController = Get.put(FormPageDetailController());
  final int entryId = Get.arguments;

  final Map<String, dynamic> data;

  TambahButton({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        if (formDetailController.pickedImage != null &&
            formDetailController.scannedQR.isNotEmpty) {
          var qr = formDetailController.scannedQR.value;
          String processDate = data['process_date'].toString();
          int shift = int.parse(data['shift'].toString());
          String batchProduct = data['batch_product'].toString();
          DateTime parsedDate = DateFormat('d MMMM yyyy').parse(processDate);
          String formattedDate = DateFormat('ddMMyyyy').format(parsedDate);
          String romanShift = formDetailController.RomanNumeral(shift);
          int mediaCount = formDetailController.tableData.length + 1;
          String customFileName =
              '$formattedDate-$romanShift-$batchProduct-$mediaCount.jpg';
          print('Generated custom image title: $customFileName');

          await formDetailController.uploadMedia(
            entryId,
            formDetailController.pickedImage!,
            qr,
            customFileName,
          );
          await formDetailController.fetchData(entryId);
          Get.snackbar(
              'Success', 'Data added successfully and page refreshed!');
        } else {
          Get.snackbar('Error',
              'Please select an image and scan a QR code before uploading.');
        }
      },
      child: const Text('Tambah'),
    );
  }
}
