import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:saraka_revised/app/api/api_endpoint.dart';

class FormPageDetailController extends GetxController {
  final picker = ImagePicker();
  var tableData = <Map<String, dynamic>>[].obs;
  File? pickedImage;
  var scannedQR = ''.obs;

  // Scroll Controllers for syncing header and body
  final ScrollController horizontalScrollControllerHeader = ScrollController();
  final ScrollController horizontalScrollControllerBody = ScrollController();
  final ScrollController verticalScrollControllerBody = ScrollController();
  var isTableScrolling = false.obs; // Track if the table is scrolling

  @override
  void onInit() {
    super.onInit();
    _setupScrollSync();

    verticalScrollControllerBody.addListener(() {
      isTableScrolling.value = verticalScrollControllerBody.position.pixels > 0;

      // Print the current scroll position
      print('Vertical scroll position: ${verticalScrollControllerBody.position.pixels}');
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
      if (horizontalScrollControllerHeader.offset != horizontalScrollControllerBody.offset) {
        horizontalScrollControllerHeader.jumpTo(horizontalScrollControllerBody.offset);
        print('Body is being scrolled horizontally: ${horizontalScrollControllerBody.offset}');
      }
    });

    horizontalScrollControllerHeader.addListener(() {
      if (horizontalScrollControllerBody.offset != horizontalScrollControllerHeader.offset) {
        horizontalScrollControllerBody.jumpTo(horizontalScrollControllerHeader.offset);
        print('Header is being scrolled horizontally: ${horizontalScrollControllerHeader.offset}');
      }
    });
  }

  // Fetch the data from API and format it
  Future<Map<String, dynamic>> fetchData(int id) async {
    final String url = ApiEndpoint.baseUrl;
    try {
      final response = await http.get(Uri.parse('$url/get/$id'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        String formattedProcessDate = DateFormat('dd MMMM yyyy')
            .format(DateTime.parse(data['process_date']));
        String formattedCreatedAt = DateFormat('dd MMMM yyyy')
            .format(DateTime.parse(data['created_at']));
        String formattedUpdatedAt = DateFormat('dd MMMM yyyy')
            .format(DateTime.parse(data['updated_at']));

        data['process_date'] = formattedProcessDate;
        data['created_at'] = formattedCreatedAt;
        data['updated_at'] = formattedUpdatedAt;

        print('Fetched Data: $data');

        // Map the media data into tableData observable
        tableData.value = List<Map<String, dynamic>>.from(data['media'].map((media) {
          print('Image Title: ${media['image_title'] ?? 'No Title'}');
          print('Image Size: ${media['size'] ?? 'Unknown Size'}');

          return {
            'id': media['id'],
            'image': media['image'],
            'image_title': media['image_title'],
            'qr': media['qrcode'],
            'size': media['size'],
          };
        }).toList());
        return data;
      } else {
        throw Exception('Failed to load details');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  // Method to upload media files
  Future<void> uploadMedia(int sarakaEntryId, File image, String qrCode, String customFileName) async {
    final String url = 'https://saraka.kelaskita.site/api/saraka-medias/post';
    final String apiToken = 'your_api_token';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $apiToken';
      request.headers['Accept'] = 'application/json';

      var imageStream = http.ByteStream(image.openRead());
      var imageLength = await image.length();
      request.files.add(
        http.MultipartFile(
          'image',
          imageStream,
          imageLength,
          filename: customFileName,
        ),
      );

      request.fields['saraka_entry_id'] = sarakaEntryId.toString();
      request.fields['qrcode'] = qrCode;
      request.fields['image_title'] = customFileName;

      print('Sending the following fields:');
      request.fields.forEach((key, value) => print('$key: $value'));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print('response: $responseBody');
        Get.snackbar('Success', 'Media uploaded successfully');
        await fetchData(sarakaEntryId);
      } else {
        var responseString = await response.stream.bytesToString();
        print('Error response: $responseString');
        Get.snackbar('Error', 'Failed to upload media');
      }
    } catch (error) {
      print('Error: $error');
      Get.snackbar('Error', 'Failed to upload media');
    }
  }

  // Pick an image from the camera, add metadata, and resize the image
  Future<void> pickImage(int id) async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final imageFile = File(image.path);
      final bytes = await imageFile.readAsBytes();

      img.Image? decodedImage = img.decodeImage(bytes);

      if (decodedImage != null) {
        img.Image resizedImage = img.copyResize(decodedImage, width: 1024);
        var font = img.arial48;

        Map<String, dynamic> data = await fetchData(id);

        String batchProduct = data['batch_product'] ?? 'unknown';
        String operatorText = data['operator'] ?? 'Unknown';
        String shiftText = data['shift'] ?? 'Unknown';
        String productNameText = data['product_name'] ?? 'Unknown';

        String dateTimeString = DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now());

        int textX = 10;
        int operatorTextY = 100;
        int shiftTextY = 150;
        int productNameTextY = 200;

        img.drawString(resizedImage, 'PT Saraka Mandiri Semesta, $dateTimeString',
            font: font, x: textX, y: resizedImage.height - 50);
        img.drawString(resizedImage, 'Operator: $operatorText', font: font, x: textX, y: operatorTextY);
        img.drawString(resizedImage, 'Shift: $shiftText', font: font, x: textX, y: shiftTextY);
        img.drawString(resizedImage, 'Product: ($batchProduct)', font: font, x: textX, y: productNameTextY);

        double avgCharWidth = font.size * 0.8;
        int productNameWidth = (productNameText.length * avgCharWidth).toInt();

        int batchX = textX + productNameWidth + 240;
        img.drawString(resizedImage, productNameText, font: font, x: batchX, y: productNameTextY);

        final compressedImageBytes = img.encodeJpg(resizedImage, quality: 80);
        final compressedFile = File(image.path)..writeAsBytesSync(compressedImageBytes);

        pickedImage = compressedFile;
      }
    }
  }

  Future<void> deleteMedia(int mediaId, int entryId) async {
    final String url = 'https://saraka.kelaskita.site/api/saraka-medias/delete/$mediaId';
    final String apiToken = 'your_api_token';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiToken',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Media deleted successfully');
        await fetchData(entryId);
      } else {
        Get.snackbar('Error', 'Failed to delete media');
      }
    } catch (error) {
      print('Error: $error');
      Get.snackbar('Error', 'Failed to delete media');
    }
  }

  String romanNumeral(int shift) {
    switch (shift) {
      case 1:
        return 'I';
      case 2:
        return 'II';
      case 3:
        return 'III';
      default:
        return '';
    }
  }
}
