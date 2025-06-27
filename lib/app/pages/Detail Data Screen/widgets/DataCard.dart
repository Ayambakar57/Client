import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
// Import the improved LineChartWidget
import 'ChartLine.dart'; // Make sure this imports the updated LineChartWidget

class DataCard extends StatefulWidget {
  final String title;
  final List<FlSpot> chartData;
  final String? notes; // Notes to display (read-only)
  final Color color;

  const DataCard({
    Key? key,
    required this.title,
    required this.chartData,
    this.notes,
    required this.color,
  }) : super(key: key);

  @override
  _DataCardState createState() => _DataCardState();
}

class _DataCardState extends State<DataCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    bool hasNotes = widget.notes != null && widget.notes!.isNotEmpty;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart Section
          LineChartWidget(
            data: widget.chartData,
            title: widget.title,
            primaryColor: widget.color,
            isLoading: false,
          ),

          // Notes Section (Read-only)
          if (hasNotes)
            Container(
              width: double.infinity,
              child: Column(
                children: [
                  // Expand/Collapse Button
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.sticky_note_2_outlined,
                            size: 20.w,
                            color: widget.color,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'View Notes',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Spacer(),
                          AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: Duration(milliseconds: 200),
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              size: 24.w,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Notes Display Section
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    height: _isExpanded ? null : 0,
                    child: _isExpanded
                        ? Container(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notes for ${widget.title}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            child: Text(
                              widget.notes!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        : SizedBox.shrink(),
                  ),
                ],
              ),
            ),

          // If no notes available, show a subtle indicator
          if (!hasNotes)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16.w,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'No notes available',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}