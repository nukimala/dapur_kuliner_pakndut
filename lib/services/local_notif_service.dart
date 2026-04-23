import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class LocalNotifService {
  static final LocalNotifService _instance = LocalNotifService._internal();

  factory LocalNotifService() {
    return _instance;
  }

  LocalNotifService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // For iOS/macOS we can add DarwinInitializationSettings here if needed
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print('Notification clicked: ${response.payload}');
        }
      },
    );
  }

  Future<void> showNotification({required int id, required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'admin_orders_channel', 
      'Admin Orders',
      channelDescription: 'Notifikasi pesanan baru untuk admin',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker'
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: 'new_order',
    );
  }
}
