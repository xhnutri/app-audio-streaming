// Paquetes
import 'package:get/get.dart';

// Bindings

// Pantallas
import '../bindings/list_binding.dart';
import '../bindings/serveraudio_binding.dart';
import '../bindings/useraudio_binding.dart';
import '../ui/pages/list_page/list_page.dart';
import '../ui/pages/serveraudio_page/serveraudio_page.dart';
import '../ui/pages/useraudio_page/useraudio_page.dart';

part './app_routes.dart';

/// Clase que contiene la lista de pantallas que
/// tiene la app.
abstract class AppPages {
  /// Lista de pantallas que tendra la app
  static final pages = [
    GetPage(
        name: Routes.serveraudio,
        page: () => ServerAudioPage(),
        binding: ServerAudioBinding()),
    GetPage(
        name: Routes.useraudio,
        page: () => UserAudioPage(),
        binding: UserAudioBinding()),
    GetPage(
        name: Routes.list,
        page: () => ListPage(
              title: "Lista de Audio",
            ),
        binding: ListBinding()),
  ];
}
