import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final bool isPassword;
  final bool isNumber;
  final TextInputType? keyboardType;
  final String? errorMessage;
  final String? svgIcon;
  final Function(String)? onChanged;
  final bool showErrorBorder;

  const CustomTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.isPassword = false,
    this.isNumber = false,
    this.keyboardType,
    this.errorMessage,
    this.svgIcon,
    this.onChanged,
    this.showErrorBorder = true,
  }) : assert(
  controller == null || initialValue == null,
  'Gunakan salah satu: controller atau initialValue, bukan keduanya.',
  );

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isPasswordHidden = true;
  late final TextEditingController _internalController;

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) {
      _internalController = TextEditingController(text: widget.initialValue ?? '');

      if (widget.onChanged != null && widget.initialValue != null) {
        widget.onChanged!(widget.initialValue!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final showError = widget.showErrorBorder && widget.errorMessage != null;
    final borderColor = showError ? Colors.red : const Color(0xFF275637);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(
              widget.label!,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        SizedBox(
          height: 48.h,
          child: TextField(
            controller: widget.controller ?? _internalController,
            obscureText: widget.isPassword ? _isPasswordHidden : false,
            keyboardType: widget.keyboardType ??
                (widget.isNumber ? TextInputType.number : TextInputType.text),
            style: TextStyle(fontSize: 15.sp, color: Colors.black),
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              hintText: widget.hintText ?? '',
              hintStyle: TextStyle(fontSize: 15.sp, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
              prefixIcon: widget.svgIcon != null
                  ? Padding(
                padding: EdgeInsets.all(12.w),
                child: SvgPicture.asset(
                  widget.svgIcon!,
                  width: 24.w,
                  height: 24.h,
                ),
              )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                onPressed: () {
                  setState(() {
                    _isPasswordHidden = !_isPasswordHidden;
                  });
                },
                icon: SvgPicture.asset(
                  _isPasswordHidden
                      ? 'assets/icons/eye_closed.svg'
                      : 'assets/icons/eye_open.svg',
                  width: 20.w,
                  height: 20.h,
                  colorFilter: ColorFilter.mode(
                    Colors.grey.shade600,
                    BlendMode.srcIn,
                  ),
                ),
                splashRadius: 20.r,
                padding: EdgeInsets.all(8.w),
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: borderColor, width: 1.w),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: borderColor, width: 1.w),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: borderColor, width: 1.w),
              ),
            ),
          ),
        ),
        if (widget.errorMessage != null)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(
              widget.errorMessage!,
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          ),
      ],
    );
  }
}