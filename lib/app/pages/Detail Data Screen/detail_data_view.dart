import 'package:client_page/app/pages/Detail%20Data%20Screen/widgets/DataCard.dart';
import 'package:client_page/app/pages/Detail%20Data%20Screen/widgets/DateSelection.dart';
import 'package:client_page/app/pages/Detail%20Data%20Screen/widgets/ToolCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../values/app_color.dart';
import '../../global component/CustomAppBar.dart';
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
            // Dynamic company name in AppBar
            Obx(() => CustomAppBar(
              title: controller.companyName.value,
              showBackButton: false,
            )),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshData, // Refresh both company and trap data
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display company information if available
                      Obx(() {
                        if (controller.currentCompany.value != null) {
                          final company = controller.currentCompany.value!;
                          return Container(
                            margin: EdgeInsets.only(bottom: 16.h),
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          );
                        } else if (controller.isLoading.value) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 16.h),
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColor.ijomuda,
                              ),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      }),

                      MonthSelection(
                        onMonthRangeChanged: (startDate, endDate) {},
                      ),
                      SizedBox(height: 20.h),
                      DataCard(
                        title: "Land",
                        chartData: controller.getChartData("Land"),
                        onNoteChanged: (text) => controller.updateNote(0, text),
                        onSave: () => print("Data Land disimpan!"),
                        color: AppColor.ijomuda,
                      ),
                      SizedBox(height: 25.h),
                      DataCard(
                        title: "Fly",
                        chartData: controller.getChartData("Fly"),
                        onNoteChanged: (text) => controller.updateNote(1, text),
                        onSave: () => print("Data Fly disimpan!"),
                        color: AppColor.ijomuda,
                      ),
                      SizedBox(height: 35.h),
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
                      Obx(() => ListView.separated(
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
                          );
                        },
                      )),
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
}