import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:saraka_foto_box/app/pages/features/form_page_detail/form_page_detail_controller.dart';

class TambahButton extends StatelessWidget {
  final formDetailController = Get.put(FormPageDetailController());
  final Map<String, dynamic> data;

  TambahButton({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        String qr = formDetailController.scannedQR.value;
        String processDate =
            formDetailController.fetchedItem?['process_date'] ?? '';
        String shift = formDetailController.fetchedItem?['shift'] ?? '0';
        String batchProduct =
            formDetailController.fetchedItem?['batch_product']?.toString() ??
                '';

        String formattedDate = "00000000";
        if (processDate.isNotEmpty) {
          try {
            DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(processDate);
            formattedDate = DateFormat('yyyyMMdd').format(parsedDate);
          } catch (e) {
            print("Date parsing error: $e");
          }
        } else {
          print("Process date is empty; using placeholder.");
        }

        String romanShift = formDetailController.romanNumeral(shift).toString();

        int mediaCount = formDetailController.tableData.length + 1;
        String fileNumber = mediaCount.toString();
        String fileName = '$formattedDate-$shift-$batchProduct-$mediaCount.jpg';

        print('Generated custom image title: $fileName');
        print('Image number: $fileNumber');

        String id = formDetailController.fetchedItem?['id'] ?? 'No ID';
        print({'id': id, 'nf': fileNumber, 'bc': qr});

        if (formDetailController.pickedImage != null &&
            formDetailController.scannedQR.isNotEmpty) {
          await formDetailController.uploadImageFile(
              formDetailController.pickedImage!, fileName);
          await formDetailController.postMedia(
            id: id,
            nf: fileNumber,
            bc: qr,
          );

          await formDetailController.fetchData(id);

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
