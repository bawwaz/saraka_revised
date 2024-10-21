import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:saraka_revised/app/pages/features/form_page_detail/widget/camera_textfield.dart';
import 'package:saraka_revised/app/pages/features/form_page_detail/widget/data_container.dart';
import 'package:saraka_revised/app/pages/features/form_page_detail/widget/delete_media.dart';
import 'package:saraka_revised/app/pages/features/form_page_detail/widget/qr_textfield.dart';
import 'package:saraka_revised/app/pages/features/form_page_detail/widget/tambah_button.dart';
import 'form_page_detail_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import './widget/qr_dialog.dart';
import 'dart:io';

class FormPageDetailView extends StatelessWidget {
  final formDetailController = Get.put(FormPageDetailController());
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
                  DataContainer(data: data),
                  const Divider(height: 30, thickness: 1),
                  GestureDetector(
                    onTap: () => formDetailController.pickImage(),
                    child: AbsorbPointer(child: CameraTextfield()),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () => ScanQRDialog(context),
                    child: AbsorbPointer(
                      child: QrTextfield(),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TambahButton(data: data),
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
                                  DataCell(DeleteMedia(
                                    formDetailController: formDetailController,
                                    row: row,
                                    entryId: entryId,
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
