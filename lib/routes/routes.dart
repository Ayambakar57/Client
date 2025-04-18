import 'package:client_page/app/pages/Detail%20Data%20Screen/detail_data_binding.dart';
import 'package:client_page/app/pages/Detail%20Data%20Screen/detail_data_view.dart';
import 'package:get/get.dart';
import '../app/pages/Detail History Screen/detail_binding.dart';
import '../app/pages/Detail History Screen/detail_view.dart';
import '../app/pages/Login screen/login_view.dart';
import '../app/pages/Report/History Report Screen/history_report_binding.dart';
import '../app/pages/Report/History Report Screen/history_report_view.dart';
import '../app/pages/Report/Report Detail Screen/report_detail_binding.dart';
import '../app/pages/Report/Report Detail Screen/report_detail_view.dart';
import '../app/pages/Report/Report Input Screen/report_input_binding.dart';
import '../app/pages/Report/Report Input Screen/report_input_view.dart';
import '../app/pages/Splash screen/splash_binding.dart';
import '../app/pages/Splash screen/splash_view.dart';

class Routes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const historyReport = '/HistoryReport';
  static const reportDetail = '/ReportDetail';
  static const reportInput = '/ReportInput';
  static const String detailHistory = '/detailhistory';



  static final List<GetPage> pages = [
    GetPage(
      name: splash,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: login,
      page: () => LoginView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: home,
      page: () => DetailDataView(),
      binding: DetailDataBinding(),
    ),
    GetPage(
      name: Routes.historyReport,
      page: () => HistoryReportView(),
      binding: HistoryReportBinding(),
    ),
    GetPage(
      name: Routes.reportDetail,
      page: () => ReportDetailView(),
      binding: ReportDetailBinding(),
    ),
    GetPage(
      name: Routes.reportInput,
      page: () => ReportInputView(),
      binding: ReportInputBinding(),
    ),
    GetPage(
      name: Routes.detailHistory,
      page: () => DetailHistoryView(),
      binding: DetailHistoryBinding(),
    ),

  ];
}
