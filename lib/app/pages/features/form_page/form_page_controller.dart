import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:saraka_revised/app/api/api_endpoint.dart';

class FormPageController extends GetxController {
  var tableData =
      <Map<String, dynamic>>[].obs; // Store API data as list of maps

  final TextEditingController kodeProdukController = TextEditingController();
  final TextEditingController namaProdukController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController shiftController = TextEditingController();
  final TextEditingController operatorController = TextEditingController();

  var selectedShift = '1'.obs;

  @override
  void onInit() {
    super.onInit();
    getAllData(); // Fetch data from API on initialization
  }

  // Fetch data from the API and store it in tableData
  Future<void> getAllData() async {
    String url = ApiEndpoint.baseUrl;

    try {
      final response = await http.get(Uri.parse('$url/get/'));
      if (response.statusCode == 200) {
        List<dynamic> fetchedData = json.decode(response.body);

        tableData.value = List<Map<String, dynamic>>.from(fetchedData);
        Get.snackbar('Success', 'Data fetched successfully');
      } else {
        Get.snackbar('Error', 'Failed to fetch data');
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to connect to server');
      print('Error: $e');
    }
  }

  // Post data to the API
  Future<bool> postData() async {
    String url = ApiEndpoint.baseUrl;

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
        Get.snackbar('Success', 'Data saved successfully');
        getAllData(); // Refresh the table data after posting
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
    }
  }

  // Delete data from API and remove it from the local table
  Future<void> deleteRow(int id) async {
    String url = ApiEndpoint.baseUrl + '/delete/$id';

    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        tableData
            .removeWhere((row) => row['id'] == id); // Remove the row locally
        Get.snackbar('Success', 'Row deleted successfully');
      } else {
        Get.snackbar('Error', 'Failed to delete row');
        print('Failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to connect to server');
      print('Error: $e');
    }
  }

  // Clear form after submitting data
  void addRow() async {
    bool isSuccess = await postData();
    if (isSuccess) {
      operatorController.clear();
      kodeProdukController.clear();
      namaProdukController.clear();
      batchController.clear();
      shiftController.clear();
    }
  }
}
