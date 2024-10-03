import 'package:get/get.dart';
import '../../data/models/assessment_model.dart';
import '../../data/models/history_model.dart';

class DetailHistoryController extends GetxController {
  final assessment = Assessment(
    no: 0,
    shift: '',
    updatedTime: '',
    area: '',
    subArea: '',
    sopNumber: '',
    model: '',
    machineCodeAsset: '',
    machineName: '',
    status: '',
    details: '',
  ).obs;
  final historyList = <History>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Ambil data asesmen dan riwayat dari argumen atau API
    fetchAssessmentDetails();
  }

  void fetchAssessmentDetails() async {
    try {
      isLoading(true);
      // Simulasi pengambilan data dari API
      await Future.delayed(Duration(seconds: 2));
      
      // Ganti ini dengan pemanggilan API atau pengambilan data sebenarnya
      assessment.value = Assessment(
        no: 1,
        shift: 'Day',
        area: 'Area A',
        subArea: 'Sub Area 1',
        sopNumber: 'SOP-001',
        model: 'Model X',
        updatedTime: DateTime.now().toString(),
        machineCodeAsset: 'MC001',
        machineName: 'Machine 1',
        status: 'Active',
        details: 'Some details about the assessment',
      );

      historyList.assignAll([
        History(
          submittedBy: 'John Doe',
          updatedTime: '2023-05-20 10:00',
          subArea: 'Sub Area 1',
          status: 'In Progress',
          remark: 'Initial assessment',
        ),
        History(
          submittedBy: 'Jane Smith',
          updatedTime: '2023-05-21 14:30',
          subArea: 'Sub Area 1',
          status: 'Completed',
          remark: 'Assessment completed',
        ),
      ]);
    } finally {
      isLoading(false);
    }
  }
}
