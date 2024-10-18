import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'form_page_detail_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';

class FormPageDetailView extends StatelessWidget {
  final formDetailController = Get.put(FormPageDetailController());

  String toRomanNumeral(int shift) {
    switch (shift) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      default:
        return '';
    }
  }

  String formatDate(String dateStr) {
    final DateFormat inputFormat = DateFormat("d MMMM yyyy");
    final DateTime dateTime = inputFormat.parse(dateStr);
    final DateFormat outputFormat = DateFormat('yMd');
    return outputFormat.format(dateTime);
  }

  Future<void> _scanQR(BuildContext context) async {
    String qrResult = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan QR Code'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: MobileScanner(
            onDetect: (BarcodeCapture barcodeCapture) {
              if (barcodeCapture.barcodes.isNotEmpty) {
                qrResult = barcodeCapture.barcodes.first.rawValue ?? '';
                formDetailController.scannedQR.value = qrResult;
                Navigator.pop(context);
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int entryId = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: const Text(
          'Detail',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 113, 65),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: formDetailController.fetchData(entryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var data = snapshot.data!;
            return SingleChildScrollView(
              padding: const EdgeInsets.only(
                  left: 16.0, right: 16, bottom: 16, top: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 63, 107, 65)),
                    child: Table(
                      columnWidths: const {
                        0: IntrinsicColumnWidth(),
                        2: FlexColumnWidth(),
                      },
                      children: [
                        TableRow(
                          children: [
                            const Text(
                              'ID',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                ' : ${data['id'].toString()}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text(
                              'Shift',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                ' : ${data['shift'].toString()}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text(
                              'Product Name',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                ' : ${data['product_name'].toString()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text(
                              'Product Code',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                ' : ${data['product_code'].toString()}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text(
                              'Batch Product',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                ' : ${data['batch_product'].toString()}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text(
                              'Process Date',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                ' : ${data['process_date'].toString()}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            const Text(
                              'Operator',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                ' : ${data['operator'].toString()}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 30, thickness: 1),
                  GestureDetector(
                    onTap: () => formDetailController.pickImage(),
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: 'Capture Image',
                          border: const OutlineInputBorder(),
                          suffixIcon: formDetailController.pickedImage != null
                              ? const Icon(Icons.check)
                              : const Icon(Icons.camera_alt),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => _scanQR(context),
                    child: AbsorbPointer(
                      child: Obx(() => TextField(
                            decoration: InputDecoration(
                              labelText: 'Scan QR Code',
                              border: const OutlineInputBorder(),
                              suffixIcon: const Icon(Icons.qr_code_scanner),
                            ),
                            controller: TextEditingController(
                              text: formDetailController.scannedQR.value,
                            ),
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (formDetailController.pickedImage != null &&
                          formDetailController.scannedQR.isNotEmpty) {
                        var qr = formDetailController.scannedQR.value;

                        String processDate = data['process_date'].toString();
                        int shift = int.parse(data['shift']
                            .toString()); 
                        String batchProduct = data['batch_product'].toString();

                        DateTime parsedDate =
                            DateFormat('d MMMM yyyy').parse(processDate);
                        String formattedDate =
                            DateFormat('ddMMyyyy').format(parsedDate);

                        String romanShift = toRomanNumeral(shift);

                        int mediaCount =
                            formDetailController.tableData.length + 1;

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

                        Get.snackbar('Success',
                            'Data added successfully and page refreshed!');
                      } else {
                        Get.snackbar('Error',
                            'Please select an image and scan a QR code before uploading.');
                      }
                    },
                    child: const Text('Tambah'),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    if (formDetailController.tableData.isEmpty) {
                      return const Text('No media available');
                    } else {
                      var sortedTableData =
                          formDetailController.tableData.reversed.toList();

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('No')),
                            DataColumn(label: Text('Image')),
                            DataColumn(label: Text('Image Title')),
                            DataColumn(label: Text('QR Code')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: List.generate(
                            sortedTableData.length,
                            (index) {
                              var row = sortedTableData[index];
                              return DataRow(
                                cells: [
                                  DataCell(Text('${index + 1}')),
                                  DataCell(
                                    row['image'] != null
                                        ? GestureDetector(
                                            onTap: () {
                                              String imagePath;
                                              if (row['image'] is String) {
                                                imagePath = row['image'];
                                              } else if (row['image'] is File) {
                                                imagePath = row['image'].path;
                                              } else {
                                                imagePath = '';
                                              }

                                              if (imagePath.isNotEmpty) {
                                                String baseUrl =
                                                    'https://saraka.kelaskita.site/storage/';
                                                String imageUrl =
                                                    baseUrl + imagePath;

                                                Get.dialog(
                                                  Dialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          height: 200,
                                                          child: Image.network(
                                                            imageUrl,
                                                            fit: BoxFit.fill,
                                                            errorBuilder:
                                                                (context, error,
                                                                    stackTrace) {
                                                              return Center(
                                                                child:
                                                                    const Text(
                                                                  'Failed to load image',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .red),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Column(
                                                            children: [
                                                              Text(
                                                                'Image Title: ${row['image_title'] ?? 'Unknown'}',
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              Text(
                                                                'Size: ${(row['size'] != null ? (row['size'] / 1024).toStringAsFixed(2) : 'Unknown')} KB',
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                Get.snackbar('Error',
                                                    'Invalid image URL or path');
                                              }
                                            },
                                            child: Icon(Icons.remove_red_eye))
                                        : const Text('No Image'),
                                  ),
                                  DataCell(
                                    Text(
                                      row['image_title'] != null
                                          ? (row['image_title']!.length > 25
                                              ? '${row['image_title']!.substring(0, 25)}...'
                                              : row['image_title'])
                                          : 'No title',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      row['qr'] != null
                                          ? (row['qr']!.length > 21
                                              ? '${row['qr']!.substring(0, 21)}...'
                                              : row['qr'])
                                          : 'No QR',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                  ),
                                  DataCell(IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Delete item?'),
                                            actions: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text('No'),
                                                  ),
                                                  Container(
                                                    height: 60,
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromARGB(
                                                              255, 137, 53, 53),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 10,
                                                        horizontal: 20),
                                                    child: Center(
                                                      child: TextButton(
                                                        onPressed: () {
                                                          formDetailController
                                                              .deleteMedia(
                                                                  row['id'],
                                                                  entryId);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          'Yes',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  )),
                                ],
                              );
                            },
                          ),
                        ),
                      );
                    }
                  }),
                ],
              ),
            );
          } else {
            return Center(child: const Text('No data found.'));
          }
        },
      ),
    );
  }
}
