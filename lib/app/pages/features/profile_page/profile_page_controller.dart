import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:saraka_foto_box/app/route/app_pages.dart';
import 'dart:convert';

class ProfilePageController extends GetxController {
  final storage = GetStorage();

  Future<void> logout() async {
    try {
      String? token = storage.read('token');

      if (token != null) {
        var response = await http.post(
          Uri.parse('https://saraka.kelaskita.site/api/saraka-auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.body);
          print("Logout successful: $jsonResponse");
          await storage.erase(); // Clear all data
          Get.offAllNamed(Routes.LOGIN);
        } else {
          print("Failed to logout: ${response.statusCode}");
        }
      }
    } catch (e) {
      print("Error occurred during logout: $e");
    }
  }

  Future<void> clearTokenAndLogout() async {
    await storage.erase(); // Clear all data
    Get.offAllNamed(Routes.LOGIN);
  }
}
