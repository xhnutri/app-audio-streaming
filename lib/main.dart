import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'app/routes/app_pages.dart';

void main() async {
  runApp(GetMaterialApp(
    title: 'Flutter Sound Examples',
    debugShowCheckedModeBanner: false,
    initialRoute: Routes.list,
    getPages: AppPages.pages,
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}

///
// class ExamplesApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Sound Examples',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: ListPage(title: 'Flutter Sound Examples'),
//     );
//   }
// }
