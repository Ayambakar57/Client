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

class DetailDataView extends StatefulWidget {
  const DetailDataView({super.key});

  @override
  _DetailDataViewState createState() => _DetailDataViewState();
}

class _DetailDataViewState extends State<DetailDataView> {
  final controller = Get.find<DetailDataController>();
  int selectedMonth = 0;

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
                    // MonthSlider
                    MonthSlider(
                      onMonthChanged: (index) {
                        setState(() {
                          selectedMonth = index;
                        });
                        print("Bulan terpilih: ${selectedMonth + 1}");
                      },
                    ),
                    SizedBox(height: 20.h),

                    // Grafik DataCard
                    DataCard(
                      title: "Land",
                      dataPoints: [
                        FlSpot(1, 5),
                        FlSpot(2, 7),
                        FlSpot(3, 3),
                        FlSpot(4, 9),
                      ],
                      onNoteChanged: (text) {
                        print("Catatan: $text");
                      },
                    ),
                    SizedBox(height: 25.h),

                    DataCard(
                      title: "Fly",
                      dataPoints: [
                        FlSpot(1, 5),
                        FlSpot(2, 7),
                        FlSpot(3, 3),
                        FlSpot(4, 9),
                      ],
                      onNoteChanged: (text) {
                        print("Catatan: $text");
                      },
                    ),
                    SizedBox(height: 35.h),

                    // History Section
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

                    // ListView di dalam ScrollView
                    Obx(
                          () => ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: controller.traps.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 12.h),
                        itemBuilder: (context, index) {
                          final item = controller.traps[index];
                          return ExpandableHistoryCard(
                            imagePath: item["image"],
                            location: item["location"],
                            historyItems: List<Map<String, dynamic>>.from(
                                item["history"]),
                            isExpanded: item["isExpanded"],
                            onTap: () => controller.toggleExpand(index),
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
