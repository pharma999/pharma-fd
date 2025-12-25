import 'package:get/get.dart';
import 'package:home_care/Model/address_model.dart';
import 'package:home_care/Model/user_detail_model.dart';

// class ProfileController extends GetxController {
 
// }




class ProfileController extends GetxController {
  late UserDetail user;

  @override
  void onInit() {
    super.onInit();

    user = UserDetail(
      userId: '1',
      name: 'Alex Morgan',
      email: 'alex@example.com',
      phoneNumber: '+91 9876543210',
      gender: 'MALE',
      status: 'ACTIVE',
      blockStatus: 'UNBLOCKED',
      userService: 'UNSUBSCRIBED',
      serviceStatus: 'NEW',
      address1: Address(
        houseNumber: '12A',
        street: 'Jankipuram Sector-H',
        landmark: 'Near City Mall',
        pinCode: '226021',
        latitude: '26.8467',
        longitude: '80.9462',
        isPrimary: true,
      ),
      address2: null,
    );
  }

   void profile() {
    Get.offAllNamed('/profile');
    // print("book now");
  }
}
