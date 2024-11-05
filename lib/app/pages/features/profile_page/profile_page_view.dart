import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:saraka_foto_box/app/style/color.dart';
import 'package:saraka_foto_box/app/style/fonts.dart';
import 'profile_page_controller.dart';

class ProfilePageView extends StatelessWidget {
  const ProfilePageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfilePageController());
    String formatDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final storage = GetStorage();
    final String username = storage.read('username') ?? 'Unknown User';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        backgroundColor: AppColors.primaryColor,
        title: Text(
          'Information',
          style: Fonts.header,
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              readOnly: true,
              decoration: InputDecoration(hintText: 'Tanggal : $formatDate'),
            ),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'User : $username',
              ),
            ),
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
