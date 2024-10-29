import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'form_page_controller.dart';
import 'package:saraka_revised/app/route/app_pages.dart';

class FormPageView extends StatelessWidget {
  final formController = Get.put(FormPageController());
  final ScrollController _verticalScrollController = ScrollController();
  final ScrollController _horizontalScrollControllerHeader = ScrollController();
  final ScrollController _horizontalScrollControllerBody = ScrollController();

  FormPageView({Key? key}) : super(key: key);

  Future<void> _refreshPage() async {
    await formController.fetchData();
  }

  @override
  void initState() {
    // Synchronize horizontal scroll between header and body
    _horizontalScrollControllerBody.addListener(() {
      _horizontalScrollControllerHeader
          .jumpTo(_horizontalScrollControllerBody.offset);
      print(
          'Body is scrolling horizontally, offset: ${_horizontalScrollControllerBody.offset}');
    });

    _horizontalScrollControllerHeader.addListener(() {
      _horizontalScrollControllerBody
          .jumpTo(_horizontalScrollControllerHeader.offset);
      print(
          'Header is scrolling horizontally, offset: ${_horizontalScrollControllerHeader.offset}');
    });
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
                    () {
                      if (!['i', 'ii', 'iii']
                          .contains(formController.selectedShift.value)) {
                        formController.selectedShift.value = '';
                      }

                      return DropdownButton<String>(
                        value: formController.selectedShift.value.isNotEmpty
                            ? formController.selectedShift.value
                            : null,
                        items: ['i', 'ii', 'iii'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        hint: Text('Select Shift'),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            formController.selectedShift.value = newValue;
                          }
                        },
                      );
                    },
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
                decoration: InputDecoration(
                  labelText: 'Batch Product',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      formController.searchBatchProduct(
                          context); // Call the function when pressed
                    },
                  ),
                ),
              ),

              TextField(
                controller: formController.kodeProdukController,
                decoration: InputDecoration(labelText: 'Product Code'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  formController.addRow();
                  formController.postData2();
                },
                child: Text('Simpan'),
              ),
              SizedBox(height: 20),
              // Sticky Header with Scrollable Body
              Expanded(
                child: Column(
                  children: [
                    // Horizontal scrollable header
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
                          TableRow(
                            decoration: BoxDecoration(
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
                    // Scrollable body
                    Expanded(
                      child: Obx(() {
                        if (formController.tableData.isEmpty) {
                          return Center(child: Text('No data available'));
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
                                              row['shift'].toString()),
                                          _buildDataCell(
                                            row['process_date'] != null
                                                ? DateFormat('dd MMM yyyy')
                                                    .format(
                                                    DateTime.parse(
                                                        row['process_date']),
                                                  )
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
          IconButton(
            icon: Icon(Icons.visibility),
            onPressed: () {
              String id = row['id'].toString();
              print("ID:$id");
              Get.toNamed(Routes.FORMDETAIL, arguments: {'id': id});
            },
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete this item?'),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              formController.deleteRow(row['id']);
                              Navigator.of(context).pop();
                            },
                            child: Text('Yes'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('No'),
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
      ),
    );
  }
}