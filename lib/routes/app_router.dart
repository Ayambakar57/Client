import 'package:client_page/bindings/history_report_binding.dart';
import 'package:client_page/bindings/report_detail_binding.dart';
import 'package:client_page/bindings/report_input_binding.dart';
import 'package:client_page/views/history_report_screen.dart';
import 'package:client_page/views/report_detail_screen.dart';
import 'package:client_page/views/report_input_screen.dart';
import 'package:get/get.dart';
import '../bindings/detail_data_binding.dart';
import '../bindings/login_binding.dart';
import '../bindings/splash_binding.dart';
import '../views/detail_data_screen.dart';
import '../views/login_screen.dart';
import '../views/splash_screen.dart';

class Routes {
  static const SPLASH = '/splash';
  static const LOGIN = '/login';
  static const HOME = '/home';
  static const HISTORY = '/HistoryReport';
  static const REPORTDETAIL = '/ReportDetail';
  static const REPORTINPUT = '/ReportInput';

  static final routes = [
    GetPage(
      name: SPLASH,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: LOGIN,
      page: () => LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: HOME,
      page: () => DetailDataView(),
      binding: DetailDataBinding(),
    ),
    GetPage(
        name: HISTORY,
        page: () => HistoryReportView(),
        binding: HistoryReportBinding(),
    ),
    GetPage(
      name: REPORTDETAIL,
      page: () => ReportDetailView(),
      binding: ReportDetailBinding(),
    ),
    GetPage(
      name: REPORTINPUT,
      page: () => ReportInputView(),
      binding: ReportInputBinding(),
    )

  ];
}
