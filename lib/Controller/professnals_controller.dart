import 'package:get/get.dart';

class ProfessnalsController extends GetxController {
  void bookNow() {
    Get.offAllNamed('/book-now');
    // print("book now");
  }

  void profilePage() {
    Get.offAllNamed('/professnal-page');
  }
}
