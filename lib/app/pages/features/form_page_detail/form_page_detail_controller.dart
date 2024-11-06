import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class FormPageDetailController extends GetxController {
  final picker = ImagePicker();
  var tableData = <Map<String, dynamic>>[].obs;
  var pickedImage = Rx<File?>(null);
  var imageTitle = ''.obs;
  var isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  var mediaCount = 1.obs;
  var torchOn = false.obs;
  var currentZoom = 4.0.obs;
  var previousZoom = 1.0.obs;
  var mediaUpdated = false.obs;

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
    final String? id = Get.arguments is int
        ? Get.arguments.toString() // Directly use the integer as a string
        : Get.arguments is Map && Get.arguments['id'] != null
            ? Get.arguments['id'].toString() // Access ID from map
            : null;

    if (id != null) {
      fetchData(id);
    } else {
      print('ID argument not provided or invalid format');
    }
  }

  @override
  void onClose() {
    horizontalScrollControllerHeader.dispose();
    horizontalScrollControllerBody.dispose();
    verticalScrollControllerBody.dispose();
    super.onClose();
  }

  void toggleTorch() {
    torchOn.value = !torchOn.value;
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

  Future<void> fetchData(String id) async {
    try {
      final response = await http.get(Uri.parse(
          'http://192.168.101.65/saraka/android/Data_FilterDetail.php?id=$id'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        tableData.value = data
            .map((item) {
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
            })
            .where((row) =>
                row.values.any((value) => value != null && value != ''))
            .toList();

        if (tableData.isNotEmpty) {
          fetchedItem = tableData.first;
          String bc = fetchedItem!['batch_product'];
          String shift = fetchedItem!['shift'];

          List<Map<String, dynamic>> mediaData =
              await fetchDataMedia(bc, shift);
          for (var media in mediaData) {
            tableData.add({
              'image_title': media['image_title'] ?? 'No title',
              'qrcode': media['qrcode'] ?? 'No QR',
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

  Future<List<Map<String, dynamic>>> fetchDataMedia(
      String bc, String shift) async {
    try {
      final response = await http.get(Uri.parse(
        'http://192.168.101.65/saraka/android/Data_Vw_FileFoto.php?bc=$bc&shift=$shift',
      ));

      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        // Remove any empty rows if present
        List<Map<String, dynamic>> filteredData =
            List<Map<String, dynamic>>.from(
          jsonData.where(
            (item) => item.values.any(
              (value) => value != null && value.toString().isNotEmpty,
            ),
          ),
        );

        // Reverse the list to display the newest data first
        return filteredData.reversed.toList();
      } else {
        throw Exception('Failed to load media data');
      }
    } catch (error) {
      print('Error fetching data: $error');
      return [];
    }
  }

  Future<void> requestPermissions() async {
    // Request camera and storage permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();

    // Check if any permissions were permanently denied
    if (statuses[Permission.camera]!.isPermanentlyDenied ||
        statuses[Permission.storage]!.isPermanentlyDenied) {
      print(
          'Permissions permanently denied. Please enable them in app settings.');
    }
  }

  Future<void> pickImage() async {
    await requestPermissions();
    isLoading.value = true;
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        pickedImage.value = await _processAndUploadImage(image);
        String timestamp = DateFormat('yyyyMMdd').format(DateTime.now());
        String shift = fetchedItem?['shift'] ?? 'UnknownShift';
        String batchProduct = fetchedItem?['batch_product'] ?? 'UnknownBatch';
        imageTitle.value = '$timestamp-$shift-$batchProduct.jpg';
      } else {
        print("No image selected.");
      }
    } catch (e) {
      print("Image picking error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<File?> _processAndUploadImage(XFile imageFile) async {
    try {
      final image = File(imageFile.path);
      final bytes = await image.readAsBytes();
      img.Image? decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) return null;

      img.Image resizedImage = img.copyResize(decodedImage, width: 1024);
      final font = img.arial24;

      num r = 0;
      num g = 0;
      num b = 139;

      String dateTimeString =
          DateFormat('dd MMM yyyy HH:mm:ss').format(DateTime.now());
      String batchProduct = fetchedItem?['batch_product'] ?? 'unknown';
      String operatorText = fetchedItem?['operator'] ?? 'Unknown';
      String shiftText = fetchedItem?['shift'] ?? 'Unknown';
      String productNameText = fetchedItem?['product_name'] ?? 'Unknown';

      img.drawString(
        resizedImage,
        'PT Saraka Mandiri Semesta, $dateTimeString',
        font: font,
        x: 10,
        y: resizedImage.height - 50,
        color: img.ColorFloat32.rgb(r, g, b),
      );

      img.drawString(
        resizedImage,
        'Operator: $operatorText',
        font: font,
        x: 10,
        y: 50,
        color: img.ColorFloat32.rgb(r, g, b),
      );
      img.drawString(
        resizedImage,
        'Shift: $shiftText',
        font: font,
        x: 10,
        y: 100,
        color: img.ColorFloat32.rgb(r, g, b),
      );
      img.drawString(
        resizedImage,
        'Product: ($batchProduct)',
        font: font,
        x: 10,
        y: 150,
        color: img.ColorFloat32.rgb(r, g, b),
      );
      img.drawString(resizedImage, productNameText,
          font: font,
          x: 10 + (productNameText.length * 10),
          y: 150,
          color: img.ColorFloat32.rgb(r, g, b));

      int quality = 90;
      List<int> compressedBytes;
      do {
        compressedBytes = img.encodeJpg(resizedImage, quality: quality);
        quality -= 10;
      } while (compressedBytes.length > 250 * 1024 && quality > 10);

      String formattedDate = DateFormat('yyyyMMdd').format(DateTime.now());
      String fileName =
          '$formattedDate-$shiftText-$batchProduct-${mediaCount.value}.jpg';

      final renamedImage = File('${image.parent.path}/$fileName')
        ..writeAsBytesSync(compressedBytes);
      mediaCount.value++;
      await uploadImageFile(renamedImage, fileName);

      return renamedImage;
    } catch (e) {
      print("Error during image processing: $e");
      return null;
    }
  }

  Future<void> uploadImageFile(File imageFile, String fileName) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.101.65/saraka/upload.php'),
      );
      request.files.add(await http.MultipartFile.fromPath(
          'file', imageFile.path,
          filename: fileName));

      final response = await request.send();
      if (response.statusCode == 200) {
        print('Image uploaded successfully: $fileName');

        await DefaultCacheManager().emptyCache();
        print('Image cache cleared');
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Image upload error: $e");
    }
  }

  Future<void> postMedia(
      {required String id, required String nf, required String bc}) async {
    final String url =
        'http://192.168.101.65/saraka/android/Data_InputBCode.php';
    try {
      final response = await http.post(Uri.parse('$url?id=$id&nf=$nf&bc=$bc'));
      if (response.statusCode == 200) {
        print('$url?id=$id&nf=$nf&bc=$bc');
        print(
            'QR Code and file name posted successfully. Response: ${response.body}');
      } else {
        print('Failed to post media. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  Future<void> deleteMedia({
    required String id,
    required String nf,
  }) async {
    final String url =
        'http://192.168.101.65/saraka/android/Data_HapusFileFoto.php';
    try {
      final response = await http.delete(Uri.parse('$url?id=$id&nf=$nf'));
      if (response.statusCode == 200) {
        print('$url?id=$id&nf=$nf');
        Get.snackbar('Success', 'Deleted');

        mediaUpdated.value = !mediaUpdated.value;
      } else {
        print('failed');
        print(response.body);
      }
    } catch (e) {
      print('error $e');
    }
  }

  String romanNumeral(String shift) {
    switch (shift) {
      case '1':
        return 'I';
      case '2':
        return 'II';
      case '3':
        return 'III';
      default:
        return '';
    }
  }
}
