import 'package:client_page/controllers/report_detail_controller.dart';
import 'package:get/get.dart';


class ReportDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportDetailController>(() => ReportDetailController());
  }
}
