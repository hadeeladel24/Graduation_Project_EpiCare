import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _notifications.initialize(initializationSettings);
  }

  static Future<void> showMedicationReminder({
    required int id,
    required String title,
    required String body,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medication_channel',
      'medication_reminders'.tr(),
      channelDescription: 'medication_reminders_desc'.tr(),
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'medication',
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> showEmergencyAlert({
    required String contactName,
    required String message,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'emergency_channel',
      'emergency_alerts'.tr(),
      channelDescription: 'emergency_alerts_desc'.tr(),
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'emergency',
      color: const Color(0xFFDC2626),
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );
     NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

await _notifications.show(
  id,
  'emergency_notification_title'.tr(),
  message,
  notificationDetails,
);

  }

  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}