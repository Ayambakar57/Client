import 'package:client_page/widgets/expandable_history_card.dart';
import 'package:client_page/widgets/month_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../controllers/detail_data_controller.dart';
import '../widget_global/custom_app_bar.dart';
import '../widgets/data_card.dart';

class DetailDataView extends StatelessWidget {
  DetailDataView({super.key});

  final DetailDataController controller = Get.find<DetailDataController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCCD7CD),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAppBar(
              title: "Name company",
              rightIcon: "assets/icons/report_icon.svg",
              rightOnTap: () {
                Get.offNamed('HistoryReport');
              },
              showBackButton: false,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  children: [
                    GetBuilder<DetailDataController>(
                      builder: (controller) =>
                          MonthSlider(onMonthChanged: controller.changeMonth),
                    ),
                    SizedBox(height: 20.h),
                    DataCard(
                      title: "Land",
                      chartData: controller.getChartData("Land"),
                      onNoteChanged: (text) => controller.updateNote(0, text),
                      onSave: () => print("Data Land disimpan!"),
                    ),
                    SizedBox(height: 25.h),

                    DataCard(
                      title: "Fly",
                      chartData: controller.getChartData("Fly"),
                      onNoteChanged: (text) => controller.updateNote(1, text),
                      onSave: () => print("Data Fly disimpan!"),
                    ),
                    SizedBox(height: 35.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "History",
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 9.w),
                        SvgPicture.asset(
                          "assets/icons/history_icon.svg",
                          width: 36.w,
                          height: 36.h,
                        ),
                      ],
                    ),
                    SizedBox(height: 25.h),
                    GetBuilder<DetailDataController>(
                      builder: (controller) => ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: controller.traps.length,
                        separatorBuilder: (context, index) => SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final item = controller.traps[index];
                          return ExpandableHistoryCard(
                            imagePath: item["image"],
                            location: item["location"],
                            historyItems: List<Map<String, dynamic>>.from(item["history"]),
                            isExpanded: item["isExpanded"],
                            onTap: () {
                              controller.toggleExpand(index);
                              controller.update();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
