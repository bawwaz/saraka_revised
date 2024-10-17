import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saraka_revised/app/pages/initial_pages/login/login_page_controller.dart';
import 'package:saraka_revised/app/route/app_pages.dart';

class LoginPageView extends StatelessWidget {
  const LoginPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginPageController controller = Get.put(LoginPageController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Saraka'),
      ),
      body: Obx(() {
        return Container(
          margin: EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: controller.usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              Obx(() => TextField(
                    controller: controller.passwordController,
                    obscureText: controller.isPasswordHidden.value,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.isPasswordHidden.value
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          controller.togglePasswordVisibility();
                        },
                      ),
                    ),
                  )),
              SizedBox(height: 20),
              controller.isLoading.value
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        controller.login();
                      },
                      child: Text('Login'),
                    ),
            ],
          ),
        );
      }),
    );
  }
}
