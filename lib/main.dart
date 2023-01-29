import 'package:flutter/material.dart';
import 'package:flutter_test_app/flutter_sms.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  await WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
        builder: (context, orientation, deviceType) {
          return GetMaterialApp(
            navigatorKey: navigatorKey,
            debugShowCheckedModeBanner: false,

            title: 'Test App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            initialRoute: '/',
            getPages: [
              GetPage(name: '/', page: () => SMSscreen()),

            ],
          );
        }
    );
  }
}
