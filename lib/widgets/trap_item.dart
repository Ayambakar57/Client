import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TrapItem extends StatelessWidget {
  final String image;
  final String name;

  TrapItem({required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 150.w,
          height: 100.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 5.h),
        Text(name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
