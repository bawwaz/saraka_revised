import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:saraka_revised/app/api/api_endpoint.dart';

class FormPageDetailController extends GetxController {
  final picker = ImagePicker();
  var tableData = <Map<String, dynamic>>[].obs;
  File? pickedImage;

  var scannedQR = ''.obs;

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

        // Print entire data response for debugging
        print('Fetched Data: $data');

        tableData.value = data['media'].map<Map<String, dynamic>>((media) {
          print('Image Title: ${media['image_title'] ?? 'No Title'}');
          print('Image Size: ${media['size'] ?? 'Unknown Size'}');

          return {
            'id': media['id'],
            'image': media['image'],
            'image_title': media['image_title'],
            'qr': media['qrcode'],
            'size': media['size'],
          };
        }).toList();
        return data;
      } else {
        throw Exception('Failed to load details');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<void> uploadMedia(int sarakaEntryId, File image, String qrCode,
      String customFileName) async {
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

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      final imageFile = File(image.path);
      final bytes = await imageFile.readAsBytes();

      img.Image? decodedImage = img.decodeImage(bytes);

      if (decodedImage != null) {
        img.Image resizedImage = img.copyResize(decodedImage, width: 1024);

        final compressedImageBytes = img.encodeJpg(resizedImage, quality: 80);

        final compressedFile = File(image.path)
          ..writeAsBytesSync(compressedImageBytes);

        pickedImage = compressedFile;
      }
    }
  }

  Future<void> deleteMedia(int mediaId, int entryId) async {
    // final String url = ApiEndpoint.MediaBaseUrl;
    final String url =
        'https://saraka.kelaskita.site/api/saraka-medias/delete/$mediaId';
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
}
