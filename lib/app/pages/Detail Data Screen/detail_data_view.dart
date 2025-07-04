import 'package:client_page/app/pages/Detail%20Data%20Screen/widgets/DataCard.dart';
import 'package:client_page/app/pages/Detail%20Data%20Screen/widgets/DateSelection.dart';
import 'package:client_page/app/pages/Detail%20Data%20Screen/widgets/SummarySection.dart';
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
            Obx(() => CustomAppBar(
              title: controller.companyName.value,
              showBackButton: false, onBackTap: () {  },
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
                      // Company Info Section
                      Obx(() => SummarySection(
                        totalAlat: controller.traps.length,
                        totalPengecekan: controller.totalPengecekan,
                        onQrTap: () => Get.offNamed('/CreateQrTools', arguments: {
                          'companyId': controller.companyId.value,
                        }),
                      )),
                      SizedBox(height: 20.h),

                      // Month Selection with callback
                      MonthSelection(
                        onMonthRangeChanged: controller.onDateRangeChanged,
                      ),
                      SizedBox(height: 20.h),

                      // Loading indicator for charts
                      Obx(() {
                        if (controller.isLoadingChart.value) {
                          return Container(
                            height: 100.h,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColor.ijomuda,
                              ),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      }),

                      // Land Chart
                      Obx(() =>DataCard(
                        title: "Land",
                        chartData: controller.getChartData("Land"),
                        color: AppColor.ijomuda,
                      ),),
                      SizedBox(height: 25.h),

                      // Fly Chart
                      Obx(() =>DataCard(
                        title: "Fly",
                        chartData: controller.getChartData("Fly"),
                        color: AppColor.btnoren,
                      ),),
                      SizedBox(height: 35.h),

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
}