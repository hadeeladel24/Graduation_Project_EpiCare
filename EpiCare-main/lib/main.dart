// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'screens/splash_screen.dart';
// import 'screens/login_screen.dart';
// import 'screens/register_screen.dart';
// import 'screens/main_screen.dart';
// void main() async {
//  WidgetsFlutterBinding.ensureInitialized();
//  await Firebase.initializeApp(
// options: const FirebaseOptions(
// apiKey: "AIzaSyAVOKWPCPrdRuOIuLnRuudMhAwAJGIHUiY",
// appId: "1:716168221491:android:709b5f048cd819b7f4e446",
// messagingSenderId: "716168221491",
// projectId: "epicare-v1",
// databaseURL: "https://epicare-v1-default-rtdb.firebaseio.com/", 
// ),
// );
//  runApp( EpiCareApp());
// }
// class EpiCareApp extends StatelessWidget {
//   const EpiCareApp({super.key});
// @override
// Widget build(BuildContext context) {
//  return MaterialApp(
// title: 'EpiCare',
// debugShowCheckedModeBanner: false,
// theme: ThemeData(
//  useMaterial3: true,
// colorSchemeSeed: const Color(0xFF14B8A6),
//  fontFamily: 'Cairo',
//  ),
// home: const SplashScreen(),
//         routes: {
//        '/login': (_) => const LoginScreen(),
//        '/register': (_) => const RegisterScreen(),
//           '/main': (_) => const MainScreen(),
// }, );
// }
// }


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_screen.dart';

import 'package:epilepsy_care_app/services/notification_service.dart';
import 'package:epilepsy_care_app/services/bluetooth_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة الترجمة
  await EasyLocalization.ensureInitialized();
  
  // تهيئة Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAVOKWPCPrdRuOIuLnRuudMhAwAJGIHUiY",
      appId: "1:716168221491:android:709b5f048cd819b7f4e446",
      messagingSenderId: "716168221491",
      projectId: "epicare-v1",
      databaseURL: "https://epicare-v1-default-rtdb.firebaseio.com/", 
    ),
  );
  // تهيئة خدمة الإشعارات
  await NotificationService.initialize();
  // تهيئة خدمة البلوتوث
  await BluetoothService().start();
  

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ar'), // العربية
        Locale('en'), // الإنجليزية
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'), // اللغة الاحتياطية
      startLocale: const Locale('ar'), // اللغة الافتراضية عند فتح التطبيق
      child: const EpiCareApp(),
    ),
  );
}

class EpiCareApp extends StatelessWidget {
  const EpiCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EpiCare',
      debugShowCheckedModeBanner: false,
      
      // ربط الترجمة مع التطبيق
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF14B8A6),
        fontFamily: 'Cairo',
      ),
      
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/main': (_) => const MainScreen(),
      },
    );
  }
}