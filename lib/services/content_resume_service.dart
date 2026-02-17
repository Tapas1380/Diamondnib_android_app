import 'package:shared_preferences/shared_preferences.dart';
import 'package:diamondnib/utils/utils.dart';

/// Service to track the last played episode index for each content/audiobook
/// This allows resuming from the correct episode when user returns to a content
class ContentResumeService {
  static const String _keyPrefix = 'content_last_episode_';
  static const String _keyPositionPrefix = 'content_last_position_';
  
  /// Save the last played episode index for a specific content
  static Future<void> saveLastPlayedEpisode({
    required String contentId,
    required int episodeIndex,
    int positionMs = 0,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$_keyPrefix$contentId', episodeIndex);
      await prefs.setInt('$_keyPositionPrefix$contentId', positionMs);
      printLog('📍 [RESUME SERVICE] Saved: contentId=$contentId, episodeIndex=$episodeIndex, positionMs=$positionMs');
    } catch (e) {
      printLog('❌ [RESUME SERVICE] Error saving last episode: $e');
    }
  }
  
  /// Get the last played episode index for a specific content
  /// Returns 0 if no saved episode found (start from beginning)
  static Future<int> getLastPlayedEpisodeIndex(String contentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final index = prefs.getInt('$_keyPrefix$contentId') ?? 0;
      printLog('📍 [RESUME SERVICE] Retrieved: contentId=$contentId, episodeIndex=$index');
      return index;
    } catch (e) {
      printLog('❌ [RESUME SERVICE] Error getting last episode: $e');
      return 0;
    }
  }
  
  /// Get the last played position in milliseconds for a specific content
  static Future<int> getLastPlayedPosition(String contentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final position = prefs.getInt('$_keyPositionPrefix$contentId') ?? 0;
      printLog('📍 [RESUME SERVICE] Retrieved position: contentId=$contentId, positionMs=$position');
      return position;
    } catch (e) {
      printLog('❌ [RESUME SERVICE] Error getting last position: $e');
      return 0;
    }
  }
  
  /// Check if there's a saved episode for this content
  static Future<bool> hasResumeData(String contentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('$_keyPrefix$contentId');
    } catch (e) {
      return false;
    }
  }
  
  /// Clear resume data for a specific content
  static Future<void> clearResumeData(String contentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_keyPrefix$contentId');
      await prefs.remove('$_keyPositionPrefix$contentId');
      printLog('🗑️ [RESUME SERVICE] Cleared resume data for contentId=$contentId');
    } catch (e) {
      printLog('❌ [RESUME SERVICE] Error clearing resume data: $e');
    }
  }
  
  /// Clear all resume data
  static Future<void> clearAllResumeData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_keyPrefix) || key.startsWith(_keyPositionPrefix)) {
          await prefs.remove(key);
        }
      }
      printLog('🗑️ [RESUME SERVICE] Cleared all resume data');
    } catch (e) {
      printLog('❌ [RESUME SERVICE] Error clearing all resume data: $e');
    }
  }
}
