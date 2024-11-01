import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:saraka_foto_box/app/route/app_pages.dart';

class LoginPageController extends GetxController {
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final storage = GetStorage(); // Initialize GetStorage

  @override
  void onInit() {
    super.onInit();
    // Removed autoLogin() to ensure the user must always log in
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login(String usernameInput, String passwordInput) async {
    if (usernameInput.isEmpty || passwordInput.isEmpty) {
      Get.snackbar('Error', 'Please enter both username and password.');
      return;
    }

    isLoading.value = true;

    // Construct the URL with query parameters for username and password
    String url = 'http://192.168.101.65/saraka/android/Data_Login.php?us=$usernameInput&ps=$passwordInput';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = response.body;

        if (data == '1') {
          // Successful login
          storage.write('username', usernameInput); // Save username to GetStorage

          Get.snackbar('Success', 'Login successful');
          Get.offAllNamed(Routes.FORM, arguments: {
            'username': usernameInput,
          });
        } else if (data == '2') {
          // Invalid credentials
          Get.snackbar('Error', 'Invalid username or password');
        } else {
          // Unexpected response
          Get.snackbar('Error', 'Unexpected response from the server');
        }
      } else {
        Get.snackbar('Error', 'Server error: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to connect to the server');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await storage.erase();
    Get.offAllNamed(Routes.LOGIN);
  }
}
