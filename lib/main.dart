import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'dart:io';

import 'package:tv_app_order/view/unit_selection_screen.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();

  // TV-specific system UI mode
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Orders Dashboard TV',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: UnitSelectionScreen(),
      debugShowCheckedModeBanner: false,
      // GetX configuration
      enableLog: false, // Disable GetX logs for production
      defaultTransition: Transition.fade,
      transitionDuration: Duration(milliseconds: 300),
      // Memory management
      routingCallback: (routing) {
        // Clean up controllers when routes change
        if (routing?.previous != null && routing?.current != null) {
          // Optional: Add route-specific cleanup logic here
        }
      },
    );
  }
}