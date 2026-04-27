// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:easy_localization/easy_localization.dart';
// import '../models/contact.dart';
// import '../widgets/emergency_contacts.dart';

// class EmergencyScreen extends StatefulWidget {
//   const EmergencyScreen({super.key});

//   @override
//   State<EmergencyScreen> createState() => _EmergencyScreenState();
// }

// class _EmergencyScreenState extends State<EmergencyScreen> {
//   List<Contact> contacts = [];

//   @override
//   void initState() {
//     super.initState();
//   }

//   void _makePhoneCall(String phoneNumber) async {
//     final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
//     if (await canLaunchUrl(launchUri)) {
//       await launchUrl(launchUri);
//     } else if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("can_not_do_a_call".tr())),
//       );
//     }
//   }

//   Future<void> _playAlarm() async {
//     try {
//       final player = AudioPlayer();
//       await player.play(AssetSource("sounds/alarm.wav"));
//     } catch (e) {
//       debugPrint("Alarm error: $e");
//     }
//   }

//   Future<Map<String, dynamic>?> _getLocation() async {
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
//         "url":
//             "https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}",
//       };
//     } catch (e) {
//       debugPrint("Location error: $e");
//       return null;
//     }
//   }

//   Future<void> _logEmergencyToFirebase(Map<String, dynamic>? loc) async {
//     final uid = FirebaseAuth.instance.currentUser?.uid;
//     if (uid == null) return;

//     final alertRef =
//         FirebaseDatabase.instance.ref().child("emergencyAlerts/$uid").push();

//     await alertRef.set({
//       "timestamp": DateTime.now().toIso8601String(),
//       "lat": loc?["lat"],
//       "lng": loc?["lng"],
//       "mapURL": loc?["url"],
//     });
//   }

//   Future<void> _sendSMS(String phone, String message) async {
//     final Uri smsUri = Uri(
//       scheme: "sms",
//       path: phone,
//       queryParameters: {"body": message},
//     );

//     if (await canLaunchUrl(smsUri)) {
//       await launchUrl(smsUri);
//     }
//   }

//   Future<void> _handleEmergencyAlert() async {
//     await _playAlarm();
//     final loc = await _getLocation();

//     final message = """
// 🚨 *تنبيه طارئ من تطبيق EpiCare*
// حدثت نوبة محتملة للمريض!

// الموقع:
// ${loc?["url"] ?? "location_could_not_be_found".tr()}

// الرجاء التدخل فوراً.
// """;

//     for (final c in contacts) {
//       await _sendSMS(c.phone, message);
//     }

//     await _logEmergencyToFirebase(loc);

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("🚨Alert + sound + location sent successfully".tr()),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final height = size.height;
//     final width = size.width;

//     return Scaffold(
//       backgroundColor: Color(0xFFF9FAFB),
//       appBar: AppBar(
//         title: Text(
//           "emergency".tr(),
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topRight,
//               end: Alignment.bottomLeft,
//               colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
//             ),
//           ),
//         ),
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(
//             horizontal: width * 0.05,
//             vertical: height * 0.02,
//           ),
//           child: Column(
//             children: [
//               _buildEmergencyHeader(width, height),
//               SizedBox(height: height * 0.02),
//               EmergencyContacts(
//                 contacts: contacts,
//                 onContactsChanged: (updatedContacts) {
//                   setState(() => contacts = updatedContacts);
//                 },
//               ),
//               SizedBox(height: height * 0.02),
//               _buildQuickCallButton(width, height),
//               SizedBox(height: height * 0.02),
//               _buildEmergencyAlertButton(width, height),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmergencyHeader(double width, double height) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.04),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
//         ),
//         borderRadius: BorderRadius.circular(width * 0.05),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.red.withOpacity(0.3),
//             blurRadius: width * 0.05,
//             offset: Offset(0, height * 0.01),
//           )
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: width * 0.18,
//             height: width * 0.18,
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(width * 0.06),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: width * 0.005,
//               ),
//             ),
//             child: Icon(
//               Icons.shield_rounded,
//               color: Colors.white,
//               size: width * 0.1,
//             ),
//           ),
//           SizedBox(height: height * 0.02),
//           Text(
//             "emergency_smart_system".tr(),
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: width * 0.06,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: height * 0.015),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildFeatureIcon(Icons.location_on_rounded, "Gps".tr()),
//               _buildFeatureIcon(Icons.phone_rounded, "emergency_connection".tr()),
//               _buildFeatureIcon(Icons.favorite_rounded, "live_data".tr()),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickCallButton(double width, double height) {
//     return SizedBox(
//       width: double.infinity,
//       height: height * 0.08,
//       child: ElevatedButton(
//         onPressed: () => _makePhoneCall('101'),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Color(0xFFDC2626),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(width * 0.03),
//             side: BorderSide(
//               color: Color(0xFFFCA5A5),
//               width: width * 0.01,
//             ),
//           ),
//           elevation: 8,
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.phone_rounded, size: width * 0.05),
//             SizedBox(width: width * 0.02),
//             Text(
//               "emergancy:101".tr(),
//               style: TextStyle(
//                 fontSize: width * 0.045,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEmergencyAlertButton(double width, double height) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topRight,
//           end: Alignment.bottomLeft,
//           colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
//         ),
//         borderRadius: BorderRadius.circular(width * 0.05),
//         border: Border.all(
//           color: Color(0xFFFCA5A5),
//           width: width * 0.01,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.red.withOpacity(0.3),
//             blurRadius: width * 0.05,
//             offset: Offset(0, height * 0.01),
//           )
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(width * 0.05),
//           onTap: _handleEmergencyAlert,
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.025),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: width * 0.12,
//                   height: width * 0.12,
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     Icons.warning_amber_rounded,
//                     color: Colors.white,
//                     size: width * 0.08,
//                   ),
//                 ),
//                 SizedBox(width: width * 0.04),
//                 Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "send_emergency_alert".tr(),
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: width * 0.045,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       "Location + Contact with Parents".tr(),
//                       style: TextStyle(
//                         color: Color(0xFFFECACA),
//                         fontSize: width * 0.03,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFeatureIcon(IconData icon, String label) {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;

//     return Container(
//       padding: EdgeInsets.all(width * 0.03),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(width * 0.03),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: Colors.white, size: width * 0.06),
//           SizedBox(height: height * 0.005),
//           Text(
//             label,
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: width * 0.035,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/contact.dart';
import '../widgets/emergency_contacts.dart';
import '../services/emergency_service.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.phone,
      Permission.sms,
      Permission.location,
    ].request();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // اطلب إذن المكالمات أولاً
      var status = await Permission.phone.status;
      
      if (!status.isGranted) {
        status = await Permission.phone.request();
      }
      
      if (status.isGranted) {
        final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
        
        if (await canLaunchUrl(launchUri)) {
          await launchUrl(launchUri);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("can_not_do_a_call".tr())),
            );
          }
        }
      } else {
        // المستخدم رفض الإذن
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("call_permission_must_be_granted".tr())),
          );
        }
      }
    } catch (e) {
      debugPrint('Error making call: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error in call permission'.tr())),
        );
      }
    }
  }

  Future<void> _playAlarm() async {
    try {
      final player = AudioPlayer();
      await player.play(AssetSource("sounds/alarm.wav"));
    } catch (e) {
      debugPrint("Alarm error: $e");
    }
  }

  Future<Map<String, dynamic>?> _getLocation() async {
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
        desiredAccuracy: LocationAccuracy.high,
      );

      return {
        "lat": pos.latitude,
        "lng": pos.longitude,
        "url":
            "https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}",
      };
    } catch (e) {
      debugPrint("Location error: $e");
      return null;
    }
  }

  Future<void> _logEmergencyToFirebase(Map<String, dynamic>? loc) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final alertRef =
        FirebaseDatabase.instance.ref().child("emergencyAlerts/$uid").push();

    await alertRef.set({
      "timestamp": DateTime.now().toIso8601String(),
      "lat": loc?["lat"],
      "lng": loc?["lng"],
      "mapURL": loc?["url"],
    });
  }

  Future<void> _sendSMS(String phone, String message) async {
    try {
      // تحقق من إذن الرسائل
      var status = await Permission.sms.status;
      
      if (!status.isGranted) {
        status = await Permission.sms.request();
      }
      
      if (status.isGranted) {
        final Uri smsUri = Uri(
          scheme: "sms",
          path: phone,
          queryParameters: {"body": message},
        );

        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
        }
      }
    } catch (e) {
      debugPrint("SMS error: $e");
    }
  }
// التعامل مع تنبيه الطوارئ
Future<void> _handleEmergencyAlert() async {
  await EmergencyService.triggerEmergency(
    context,
    contacts: contacts);

  if (mounted) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text("🚨 emergency_alert_sent".tr()),
    //     backgroundColor: Colors.red,
    //   ),
    // );
  }
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          "emergency".tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.02,
          ),
          child: Column(
            children: [
              _buildEmergencyHeader(width, height),
              SizedBox(height: height * 0.02),
              EmergencyContacts(
                contacts: contacts,
                onContactsChanged: (updatedContacts) {
                  setState(() => contacts = updatedContacts);
                },
              ),
              SizedBox(height: height * 0.02),
              _buildQuickCallButton(width, height),
              SizedBox(height: height * 0.02),
              _buildEmergencyAlertButton(width, height),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyHeader(double width, double height) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
        ),
        borderRadius: BorderRadius.circular(width * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: width * 0.05,
            offset: Offset(0, height * 0.01),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            width: width * 0.18,
            height: width * 0.18,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(width * 0.06),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: width * 0.005,
              ),
            ),
            child: Icon(
              Icons.shield_rounded,
              color: Colors.white,
              size: width * 0.1,
            ),
          ),
          SizedBox(height: height * 0.02),
          Text(
            "emergency_smart_system".tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.06,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: height * 0.015),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureIcon(Icons.location_on_rounded, "Gps".tr()),
              _buildFeatureIcon(Icons.phone_rounded, "emergency_connection".tr()),
              _buildFeatureIcon(Icons.favorite_rounded, "live_data".tr()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickCallButton(double width, double height) {
    return SizedBox(
      width: double.infinity,
      height: height * 0.08,
      child: ElevatedButton(
        onPressed: () => _makePhoneCall('101'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFDC2626),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.03),
            side: BorderSide(
              color: Color(0xFFFCA5A5),
              width: width * 0.01,
            ),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_rounded, size: width * 0.05),
            SizedBox(width: width * 0.02),
            Text(
              "emergancy:101".tr(),
              style: TextStyle(
                fontSize: width * 0.045,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyAlertButton(double width, double height) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
        ),
        borderRadius: BorderRadius.circular(width * 0.05),
        border: Border.all(
          color: Color(0xFFFCA5A5),
          width: width * 0.01,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: width * 0.05,
            offset: Offset(0, height * 0.01),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(width * 0.05),
          onTap: _handleEmergencyAlert,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.025),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: width * 0.12,
                  height: width * 0.12,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: width * 0.08,
                  ),
                ),
                SizedBox(width: width * 0.04),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "send_emergency_alert".tr(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Location + Contact with Parents".tr(),
                      style: TextStyle(
                        color: Color(0xFFFECACA),
                        fontSize: width * 0.03,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(width * 0.03),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(width * 0.03),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: width * 0.06),
          SizedBox(height: height * 0.005),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.035,
            ),
          ),
        ],
      ),
    );
  }
}
