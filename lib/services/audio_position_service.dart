import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AudioPositionService {
  static const String _positionKeyPrefix = 'audio_position_';
  static const String _durationKeyPrefix = 'audio_duration_';

  static Future<void> savePosition(String audioId, Duration position, {Duration? duration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_positionKeyPrefix$audioId', position.inMilliseconds);
      
      if (duration != null) {
        await prefs.setInt('$_durationKeyPrefix$audioId', duration.inMilliseconds);
      }
      
      print('✅ Position saved for $audioId: ${position.inSeconds}s');
    } catch (e) {
      print('❌ Error saving position: $e');
    }
  }

  static Future<Duration> getPosition(String audioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positionMs = prefs.getInt('$_positionKeyPrefix$audioId') ?? 0;
      print('📁 Retrieved position for $audioId: ${(positionMs / 1000).round()}s');
      return Duration(milliseconds: positionMs);
    } catch (e) {
      print('❌ Error getting position: $e');
      return Duration.zero;
    }
  }

  static Future<Duration> getDuration(String audioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final durationMs = prefs.getInt('$_durationKeyPrefix$audioId') ?? 0;
      return Duration(milliseconds: durationMs);
    } catch (e) {
      return Duration.zero;
    }
  }

  static Future<void> clearPosition(String audioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_positionKeyPrefix$audioId');
      await prefs.remove('$_durationKeyPrefix$audioId');
      print('🗑️ Position cleared for $audioId');
    } catch (e) {
      print('❌ Error clearing position: $e');
    }
  }

  static Future<bool> hasPosition(String audioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('$_positionKeyPrefix$audioId');
    } catch (e) {
      return false;
    }
  }
}