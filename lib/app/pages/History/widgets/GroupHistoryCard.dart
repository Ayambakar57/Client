import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../values/app_color.dart';
import '../history_tools_controller.dart';
import 'SingleHistoryCard.dart';

class GroupedHistoryCard extends StatelessWidget {
  final String month;
  final List<Map<String, dynamic>> items;
  final bool isToolGroup;
  final RxBool isExpanded = false.obs;
  final HistoryController controller = Get.find();

  GroupedHistoryCard({
    required this.month,
    required this.items,
    this.isToolGroup = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColor.backgroundsetengah,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header yang bisa diklik
            InkWell(
              onTap: () => isExpanded.toggle(),
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: AppColor.ijomuda,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              isToolGroup
                                  ? controller.getAlatName(month)
                                  : controller.getMonthName(month),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (isToolGroup) ...[
                            SizedBox(height: 4.h),
                            Text(
                              "ID: ${controller.getAlatId(month)} • ${items.length} records",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            if (items.isNotEmpty) ...[
                              SizedBox(height: 2.h),
                              Text(
                                "Location: ${items.first['lokasi']}, ${items.first['detail_lokasi']}",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.black45,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ] else ...[
                            SizedBox(height: 4.h),
                            Text(
                              "${items.length} records",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black54,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColor.ijomuda.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedRotation(
                        turns: isExpanded.value ? 0.5 : 0,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 24.sp,
                          color: AppColor.ijomuda,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Divider dengan animasi
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isExpanded.value ? 1 : 0,
              color: AppColor.ijomuda.withOpacity(0.3),
              margin: EdgeInsets.symmetric(horizontal: 16.w),
            ),

            // Content dengan animasi slide down yang smooth
            AnimatedContainer(
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              height: isExpanded.value ? null : 0,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 350),
                curve: Curves.easeIn,
                opacity: isExpanded.value ? 1.0 : 0.0,
                child: ClipRRect(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    child: Column(
                      children: [
                        // Animasi staggered untuk setiap item
                        ...List.generate(
                          items.length,
                              (index) => AnimatedContainer(
                            duration: Duration(milliseconds: 300 + (index * 50)),
                            curve: Curves.easeOutQuart,
                            transform: Matrix4.translationValues(
                                0,
                                isExpanded.value ? 0 : 20,
                                0
                            ),
                            child: AnimatedOpacity(
                              duration: Duration(milliseconds: 400 + (index * 100)),
                              curve: Curves.easeOut,
                              opacity: isExpanded.value ? 1.0 : 0.0,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: SingleHistoryCard(item: items[index]),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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