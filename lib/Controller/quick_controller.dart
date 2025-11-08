import 'package:get/get.dart';
import 'package:home_care/Pages/Quick/quick_page.dart';

class QuickController extends GetxController {
  void quick() {
    print("Go to Quick Services page");
    Get.to(
      () => QuickServicesPage(),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }
}
