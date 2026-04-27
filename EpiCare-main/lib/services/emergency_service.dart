// v1.0.0
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyService {
  static final _db = FirebaseDatabase.instance.ref();
  static final _auth = FirebaseAuth.instance;
  static final AudioPlayer _player = AudioPlayer();
  
  // --------------------------------------------------
  // 🔥 تشغيل صوت الإنذار
  // --------------------------------------------------
  static Future<void> playAlarm() async {
    try {
      await _player.play(AssetSource("sounds/alarm.wav"));
    } catch (e) {
      debugPrint("Alarm Error: $e");
    }
  }
  
  // --------------------------------------------------
  // 📍 الحصول على الموقع الحالي
  // --------------------------------------------------
  static Future<Map<String, dynamic>?> getLocation() async {
    try {
      bool enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;
      
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      return {
        "lat": pos.latitude,
        "lng": pos.longitude,
        "locationURL":
            "https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}",
      };
    } catch (e) {
      debugPrint("Location Error: $e");
      return null;
    }
  }
  
  // --------------------------------------------------
  // 🚨 إرسال بلاغ الطوارئ إلى Firebase
  // --------------------------------------------------
  static Future<void> sendEmergencyAlert() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    
    final ref = _db.child("emergencyAlerts/$uid").push();
    
    final Map<String, dynamic> payload = {
      "timestamp": DateTime.now().toIso8601String(),
      "userId": uid,
      "type": "seizure_alert",
    };
    
    final loc = await getLocation();
    if (loc != null) {
      payload.addAll(loc);
    }
    
    await ref.set(payload);
  }
  
  // --------------------------------------------------
  // 📱 فتح تطبيق الرسائل
  // --------------------------------------------------
  static Future<void> _openSMSApp({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      var status = await Permission.sms.status;
      if (!status.isGranted) {
        status = await Permission.sms.request();
      }
      
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final Uri smsUri = Uri(
        scheme: "sms",
        path: cleanNumber,
        queryParameters: {"body": message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("SMS error: $e");
    }
  }
  
  // --------------------------------------------------
  // 🎯 الوظيفة الرئيسية - مبسطة ومباشرة
  // --------------------------------------------------
  static Future<void> triggerEmergency(
    BuildContext context, {
    List<dynamic>? contacts,
  }) async {
    // 1. التحقق من جهات الاتصال
    if (contacts == null || contacts.isEmpty) {
      if (context.mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text("emergency_seizure_alert_sent".tr()),
        //     backgroundColor: Colors.red,
        //     duration: const Duration(seconds: 2),
        //   ),
        // );
      }
      return;
    }
    
    // 2. تشغيل الإنذار
    await playAlarm();
    
    // 3. الحصول على الموقع
    final location = await getLocation();
    
    // 4. حفظ في Firebase
    await sendEmergencyAlert();
    
    // 5. تحضير الرسالة
    final locationText = location?["locationURL"] ?? "location not found".tr();
    final message = """
🚨 تنبيه طوارئ من EpiCare

حدثت نوبة محتملة للمريض!

الموقع:
$locationText

الرجاء التدخل فوراً.
""";
    
    // 6. إرسال الرسائل - طريقة مبسطة
    // نفتح تطبيق الرسائل لكل جهة اتصال بدون انتظار
    for (int i = 0; i < contacts.length; i++) {
      final contact = contacts[i];
      
      if (context.mounted) {
        // عرض رسالة للمستخدم
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text('📨 Messages are being opened for${contact.name ?? "contact ${i + 1}"}...').tr(),
        //     duration: const Duration(seconds: 2),
        //     backgroundColor: Colors.blue,
        //   ),
        // );
      }
      
      // فتح تطبيق الرسائل
      await _openSMSApp(
        phoneNumber: contact.phone ?? '',
        message: message,
      );
      
      // انتظار 5 ثواني (يعطي المستخدم وقت يرسل ويرجع)
      await Future.delayed(const Duration(seconds: 5));
    }
    
    // 7. رسالة النهاية
    if (context.mounted) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text('✅The messaging app has been opened for${contacts.length} contacts.').tr(),
      //     backgroundColor: Colors.green,
      //     duration: const Duration(seconds: 3),
      //   ),
      // );
    }
  }
}



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:http/http.dart' as http;
// import 'notification_service.dart';

// class EmergencyService {
//   static final _auth = FirebaseAuth.instance;
//   static final AudioPlayer _player = AudioPlayer();

//   static bool _triggered = false;

//   // 🔥 تشغيل صوت الإنذار
//   static Future<void> playAlarm() async {
//     try {
//       await _player.play(AssetSource("sounds/alarm.wav"));
//     } catch (e) {
//       debugPrint("Alarm Error: $e");
//     }
//   }

//   // 📍 الحصول على الموقع
//   static Future<Map<String, double>?> getLocation() async {
//     try {
//       bool enabled = await Geolocator.isLocationServiceEnabled();
//       if (!enabled) return null;

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         return null;
//       }

//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       return {
//         "lat": pos.latitude,
//         "lng": pos.longitude,
//       };
//     } catch (_) {
//       return null;
//     }
//   }

//   // 🚨 الدالة الرئيسية
//   static Future<void> triggerEmergency(BuildContext context) async {
//     if (_triggered) return;
//     _triggered = true;

//     final uid = _auth.currentUser?.uid;
//     if (uid == null) return;

//     // 1️⃣ Alarm
//     await playAlarm();

//     // 2️⃣ Location
//     final loc = await getLocation();

//     // 3️⃣ Local notification
//     await NotificationService.showEmergencyAlert(
//       contactName: "Emergency",
//       message: "🚨 Seizure detected",
//     );

//     // 4️⃣ إرسال للباك إند (SMS + Call تلقائي)
//     try {
//       await http.post(
//         Uri.parse("http://192.168.11.4:5000/seizure_event"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "userId": uid,
//           "lat": loc?["lat"],
//           "lng": loc?["lng"],
//         }),
//       );
//     } catch (e) {
//       debugPrint("Backend error: $e");
//     }

//     // 5️⃣ إعادة السماح بعد دقيقتين
//     Future.delayed(const Duration(minutes: 2), () {
//       _triggered = false;
//     });

//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("🚨 emergency_alert_sent".tr()),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }
// }
