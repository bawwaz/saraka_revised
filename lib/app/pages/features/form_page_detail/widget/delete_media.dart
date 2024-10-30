import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saraka_revised/app/pages/features/form_page_detail/form_page_detail_controller.dart';

class DeleteMedia extends StatelessWidget {
  final FormPageDetailController formDetailController;
  final Map<String, dynamic> row;

  const DeleteMedia({
    super.key,
    required this.formDetailController,
    required this.row,
  });

  @override
  Widget build(BuildContext context) {
    // Add mediaCount and fileNumber here
    int mediaCount = formDetailController.tableData.length + 1;
    String fileNumber = mediaCount.toString();

    return IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete item?'),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('No'),
                    ),
                    Container(
                      height: 60,
                      width: 100,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 137, 53, 53),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            formDetailController.deleteMedia(
                              id: formDetailController.fetchedItem?['id'],
                              nf: fileNumber,
                            );
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
