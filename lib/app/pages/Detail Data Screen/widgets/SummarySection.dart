import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../data/services/PdfExportService.dart';
import '../../../../values/app_color.dart';
import '../detail_data_controller.dart';
import 'SummaryCard.dart';

class SummarySection extends StatelessWidget {
  final int totalAlat;
  final int totalPengecekan;
  final VoidCallback onPdfTap;

  const SummarySection({
    super.key,
    required this.totalAlat,
    required this.totalPengecekan,
    required this.onPdfTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DetailDataController>();
    double size = 82.w < 82.h ? 82.w : 82.h;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          SummaryCard(title: "Total alat", value: totalAlat.toString()),
          SummaryCard(title: "Pengecekan", value: totalPengecekan.toString()),


          // GestureDetector(
          //   onTap: onPdfTap, // Use the callback passed from parent
          //   child: Container(
          //     width: size,
          //     height: size,
          //     decoration: BoxDecoration(
          //       color: AppColor.btnoren,
          //       borderRadius: BorderRadius.circular(8.r),
          //     ),
          //     child: Center(
          //       child: SvgPicture.asset(
          //         "assets/icons/pdf_icont.svg",
          //         width: 50.w,
          //         height: 50.h,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  // Alternative: If you want to keep the PDF generation in this widget
  Future<void> _generatePdfReport(DetailDataController controller) async {
    try {
      // Show loading dialog
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColor.btnoren),
                SizedBox(height: 16),
                Text('Membuat laporan PDF...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Check if company data is available
      if (controller.currentCompany.value == null) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          "Error",
          "Data perusahaan tidak tersedia. Silakan coba lagi.",
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      // Generate PDF report - FIXED: Remove the extra label parameter
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
        getLabelsByPestType: (pestType) => controller.getLabelsByPestType(pestType), // FIXED: Only one parameter
      );

      Get.back(); // Close loading dialog

      Get.snackbar(
        "Berhasil",
        "Laporan PDF berhasil dibuat dan dibagikan",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );

    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        "Error",
        "Gagal membuat laporan PDF: ${e.toString()}",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }
}