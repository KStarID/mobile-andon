import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/assessment_model.dart';
import 'asesment_controller.dart';

class AsesmentView extends GetView<AsesmentController> {
  const AsesmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asesmen'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Implementasi logika logout di sini
              Get.offAllNamed('/login-page');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: controller.search,
              decoration: InputDecoration(
                labelText: 'Cari',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => DataTable(
                sortColumnIndex: controller.sortColumnIndex.value,
                sortAscending: controller.isAscending.value,
                columns: [
                  DataColumn(
                    label: const Text('No.'),
                    onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Waktu Update'),
                    onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Area'),
                    onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Sub Area'),
                    onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Nomor SOP'),
                    onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Model'),
                    onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Kode Aset Mesin'),
                    onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Nama Mesin'),
                    onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                  ),
                  DataColumn(
                    label: const Text('Status'),
                    onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                  ),
                  const DataColumn(label: Text('Detail')),
                ],
                rows: controller.filteredAssessments.map((assessment) => DataRow(
                  cells: [
                    DataCell(Text(assessment.no.toString())),
                    DataCell(Text(assessment.updatedTime)),
                    DataCell(Text(assessment.area)),
                    DataCell(Text(assessment.subArea)),
                    DataCell(Text(assessment.sopNumber)),
                    DataCell(Text(assessment.model)),
                    DataCell(Text(assessment.machineCodeAsset)),
                    DataCell(Text(assessment.machineName)),
                    DataCell(Text(assessment.status)),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => _showDetailsOverlay(context, assessment),
                      ),
                    ),
                  ],
                )).toList(),
              )),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add-ases',
            onPressed: () => Get.toNamed('/add-ases'),
          child: const Icon(Icons.add),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'qr-scanner',
          onPressed: () => Get.toNamed('/qr-scan'),
          child: const Icon(Icons.qr_code_scanner),
          ),
        ],
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Asesmen',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Get.offAllNamed('/home');
          }
        },
      ),
    );
  }

  void _showDetailsOverlay(BuildContext context, Assessment assessment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Detail Asesmen'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No: ${assessment.no}'),
                Text('Waktu Update: ${assessment.updatedTime}'),
                Text('Area: ${assessment.area}'),
                Text('Sub Area: ${assessment.subArea}'),
                Text('Nomor SOP: ${assessment.sopNumber}'),
                Text('Model: ${assessment.model}'),
                Text('Kode Aset Mesin: ${assessment.machineCodeAsset}'),
                Text('Nama Mesin: ${assessment.machineName}'),
                Text('Status: ${assessment.status}'),
                Text('Detail: ${assessment.details}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Tutup'),
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
