import 'package:get/get.dart';
import '../../data/models/assessment_model.dart';
import '../../services/service.dart';

class DetailHistoryController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final assessment = Rx<Assessment?>(null);
  final historyList = <Assessment>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final Assessment? arg = Get.arguments;
    if (arg != null) {
      assessment.value = arg;
      fetchAssessmentHistory(arg.machine.id);
    }
  }

  void fetchAssessmentHistory(String machineId) async {
    try {
      isLoading(true);
      final history = await _apiService.getAssessmentHistoryByMachineId(machineId);
      // Urutkan berdasarkan ID secara descending (terbaru dulu)
      history.sort((a, b) => b.id.compareTo(a.id));
      historyList.assignAll(history);
      // Memastikan assessment yang ditampilkan adalah yang terbaru
      if (historyList.isNotEmpty) {
        assessment.value = historyList.first;
      }
    } catch (e) {
      print('Error fetching assessment history: $e');
      Get.snackbar('Error', 'Failed to fetch assessment history');
    } finally {
      isLoading(false);
    }
  }
}
