
import 'package:get/get.dart';
import '../controllers/useraudio_controller.dart';


class UserAudioBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserAudioController>(() => UserAudioController());
  }
}