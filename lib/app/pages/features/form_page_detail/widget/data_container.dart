import 'package:flutter/material.dart';

class DataContainer extends StatelessWidget {
  final Map<String, dynamic> data;

  const DataContainer({
    Key? key,
    required this.data, 
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 63, 107, 65),
      ),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
          2: FlexColumnWidth(),
        },
        children: [
          _buildRow('ID', data['id']),
          _buildRow('Shift', data['shift']),
          _buildRow('Product Name', data['product_name']),
          _buildRow('Product Code', data['product_code']),
          _buildRow('Batch Product', data['batch_product']),
          _buildRow('Process Date', data['process_date']),
          _buildRow('Operator', data['operator']),
        ],
      ),
    );
  }

  TableRow _buildRow(String label, dynamic value) {
    return TableRow(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            ' : ${value?.toString() ?? 'Not Available'}',
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
