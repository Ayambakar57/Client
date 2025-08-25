import 'package:client_page/app/pages/Detail%20Data%20Screen/widgets/ChartTool.dart';
import 'package:client_page/app/pages/Detail%20Data%20Screen/widgets/DateSelection.dart';
import 'package:client_page/app/pages/Detail%20Data%20Screen/widgets/SummarySection.dart';
import 'package:client_page/app/pages/Detail%20Data%20Screen/widgets/ToolCard.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../values/app_color.dart';
import '../../global component/CustomAppBar.dart';
import '../../../../data/services/PdfExportService.dart';
import 'detail_data_controller.dart';

class DetailDataView extends StatelessWidget {
  const DetailDataView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DetailDataController>();

    return Scaffold(
      backgroundColor: AppColor.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => CustomAppBar(
              title: controller.companyName.value,
              showBackButton: false,
              rightIcon: "assets/icons/report.svg",
              rightOnTap: () => Get.toNamed('/HistoryReport'),
              onBackTap: () {},
            )),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.fetchData,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company Info Section with PDF Export
                      Obx(() => SummarySection(
                        totalAlat: controller.traps.length,
                        totalPengecekan: controller.totalPengecekan,
                        onPdfTap: () => _handlePdfExport(controller),
                      )),
                      SizedBox(height: 20.h),

                      // Month Selection with callback
                      MonthSelection(
                        onMonthRangeChanged: controller.onDateRangeChanged,
                      ),
                      SizedBox(height: 20.h),

                      Obx(() {
                        if (controller.isLoadingChart.value) {
                          return Container(
                            height: 300.h,
                            margin: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColor.btnoren),
                                  ),
                                  SizedBox(height: 16.h),
                                  Text(
                                    'Loading chart data...',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (controller.availablePestTypes.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(32.w),
                            margin: EdgeInsets.symmetric(vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  size: 64.w,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  "No chart data available",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "Data will appear when catches are recorded for tools",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        // Generate layered charts for each pest type
                        return Column(
                          children: controller.availablePestTypes.map((pestType) {
                            // Get layered data for this pest type
                            List<List<FlSpot>> layeredChartData = controller.getLayeredChartDataByPestType(pestType);
                            List<Color> layeredColors = controller.getLayeredColorsByPestType(pestType);
                            List<String> labels = controller.getLabelsByPestType(pestType);

                            return Column(
                              children: [
                                ChartTool(
                                  title: pestType,
                                  chartData: layeredChartData,
                                  colors: layeredColors,
                                  labels: labels,
                                  onNoteChanged: (text) => controller.updateNote(
                                      controller.availablePestTypes.indexOf(pestType),
                                      text
                                  ),
                                  onSave: () => print("Layered data for $pestType saved!"),
                                ),
                                SizedBox(height: 25.h),
                              ],
                            );
                          }).toList(),
                        );
                      }),

                      // History Section
                      Row(
                        children: [
                          Text(
                            "History",
                            style: TextStyle(
                                fontSize: 24.sp, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 9.w),
                          SvgPicture.asset("assets/icons/history_icon.svg",
                              width: 36.w, height: 36.h),
                        ],
                      ),
                      SizedBox(height: 25.h),

                      // Tools List
                      Obx(() {
                        if (controller.traps.isEmpty) {
                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(32.w),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inventory_2_outlined,
                                  size: 64.w,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  "No tools found for this company",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  "Tools will appear here once they are added",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: controller.traps.length,
                          separatorBuilder: (_, __) => SizedBox(height: 12.h),
                          itemBuilder: (_, index) {
                            final item = controller.traps[index];
                            return ToolCard(
                              toolName: item.namaAlat,
                              imagePath: item.imagePath ?? "",
                              location: item.lokasi,
                              locationDetail: item.detailLokasi,
                              historyItems: [],
                              kondisi: item.kondisi,
                              pest_type: item.pestType,
                              kode_qr: item.kodeQr,
                              alatId: item.id.toString(),
                            );
                          },
                        );
                      }),
                      SizedBox(height: 25.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PDF Export Handler
  Future<void> _handlePdfExport(DetailDataController controller) async {
    try {
      // Show confirmation dialog first
      bool? shouldProceed = await _showPdfExportDialog();
      if (shouldProceed != true) return;

      // Show loading dialog
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(24.w),
            margin: EdgeInsets.symmetric(horizontal: 40.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppColor.btnoren,
                  strokeWidth: 3,
                ),
                SizedBox(height: 20.h),
                Text(
                  'Membuat Laporan PDF...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Mohon tunggu sebentar',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Validate required data
      if (controller.currentCompany.value == null) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          "Error",
          "Data perusahaan tidak tersedia. Silakan refresh halaman dan coba lagi.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          icon: Icon(Icons.error_outline, color: Colors.red.shade800),
          duration: Duration(seconds: 4),
        );
        return;
      }

      if (controller.traps.isEmpty) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          "Warning",
          "Tidak ada data alat untuk diekspor. Tambahkan alat terlebih dahulu.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.shade100,
          colorText: Colors.orange.shade800,
          icon: Icon(Icons.warning_outlined, color: Colors.orange.shade800),
          duration: Duration(seconds: 4),
        );
        return;
      }

      // Generate PDF report
      await PdfExportService.generateCompanyReport(
        company: controller.currentCompany.value!,
        startDate: controller.startDate.value,
        endDate: controller.endDate.value,
        totalAlat: controller.traps.length,
        totalPengecekan: controller.totalPengecekan,
        availablePestTypes: controller.availablePestTypes,
        pestTypeLayeredData: controller.pestTypeLayeredData,
        pestTypeLabelColors: controller.pestTypeLabelColors,
        tools: controller.traps,
        getLabelsByPestType: (pestType) => controller.getLabelsByPestType(pestType),
      );

      Get.back(); // Close loading dialog

      // Show success message
      Get.snackbar(
        "Berhasil",
        "Laporan PDF berhasil dibuat dan siap dibagikan",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
        icon: Icon(Icons.check_circle_outline, color: Colors.green.shade800),
        duration: Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () => _showShareOptions(controller),
          child: Text(
            'BAGIKAN LAGI',
            style: TextStyle(
              color: Colors.green.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

    } catch (e) {
      Get.back(); // Close loading dialog
      print('PDF Export Error: $e'); // For debugging

      Get.snackbar(
        "Error",
        "Gagal membuat laporan PDF: ${_getErrorMessage(e.toString())}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        icon: Icon(Icons.error_outline, color: Colors.red.shade800),
        duration: Duration(seconds: 6),
        mainButton: TextButton(
          onPressed: () => _handlePdfExport(controller),
          child: Text(
            'COBA LAGI',
            style: TextStyle(
              color: Colors.red.shade800,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  // Show PDF export confirmation dialog
  Future<bool?> _showPdfExportDialog() async {
    return Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.picture_as_pdf, color: AppColor.btnoren, size: 28.w),
            SizedBox(width: 12.w),
            Text(
              'Ekspor Laporan PDF',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda ingin membuat laporan PDF untuk periode ini?',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Laporan akan mencakup:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '• Ringkasan data alat dan pengecekan\n'
                        '• Grafik tangkapan berdasarkan jenis hama\n'
                        '• Daftar lengkap alat monitoring\n'
                        '• Data untuk periode yang dipilih',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Batal',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.btnoren,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Buat PDF',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Show additional sharing options
  void _showShareOptions(DetailDataController controller) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Opsi Berbagi',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: Icon(Icons.preview, color: AppColor.btnoren),
              title: Text('Preview PDF'),
              subtitle: Text('Lihat laporan sebelum membagikan'),
              onTap: () {
                Get.back();
                _previewPdf(controller);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.blue),
              title: Text('Bagikan Kembali'),
              subtitle: Text('Bagikan laporan yang sudah dibuat'),
              onTap: () {
                Get.back();
                _handlePdfExport(controller);
              },
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'Tutup',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Preview PDF before sharing
  Future<void> _previewPdf(DetailDataController controller) async {
    try {
      if (controller.currentCompany.value == null) {
        Get.snackbar(
          "Error",
          "Data perusahaan tidak tersedia untuk preview.",
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      await PdfExportService.previewPdf(
        company: controller.currentCompany.value!,
        startDate: controller.startDate.value,
        endDate: controller.endDate.value,
        totalAlat: controller.traps.length,
        totalPengecekan: controller.totalPengecekan,
        availablePestTypes: controller.availablePestTypes,
        pestTypeLayeredData: controller.pestTypeLayeredData,
        pestTypeLabelColors: controller.pestTypeLabelColors,
        tools: controller.traps,
        getLabelsByPestType: (pestType) => controller.getLabelsByPestType(pestType),
      );

    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal membuka preview PDF: ${_getErrorMessage(e.toString())}",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // Get user-friendly error message
  String _getErrorMessage(String error) {
    if (error.contains('permission')) {
      return 'Izin penyimpanan diperlukan. Silakan berikan izin dan coba lagi.';
    } else if (error.contains('storage') || error.contains('space')) {
      return 'Ruang penyimpanan tidak cukup. Silakan bersihkan ruang dan coba lagi.';
    } else if (error.contains('network') || error.contains('connection')) {
      return 'Masalah koneksi jaringan. Periksa koneksi internet Anda.';
    } else if (error.contains('data') || error.contains('company')) {
      return 'Data tidak lengkap. Silakan refresh halaman dan coba lagi.';
    }
    return 'Terjadi kesalahan tak terduga. Silakan coba lagi.';
  }
}