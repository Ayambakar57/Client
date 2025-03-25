import 'package:client_page/views/detail_data_screen.dart';
import 'package:client_page/views/history_report_screen.dart';
import 'package:client_page/views/report_detail_screen.dart';
import 'package:client_page/views/report_input_screen.dart';
import 'package:get/get.dart';
import '../views/login_screen.dart';
import '../views/splash_screen.dart';
import 'app_router.dart';



class AppPages {
  static final pages = [
    GetPage(name: Routes.SPLASH, page: () => SplashScreen()),
    GetPage(name: Routes.LOGIN, page: () => LoginScreen()),
    GetPage(name: Routes.HISTORY, page:() => HistoryReportView()),
    GetPage(name: Routes.HOME, page: () => DetailDataView()),
    GetPage(name: Routes.REPORTDETAIL, page:() => ReportDetailView()),
    GetPage(name: Routes.REPORTINPUT, page:() => ReportInputView()),
  ];
}
