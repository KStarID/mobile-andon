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
                  _buildDowntimeCard(),
                  SizedBox(height: 24),
                  _buildMachinePieCard(),
                  SizedBox(height: 24),
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

  Widget _buildDateFilter(String type) {
    bool isMonthlyView;
    Function toggleViewMode;
    
    switch (type) {
      case 'mttr':
        isMonthlyView = controller.isMTTRMonthlyView.value;
        toggleViewMode = controller.toggleMTTRViewMode;
        break;
      case 'mtbf':
        isMonthlyView = controller.isMTBFMonthlyView.value;
        toggleViewMode = controller.toggleMTBFViewMode;
        break;
      case 'downtime':
        isMonthlyView = controller.isDowntimeMonthlyView.value;
        toggleViewMode = controller.toggleDowntimeViewMode;
        break;
      default:
        isMonthlyView = true;
        toggleViewMode = () {};
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Year',
                    labelStyle: TextStyle(color: AppColors.primary400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary400),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary400),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.primary400, width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: _getSelectedYear(type),
                  items: List.generate(5, (index) {
                    final year = DateTime.now().year - 2 + index;
                    return DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }),
                  onChanged: (year) {
                    if (year != null) {
                      _updatePeriod(type, year, _getSelectedMonth(type));
                    }
                  },
                ),
              ),
              SizedBox(width: 16),
              if (isMonthlyView)
                Expanded(
                  child: DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Month',
                      labelStyle: TextStyle(color: AppColors.primary400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primary400),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primary400),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primary400, width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    value: _getSelectedMonth(type),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(controller.monthNames[index]),
                      );
                    }),
                    onChanged: (month) {
                      if (month != null) {
                        _updatePeriod(type, _getSelectedYear(type), month);
                      }
                    },
                  ),
                ),
            ],
          ),
          SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => toggleViewMode(),
            icon: Icon(
              isMonthlyView ? Icons.calendar_month : Icons.calendar_today,
              color: Colors.white,
            ),
            label: Text(
              isMonthlyView ? 'Switch to Yearly View' : 'Switch to Monthly View',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary400,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getSelectedYear(String type) {
    switch (type) {
      case 'mttr':
        return controller.selectedYearMTTR.value;
      case 'mtbf':
        return controller.selectedYearMTBF.value;
      case 'downtime':
        return controller.selectedYearDowntime.value;
      default:
        return DateTime.now().year;
    }
  }

  int _getSelectedMonth(String type) {
    switch (type) {
      case 'mttr':
        return controller.selectedMonthMTTR.value;
      case 'mtbf':
        return controller.selectedMonthMTBF.value;
      case 'downtime':
        return controller.selectedMonthDowntime.value;
      default:
        return DateTime.now().month;
    }
  }

  void _updatePeriod(String type, int year, int month) {
    switch (type) {
      case 'mttr':
        controller.updateMTTRPeriod(year, month);
        break;
      case 'mtbf':
        controller.updateMTBFPeriod(year, month);
        break;
      case 'downtime':
        controller.updateDowntimePeriod(year, month);
        break;
    }
  }

  Widget _buildMetricCard(String title, List<ChartData> data, double? target, Widget filterWidget) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary400,
              ),
            ),
            SizedBox(height: 16),
            filterWidget,
            SizedBox(height: 16),
            Container(
              height: 300,
              child: data.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary400),
                          SizedBox(height: 16),
                          Text('Loading data...'),
                        ],
                      ),
                    )
                  : _buildLineChart(data, targetValue: target),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMachinePieCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Machine Status Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary400,
              ),
            ),
            SizedBox(height: 16),
            Obx(() {
              if (controller.machineStatusData.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.primary400),
                      SizedBox(height: 16),
                      Text('Loading machine status data...'),
                    ],
                  ),
                );
              }

              final total = controller.machineStatusData
                  .fold(0.0, (sum, item) => sum + item.y);

              return Column(
                children: [
                  Container(
                    height: 300,
                    child: SfCircularChart(
                      palette: [
                        Colors.green.shade400,
                        Colors.orange.shade400,
                        Colors.red.shade400,
                      ],
                      legend: Legend(
                        isVisible: true,
                        position: LegendPosition.bottom,
                        orientation: LegendItemOrientation.horizontal,
                        overflowMode: LegendItemOverflowMode.wrap,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      series: <CircularSeries>[
                        DoughnutSeries<ChartData, String>(
                          dataSource: controller.machineStatusData,
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          radius: '80%',
                          innerRadius: '60%',
                          enableTooltip: true,
                          dataLabelSettings: DataLabelSettings(
                            isVisible: true,
                            labelPosition: ChartDataLabelPosition.outside,
                            textStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            connectorLineSettings: ConnectorLineSettings(
                              type: ConnectorType.curve,
                              length: '20%',
                            ),
                            builder: (dynamic data, dynamic point, dynamic series,
                                int pointIndex, int seriesIndex) {
                              final percentage =
                                  ((point.y / total) * 100).toStringAsFixed(1);
                              return Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 2,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${point.x}: ${percentage}%',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      annotations: <CircularChartAnnotation>[
                        CircularChartAnnotation(
                          widget: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                total.toInt().toString(),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary400,
                                ),
                              ),
                              Text(
                                'Machines',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Status Summary Cards
                  Row(
                    children: controller.machineStatusData.map((data) {
                      final percentage =
                          ((data.y / total) * 100).toStringAsFixed(1);
                      Color statusColor;
                      switch (data.x) {
                        case 'OK':
                          statusColor = Colors.green.shade400;
                          break;
                        case 'REPAIRING':
                          statusColor = Colors.orange.shade400;
                          break;
                        case 'NG':
                          statusColor = Colors.red.shade400;
                          break;
                        default:
                          statusColor = Colors.grey;
                      }

                      return Expanded(
                        child: Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    _getStatusIcon(data.x),
                                    color: statusColor,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  data.x,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${data.y.toInt()} (${percentage}%)',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'OK':
        return Icons.check_circle_outline;
      case 'REPAIRING':
        return Icons.build_outlined;
      case 'NG':
        return Icons.error_outline;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildLineChart(List<ChartData> data, {double? targetValue}) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        majorGridLines: MajorGridLines(width: 0),
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
        labelRotation: 45,
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey[300]),
        labelStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      series: <CartesianSeries>[
        LineSeries<ChartData, String>(
          name: 'Actual',
          dataSource: data,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          markerSettings: MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
            borderWidth: 2,
            borderColor: AppColors.primary400,
          ),
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.top,
          ),
          color: AppColors.primary400,
        ),
        if (targetValue != null)
          LineSeries<ChartData, String>(
            name: 'Target',
            dataSource: data,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => targetValue,
            color: Colors.red,
            dashArray: <double>[5, 5],
            markerSettings: MarkerSettings(isVisible: false),
            dataLabelSettings: DataLabelSettings(
              isVisible: true,
              labelPosition: ChartDataLabelPosition.outside,
              textStyle: TextStyle(color: Colors.red),
            ),
          ),
      ],
      tooltipBehavior: TooltipBehavior(
        enable: true,
        format: 'point.x : point.y',
        color: AppColors.primary400,
      ),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: TextStyle(fontWeight: FontWeight.bold),
      ),
      plotAreaBorderWidth: 0,
      borderWidth: 0,
    );
  }

  Widget _buildMTTRCard() {
    return _buildMetricCard(
      'MTTR Overview',
      controller.mttrData,
      controller.mttrTarget.value,
      _buildDateFilter('mttr'),
    );
  }

  Widget _buildMTBFCard() {
    return _buildMetricCard(
      'MTBF Overview',
      controller.mtbfData,
      controller.mtbfTarget.value,
      _buildDateFilter('mtbf'),
    );
  }

  Widget _buildDowntimeCard() {
    return _buildMetricCard(
      'Downtime Overview',
      controller.downtimeData,
      controller.downtimeTarget.value,
      _buildDateFilter('downtime'),
    );
  }
}
