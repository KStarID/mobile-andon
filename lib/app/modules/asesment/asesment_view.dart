import 'package:flutter/material.dart';

class AsesmentView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asesmen'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('No.')),
            DataColumn(label: Text('Updated Time')),
            DataColumn(label: Text('Area')),
            DataColumn(label: Text('Sub Area')),
            DataColumn(label: Text('SOP Number')),
            DataColumn(label: Text('Model')),
            DataColumn(label: Text('Mesin Code Asset')),
            DataColumn(label: Text('Machine Name')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Details')),
          ],
          rows: List<DataRow>.generate(
            10, // Ganti dengan jumlah baris yang sesuai
            (index) => DataRow(
              cells: [
                DataCell(Text('${index + 1}')),
                DataCell(Text('2023-05-${index + 1} 10:00')),
                DataCell(Text('Area ${index + 1}')),
                DataCell(Text('Sub Area ${index + 1}')),
                DataCell(Text('SOP-${index + 100}')),
                DataCell(Text('Model ${index + 1}')),
                DataCell(Text('MC-${index + 1000}')),
                DataCell(Text('Machine ${index + 1}')),
                DataCell(Text('Active')),
                DataCell(
                  IconButton(
                    icon: Icon(Icons.info_outline),
                    onPressed: () => _showDetailsOverlay(context, index),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailsOverlay(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detail Asesmen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('No: ${index + 1}'),
              Text('Updated Time: 2023-05-${index + 1} 10:00'),
              Text('Area: Area ${index + 1}'),
              Text('Sub Area: Sub Area ${index + 1}'),
              Text('SOP Number: SOP-${index + 100}'),
              Text('Model: Model ${index + 1}'),
              Text('Mesin Code Asset: MC-${index + 1000}'),
              Text('Machine Name: Machine ${index + 1}'),
              Text('Status: Active'),
              // Tambahkan informasi detail lainnya di sini
            ],
          ),
          actions: [
            TextButton(
              child: Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
