import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'asesment_controller.dart';

class AsesmentView extends GetView<AsesmentController> {
  const AsesmentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Implementasi logika logout di sini
              Get.offAllNamed('/splash-screen');
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.delayed(Duration(seconds: 1)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }
          return Column(
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
                        label: const Text('Shift'),
                        onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                      ),
                      DataColumn(
                        label: const Text('Updated Time'),
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
                        label: const Text('SOP Number'),
                        onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                      ),
                      DataColumn(
                        label: const Text('Models'),
                        onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                      ),
                      DataColumn(
                        label: const Text('Code Asset'),
                        onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                      ),
                      DataColumn(
                        label: const Text('Machine Name'),
                        onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                      ),
                      DataColumn(
                        label: const Text('Status'),
                        onSort: (columnIndex, ascending) => controller.sort(columnIndex, ascending),
                      ),
                      const DataColumn(label: Text('Details')),
                    ],
                    rows: controller.filteredAssessments.map((assessment) => DataRow(
                      cells: [
                        DataCell(Text(assessment.no.toString())),
                        DataCell(Text(assessment.shift)),
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
                            onPressed: () {
                            Get.toNamed('/detail-history');
                            },
                          ),
                        ),
                      ],
                    )).toList(),
                  )),
                ),
              ),
            ],
          );
        },
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
            label: 'Assesmen',
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
  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Filter'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                child: Text('Filter by Date'),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDate.value ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null) {
                    controller.filterByDate(picked);
                  }
                },
              ),
              ElevatedButton(
                child: Text('Filter by Month'),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedMonth.value ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null) {
                    controller.filterByMonth(DateTime(picked.year, picked.month));
                  }
                },
              ),
              ElevatedButton(
                child: Text('Filter by Year'),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedYear.value ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null) {
                    controller.filterByYear(DateTime(picked.year));
                  }
                },
              ),
              ElevatedButton(
                child: Text('Clear Filters'),
                onPressed: () {
                  controller.filterByDate(null);
                  controller.filterByMonth(null);
                  controller.filterByYear(null);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
