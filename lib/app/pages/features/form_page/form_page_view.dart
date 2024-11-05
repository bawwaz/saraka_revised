import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:saraka_foto_box/app/pages/features/form_page/widget/batch_textfield.dart';
import 'package:saraka_foto_box/app/pages/features/form_page/widget/delete_icon.dart';
import 'package:saraka_foto_box/app/pages/features/form_page/widget/dropdown_button.dart';
import 'package:saraka_foto_box/app/pages/features/form_page/widget/kode_produk_textfield.dart';
import 'package:saraka_foto_box/app/pages/features/form_page/widget/nama_produk_textfield.dart';
import 'package:saraka_foto_box/app/pages/features/form_page/widget/operator_textfield.dart';
import 'package:saraka_foto_box/app/pages/features/form_page/widget/simpan_button.dart';
import 'package:saraka_foto_box/app/pages/features/form_page/widget/view_icon.dart';
import 'package:saraka_foto_box/app/style/color.dart';
import 'package:saraka_foto_box/app/style/fonts.dart';
import 'form_page_controller.dart';
import 'package:saraka_foto_box/app/route/app_pages.dart';

class FormPageView extends StatelessWidget {
  final formController = Get.put(FormPageController());
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollControllerHeader = ScrollController();
  final ScrollController _horizontalScrollControllerBody = ScrollController();

  FormPageView({Key? key}) : super(key: key);

  Future<void> _refreshPage() async {
    await formController.getAllData();
    if (formController.tableData.isEmpty) {
      Get.snackbar('Info', 'No new data available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Entry Foto Box',
          style: Fonts.header,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: () {
                Get.toNamed(Routes.PROFILE);
              },
              icon: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 20.0),
                    child: Text(
                      'Shift',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DropdownButtonWidget(),
                ],
              ),
              OperatorTextfield(),
              NamaProdukTextfield(),
              BatchTextfield(),
              KodeProdukTextfield(),
              const SizedBox(height: 20),
              SimpanButton(),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  children: [
                    SingleChildScrollView(
                      controller:
                          formController.horizontalScrollControllerHeader,
                      scrollDirection: Axis.horizontal,
                      child: Table(
                        columnWidths: const {
                          0: FixedColumnWidth(50.0),
                          1: FixedColumnWidth(100.0),
                          2: FixedColumnWidth(150.0),
                          3: FixedColumnWidth(120.0),
                          4: FixedColumnWidth(100.0),
                          5: FixedColumnWidth(80.0),
                          6: FixedColumnWidth(130.0),
                          7: FixedColumnWidth(120.0),
                        },
                        border: const TableBorder(
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
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 215, 238, 151),
                            ),
                            children: [
                              _buildHeaderCell('ID'),
                              _buildHeaderCell('Operator'),
                              _buildHeaderCell('Product Name'),
                              _buildHeaderCell('Batch Product'),
                              _buildHeaderCell('Product Code'),
                              _buildHeaderCell('Shift'),
                              _buildHeaderCell('Process Date'),
                              _buildHeaderCell('Actions'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Obx(() {
                        if (formController.isLoading.value) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (formController.tableData.isEmpty) {
                          return const Center(child: Text('No data available'));
                        }
                        return SingleChildScrollView(
                          controller:
                              formController.verticalScrollControllerBody,
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            controller:
                                formController.horizontalScrollControllerBody,
                            scrollDirection: Axis.horizontal,
                            child: Table(
                              columnWidths: const {
                                0: FixedColumnWidth(50.0),
                                1: FixedColumnWidth(100.0),
                                2: FixedColumnWidth(150.0),
                                3: FixedColumnWidth(120.0),
                                4: FixedColumnWidth(100.0),
                                5: FixedColumnWidth(80.0),
                                6: FixedColumnWidth(130.0),
                                7: FixedColumnWidth(120.0),
                              },
                              border: const TableBorder(
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
                                ...formController.tableData
                                    .map(
                                      (row) => TableRow(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                        ),
                                        children: [
                                          _buildDataCell(row['id'].toString()),
                                          _buildDataCell(
                                              row['operator'].toString()),
                                          _buildDataCell(
                                              row['product_name'].toString()),
                                          _buildDataCell(
                                              row['batch_product'].toString()),
                                          _buildDataCell(
                                              row['product_code'] ?? ''),
                                          _buildDataCell(
                                              _convertShift(row['shift'])),
                                          _buildDataCell(
                                            row['process_date'] != null
                                                ? DateFormat('dd MMM yyyy')
                                                    .format(DateTime.parse(
                                                        row['process_date']))
                                                : 'N/A',
                                          ),
                                          _buildActionCell(context, row),
                                        ],
                                      ),
                                    )
                                    .toList(),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _convertShift(dynamic shift) {
    if (_isRomanNumeral(shift.toString())) {
      return shift.toString();
    }
    int shiftInt = int.tryParse(shift.toString()) ?? 0;
    switch (shiftInt) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      default:
        return 'N/A';
    }
  }

  bool _isRomanNumeral(String shift) {
    final regex = RegExp(r'^(I|II|III|IV|V|VI|VII|VIII|IX|X|XI|XII)$');
    return regex.hasMatch(shift);
  }

  Widget _buildHeaderCell(String label) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(text),
      ),
    );
  }

  Widget _buildActionCell(BuildContext context, Map<String, dynamic> row) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ViewIcon(row: row),
        ],
      ),
    );
  }
}
