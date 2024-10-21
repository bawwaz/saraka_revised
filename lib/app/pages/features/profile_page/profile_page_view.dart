import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_page_controller.dart'; // Import your controller

class ProfilePageView extends StatelessWidget {
  const ProfilePageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfilePageController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Me'),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              readOnly: true,
              decoration: InputDecoration(hintText: 'User Information'),
            )
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: ElevatedButton(
            onPressed: () {

              controller.clearTokenAndLogout();
            },
            child: Text("Logout"),
          ),
        ),
      ),
    );
  }
}
