import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../utils/app_colors.dart';
import '../../services/service.dart';
import '../../services/user_roles.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white)),
        centerTitle: true,
        backgroundColor: AppColors.primary400,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 30),
            onPressed: () {
              Get.find<AuthService>().logout();
              Get.offAllNamed('/splash-screen');
            },
          ),
        ],
      ),
      body: Obx(() {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary400, Colors.white],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome,',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          Text(
                            controller.name.value?.toUpperCase() ?? "User",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: AppColors.primary400),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your Role: ${controller.role.value.stringValue.toUpperCase()}',
                            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  _buildChartCard(
                      'Downtime Overview', 
                      _buildLineChart(controller.downtimeData), 
                      'downtime'
                    ),
                  SizedBox(height: 24),
                  _buildChartCard(
                    'Machine Status Overview', 
                    _buildPieChart(), 
                    'machine_status'
                  ),
                  _buildMTBFCard(),
                  SizedBox(height: 24),
                  _buildMTTRCard(),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final bool canViewAssessment = controller.canViewAssessment;
        return BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: AppColors.primary400,
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          elevation: 8,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            if (canViewAssessment)
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_suggest),
                label: 'Machinery',
              ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notification_important),
              label: 'Andon System',
            ),
          ],
          onTap: (index) {
            if (index == 0) {
              Get.offAllNamed('/home');
            } else if (index == 1 && canViewAssessment) {
              Get.offAllNamed('/asesment');
            } else if (index == (canViewAssessment ? 2 : 1)) {
              Get.offAllNamed('/andon-home');
            }
          },
        );
      }),
    );
  }

  Widget _buildChartCard(String title, Widget chart, String type) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, 
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: AppColors.primary400
              )
            ),
            SizedBox(height: 16),
            if (type == 'downtime') ...[
              _buildDateFilter(type),
              SizedBox(height: 16),
            ],
            SizedBox(
              height: 300,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilter(String type) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Year',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value: type == 'downtime' 
              ? controller.selectedYearDowntime.value 
              : controller.selectedYearMachineStatus.value,
            items: List.generate(5, (index) {
              final year = DateTime.now().year - 2 + index;
              return DropdownMenuItem(
                value: year,
                child: Text(year.toString()),
              );
            }),
            onChanged: (year) {
              if (year != null) {
                if (type == 'downtime') {
                  controller.updateDowntimePeriod(year, controller.selectedMonthDowntime.value);
                } else {
                  controller.updateMachineStatusPeriod(year, controller.selectedMonthMachineStatus.value);
                }
              }
            },
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Month',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            value: type == 'downtime' 
              ? controller.selectedMonthDowntime.value 
              : controller.selectedMonthMachineStatus.value,
            items: List.generate(12, (index) {
              return DropdownMenuItem(
                value: index + 1,
                child: Text(controller.monthNames[index]),
              );
            }),
            onChanged: (month) {
              if (month != null) {
                if (type == 'downtime') {
                  controller.updateDowntimePeriod(
                    controller.selectedYearDowntime.value, 
                    month
                  );
                } else {
                  controller.updateMachineStatusPeriod(
                    controller.selectedYearMachineStatus.value, 
                    month
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    return Obx(() {
      if (controller.machineStatusData.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      return SfCircularChart(
        legend: Legend(
          isVisible: true,
          position: LegendPosition.bottom,
          orientation: LegendItemOrientation.horizontal,
          overflowMode: LegendItemOverflowMode.wrap,
        ),
        series: <CircularSeries>[
          PieSeries<ChartData, String>(
            dataSource: controller.machineStatusData,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            dataLabelSettings: DataLabelSettings(
              isVisible: false,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            dataLabelMapper: (ChartData data, _) => '${data.x}: ${data.y.toInt()}',
            pointColorMapper: (ChartData data, _) {
              switch (data.x) {
                case 'OK':
                  return Colors.green;
                case 'REPAIRING':
                  return Colors.orange;
                case 'NG':
                  return Colors.red;
                default:
                  return Colors.grey;
              }
            },
          )
        ],
        annotations: <CircularChartAnnotation>[
          CircularChartAnnotation(
            widget: Container(
              child: Text(
                controller.machineStatusData.isEmpty 
                  ? 'No Data'
                  : 'Total: ${controller.machineStatusData
                      .fold(0.0, (sum, item) => sum + item.y)
                      .toInt()}',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLineChart(List<ChartData> data) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey[300]),
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      series: <CartesianSeries>[
        LineSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          markerSettings: MarkerSettings(isVisible: true),
          dataLabelSettings: DataLabelSettings(isVisible: true),
        )
      ],
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  Widget _buildMTTRLineChart() {
    return Obx(() {
      if (controller.mttrData.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }
      return SfCartesianChart(
        primaryXAxis: CategoryAxis(
          majorGridLines: MajorGridLines(width: 0),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        primaryYAxis: NumericAxis(
          majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey[300]),
          labelStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        series: <CartesianSeries>[
          LineSeries<ChartData, String>(
            dataSource: controller.mttrData,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            markerSettings: MarkerSettings(isVisible: true),
            dataLabelSettings: DataLabelSettings(isVisible: true),
          )
        ],
        tooltipBehavior: TooltipBehavior(enable: true),
      );
    });
  }

  Widget _buildMTBFLineChart() {
    return Obx(() {
    if (controller.mtbfData.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey[300]),
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      series: <CartesianSeries>[
        LineSeries<ChartData, String>(
          dataSource: controller.mtbfData,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          markerSettings: MarkerSettings(isVisible: true),
          dataLabelSettings: DataLabelSettings(isVisible: true),
        )
      ],
        tooltipBehavior: TooltipBehavior(enable: true),
      );
    });
  }

  Widget _buildMTBFCard() {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MTBF Overview', 
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: AppColors.primary400
            )
          ),
          SizedBox(height: 16),
          _buildMTBFDateFilter(),
          SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: _buildMTBFLineChart(),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildMTTRCard() {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MTTR Overview', 
            style: TextStyle(
              fontSize: 20, 
              fontWeight: FontWeight.bold, 
              color: AppColors.primary400
            )
          ),
          SizedBox(height: 16),
          _buildMTTRDateFilter(),
          SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: _buildMTTRLineChart(),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildMTTRDateFilter() {
  return Row(
    children: [
      Expanded(
        child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Year',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: controller.selectedYearMTTR.value,
          items: List.generate(5, (index) {
            final year = DateTime.now().year - 2 + index;
            return DropdownMenuItem(
              value: year,
              child: Text(year.toString()),
            );
          }),
          onChanged: (year) {
            if (year != null) {
              controller.updateMTTRPeriod(year, controller.selectedMonthMTTR.value);
            }
          },
        ),
      ),
      SizedBox(width: 16),
      Expanded(
        child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Month',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: controller.selectedMonthMTTR.value,
          items: List.generate(12, (index) {
            return DropdownMenuItem(
              value: index + 1,
              child: Text(controller.monthNames[index]),
            );
          }),
          onChanged: (month) {
            if (month != null) {
              controller.updateMTTRPeriod(controller.selectedYearMTTR.value, month);
            }
          },
        ),
      ),
    ],
    );
  }

  Widget _buildMTBFDateFilter() {
  return Row(
    children: [
      Expanded(
        child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Year',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: controller.selectedYearMTBF.value,
          items: List.generate(5, (index) {
            final year = DateTime.now().year - 2 + index;
            return DropdownMenuItem(
              value: year,
              child: Text(year.toString()),
            );
          }),
          onChanged: (year) {
            if (year != null) {
              controller.updateMTBFPeriod(year, controller.selectedMonthMTBF.value);
            }
          },
        ),
      ),
      SizedBox(width: 16),
      Expanded(
        child: DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Month',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          value: controller.selectedMonthMTBF.value,
          items: List.generate(12, (index) {
            return DropdownMenuItem(
              value: index + 1,
              child: Text(controller.monthNames[index]),
            );
          }),
          onChanged: (month) {
            if (month != null) {
              controller.updateMTBFPeriod(controller.selectedYearMTBF.value, month);
            }
          },
        ),
      ),
    ],
    );
  }
}
