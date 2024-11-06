import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:saraka_foto_box/app/pages/features/form_page_detail/widget/qr_dialog.dart';
import 'package:saraka_foto_box/app/style/color.dart';
import 'package:saraka_foto_box/app/style/fonts.dart';
import 'form_page_detail_controller.dart';
import './widget/camera_textfield.dart';
import './widget/data_container.dart';
import './widget/delete_media.dart';
import './widget/qr_textfield.dart';
import './widget/tambah_button.dart';

class FormPageDetailView extends StatelessWidget {
  final formDetailController = Get.find<FormPageDetailController>(); // Updated

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text('Detail Foto Box', style: Fonts.header),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Wrapping only necessary widget in Obx to reduce rebuilds
            Obx(() {
              return formDetailController.tableData.isNotEmpty
                  ? DataContainer(data: formDetailController.tableData.first)
                  : const Center(child: Text('No data available'));
            }),
            const Divider(height: 30, thickness: 1),
            QrTextfield(),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => formDetailController.pickImage(),
              child: AbsorbPointer(child: CameraTextfield()),
            ),
            const SizedBox(height: 10),
            TambahButton(
              data: {
                'process_date':
                    formDetailController.fetchedItem?['process_date'] ?? '',
                'shift': formDetailController.fetchedItem?['shift'] ?? '',
                'batch_product':
                    formDetailController.fetchedItem?['batch_product'] ?? '',
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              // Optimized: Only necessary part is wrapped in Obx
              child: Obx(() {
                if (formDetailController.tableData.isEmpty) {
                  return const Center(child: Text('No media available'));
                }
                return Column(
                  children: [
                    SingleChildScrollView(
                      controller:
                          formDetailController.horizontalScrollControllerHeader,
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
                        border: const TableBorder(
                          horizontalInside: BorderSide(
                              width: 1,
                              color: Colors.black,
                              style: BorderStyle.solid),
                          verticalInside: BorderSide(
                              width: 1,
                              color: Colors.black,
                              style: BorderStyle.solid),
                        ),
                        children: [
                          TableRow(
                            decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 215, 238, 151)),
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
                    Expanded(
                      // Placeholder for lazy loading or pagination
                      child: SingleChildScrollView(
                        controller:
                            formDetailController.verticalScrollControllerBody,
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
                            border: const TableBorder(
                              horizontalInside: BorderSide(
                                  width: 1,
                                  color: Colors.black,
                                  style: BorderStyle.solid),
                              verticalInside: BorderSide(
                                  width: 1,
                                  color: Colors.black,
                                  style: BorderStyle.solid),
                            ),
                            children: formDetailController.tableData
                                .where((row) =>
                                    row['image_title'] != '' ||
                                    row['qrcode'] != '')
                                .toList()
                                .asMap()
                                .entries
                                .map((entry) {
                              int index = entry.key;
                              var row = entry.value;
                              return TableRow(
                                decoration:
                                    BoxDecoration(color: Colors.grey[200]),
                                children: [
                                  _buildDataCell(
                                      '${formDetailController.tableData.length - formDetailController.tableData.indexOf(row)}'),
                                  _buildImageCell(context, row),
                                  _buildDataCell(
                                      row['image_title'] ?? 'No title'),
                                  _buildDataCell(row['qrcode'] ?? 'No QR'),
                                  _buildActionCell(context, row),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(text, maxLines: 4, overflow: TextOverflow.visible),
      ),
    );
  }

  Widget _buildImageCell(BuildContext context, Map<String, dynamic> row) {
    return GestureDetector(
      onTap: () {
        String imagePath = row['image_title'] ?? '';
        if (imagePath.isNotEmpty) {
          String baseUrl = 'http://192.168.101.65/saraka/view_image.php?image=';
          String imageUrl = "$baseUrl${Uri.encodeComponent(imagePath)}.jpg";
          Get.dialog(
            Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 400,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.fill,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Center(child: Text('Failed to load image')),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Image Title: ${row['image_title'] ?? 'Unknown'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
      child: Icon(Icons.remove_red_eye),
    );
  }

  Widget _buildActionCell(BuildContext context, Map<String, dynamic> row) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DeleteMedia(formDetailController: formDetailController, row: row),
      ],
    );
  }
}
