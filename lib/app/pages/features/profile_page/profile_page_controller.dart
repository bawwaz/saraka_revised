import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:saraka_revised/app/route/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfilePageController extends GetxController {
  Future<void> logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

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
          await prefs.clear();
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
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.remove('token');
    await prefs.remove('username');
    Get.offAllNamed('/login');
  }
}
