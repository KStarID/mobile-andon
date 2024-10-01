import 'package:get/get.dart';

class HomeController extends GetxController {
  final downtimeMonth = DateTime.now().obs;
  final machineStatusMonth = DateTime.now().obs;
  final mtbfMonth = DateTime.now().obs;
  final mttrMonth = DateTime.now().obs;

  List<ChartData> getDowntimeData() {
    // Implementasi logika untuk mendapatkan data downtime/ok
    return [
      ChartData('OK', 70),
      ChartData('Downtime', 30),
    ];
  }

  List<ChartData> getMachineStatusData() {
    // Implementasi logika untuk mendapatkan data status mesin
    return [
      ChartData('M1', 8),
      ChartData('M2', 10),
      ChartData('M3', 14),
      ChartData('M4', 15),
      ChartData('M5', 13),
    ];
  }

  List<ChartData> getMTBFData() {
    // Implementasi logika untuk mendapatkan data MTBF
    return [
      ChartData('Day 1', 3),
      ChartData('Day 2', 1.5),
      ChartData('Day 3', 4),
      ChartData('Day 4', 3),
      ChartData('Day 5', 5),
    ];
  }

  List<ChartData> getMTTRData() {
    // Implementasi logika untuk mendapatkan data MTTR
    return [
      ChartData('Day 1', 1),
      ChartData('Day 2', 2),
      ChartData('Day 3', 1.5),
      ChartData('Day 4', 3),
      ChartData('Day 5', 2.5),
    ];
  }

  void updateDowntimeMonth(DateTime newMonth) {
    downtimeMonth.value = newMonth;
    // Perbarui data downtime berdasarkan bulan baru
  }

  void updateMachineStatusMonth(DateTime newMonth) {
    machineStatusMonth.value = newMonth;
    // Perbarui data status mesin berdasarkan bulan baru
  }

  void updateMTBFMonth(DateTime newMonth) {
    mtbfMonth.value = newMonth;
    // Perbarui data MTBF berdasarkan bulan baru
  }

  void updateMTTRMonth(DateTime newMonth) {
    mttrMonth.value = newMonth;
    // Perbarui data MTTR berdasarkan bulan baru
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}
