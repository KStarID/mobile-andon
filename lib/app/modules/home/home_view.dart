import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Implementasi logika logout di sini
              // Contoh: Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildChartCard('Downtime/OK', _buildPieChart(), controller.downtimeMonth),
              const SizedBox(height: 16),
              _buildChartCard('Machine Status', _buildBarChart(), controller.machineStatusMonth),
              const SizedBox(height: 16),
              _buildChartCard('MTBF', _buildLineChart(controller.getMTBFData()), controller.mtbfMonth),
              const SizedBox(height: 16),
              _buildChartCard('MTTR', _buildLineChart(controller.getMTTRData()), controller.mttrMonth),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Indeks untuk halaman home
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
          if (index == 1) {
            // Navigasi ke halaman asesmen
            Get.offAllNamed('/asesment');
          }
        },
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart, Rx<DateTime> month) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                _buildMonthPicker(month, title),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: chart),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthPicker(Rx<DateTime> month, String chartType) {
    return Obx(() => ElevatedButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: Get.context!,
              initialDate: month.value,
              firstDate: DateTime(2000),
              lastDate: DateTime(2025),
              initialDatePickerMode: DatePickerMode.year,
            );
            if (picked != null) {
              final newMonth = DateTime(picked.year, picked.month);
              switch (chartType) {
                case 'Downtime/OK':
                  controller.updateDowntimeMonth(newMonth);
                  break;
                case 'Machine Status':
                  controller.updateMachineStatusMonth(newMonth);
                  break;
                case 'MTBF':
                  controller.updateMTBFMonth(newMonth);
                  break;
                case 'MTTR':
                  controller.updateMTTRMonth(newMonth);
                  break;
              }
            }
          },
          child: Text('${month.value.month}/${month.value.year}'),
        ));
  }

  Widget _buildPieChart() {
    return SfCircularChart(
      series: <CircularSeries>[
        PieSeries<ChartData, String>(
          dataSource: controller.getDowntimeData(),
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
        )
      ],
    );
  }

  Widget _buildBarChart() {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      series: <CartesianSeries>[
        ColumnSeries<ChartData, String>(
          dataSource: controller.getMachineStatusData(),
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
        )
      ],
    );
  }

  Widget _buildLineChart(List<ChartData> data) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      series: <CartesianSeries>[
        LineSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
        )
      ],
    );
  }
}
