import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../data/models/alat_model.dart';
import '../../../data/models/company_model.dart';
import '../../../data/services/alat_service.dart';
import '../../../data/services/company_service.dart';

class DetailDataController extends GetxController {
  var traps = <AlatModel>[].obs;
  var selectedMonth = 0.obs;
  var currentCompany = Rxn<CompanyModel>();
  var companyName = 'Loading...'.obs;
  var isLoading = false.obs;

  final CompanyService _companyService = CompanyService();

  @override
  void onInit() {
    super.onInit();
    loadCompanyData();
    fetchData();
  }

  // Load company data berdasarkan client_id
  Future<void> loadCompanyData() async {
    try {
      isLoading.value = true;

      final company = await _companyService.getCompanyByClientId();

      if (company != null) {
        currentCompany.value = company;
        companyName.value = company.name;
      } else {
        companyName.value = 'No Company Found';
        Get.snackbar(
            "Error",
            "No company data found for this user",
            snackPosition: SnackPosition.TOP
        );
      }
    } catch (e) {
      companyName.value = 'Error Loading';
      Get.snackbar(
          "Error",
          "Failed to load company data: ${e.toString()}",
          snackPosition: SnackPosition.TOP
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchData() async {
    try {
      traps.value = await AlatService.fetchAlat();
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  // Refresh semua data
  Future<void> refreshData() async {
    await Future.wait([
      loadCompanyData(),
      fetchData(),
    ]);
  }

  void changeDate(DateTime date) {
    // Implementasi perubahan tanggal
    print("Tanggal berubah ke: ${date.toString()}");
  }

  void updateNote(int index, String value) {}

  List<FlSpot> getChartData(String title) {
    // Dummy chart data
    return [
      FlSpot(1, 10),
      FlSpot(2, 15),
      FlSpot(3, 7),
      FlSpot(4, 12),
    ];
  }
}