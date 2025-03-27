import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../widget_global/custom_textfield.dart';
import 'chart_line.dart';


class DataCard extends StatelessWidget {
  final String title;
  final List<FlSpot> chartData;
  final Function(String) onNoteChanged;
  final VoidCallback onSave;
  final Color? color;

  const DataCard({
    super.key,
    required this.title,
    required this.chartData,
    required this.onNoteChanged,
    required this.onSave,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF9CB1A3),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20.h),

          LineChartWidget(
            data: chartData,
            primaryColor: Colors.blue,
          ),

          SizedBox(height: 20.h),

          CustomTextField(
            label: "Catatan",
            svgIcon: "assets/icons/note_icont.svg",
            onChanged: onNoteChanged,
          ),

          SizedBox(height: 12.h),


        ],
      ),
    );
  }
}
