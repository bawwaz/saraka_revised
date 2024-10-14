import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'form_page_controller.dart';
import 'package:saraka_revised/app/route/app_pages.dart';

class FormPageView extends StatelessWidget {
  final formController = Get.put(FormPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saraka Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(
              () => DropdownButton<String>(
                value: formController.selectedShift.value,
                items: ['1', '2', '3'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  formController.selectedShift.value = newValue!;
                },
              ),
            ),
            TextField(
              controller: formController.operatorController,
              decoration: InputDecoration(labelText: 'Operator'),
            ),
            TextField(
              controller: formController.namaProdukController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: formController.batchController,
              decoration: InputDecoration(labelText: 'Batch Product'),
            ),
            TextField(
              controller: formController.kodeProdukController,
              decoration: InputDecoration(labelText: 'Product Code'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                formController.addRow(); // Post the data and refresh table
              },
              child: Text('Simpan'),
            ),
            SizedBox(height: 20),

            // Expanded widget to fill the remaining space and keep the table scrollable
            Expanded(
              child: Obx(
                () {
                  if (formController.tableData.isEmpty) {
                    return Center(child: Text('No data available'));
                  }
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Horizontal scroll
                    child: DataTable(
                      columns: const <DataColumn>[
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Operator')),
                        DataColumn(label: Text('Product Name')),
                        DataColumn(label: Text('Batch Product')),
                        DataColumn(label: Text('Product Code')),
                        DataColumn(label: Text('Shift')),
                        DataColumn(label: Text('Process Date')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: formController.tableData.map((row) {
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(Text(row['id'].toString())),
                            DataCell(Text(row['operator'].toString())),
                            DataCell(Text(row['product_name'].toString())),
                            DataCell(Text(row['batch_product'].toString())),
                            DataCell(Text(row['product_code'] ?? '')),
                            DataCell(Text(row['shift'].toString())),

                            // Format the 'process_date' here using intl
                            DataCell(Text(
                              row['process_date'] != null
                                  ? DateFormat('dd MMMM yyyy').format(
                                      DateTime.parse(row['process_date']))
                                  : 'N/A',
                            )),
                            DataCell(Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.visibility),
                                  onPressed: () {
                                    int id = row['id'];
                                    Get.toNamed(Routes.FORMDETAIL,
                                        arguments: id);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    formController.deleteRow(row['id']);
                                  },
                                ),
                              ],
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
