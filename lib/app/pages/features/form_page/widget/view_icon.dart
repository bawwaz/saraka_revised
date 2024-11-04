import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saraka_foto_box/app/route/app_pages.dart';

class ViewIcon extends StatelessWidget {
  final Map<String, dynamic> row; // Add a row parameter

  const ViewIcon({super.key, required this.row}); // Accept row in the constructor

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.visibility),
      onPressed: () {
        String id = row['id'].toString();
        print("ID: $id");
        Get.toNamed(Routes.FORMDETAIL, arguments: {'id': id});
      },
    );
  }
}
