import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:diamondnib/utils/constant.dart';

class FCMBroadcastService {
  // Get this from Firebase Console → Project Settings → Cloud Messaging → Server Key
  static const String serverKey = 'YOUR_SERVER_KEY_HERE'; // Replace with your actual key
  
  /// Send notification to ALL Diamondnib users
  static Future<Map<String, dynamic>> sendToAllUsers({
    required String title,
    required String body,
    required String audioId,
    String? description,
    String? imageUrl,
  }) async {
    try {
      print('FCM: Sending broadcast to all users...');
      
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Authorization': 'key=$serverKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'to': '/topics/all_diamondnib_users',
          'notification': {
            'title': title,
            'body': body,
            'sound': 'default',
            'image': imageUrl,
          },
          'data': {
            'type': 'audio',
            'id': audioId,
            'title': title,
            'description': description ?? '',
            'screen': 'audio_player',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'image_url': imageUrl ?? '',
          },
          'android': {
            'priority': 'high',
            'notification': {
              'channel_id': Constant.appPackageName,
              'sound': 'default',
            }
          },
          'apns': {
            'payload': {
              'aps': {
                'content-available': 1,
                'sound': 'default',
                'badge': 1,
              }
            }
          }
        }),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print('✅ FCM: Broadcast sent successfully! Message ID: ${result['message_id']}');
        return {
          'success': true,
          'message': 'Notification sent to all users successfully',
          'messageId': result['message_id'],
        };
      } else {
        print('❌ FCM: Broadcast failed - Status: ${response.statusCode}');
        print('FCM: Response: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to send notification: ${response.statusCode}',
          'error': response.body,
        };
      }
    } catch (e) {
      print('❌ FCM: Error sending broadcast: $e');
      return {
        'success': false,
        'message': 'Error sending notification: $e',
        'error': e.toString(),
      };
    }
  }

  /// Simple method for new audio notifications to all users
  static Future<Map<String, dynamic>> sendNewAudioToAllUsers({
    required String audioTitle,
    required String audioId,
    String? description,
    String? imageUrl,
  }) async {
    return await sendToAllUsers(
      title: '🎵 $audioTitle',
      body: description ?? 'New audio content is available! Tap to listen now.',
      audioId: audioId,
      description: description,
      imageUrl: imageUrl,
    );
  }

  /// Send general announcement to all users
  static Future<Map<String, dynamic>> sendAnnouncementToAll({
    required String title,
    required String message,
  }) async {
    return await sendToAllUsers(
      title: title,
      body: message,
      audioId: 'announcement_${DateTime.now().millisecondsSinceEpoch}',
      description: message,
    );
  }

  /// Send urgent notification to all users
  static Future<Map<String, dynamic>> sendUrgentToAll({
    required String title,
    required String message,
  }) async {
    return await sendToAllUsers(
      title: '🚨 $title',
      body: message,
      audioId: 'urgent_${DateTime.now().millisecondsSinceEpoch}',
      description: message,
    );
  }
}