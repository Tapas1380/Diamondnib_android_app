import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
      
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Initialize local notifications for Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    // Initialize local notifications for iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin.initialize(settings);

    // Request notification permissions
    NotificationSettings notificationSettings = 
        await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    
    print('Notification permissions: ${notificationSettings.authorizationStatus}');
    
    // Configure for iOS
    if (!kIsWeb) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // channelId
      'High Importance Notifications', // channelName
      channelDescription: 'This channel is used for important notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    
    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? 'You have a new message',
      details,
      payload: message.data.toString(),
    );
  }

  static Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }

  /// Subscribe to all broadcast topics for automatic notifications
  /// Call this when app starts or user logs in
  static Future<void> subscribeToAllTopics() async {
    try {
      await subscribeToTopic('all_users');  // Main topic for all notifications
      print('Successfully subscribed to all_users topic');
    } catch (e) {
      print('Error subscribing to topics: $e');
    }
  }

  /// Unsubscribe from all topics (e.g., when user logs out)
  static Future<void> unsubscribeFromAllTopics() async {
    try {
      await unsubscribeFromTopic('all_users');
      print('Successfully unsubscribed from all topics');
    } catch (e) {
      print('Error unsubscribing from topics: $e');
    }
  }
}