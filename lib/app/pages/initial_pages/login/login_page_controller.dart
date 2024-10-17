import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:saraka_revised/app/route/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPageController extends GetxController {
  var isLoading = false.obs; // Observable for loading state
  var isPasswordHidden = true.obs; // Observable for password visibility

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    autoLogin(); // Auto login if token exists
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Method to handle login
  Future<void> login() async {
    String url = 'https://saraka.kelaskita.site/api/saraka-auth/login';
    String usernameInput = usernameController.text;
    String password = passwordController.text;

    if (usernameInput.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please enter both username and password.');
      return;
    }

    isLoading.value = true;

    Map<String, String> body = {
      'username': usernameInput,
      'password': password,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        String token = data['token'];
        int userId = data['user']['id'];
        String username = data['user']['username'];

        // Save token and user data using SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setInt('userId', userId);
        await prefs.setString('username', username);

        Get.snackbar('Success', 'Login successful');
        Get.offAllNamed(Routes.FORM); // Navigate to the main form screen
      } else {
        Get.snackbar('Error', 'Invalid username or password');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to connect to the server');
    } finally {
      isLoading.value = false;
    }
  }

  // Auto login if token exists
  Future<void> autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString('token');

    if (savedToken != null && savedToken.isNotEmpty) {
      // Token exists, navigate to the main form page
      Get.offAllNamed(Routes.FORM);
    }
  }

  // Logout method to clear token and navigate back to the login page
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear stored token and user data
    Get.offAllNamed(Routes.LOGIN); // Navigate back to login screen
  }
}
