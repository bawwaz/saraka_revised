import 'dart:convert'; // Import for jsonDecode
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FormPageDetailController extends GetxController {
  final picker = ImagePicker();
  var tableData = <Map<String, dynamic>>[].obs;
  File? pickedImage;
  var scannedQR = ''.obs;
  Map<String, dynamic>? fetchedItem;

  final ScrollController horizontalScrollControllerHeader = ScrollController();
  final ScrollController horizontalScrollControllerBody = ScrollController();
  final ScrollController verticalScrollControllerBody = ScrollController();
  var isTableScrolling = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupScrollSync();

    verticalScrollControllerBody.addListener(() {
      isTableScrolling.value = verticalScrollControllerBody.position.pixels > 0;
    });

    final String? id = Get.arguments['id']; 

    if (id != null) {
      fetchData(id);
    }
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

  Future<List<Map<String, dynamic>>> fetchDataMedia(
      String bc, String shift) async {
    try {
      final response = await http.get(Uri.parse(
        'http://192.168.101.65/saraka/android/Data_Vw_FileFoto.php?bc=$bc&shift=$shift',
      ));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(
            jsonData); // Convert to a list of maps
      } else {
        throw Exception('Failed to load media data');
      }
    } catch (error) {
      print('Error fetching data: $error');
      return [];
    }
  }

  Future<void> fetchData(String id) async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.101.65/saraka/android/Data_FilterDetail.php?id=$id'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        tableData.value = data.map((item) {
          return {
            'id': item['id'],
            'shift': item['shift'],
            'product_name': item['product_name'],
            'product_code': item['product_code'],
            'batch_product': item['batch_product'],
            'process_date': item['process_date'],
            'operator': item['operator'],
            'image_title': '',
            'qrcode': ''
          };
        }).toList();

        if (tableData.isNotEmpty) {
          fetchedItem = tableData.first;

          String bc = fetchedItem!['batch_product'];
          String shift = fetchedItem!['shift'];

          List<Map<String, dynamic>> mediaData =
              await fetchDataMedia(bc, shift);
          // Add media data to the table
          for (var media in mediaData) {
            tableData.add({
              'image_title': media['image_title'] ?? 'No title',
              'qrcode': media['qrcode'] ?? 'No QR',
              // Add empty placeholders for the other fields
              'id': '',
              'shift': '',
              'product_name': '',
              'product_code': '',
              'batch_product': '',
              'process_date': '',
              'operator': ''
            });
          }
        }
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final imageFile = File(image.path);
      final bytes = await imageFile.readAsBytes();
      img.Image? decodedImage = img.decodeImage(bytes);

      if (decodedImage != null) {
        img.Image resizedImage = img.copyResize(decodedImage, width: 1024);
        var font1 = img.arial24;
        var font2 = img.arial48;

        String batchProduct = 'unknown';
        String operatorText = 'Unknown';
        String shiftText = 'Unknown';
        String productNameText = 'Unknown';

        String dateTimeString =
            DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now());

        img.drawString(
            resizedImage, 'PT Saraka Mandiri Semesta, $dateTimeString',
            font: font1, x: 10, y: resizedImage.height - 50);
        img.drawString(resizedImage, 'Operator: $operatorText',
            font: font2, x: 10, y: 50);
        img.drawString(resizedImage, 'Shift: $shiftText',
            font: font2, x: 10, y: 100);
        img.drawString(resizedImage, 'Product: ($batchProduct)',
            font: font2, x: 10, y: 150);
        img.drawString(resizedImage, productNameText,
            font: font2,
            x: 10 + (productNameText.length * 8),
            y: 150); 

        List<int> compressedImageBytes;
        int quality = 80;
        do {
          compressedImageBytes = img.encodeJpg(resizedImage, quality: quality);
          quality -= 5;
          if (quality < 10) break;
        } while (compressedImageBytes.length > 80 * 1024);

        final compressedFile = File(image.path)
          ..writeAsBytesSync(compressedImageBytes);
        pickedImage = compressedFile;

        print('Compressed image size: ${compressedImageBytes.length} bytes');
      }
    }
  }

  Future<void> postMedia({
    required String id,
    required String nf,
    required String bc,
  }) async {
    final String url = 'http://192.168.101.65/saraka/Data_InputBCode.php';

    try {
      final response = await http.get(Uri.parse('$url?id=$id&nf=$nf&bc=$bc'));

      if (response.statusCode == 200) {
        print('Response data: ${response.body}');
      } else {
        print('Failed to post media. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  String romanNumeral(String shift) {
    switch (shift) {
      case 'i':
        return 'I';
      case 'ii':
        return 'II';
      case 'iii':
        return 'III';
      default:
        return '';
    }
  }
}
