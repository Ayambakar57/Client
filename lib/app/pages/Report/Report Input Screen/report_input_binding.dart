import 'package:client_page/app/pages/Report/Report%20Input%20Screen/report_input_controller.dart';
import 'package:get/get.dart';

class ReportInputBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportInputController>(() => ReportInputController());
  }
}
