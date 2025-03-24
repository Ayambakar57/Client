import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/login_controller.dart';
import '../routes/app_router.dart';
import '../widgets/custom_textfield.dart';

class LoginScreen extends StatelessWidget {
  final LoginController controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDE7DC),
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height, // Make it full screen height
            child: Padding(
              padding: EdgeInsets.all(20.w), // Padding responsif
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                crossAxisAlignment: CrossAxisAlignment.start , // Center horizontally
                children: [
                  SvgPicture.asset(
                    'assets/images/login_illustration.svg',
                    width: 310.w, // Ukuran responsif
                  ),
                  SizedBox(height: 40.h),

                  // Teks "Login"
                  Text(
                    "Login",
                    style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),

                  // Teks "Please Sign in to continue."
                  Text(
                      "Please Sign in to continue.",
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.left
                  ),
                  SizedBox(height: 20.h),

                  // Input Username
                  CustomTextField(
                    hintText: "Username",
                    icon: Icons.person,
                    onChanged: (value) => controller.username.value = value,
                  ),
                  SizedBox(height: 15.h),

                  // Input Password dengan ikon mata
                  Obx(() => CustomTextField(
                    hintText: "Password",
                    icon: Icons.lock,
                    isObscure: !controller.isPasswordVisible.value,
                    onChanged: (value) => controller.password.value = value,
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.isPasswordVisible.value
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        controller.isPasswordVisible.toggle();
                      },
                    ),
                  )),
                  SizedBox(height: 20.h),

                  // Tombol Sign In
                  ElevatedButton(
                    onPressed: () {
                      Get.toNamed(Routes.HOME); // Langsung navigasi ke Home tanpa login
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA726),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      minimumSize: Size(double.infinity, 40.h),
                    ),
                    child: Text(
                      "Sign In",
                      style: TextStyle(color: Colors.black, fontSize: 16.sp),
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}
