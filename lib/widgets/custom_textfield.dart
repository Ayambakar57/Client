import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool isObscure;
  final Function(String) onChanged;
  final Widget? suffixIcon;

  const CustomTextField({
    Key? key,
    required this.hintText,
    required this.icon,
    this.isObscure = false,
    required this.onChanged,
    this.suffixIcon, // Tambahkan suffixIcon
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(

      obscureText: isObscure,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.black),
        filled: true,
        fillColor: Color(0xFFF2F2F2),
        suffixIcon: suffixIcon, // Tambahkan suffixIcon di sini
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Color(0xFFF2F2F2), width: 2), // White border
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Color(0xFFF2F2F2), width: 2), // White border when focused
        ),
      ),
    );
  }
}

