import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../../data/models/alat_model.dart';
import '../../../data/models/chart_model.dart';
import '../../../data/services/alat_service.dart';
import '../../../data/services/chart_service.dart';
import '../../../data/models/company_model.dart';
import '../../../data/services/company_service.dart';
import '../Login screen/login_controller.dart';

class DetailDataController extends GetxController {
  var traps = <AlatModel>[].obs;
  var selectedMonth = 0.obs;
  var isLoadingChart = false.obs;

  // Modified for layered charts
  var pestTypeLayeredData = <String, Map<String, List<FlSpot>>>{}.obs;
  var pestTypeLabelColors = <String, Map<String, Color>>{}.obs;
  var availablePestTypes = <String>[].obs;

  var startDate = DateTime.now().obs;
  var endDate = DateTime.now().obs;

  // Company data - simplified
  var companyId = 0.obs;
  var companyName = 'Loading...'.obs;
  var companyAddress = ''.obs;
  var companyPhoneNumber = ''.obs;
  var companyEmail = ''.obs;
  var companyImagePath = ''.obs;
  var companyCreatedAt = ''.obs;
  var companyUpdatedAt = ''.obs;

  var currentCompany = Rxn<CompanyModel>();
  var isLoading = false.obs;
  final CompanyService _companyService = CompanyService();

  final List<Color> _colorPalette = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.indigo,
    Colors.brown,
    Colors.cyan,
    Colors.lime,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.blueGrey,
    Colors.grey,
    const Color(0xFF64B5F6),
    const Color(0xFFEF5350),
    const Color(0xFF66BB6A),
    const Color(0xFFFF9800),
    const Color(0xFFAB47BC),
    const Color(0xFF26A69A),
    const Color(0xFFEC407A),
    const Color(0xFFFFCA28),
  ];

  @override
  void onInit() {
    super.onInit();

    final now = DateTime.now();
    startDate.value = DateTime(now.year, now.month, 1);
    endDate.value = DateTime(now.year, now.month + 1, 0);

    // Load company ID and then fetch data
    loadCompanyId().then((_) {
      if (companyId.value > 0) {
        fetchData();
      } else {
        Get.snackbar("Error", "Cannot fetch tools: No valid company ID",
            snackPosition: SnackPosition.TOP);
      }
    });
  }

  Future<void> loadCompanyId() async {
    try {
      isLoading.value = true;
      final savedCompanyId = await getCompanyIdFromPrefs();
      if (savedCompanyId != null && savedCompanyId > 0) {
        companyId.value = savedCompanyId;
        print('Loaded company ID from SharedPreferences: $savedCompanyId');
        // Fetch company details after loading ID
        await _fetchCompanyDetails(savedCompanyId);
        return;
      }
      final clientId = await LoginController.getClientId();
      if (clientId == null) {
        throw Exception('Client ID not found. Please login again.');
      }
      final company = await _companyService.getCompanyByClientId();
      if (company != null) {
        companyId.value = company.id;
        await _saveCompanyIdToPrefs(company.id);
        currentCompany.value = company;
        // Update company name here
        companyName.value = company.name;
        companyAddress.value = company.address;
        print('Loaded company ID from service: ${company.id}');
      }
      else {
        throw Exception('No company ID found for client ID: $clientId');
      }
    } catch (e) {
      companyId.value = 0;
      Get.snackbar(
        "Error",
        "Failed to load company ID: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
      );
      print('Error in loadCompanyId: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCompanyDetails(int id) async {
    try {
      final company = await _companyService.getCompanyById(id);
      if (company != null) {
        currentCompany.value = company;
        companyName.value = company.name;
        companyAddress.value = company.address;
      }
    } catch (e) {
      print('Error fetching company details: $e');
      companyName.value = 'Failed to load name';
    }
  }

  Future<void> _saveCompanyIdToPrefs(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('companyid', id);
    } catch (e) {
      print('Error saving company ID to SharedPreferences: $e');
    }
  }

  Future<int?> getCompanyIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('companyid');
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
        traps.value = [];
        return;
      }
      // Ensure company name is set before fetching traps
      if (companyName.value == 'Loading...') {
        await _fetchCompanyDetails(companyId.value);
      }
      traps.value = await AlatService.fetchAlatByCompany(companyId.value);
      print('Fetched ${traps.length} tools for company ID: ${companyId.value}');
      await fetchChartData();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch tools: ${e.toString()}",
          snackPosition: SnackPosition.TOP);
      traps.value = [];
    }
  }

  Future<void> fetchChartData() async {
    if (companyId.value <= 0) return;
    try {
      isLoadingChart.value = true;
      final dateFormat = DateFormat('yyyy-MM-dd');
      final startDateStr = dateFormat.format(startDate.value);
      final endDateStr = dateFormat.format(endDate.value);
      print('Fetching chart data for company: ${companyId.value}');
      print('Date range: $startDateStr to $endDateStr');
      final allChartData = await ChartService.fetchAllChartData(
        companyId: companyId.value,
        startDate: startDateStr,
        endDate: endDateStr,
      );
      print('Received ${allChartData.length} chart data items');
      _processLayeredChartData(allChartData);
    } catch (e) {
      print('Error fetching chart data: $e');
      pestTypeLayeredData.clear();
      availablePestTypes.clear();
      pestTypeLabelColors.clear();
      Get.snackbar("Chart Error", "Failed to load chart data: ${e.toString()}");
    } finally {
      isLoadingChart.value = false;
    }
  }

  void _processLayeredChartData(List<ChartModel> allData) {
    pestTypeLayeredData.clear();
    pestTypeLabelColors.clear();
    availablePestTypes.clear();
    if (allData.isEmpty) {
      print('No chart data to process');
      return;
    }
    Map<String, Map<String, List<ChartModel>>> groupedData = {};
    for (var item in allData) {
      String pestType = item.pestType.trim();
      String label = item.label.trim();
      if (pestType.isEmpty) {
        pestType = 'Unknown';
      }
      if (label.isEmpty) {
        label = 'Unknown Label';
      }
      if (!groupedData.containsKey(pestType)) {
        groupedData[pestType] = {};
      }
      if (!groupedData[pestType]!.containsKey(label)) {
        groupedData[pestType]![label] = [];
      }
      groupedData[pestType]![label]!.add(item);
    }
    int globalColorIndex = 0;
    groupedData.forEach((pestType, labelMap) {
      availablePestTypes.add(pestType);
      pestTypeLayeredData[pestType] = {};
      pestTypeLabelColors[pestType] = {};
      labelMap.forEach((label, data) {
        pestTypeLayeredData[pestType]![label] = _convertToFlSpots(data);
        Color assignedColor = _colorPalette[globalColorIndex % _colorPalette.length];
        pestTypeLabelColors[pestType]![label] = assignedColor;
        print('Processed: "$pestType" -> "$label": ${data.length} items, color: $assignedColor');
        globalColorIndex++;
      });
    });
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

  List<List<FlSpot>> getLayeredChartDataByPestType(String pestType) {
    Map<String, List<FlSpot>>? labelData = pestTypeLayeredData[pestType];
    if (labelData == null || labelData.isEmpty) {
      return [[FlSpot(0, 0)]];
    }
    return labelData.values.toList();
  }

  List<Color> getLayeredColorsByPestType(String pestType) {
    Map<String, Color>? labelColors = pestTypeLabelColors[pestType];
    if (labelColors == null || labelColors.isEmpty) {
      return [Colors.grey];
    }
    return labelColors.values.toList();
  }

  List<String> getLabelsByPestType(String pestType) {
    Map<String, List<FlSpot>>? labelData = pestTypeLayeredData[pestType];
    if (labelData == null || labelData.isEmpty) {
      return ['No Data'];
    }
    return labelData.keys.toList();
  }

  Color getColorByPestTypeAndLabel(String pestType, String label) {
    return pestTypeLabelColors[pestType]?[label] ?? Colors.grey;
  }

  List<FlSpot> getChartDataByPestType(String pestType) {
    List<List<FlSpot>> layeredData = getLayeredChartDataByPestType(pestType);
    return layeredData.isNotEmpty ? layeredData.first : [FlSpot(0, 0)];
  }

  Color getColorByPestType(String pestType) {
    List<Color> layeredColors = getLayeredColorsByPestType(pestType);
    return layeredColors.isNotEmpty ? layeredColors.first : Colors.grey;
  }

  int getTotalCatchesByPestType(String pestType) {
    Map<String, List<FlSpot>>? labelData = pestTypeLayeredData[pestType];
    if (labelData == null || labelData.isEmpty) return 0;
    int total = 0;
    labelData.values.forEach((data) {
      if (data.isNotEmpty && !(data.length == 1 && data.first.y == 0)) {
        total += data.map((e) => e.y.toInt()).reduce((a, b) => a + b);
      }
    });
    return total;
  }

  int getTotalCatchesByPestTypeAndLabel(String pestType, String label) {
    List<FlSpot>? data = pestTypeLayeredData[pestType]?[label];
    if (data == null || data.isEmpty) return 0;
    if (data.length == 1 && data.first.y == 0) return 0;
    return data.map((e) => e.y.toInt()).reduce((a, b) => a + b);
  }

  void onDateRangeChanged(DateTime start, DateTime end) {
    if (start.isAfter(end)) {
      Get.snackbar("Invalid", "Start date cannot be after end date");
      return;
    }
    final range = end.difference(start).inDays;
    if (range > 365) {
      Get.snackbar("Too Long", "Please choose a range within 1 year");
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


  String getCompanyInfo() {
    return "${companyName.value} - ${companyAddress.value}";
  }

  Future<void> refreshData() async {
    await fetchData();
  }

  Future<void> retryChartData() async {
    await fetchChartData();
  }

  int get totalPengecekan {
    int total = 0;
    pestTypeLayeredData.forEach((pestType, labelMap) {
      labelMap.forEach((label, data) {
        total += data.where((e) => e.y > 0).length;
      });
    });
    return total;
  }

  bool get hasChartData {
    return availablePestTypes.isNotEmpty &&
        pestTypeLayeredData.values.any((labelMap) =>
            labelMap.values.any((data) =>
            data.isNotEmpty && !(data.length == 1 && data.first.y == 0)
            )
        );
  }

  int get totalAllCatches {
    int total = 0;
    availablePestTypes.forEach((pestType) {
      total += getTotalCatchesByPestType(pestType);
    });
    return total;
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