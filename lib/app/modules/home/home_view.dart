import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../utils/app_colors.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.primary100,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Get.offAllNamed('/splash-screen');
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.delayed(Duration(seconds: 2)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            );
          }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hello, ${controller.username.value ?? "User"}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                  ),
                ),
                const SizedBox(height: 16),
                _buildChartCard('Downtime/OK', _buildLineChart(controller.getDowntimeData()), controller.downtimeMonth),
                const SizedBox(height: 16),
                _buildChartCard('Machine Status', _buildPieChart(), controller.machineStatusMonth),
                const SizedBox(height: 16),
                _buildChartCard('MTBF', _buildLineChart(controller.getMTBFData()), controller.mtbfMonth),
                const SizedBox(height: 16),
                _buildChartCard('MTTR', _buildLineChart(controller.getMTTRData()), controller.mttrMonth),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: AppColors.primary400,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Assessment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_important),
            label: 'Andon System',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Get.offAllNamed('/home');
          } else if (index == 1) {
            Get.offAllNamed('/asesment');
          } else if (index == 2) {
            Get.offAllNamed('/andon-home');
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
          dataSource: controller.getMachineStatusData(),
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelPosition: ChartDataLabelPosition.outside,
            textStyle: TextStyle(fontSize: 20),
          ),
          dataLabelMapper: (ChartData data, _) => '${data.x}: ${data.y}%',
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
