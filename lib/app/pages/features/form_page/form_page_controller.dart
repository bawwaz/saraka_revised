import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:saraka_revised/app/api/api_endpoint.dart';
import 'package:saraka_revised/app/route/app_pages.dart';

class FormPageController extends GetxController {
  var tableData = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isTableScrolling = false.obs;
  var selectedId = ''.obs;

  final TextEditingController kodeProdukController = TextEditingController();
  final TextEditingController namaProdukController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController shiftController = TextEditingController();
  final TextEditingController operatorController = TextEditingController();

  var selectedShift = '1'.obs; // Default to '1' to represent Roman numeral I
  late String username;

  // Scroll controllers for scroll synchronization
  final ScrollController horizontalScrollControllerHeader = ScrollController();
  final ScrollController horizontalScrollControllerBody = ScrollController();
  final ScrollController verticalScrollControllerBody = ScrollController();

  @override
  void onInit() {
    super.onInit();
    username = Get.arguments['username'];
    operatorController.text = username;
    getAllData();

    tableData.listen((data) {
      if (data.isNotEmpty) {
        _setupScrollSync();
      } else {
        horizontalScrollControllerHeader.jumpTo(0);
        horizontalScrollControllerBody.jumpTo(0);
      }
    });

    verticalScrollControllerBody.addListener(() {
      isTableScrolling.value = verticalScrollControllerBody.position.pixels > 0;
    });
  }

  @override
  void onClose() {
    horizontalScrollControllerHeader.dispose();
    horizontalScrollControllerBody.dispose();
    verticalScrollControllerBody.dispose();
    super.onClose();
  }

  void _setupScrollSync() {
    horizontalScrollControllerBody.addListener(() {
      if (horizontalScrollControllerHeader.offset !=
          horizontalScrollControllerBody.offset) {
        horizontalScrollControllerHeader
            .jumpTo(horizontalScrollControllerBody.offset);
      }
    });

    horizontalScrollControllerHeader.addListener(() {
      if (horizontalScrollControllerBody.offset !=
          horizontalScrollControllerHeader.offset) {
        horizontalScrollControllerBody
            .jumpTo(horizontalScrollControllerHeader.offset);
      }
    });
  }

  Future<void> getAllData() async {
    String url = "http://192.168.101.65/saraka/android/Data_Vw_FotoBox.php";
    isLoading.value = true; // Start loading

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> fetchedData = json.decode(response.body);

        List<Map<String, dynamic>> sortedData =
            await _sortDataInIsolate(fetchedData);
        tableData.value = sortedData;

        Get.snackbar('Success', 'Data fetched and sorted successfully');
      } else {
        Get.snackbar('Error', 'Failed to fetch data');
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to connect to server');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> _sortDataInIsolate(
      List<dynamic> fetchedData) async {
    final response = await Isolate.run(() {
      List<Map<String, dynamic>> sortedData =
          List<Map<String, dynamic>>.from(fetchedData);
      sortedData.sort((a, b) {
        DateTime dateA = DateTime.parse(a['process_date']);
        DateTime dateB = DateTime.parse(b['process_date']);
        return dateB.compareTo(dateA);
      });
      return sortedData;
    });
    return response;
  }

  Future<bool> postData2() async {
    String id = selectedId.value;
    String batch = batchController.text;
    String shift = selectedShift.value; // This will now be '1', '2', or '3'
    String opr = operatorController.text;

    String url = 'http://192.168.101.65/saraka/android/Data_InputFoto.php'
        '?id=$id&batch=$batch&Shift=$shift&Opr=$opr';

    if (id.isNotEmpty && batch.isNotEmpty && shift.isNotEmpty && opr.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          print("id: $id");
          print("opr: $opr");
          print('shift: $shift');
          print('batch: $batch');
          print('Data posted successfully: ${response.body}');
          batchController.clear();
          operatorController.clear();
          selectedId.value = '';
          selectedShift.value = ''; // Reset shift selection
          return true; // Return true for success
        } else {
          Get.snackbar('Error', 'Failed to post data: ${response.statusCode}');
          return false;
        }
      } catch (e) {
        Get.snackbar('Error', 'An error occurred: $e');
        return false;
      }
    } else {
      Get.snackbar('Error', 'Please fill in all fields before saving.');
      return false; // Return false if fields are incomplete
    }
  }

  bool isDuplicate() {
    for (var row in tableData) {
      if (row['product_code'] == kodeProdukController.text &&
          row['batch_product'] == batchController.text &&
          row['operator'].toLowerCase() ==
              operatorController.text.toLowerCase()) {
        return true;
      }
    }
    return false;
  }

  void addRow() async {
    if (isDuplicate()) {
      var existingRow = tableData.firstWhere(
        (row) =>
            row['product_code'] == kodeProdukController.text &&
            row['batch_product'] == batchController.text &&
            row['operator'].toLowerCase() ==
                operatorController.text.toLowerCase(),
        orElse: () => null!,
      );

      if (existingRow != null) {
        kodeProdukController.clear();
        namaProdukController.clear();
        batchController.clear();
        shiftController.clear();

        int existingId = existingRow['id'];
        Get.toNamed(Routes.FORMDETAIL, arguments: existingId);

        Get.snackbar('Duplicate', 'This data already exists');
      }
    } else {
      bool isSuccess = await postData2();
      if (isSuccess) {
        kodeProdukController.clear();
        namaProdukController.clear();
        batchController.clear();
        shiftController.clear();
      }
    }
  }

  Future<void> deleteRow(int id) async {
    String url = ApiEndpoint.baseUrlEntries + '/delete/$id';
    isLoading.value = true;

    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        tableData.removeWhere((row) => row['id'] == id);
        Get.snackbar('Success', 'Row deleted successfully');
      } else {
        Get.snackbar('Error', 'Failed to delete row');
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to connect to server');
      print('Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchBatchProduct(BuildContext context) async {
    String batchProduct = batchController.text;

    if (batchProduct.isEmpty) {
      Get.snackbar('Error', 'Please enter a batch product to search.');
      return;
    }

    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse('http://192.168.101.65/saraka/android/Data_Batch.php'),
        body: {'Batch_Brg': batchProduct},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        var exactMatches =
            data.where((item) => item['Batch_Brg'] == batchProduct).toList();

        if (exactMatches.isNotEmpty) {
          Get.bottomSheet(
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                // Make the content scrollable
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: exactMatches.map<Widget>((item) {
                    return ListTile(
                      title: Text('Product Name: ${item['Nm_Brg']}'),
                      subtitle: Text(
                          'Code: ${item['Kd_Brg']}\nBatch: ${item['Batch_Brg']}\nExpiry: ${item['ED_Brg']}\nID: ${item['ID']}'),
                      onTap: () {
                        selectedId.value = item['ID'];
                        namaProdukController.text = item['Nm_Brg'];
                        kodeProdukController.text = item['Kd_Brg'];
                        batchController.text = item['Batch_Brg'];
                        Get.back();
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        } else {
          Get.snackbar('Error', 'No batch product found');
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch batch product data');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while searching');
    } finally {
      isLoading(false);
    }
  }
}
