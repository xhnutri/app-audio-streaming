
import 'package:get/get.dart';
import '../controllers/serveraudio_controller.dart';


class ServerAudioBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServerAudioController>(() => ServerAudioController());
  }
}