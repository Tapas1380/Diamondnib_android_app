import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:diamondnib/utils/utils.dart';

// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  printLog('FCM: Handling background message: ${message.messageId}');
  printLog('FCM: Message data: ${message.data}');
  printLog('FCM: Message notification: ${message.notification?.title}');
}

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Callback functions for notification handling
  static Function(Map<String, dynamic> data)? onNotificationOpened;
  static Function(RemoteMessage message)? onNotificationReceived;

  // Android notification channel
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
  );

  /// Initialize FCM service
  static Future<void> initialize() async {
    if (kIsWeb) return;

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request notification permissions
    await _requestPermissions();

    // Initialize local notifications for foreground
    await _initializeLocalNotifications();

    // Create Android notification channel
    await _createNotificationChannel();

    // Setup message handlers
    _setupMessageHandlers();

    // Get and print FCM token
    String? token = await getCurrentToken();
    printLog('FCM: Device Token: $token');
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    printLog('FCM: Permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      printLog('FCM: User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      printLog('FCM: User granted provisional permission');
    } else {
      printLog('FCM: User declined or has not accepted permission');
    }
  }

  /// Initialize local notifications for displaying foreground notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Create Android notification channel
  static Future<void> _createNotificationChannel() async {
    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    printLog('FCM: Notification tapped with payload: ${response.payload}');
    if (response.payload != null && onNotificationOpened != null) {
      // Parse payload and call handler
      try {
        // You can parse JSON payload here if needed
        onNotificationOpened!({'payload': response.payload});
      } catch (e) {
        printLog('FCM: Error parsing notification payload: $e');
      }
    }
  }

  /// Setup FCM message handlers
  static void _setupMessageHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      printLog('FCM: Foreground message received!');
      printLog('FCM: Message data: ${message.data}');

      if (message.notification != null) {
        printLog('FCM: Notification Title: ${message.notification?.title}');
        printLog('FCM: Notification Body: ${message.notification?.body}');

        // Show local notification
        _showLocalNotification(message);
      }

      // Call the callback if set
      if (onNotificationReceived != null) {
        onNotificationReceived!(message);
      }
    });

    // When app is opened from terminated state via notification
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        printLog('FCM: App opened from terminated state via notification');
        printLog('FCM: Initial message data: ${message.data}');

        if (onNotificationOpened != null) {
          onNotificationOpened!(message.data);
        }
      }
    });

    // When app is in background and notification is tapped
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      printLog('FCM: App opened from background via notification');
      printLog('FCM: Message data: ${message.data}');

      if (onNotificationOpened != null) {
        onNotificationOpened!(message.data);
      }
    });
  }

  /// Show local notification for foreground messages
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: android.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Get current FCM token
  static Future<String?> getCurrentToken() async {
    try {
      String? token = await _messaging.getToken();
      return token;
    } catch (e) {
      printLog('FCM: Error getting token: $e');
      return null;
    }
  }

  /// Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      printLog('FCM: Subscribed to topic: $topic');
    } catch (e) {
      printLog('FCM: Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      printLog('FCM: Unsubscribed from topic: $topic');
    } catch (e) {
      printLog('FCM: Error unsubscribing from topic $topic: $e');
    }
  }

  /// Subscribe all users to general broadcast topic
  static Future<void> subscribeAllUsersToGeneralTopic() async {
    await subscribeToTopic('all_users');
  }

  /// Subscribe to audio-specific topics
  static Future<void> subscribeToAudioTopics() async {
    await subscribeToTopic('new_audiobooks');
    await subscribeToTopic('audio_updates');
  }

  /// Listen for token refresh
  static void onTokenRefresh(Function(String) callback) {
    _messaging.onTokenRefresh.listen((String token) {
      printLog('FCM: Token refreshed: $token');
      callback(token);
    });
  }
}