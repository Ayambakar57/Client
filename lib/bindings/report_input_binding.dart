import 'package:get/get.dart';
import '../controllers/report_input_controller.dart';

class ReportInputBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ReportInputController>(() => ReportInputController());
  }
}
