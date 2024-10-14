import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class FormPageDetailView extends StatefulWidget {
  const FormPageDetailView({super.key});

  @override
  _FormPageDetailViewState createState() => _FormPageDetailViewState();
}

class _FormPageDetailViewState extends State<FormPageDetailView> {
  final List<Map<String, dynamic>> _tableData = [];
  final ImagePicker _picker = ImagePicker();
  File? _pickedImage;

  Future<Map<String, dynamic>> fetchData(int id) async {
    final String url = 'http://localhost:8000/api/saraka-entries/get/$id';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load details');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server');
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
        _tableData.add({
          'image': _pickedImage,
          'qr': '',
        });
      });
    }
  }

  Future<void> _scanQR(int index) async {
    String qrResult = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan QR Code'),
        content: SizedBox(
          width: 300,
          height: 300,
          child: MobileScanner(
            onDetect: (BarcodeCapture barcodeCapture) {
              if (barcodeCapture.barcodes.isNotEmpty) {
                qrResult = barcodeCapture.barcodes.first.rawValue ?? '';
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      ),
    );

    setState(() {
      _tableData[index]['qr'] = qrResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int id = Get.arguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchData(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            var data = snapshot.data!;
            final TextEditingController operatorController =
                TextEditingController(text: data['operator']);
            final TextEditingController kodeProdukController =
                TextEditingController(text: data['product_code']);
            final TextEditingController namaProdukController =
                TextEditingController(text: data['product_name']);
            final TextEditingController batchController =
                TextEditingController(text: data['batch_product']);
            final TextEditingController shiftController =
                TextEditingController(text: data['shift']);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form fields (read-only)
                  _buildTextField('Operator', operatorController),
                  _buildTextField('Kode Produk', kodeProdukController),
                  _buildTextField('Nama Produk', namaProdukController),
                  _buildTextField('Batch', batchController),
                  _buildTextField('Shift', shiftController),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _tableData.add({
                          'image': null,
                          'qr': '',
                        });
                      });
                    },
                    child: const Text('Tambah'),
                  ),

                  _buildTable(),
                ],
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  // Build each row for the table
  Widget _buildTable() {
    return Column(
      children: _tableData.map((row) {
        int index = _tableData.indexOf(row);
        return Row(
          children: [
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: _pickImage,
            ),
            row['image'] != null
                ? Image.file(
                    row['image'],
                    width: 50,
                    height: 50,
                  )
                : const SizedBox(width: 50, height: 50),

            // QR scan button
            IconButton(
              icon: const Icon(Icons.qr_code),
              onPressed: () => _scanQR(index),
            ),
            Text(row['qr'].toString()),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          readOnly: true,
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
