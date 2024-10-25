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
  var isTableScrolling = false.obs; // Track if the table is scrolling

  final TextEditingController kodeProdukController = TextEditingController();
  final TextEditingController namaProdukController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController shiftController = TextEditingController();
  final TextEditingController operatorController = TextEditingController();

  var selectedShift = '1'.obs;
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
    _setupScrollSync();

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

  // Function to synchronize horizontal scrolling
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

  Future<void> _setCurrentOperator() async {
    String currentUsername = await _getCurrentUserUsername();
    operatorController.text = currentUsername;
  }

  Future<String> _getCurrentUserUsername() async {
    return Future.value("CurrentUsername");
  }

  fetchData() async {
    await getAllData();
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
      bool isSuccess = await postData();
      if (isSuccess) {
        kodeProdukController.clear();
        namaProdukController.clear();
        batchController.clear();
        shiftController.clear();
      }
    }
  }

  Future<void> getAllData() async {
    String url = ApiEndpoint.baseUrlEntries;
    isLoading.value = true; // Start loading

    try {
      final response = await http.get(Uri.parse('$url/get/'));
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
      isLoading.value = false; // Stop loading
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

  Future<bool> postData() async {
    String url = ApiEndpoint.baseUrlEntries;
    isLoading.value = true;

    Map<String, dynamic> postData = {
      "shift": selectedShift.value,
      "product_name": namaProdukController.text,
      "batch_product": batchController.text,
      "product_code": kodeProdukController.text,
      "process_date": DateTime.now().toIso8601String(),
      "operator": operatorController.text,
    };

    try {
      final response = await http.post(
        Uri.parse('$url/post'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(postData),
      );

      if (response.statusCode == 201) {
        // Extract ID from response and replace autogenerated ID
        var responseData = json.decode(response.body);
        int newId = responseData['id']; // Assuming your API returns the new ID
        tableData.add({
          ...postData,
          'id': newId, // Add the new ID to the tableData
        });

        Get.snackbar('Success', 'Data saved successfully');
        getAllData();
        return true;
      } else {
        Get.snackbar('Error', 'Failed to save data');
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to connect to server');
      print('Error: $e');
      return false;
    } finally {
      isLoading.value = false;
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
    isLoading(true); // Show a loading state

    // Make the API call
    final response = await http.post(
      Uri.parse('http://192.168.101.65/saraka/android/Data_Batch.php'),
      body: {'Batch_Brg': batchProduct},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      // Filter for exact matches
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
            child: SingleChildScrollView( // Make the content scrollable
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: exactMatches.map<Widget>((item) {
                  return ListTile(
                    title: Text('Product Name: ${item['Nm_Brg']}'),
                    subtitle: Text(
                        'Code: ${item['Kd_Brg']} - Batch: ${item['Batch_Brg']} - Expiry: ${item['ED_Brg']}'),
                    onTap: () {
                      // Update the text fields with selected data
                      batchController.text = item['Batch_Brg'];
                      kodeProdukController.text = item['Kd_Brg'];
                      namaProdukController.text = item['Nm_Brg'];

                      print('Selected ID: ${item['ID']}');

                      Get.back();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        );
      } else {
        Get.snackbar('No Results', 'No matching products found.');
      }
    } else {
      Get.snackbar('Error', 'Failed to fetch batch products.');
    }
  } catch (e) {
    Get.snackbar('Error', 'An error occurred while searching for products.');
    print('Error: $e');
  } finally {
    isLoading(false); // Hide the loading state
  }
}

}
