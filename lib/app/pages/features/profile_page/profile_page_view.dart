import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saraka_revised/app/pages/features/profile_page/profile_page_controller.dart';

class ProfilePageView extends StatelessWidget {
  const ProfilePageView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller using Get.put()
    final ProfilePageController controller = Get.put(ProfilePageController());

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
              // Call the logout method on button press
              controller.logout();
            },
            child: Text("Logout"),
          ),
        ),
      ),
    );
  }
}
