import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:saraka_revised/app/route/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPageController extends GetxController {
  var isLoading = false.obs;
  var isPasswordHidden = true.obs;

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    autoLogin();
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
  String url =
      'http://192.168.101.65/saraka/android/Data_Login.php?us=$usernameInput&ps=$passwordInput';

  try {
    final response = await http.get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      var data = response.body;

      if (data == '1') {
        // Successful login
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', usernameInput);

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


  Future<void> autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString('token');

    if (savedToken != null && savedToken.isNotEmpty) {
      Get.offAllNamed(
        Routes.FORM,
      );
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed(Routes.LOGIN);
  }
}
