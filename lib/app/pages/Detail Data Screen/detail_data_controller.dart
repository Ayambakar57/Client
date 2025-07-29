import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/alat_model.dart';
import '../../../data/models/company_model.dart';
import '../../../data/models/chart_model.dart';
import '../../../data/services/alat_service.dart';
import '../../../data/services/company_service.dart';
import '../../../data/services/chart_service.dart';
import '../Login screen/login_controller.dart';

class DetailDataController extends GetxController {
  var traps = <AlatModel>[].obs;
  var selectedMonth = 0.obs;
  var currentCompany = Rxn<CompanyModel>();
  var isLoading = false.obs;
  var isLoadingChart = false.obs;

  // Chart data
  var landChartData = <FlSpot>[].obs;
  var flyChartData = <FlSpot>[].obs;

  // Date range
  var startDate = DateTime.now().obs;
  var endDate = DateTime.now().obs;

  // Company data
  var companyId = 0.obs;
  var companyName = 'Loading...'.obs;
  var companyAddress = ''.obs;
  var companyPhoneNumber = ''.obs;
  var companyEmail = ''.obs;
  var companyImagePath = ''.obs;
  var companyCreatedAt = ''.obs;
  var companyUpdatedAt = ''.obs;

  final CompanyService _companyService = CompanyService();

  @override
  void onInit() {
    super.onInit();

    // Set default date range (current month)
    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, 1);
    endDate.value = DateTime(now.year, now.month + 1, 0);

    // Load company data and then fetch tools
    loadCompanyData().then((_) {
      if (companyId.value > 0) {
        fetchData();
      } else {
        Get.snackbar("Error", "Cannot fetch tools: No valid company ID",
            snackPosition: SnackPosition.TOP);
      }
    });
  }

  // Load company data berdasarkan client_id
  Future<void> loadCompanyData() async {
    try {
      isLoading.value = true;

      // PERBAIKAN: Gunakan LoginController.getClientId() langsung
      final clientId = await LoginController.getClientId();
      if (clientId == null) {
        throw Exception('Client ID not found in SharedPreferences. Please login again.');
      }

      print('Client ID: $clientId'); // Debug log

      final company = await _companyService.getCompanyByClientId();

      if (company != null) {
        currentCompany.value = company;
        companyId.value = company.id;
        companyName.value = company.name;
        companyAddress.value = company.address ?? '';
        companyPhoneNumber.value = company.phoneNumber ?? '';
        companyEmail.value = company.email ?? '';
        companyImagePath.value = company.imagePath ?? '';
        companyCreatedAt.value = company.createdAt ?? '';
        companyUpdatedAt.value = company.updatedAt ?? '';

        // Save company ID to SharedPreferences
        await _saveCompanyIdToPrefs(company.id);
        print('Loaded company ID: ${company.id}'); // Debug log
      } else {
        throw Exception('No company found for client ID: $clientId');
      }
    } catch (e) {
      companyName.value = 'Error Loading';
      companyId.value = 0;
      Get.snackbar(
        "Error",
        "Failed to load company data: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
      );
      print('Error in loadCompanyData: $e'); // Debug log
    } finally {
      isLoading.value = false;
    }
  }

  // Simpan company ID ke SharedPreferences
  Future<void> _saveCompanyIdToPrefs(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('company_id', id);
    } catch (e) {
      print('Error saving company ID to SharedPreferences: $e');
    }
  }

  // Get company ID dari SharedPreferences
  Future<int?> getCompanyIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('company_id');
    } catch (e) {
      print('Error getting company ID from SharedPreferences: $e');
      return null;
    }
  }

  Future<void> fetchData() async {
    try {
      if (companyId.value <= 0) {
        Get.snackbar("Error", "Invalid company ID. Please try again.",
            snackPosition: SnackPosition.TOP);
        traps.value = []; // Clear traps to avoid displaying incorrect data
        return;
      }

      traps.value = await AlatService.fetchAlatByCompany(companyId.value);
      print('Fetched ${traps.length} tools for company ID: ${companyId.value}'); // Debug log
      await fetchChartData();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch tools: ${e.toString()}",
          snackPosition: SnackPosition.TOP);
      traps.value = []; // Clear traps on error
    }
  }

  Future<void> fetchChartData() async {
    if (companyId.value <= 0) return;

    try {
      isLoadingChart.value = true;

      final dateFormat = DateFormat('yyyy-MM-dd');
      final startDateStr = dateFormat.format(startDate.value);
      final endDateStr = dateFormat.format(endDate.value);

      final landData = await ChartService.fetchChartData(
        companyId: companyId.value,
        pestType: 'Land',
        startDate: startDateStr,
        endDate: endDateStr,
      );

      final flyData = await ChartService.fetchChartData(
        companyId: companyId.value,
        pestType: 'Flying',
        startDate: startDateStr,
        endDate: endDateStr,
      );

      landChartData.value = _convertToFlSpots(landData);
      flyChartData.value = _convertToFlSpots(flyData);
    } catch (e) {
      landChartData.value = [FlSpot(0, 0)];
      flyChartData.value = [FlSpot(0, 0)];
    } finally {
      isLoadingChart.value = false;
    }
  }

  List<FlSpot> _convertToFlSpots(List<ChartModel> chartData) {
    if (chartData.isEmpty) return [FlSpot(0, 0)];

    Map<String, double> dateValueMap = {};
    for (var data in chartData) {
      final date = data.tanggal;
      final value = data.value.toDouble();
      dateValueMap[date] = (dateValueMap[date] ?? 0) + value;
    }

    List<String> sortedDates = dateValueMap.keys.toList()
      ..sort((a, b) {
        try {
          final dateA = DateFormat('dd-MM-yyyy').parse(a);
          final dateB = DateFormat('dd-MM-yyyy').parse(b);
          return dateA.compareTo(dateB);
        } catch (_) {
          return a.compareTo(b);
        }
      });

    List<FlSpot> spots = [];

    if (sortedDates.length == 1) {
      final singleDate = sortedDates.first;
      final value = dateValueMap[singleDate] ?? 0;
      spots.add(FlSpot(0, value));
    } else {
      for (int i = 0; i < sortedDates.length; i++) {
        final date = sortedDates[i];
        final value = dateValueMap[date] ?? 0;
        spots.add(FlSpot(i.toDouble(), value));
      }
    }

    return spots.isEmpty ? [FlSpot(0, 0)] : spots;
  }

  // Refresh semua data
  Future<void> refreshData() async {
    await Future.wait([
      loadCompanyData(),
      fetchData(),
    ]);
  }

  Future<void> retryChartData() async {
    await fetchChartData();
  }

  void onDateRangeChanged(DateTime start, DateTime end) {
    if (start.isAfter(end)) {
      Get.snackbar("Invalid", "Start date cannot be after end date",
          snackPosition: SnackPosition.TOP);
      return;
    }

    final range = end.difference(start).inDays;
    if (range > 365) {
      Get.snackbar("Too Long", "Please choose a range within 1 year",
          snackPosition: SnackPosition.TOP);
      return;
    }

    startDate.value = start;
    endDate.value = end;
    fetchChartData();
  }

  void changeDate(DateTime date) {
    print("Tanggal berubah ke: ${date.toString()}");
  }

  void updateNote(int index, String value) {
    print("Updating note for index $index: $value");
  }

  List<FlSpot> getChartData(String title) {
    if (title == "Land") {
      return landChartData.value;
    } else if (title == "Fly" || title == "Flying") {
      return flyChartData.value;
    }
    return [FlSpot(0, 0)];
  }

  void debugChartData() {
    print('Land Chart: ${landChartData.value}');
    print('Fly Chart: ${flyChartData.value}');
    print('Total Land: $totalLandCatches');
    print('Total Fly: $totalFlyCatches');
  }

  String getCompanyInfo() {
    return "${companyName.value} - ${companyAddress.value}";
  }

  // Getter untuk mendapatkan company ID yang sedang aktif
  int? get currentCompanyId => companyId.value > 0 ? companyId.value : null;

  // Method untuk mengecek apakah company data sudah ter-load
  bool get hasCompanyData => currentCompany.value != null && companyId.value > 0;

  // Chart data getters
  int get totalPengecekan {
    int countLand = landChartData.where((e) => e.y > 0).length;
    int countFly = flyChartData.where((e) => e.y > 0).length;
    return countLand + countFly;
  }

  bool get hasChartData {
    return landChartData.isNotEmpty &&
        flyChartData.isNotEmpty &&
        !(landChartData.length == 1 && landChartData.first.y == 0) &&
        !(flyChartData.length == 1 && flyChartData.first.y == 0);
  }

  int get totalLandCatches {
    if (landChartData.isEmpty) return 0;
    if (landChartData.length == 3 && landChartData[0].y == 0 && landChartData[1].y == flyChartData[2].y) {
      return landChartData[1].y.toInt();
    }
    return landChartData.map((e) => e.y.toInt()).reduce((a, b) => a + b);
  }

  int get totalFlyCatches {
    if (flyChartData.isEmpty) return 0;
    if (flyChartData.length == 3 && flyChartData[0].y == 0 && flyChartData[1].y == flyChartData[2].y) {
      return flyChartData[1].y.toInt();
    }
    return flyChartData.map((e) => e.y.toInt()).reduce((a, b) => a + b);
  }

  String get formattedDateRange {
    final formatter = DateFormat('MMM d, yyyy');
    return '${formatter.format(startDate.value)} - ${formatter.format(endDate.value)}';
  }

  @override
  void onClose() {
    super.onClose();
  }
}