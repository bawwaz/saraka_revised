import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saraka_revised/app/route/app_pages.dart';

class LoginPageView extends StatelessWidget {
  const LoginPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saraka'),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(),
            TextField(),
            ElevatedButton(
                onPressed: () {
                  Get.offAllNamed(Routes.FORM);
                },
                child: Text('Login'))
          ],
        ),
      ),
    );
  }
}
