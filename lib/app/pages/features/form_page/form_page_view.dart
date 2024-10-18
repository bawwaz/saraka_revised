import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'form_page_controller.dart';
import 'package:saraka_revised/app/route/app_pages.dart';

class FormPageView extends StatelessWidget {
  final formController = Get.put(FormPageController());

  Future<void> _refreshPage() async {
    await formController.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 63, 113, 65),
        title: Text(
          'Saraka Form',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              onPressed: () {
                Get.toNamed(Routes.PROFILE);
              },
              icon: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: Text(
                        'Shift',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
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
                  ],
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
                    formController.addRow(); // Submit form data
                  },
                  child: Text('Simpan'),
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Obx(
                    () {
                      if (formController.tableData.isEmpty) {
                        return Center(child: Text('No data available'));
                      }
                      return DataTable(
                        columns: <DataColumn>[
                          DataColumn(
                            label: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF5DEB3), 
                                border:
                                    Border.all(color: Colors.black),
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Text('ID'),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF5DEB3),
                                border: Border.all(color: Colors.black),
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Text('Operator'),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF5DEB3),
                                border: Border.all(color: Colors.black),
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Text('Product Name'),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF5DEB3),
                                border: Border.all(color: Colors.black),
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Text('Batch Product'),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF5DEB3),
                                border: Border.all(color: Colors.black),
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Text('Product Code'),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF5DEB3),
                                border: Border.all(color: Colors.black),
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Text('Shift'),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF5DEB3),
                                border: Border.all(color: Colors.black),
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Text('Process Date'),
                            ),
                          ),
                          DataColumn(
                            label: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF5DEB3),
                                border: Border.all(color: Colors.black),
                              ),
                              padding: EdgeInsets.all(8.0),
                              child: Text('Actions'),
                            ),
                          ),
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
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title:
                                                const Text('Delete this item?'),
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
                                                          formController
                                                              .deleteRow(
                                                                  row['id']);
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          'Yes',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
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
                                  ),
                                ],
                              )),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
