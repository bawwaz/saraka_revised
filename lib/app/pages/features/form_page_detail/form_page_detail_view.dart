import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saraka_revised/app/pages/features/form_page_detail/widget/qr_dialog.dart';
import 'form_page_detail_controller.dart';
import './widget/camera_textfield.dart';
import './widget/data_container.dart';
import './widget/delete_media.dart';
import './widget/qr_textfield.dart';
import './widget/tambah_button.dart';
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
          ),
        ),
        title: const Text(
          'Detail',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 113, 65),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: FutureBuilder<Map<String, dynamic>>(
          future: formDetailController.fetchData(entryId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              var data = snapshot.data!;
              return Column(
                children: [
                  DataContainer(data: data),
                  const Divider(height: 30, thickness: 1),
                  GestureDetector(
                    onTap: () => formDetailController.pickImage(entryId),
                    child: AbsorbPointer(child: CameraTextfield()),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => ScanQRDialog(context),
                    child: AbsorbPointer(child: QrTextfield()),
                  ),
                  SizedBox(height: 10),
                  TambahButton(data: data),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Obx(() {
                      if (formDetailController.tableData.isEmpty) {
                        return Center(child: Text('No media available'));
                      }

                      return Column(
                        children: [
                          // Horizontal scrollable header
                          SingleChildScrollView(
                            controller: formDetailController
                                .horizontalScrollControllerHeader,
                            scrollDirection: Axis.horizontal,
                            child: Table(
                              columnWidths: const {
                                0: FixedColumnWidth(50.0),
                                1: FixedColumnWidth(100.0),
                                2: FixedColumnWidth(150.0),
                                3: FixedColumnWidth(120.0),
                                4: FixedColumnWidth(130.0),
                                5: FixedColumnWidth(120.0),
                              },
                              border: TableBorder(
                                horizontalInside: BorderSide(
                                  width: 1,
                                  color: Colors.black,
                                  style: BorderStyle.solid,
                                ),
                                verticalInside: BorderSide(
                                  width: 1,
                                  color: Colors.black,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              children: [
                                // Header row
                                TableRow(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 215, 238, 151),
                                  ),
                                  children: [
                                    _buildHeaderCell('No'),
                                    _buildHeaderCell('Image'),
                                    _buildHeaderCell('Image Title'),
                                    _buildHeaderCell('QR Code'),
                                    _buildHeaderCell('Actions'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Scrollable body
                          Expanded(
                            child: SingleChildScrollView(
                              controller: formDetailController
                                  .verticalScrollControllerBody,
                              child: SingleChildScrollView(
                                controller: formDetailController
                                    .horizontalScrollControllerBody,
                                scrollDirection: Axis.horizontal,
                                child: Table(
                                  columnWidths: const {
                                    0: FixedColumnWidth(50.0),
                                    1: FixedColumnWidth(100.0),
                                    2: FixedColumnWidth(150.0),
                                    3: FixedColumnWidth(120.0),
                                    4: FixedColumnWidth(130.0),
                                    5: FixedColumnWidth(120.0),
                                  },
                                  border: TableBorder(
                                    horizontalInside: BorderSide(
                                      width: 1,
                                      color: Colors.black,
                                      style: BorderStyle.solid,
                                    ),
                                    verticalInside: BorderSide(
                                      width: 1,
                                      color: Colors.black,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  children: [
                                    // Data rows
                                    ...formDetailController.tableData
                                        .map(
                                          (row) => TableRow(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                            ),
                                            children: [
                                              _buildDataCell(
                                                  '${formDetailController.tableData.indexOf(row) + 1}'),
                                              _buildImageCell(context, row),
                                              _buildDataCell(
                                                  row['image_title'] ??
                                                      'No title'),
                                              _buildDataCell(
                                                  row['qr'] ?? 'No QR'),
                                              _buildActionCell(
                                                  context, row, entryId),
                                            ],
                                          ),
                                        )
                                        .toList(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              );
            } else {
              return Center(child: const Text('No data found.'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          text.length > 20 ? '${text.substring(0, 20)}...' : text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildImageCell(BuildContext context, Map<String, dynamic> row) {
    return GestureDetector(
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
          String baseUrl = 'https://saraka.kelaskita.site/storage/';
          // String baseUrl = 'http://localhost:8000/storage/';
          String imageUrl = baseUrl + imagePath;
          Get.dialog(
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 200,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'Image Title: ${row['image_title'] ?? 'Unknown'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Size: ${(row['size'] != null ? (row['size'] / 1024).toStringAsFixed(2) : 'Unknown')} KB',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          Get.snackbar('Error', 'Invalid image URL or path');
        }
      },
      child: row['image'] != null
          ? Icon(Icons.remove_red_eye)
          : const Text('No Image'),
    );
  }

  Widget _buildActionCell(
      BuildContext context, Map<String, dynamic> row, int entryId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DeleteMedia(
            formDetailController: formDetailController,
            row: row,
            entryId: entryId)
      ],
    );
  }
}
