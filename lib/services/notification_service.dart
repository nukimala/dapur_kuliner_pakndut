import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // 1. Meminta Izin (Request Permission)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // 2. Dapatkan Token FCM
      String? token = await _messaging.getToken();
      if (kDebugMode) {
        print('FCM Token: $token');
      }
      
      // Di aplikasi berskala besar, kirim token ini ke server (Firestore)
      // agar admin tahu ke token mana pesan spesifik harus dikirim.

      // 3. Tangani Pesan saat aplikasi Terbuka (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Got a message whilst in the foreground!');
          print('Message data: ${message.data}');
          
          if (message.notification != null) {
            print('Message also contained a notification: ${message.notification?.title} - ${message.notification?.body}');
          }
        }
      });

      // 4. Tangani saat Notifikasi ditekan sementara aplikasi di Background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Notifikasi ditekan! User kembali ke aplikasi dari background.');
        }
      });
      
      // 5. Tangani saat Notifikasi ditekan sementara aplikasi Terminated (Tertutup)
      RemoteMessage? initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        if (kDebugMode) {
          print('Aplikasi dibuka dari state terminated melalui notifikasi!');
        }
      }
    }
  }
}
