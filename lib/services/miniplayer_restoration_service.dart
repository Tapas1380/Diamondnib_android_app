// lib/services/miniplayer_restoration_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Enhanced service for handling miniplayer state persistence and restoration
class MiniplayerRestorationService {
  // Keys for SharedPreferences
  static const String _miniplayerStateKey = 'miniplayer_visible';
  static const String _audioIdKey = 'last_audio_id';
  static const String _currentAudioDataKey = 'current_audio_data';
  static const String _restorationAttemptedKey = 'restoration_attempted';
  static const String _appLaunchedKey = 'app_launched_count';
  static const String _isRestoredModeKey = 'is_restored_mode'; // Track if miniplayer is in restored mode

  // Static instance for easy access
  static final MiniplayerRestorationService _instance = 
      MiniplayerRestorationService._internal();
  factory MiniplayerRestorationService() => _instance;
  MiniplayerRestorationService._internal();

  // State tracking
  bool _isRestoring = false;
  Completer<void>? _restorationCompleter;
  
  // Track if currently in restored mode (only 1 track loaded)
  static bool isInRestoredMode = false;
  static Map<String, dynamic>? restoredAudioData;

  /// ==================== SAVE STATE ====================
  /// Save miniplayer state when audio is playing
  static Future<void> saveMiniplayerState({
    required MediaItem currentItem,
    required String audioUrl, // Explicit URL parameter
    String? thumbnailUrl,
    String? artistName,
    String? description,
    int? durationInSeconds,
    int? currentPositionMs, // Current playback position
    String? contentId, // Content/Album ID for loading full playlist
    int? currentIndex, // Current track index in playlist
    int? totalTracks, // Total tracks in playlist
  }) async {
    try {
      print('💾 [SAVE] ===== STARTING SAVE MINIPLAYER STATE =====');
      
      if (currentItem.id.isEmpty) {
        print('❌ [SAVE] Current item ID is empty, cannot save');
        return;
      }
      
      if (audioUrl.isEmpty) {
        print('❌ [SAVE] Audio URL is empty, cannot save');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      
      print('💾 [SAVE] Audio ID: ${currentItem.id}');
      print('💾 [SAVE] Audio URL: $audioUrl');
      print('💾 [SAVE] Title: ${currentItem.title}');
      print('💾 [SAVE] Thumbnail: $thumbnailUrl');
      print('💾 [SAVE] Artist: $artistName');
      print('💾 [SAVE] Position: ${currentPositionMs}ms');
      print('💾 [SAVE] Content ID: $contentId');
      print('💾 [SAVE] Track: ${(currentIndex ?? 0) + 1} of ${totalTracks ?? 1}');

      // Save audio ID
      await prefs.setString(_audioIdKey, currentItem.id);

      // Build comprehensive audio data
      final audioData = {
        'id': currentItem.id,
        'title': currentItem.title,
        'audioUrl': audioUrl,
        'thumbnailUrl': thumbnailUrl ?? currentItem.artUri?.toString() ?? '',
        'artistName': artistName ?? currentItem.artist ?? '',
        'description': description ?? currentItem.displaySubtitle ?? '',
        'durationInSeconds': durationInSeconds ?? 0,
        'currentPositionMs': currentPositionMs ?? 0,
        'album': currentItem.album ?? '',
        'genre': currentItem.genre ?? '',
        'contentId': contentId ?? currentItem.album ?? '',
        'currentIndex': currentIndex ?? 0,
        'totalTracks': totalTracks ?? 1,
        'savedAt': DateTime.now().toIso8601String(),
      };

      // Save to SharedPreferences
      final jsonData = jsonEncode(audioData);
      await prefs.setString(_currentAudioDataKey, jsonData);
      
      // Mark miniplayer as visible (should be restored) - CRITICAL!
      await prefs.setBool(_miniplayerStateKey, true);
      
      print('💾 [SAVE] ===== SAVE COMPLETE =====');
      print('💾 [SAVE] Title: ${currentItem.title}, Position: ${currentPositionMs}ms');

    } catch (e, stackTrace) {
      print('❌ [SAVE] Error saving miniplayer state: $e');
      print('❌ [SAVE] Stack trace: $stackTrace');
    }
  }

  /// ==================== RESTORE STATE ====================
  /// Restore miniplayer state from SharedPreferences
  static Future<Map<String, dynamic>?> restoreMiniplayerState() async {
    try {
      print('🔄 [RESTORE] ===== STARTING RESTORE =====');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Check if miniplayer should be visible
      final isVisible = prefs.getBool(_miniplayerStateKey) ?? false;
      print('🔄 [RESTORE] Miniplayer visible flag: $isVisible');
      
      if (!isVisible) {
        print('🔄 [RESTORE] Miniplayer not visible, skipping restore');
        return null;
      }
      
      // Get saved audio data
      final audioDataJson = prefs.getString(_currentAudioDataKey);
      print('🔄 [RESTORE] Audio data JSON exists: ${audioDataJson != null && audioDataJson.isNotEmpty}');
      
      if (audioDataJson == null || audioDataJson.isEmpty) {
        print('❌ [RESTORE] No audio data found');
        return null;
      }
      
      final audioData = jsonDecode(audioDataJson) as Map<String, dynamic>;
      print('🔄 [RESTORE] Audio data parsed successfully');
      print('🔄 [RESTORE] Title: ${audioData['title']}');
      print('🔄 [RESTORE] ID: ${audioData['id']}');
      print('🔄 [RESTORE] ⭐ Saved position: ${audioData['currentPositionMs']}ms (${(audioData['currentPositionMs'] ?? 0) / 1000}s)');
      
      return audioData;
      
    } catch (e, stackTrace) {
      print('❌ [RESTORE] Error restoring state: $e');
      print('❌ [RESTORE] Stack trace: $stackTrace');
      return null;
    }
  }

  /// ==================== SETUP AUDIO PLAYER ====================
  /// Setup audio player with restored data
  static Future<bool> setupAudioPlayerWithRestoredData({
    required AudioPlayer audioPlayer,
    required Map<String, dynamic> audioData,
  }) async {
    try {
      print('🎵 [SETUP] Setting up audio player with restored data...');
      print('🎵 [SETUP] Audio data keys: ${audioData.keys.toList()}');
      
      // Get URL - check both 'audioUrl' (new format) and 'url' (old format)
      final url = audioData['audioUrl']?.toString() ?? audioData['url']?.toString();
      if (url == null || url.isEmpty) {
        print('❌ [SETUP] No URL in audio data');
        print('❌ [SETUP] audioUrl: ${audioData['audioUrl']}');
        print('❌ [SETUP] url: ${audioData['url']}');
        return false;
      }
      
      print('🎵 [SETUP] Audio URL: $url');

      // Create MediaItem from saved data
      final mediaItem = MediaItem(
        id: audioData['id']?.toString() ?? 'unknown',
        title: audioData['title']?.toString() ?? 'Unknown Audio',
        album: audioData['contentId']?.toString() ?? audioData['album']?.toString() ?? '',
        artist: audioData['artistName']?.toString() ?? '',
        artUri: audioData['thumbnailUrl']?.toString().isNotEmpty == true 
            ? Uri.tryParse(audioData['thumbnailUrl'].toString())
            : null,
        genre: audioData['genre']?.toString(),
        duration: Duration(
          seconds: (audioData['durationInSeconds'] as int?) ?? 0,
        ),
        extras: {
          'url': url,
          'audio': url,
          'audioUrl': url,
          'description': audioData['description']?.toString() ?? '',
          'contentType': audioData['contentType']?.toString() ?? 'audio',
          'contentId': audioData['contentId']?.toString() ?? audioData['album']?.toString() ?? '',
          'isRestored': true,
        },
      );

      print('🎵 [SETUP] Created MediaItem: ${mediaItem.title}, ID: ${mediaItem.id}');
      print('🎵 [SETUP] Content ID: ${mediaItem.album}');

      // Set up the audio source
      await audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: mediaItem,
        ),
        preload: true,
      );
      
      // Wait for the audio source to be ready before seeking
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Seek to saved position if available
      final savedPosition = audioData['currentPositionMs'] as int? ?? 0;
      if (savedPosition > 0) {
        print('🎵 [SETUP] Seeking to saved position: ${savedPosition}ms (${savedPosition / 1000}s)');
        await audioPlayer.seek(Duration(milliseconds: savedPosition));
        
        // Verify the seek worked
        await Future.delayed(const Duration(milliseconds: 200));
        print('🎵 [SETUP] After seek, current position: ${audioPlayer.position.inMilliseconds}ms');
      }

      // ⭐ MARK AS RESTORED MODE - next/previous won't work until user plays from content page
      isInRestoredMode = true;
      restoredAudioData = audioData;
      print('🎵 [SETUP] ⚠️ Player is in RESTORED MODE - only 1 track loaded');
      print('🎵 [SETUP] Content ID for reload: ${audioData['contentId']}');

      print('✅ [SETUP] Audio player setup successful');
      return true;

    } catch (e, stackTrace) {
      print('❌ [SETUP ERROR] Failed to setup audio player: $e');
      print('❌ [SETUP ERROR] Stack trace: $stackTrace');
      return false;
    }
  }
  
  /// Clear restored mode flag (call when user plays from content page)
  static void clearRestoredMode() {
    print('🔄 [RESTORE MODE] Clearing restored mode flag');
    isInRestoredMode = false;
    restoredAudioData = null;
  }
  
  /// Get content ID from restored data (for reloading full playlist)
  static String? getRestoredContentId() {
    return restoredAudioData?['contentId']?.toString() ?? 
           restoredAudioData?['album']?.toString();
  }
  
  /// Get current index from restored data
  static int getRestoredCurrentIndex() {
    return restoredAudioData?['currentIndex'] as int? ?? 0;
  }
  
  /// Check if we need to reload full playlist
  static bool needsPlaylistReload() {
    return isInRestoredMode;
  }
  
  /// Get all restored data for MusicDetails to use
  static Map<String, dynamic>? getRestoredDataForReload() {
    if (!isInRestoredMode || restoredAudioData == null) {
      return null;
    }
    return {
      'contentId': restoredAudioData!['contentId'] ?? restoredAudioData!['album'] ?? '',
      'currentIndex': restoredAudioData!['currentIndex'] ?? 0,
      'currentPositionMs': restoredAudioData!['currentPositionMs'] ?? 0,
      'title': restoredAudioData!['title'] ?? '',
      'episodeId': restoredAudioData!['id'] ?? '',
    };
  }

  /// ==================== NAVIGATION HELPERS ====================
  /// Navigate to MusicDetails with restored data
  static Future<void> navigateToMusicDetails({
    required BuildContext context,
    required Map<String, dynamic> audioData,
    required Function(BuildContext, int, int) openDetailsCallback,
  }) async {
    try {
      print('🚀 [NAVIGATE] Navigating to MusicDetails...');
      
      // Extract necessary parameters for MusicDetails
      final videoId = int.tryParse(audioData['id']?.toString() ?? '0') ?? 0;
      final videoType = 1; // Assuming audio type, adjust as needed
      
      // Use callback to navigate
      openDetailsCallback(context, videoId, videoType);

      print('✅ [NAVIGATE] Navigation initiated');

    } catch (e, stackTrace) {
      print('❌ [NAVIGATE ERROR] Failed to navigate: $e');
      print('❌ [NAVIGATE ERROR] Stack trace: $stackTrace');
    }
  }

  /// ==================== CLEANUP ====================
  /// Clean up after successful restoration or failed attempt
  static Future<void> cleanupAfterRestoration({
    required bool success,
  }) async {
    try {
      print('🧹 [CLEANUP] Cleaning up after restoration. Success: $success');
      
      final prefs = await SharedPreferences.getInstance();
      
      if (success) {
        // On success, just mark restoration as attempted
        await prefs.setBool(_restorationAttemptedKey, true);
        print('🧹 [CLEANUP] Marked restoration as successful');
      } else {
        // On failure, clean up all state
        await _cleanupFailedRestoration(prefs);
      }
      
      print('🧹 [CLEANUP] Cleanup complete');
    } catch (e) {
      print('❌ [CLEANUP] Error during cleanup: $e');
    }
  }

  /// Private helper for failed restoration cleanup
  static Future<void> _cleanupFailedRestoration(SharedPreferences prefs) async {
    await prefs.setBool(_miniplayerStateKey, false);
    await prefs.remove(_audioIdKey);
    await prefs.remove(_currentAudioDataKey);
    await prefs.setBool(_restorationAttemptedKey, false);
    print('🧹 Cleaned up failed restoration state');
  }

  /// Clear all miniplayer state (call when audio stops)
  static Future<void> clearAllState() async {
    try {
      print('🧹 [CLEAR ALL] ===== CLEARING ALL MINIPLAYER STATE =====');
      
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool(_miniplayerStateKey, false);
      await prefs.remove(_audioIdKey);
      await prefs.remove(_currentAudioDataKey);
      await prefs.setBool(_restorationAttemptedKey, false);
      
      print('🧹 [CLEAR ALL] All state cleared');
      print('🧹 [CLEAR ALL] ===== END CLEAR =====');
    } catch (e) {
      print('❌ [CLEAR ALL] Error clearing state: $e');
    }
  }

  /// Check if miniplayer was previously playing
  static Future<bool> wasMiniplayerPlaying() async {
    try {
      print('🔍 [CHECK] Checking if miniplayer was playing...');
      final prefs = await SharedPreferences.getInstance();
      
      final wasPlaying = prefs.getBool(_miniplayerStateKey) ?? false;
      final audioId = prefs.getString(_audioIdKey);
      final audioData = prefs.getString(_currentAudioDataKey);
      
      print('🔍 [CHECK] Should restore: $wasPlaying');
      print('🔍 [CHECK] Has audio ID: ${audioId != null && audioId.isNotEmpty}');
      print('🔍 [CHECK] Has audio data: ${audioData != null && audioData.isNotEmpty}');
      
      // Return true only if we have all required data
      final shouldRestore = wasPlaying && 
                           audioId != null && 
                           audioId.isNotEmpty && 
                           audioData != null && 
                           audioData.isNotEmpty;
      
      print('🔍 [CHECK] Final decision - should restore: $shouldRestore');
      return shouldRestore;
    } catch (e) {
      print('❌ [CHECK] Error checking miniplayer state: $e');
      return false;
    }
  }

  /// Debug method to check all saved data
  static Future<void> debugSavedState() async {
    try {
      print('🔍 [DEBUG] === SAVED STATE DEBUG ===');
      
      final prefs = await SharedPreferences.getInstance();
      
      final isVisible = prefs.getBool(_miniplayerStateKey) ?? false;
      final audioId = prefs.getString(_audioIdKey);
      final restorationAttempted = prefs.getBool(_restorationAttemptedKey) ?? false;
      final audioDataJson = prefs.getString(_currentAudioDataKey);
      
      print('🔍 [DEBUG] Miniplayer visible flag: $isVisible');
      print('🔍 [DEBUG] Audio ID: $audioId');
      print('🔍 [DEBUG] Restoration attempted: $restorationAttempted');
      
      if (audioDataJson != null && audioDataJson.isNotEmpty) {
        try {
          final audioData = jsonDecode(audioDataJson) as Map<String, dynamic>;
          print('🔍 [DEBUG] ✅ Audio data found:');
          print('🔍 [DEBUG]   - ID: ${audioData['id']}');
          print('🔍 [DEBUG]   - Title: ${audioData['title']}');
          print('🔍 [DEBUG]   - Audio URL: ${audioData['audioUrl']?.toString().substring(0, 50)}...');
          print('🔍 [DEBUG]   - Position: ${audioData['currentPositionMs']}ms');
          print('🔍 [DEBUG]   - Track: ${(audioData['currentIndex'] ?? 0) + 1} of ${audioData['totalTracks'] ?? 1}');
          print('🔍 [DEBUG]   - Saved at: ${audioData['savedAt']}');
        } catch (e) {
          print('🔍 [DEBUG] Error parsing audio data: $e');
        }
      } else {
        print('🔍 [DEBUG] ❌ No audio data found');
      }
      
      print('🔍 [DEBUG] === END DEBUG ===');
    } catch (e) {
      print('❌ [DEBUG] Error in debugSavedState: $e');
    }
  }
}