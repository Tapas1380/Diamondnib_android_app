import 'dart:developer';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:diamondnib/pages/bottombar.dart';
import 'package:diamondnib/pages/musicdetails.dart';
import 'package:diamondnib/provider/downloadprovider.dart';
import 'package:diamondnib/provider/profileprovider.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/musicutils.dart';
import 'package:diamondnib/services/miniplayer_restoration_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
//import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class MusicManager {
  late ConcatenatingAudioSource playlist;
  dynamic episodeDataList;
  BuildContext context;
  bool _completionListenerAttached = false;
  static bool _saveStateListenerAttached = false; // Make static to prevent multiple listeners
  static DateTime? _lastSaveTime; // Prevent saving too frequently

  MusicManager(this.context) {
    // Attach listener to save state when audio starts playing (only once globally)
    _attachSaveStateListener();
  }
  
  /// Attach listener to save state when audio plays
  void _attachSaveStateListener() {
    if (_saveStateListenerAttached) return;
    _saveStateListenerAttached = true;
    
    print('🔊 [MUSIC MANAGER] Attaching save state listener (ONCE)');
    
    // Listen for player state changes
    audioPlayer.playerStateStream.listen((state) {
      // Save immediately when audio starts playing (no throttle for first save)
      if (state.playing && state.processingState == ProcessingState.ready) {
        print('🔊 [MUSIC MANAGER] Audio is playing and ready, saving state...');
        _saveFromCurrentAudioSource();
      }
    });
    
    // Also listen for track changes (when user skips to another episode)
    audioPlayer.currentIndexStream.listen((index) {
      if (index != null && audioPlayer.playing) {
        print('🔊 [MUSIC MANAGER] Track changed to index: $index, saving state...');
        _saveFromCurrentAudioSource();
      }
    });
    
    // Save position periodically while playing (every 10 seconds)
    audioPlayer.positionStream.listen((position) {
      if (audioPlayer.playing) {
        final now = DateTime.now();
        // Only save every 10 seconds to avoid too many writes
        if (_lastSaveTime == null || now.difference(_lastSaveTime!).inSeconds >= 10) {
          _lastSaveTime = now;
          print('🔊 [MUSIC MANAGER] Periodic position save at ${position.inSeconds}s');
          _saveFromCurrentAudioSource();
        }
      }
    });
  }
  
  /// Save state directly from audio player's current source (more reliable)
  void _saveFromCurrentAudioSource() async {
    try {
      print('💾 [MUSIC MANAGER] _saveFromCurrentAudioSource called');
      
      final sequence = audioPlayer.audioSource?.sequence;
      if (sequence == null || sequence.isEmpty) {
        print('❌ [MUSIC MANAGER] No audio source sequence available');
        return;
      }
      
      final currentIndex = audioPlayer.currentIndex ?? 0;
      final totalTracks = sequence.length;
      print('💾 [MUSIC MANAGER] Current playing index: $currentIndex of $totalTracks tracks');
      
      if (currentIndex >= sequence.length) {
        print('❌ [MUSIC MANAGER] Current index out of bounds');
        return;
      }
      
      final currentSource = sequence[currentIndex];
      final tag = currentSource.tag;
      
      if (tag == null || tag is! MediaItem) {
        print('❌ [MUSIC MANAGER] No MediaItem tag found');
        return;
      }
      
      final mediaItem = tag as MediaItem;
      print('💾 [MUSIC MANAGER] Saving from MediaItem: ${mediaItem.title}, ID: ${mediaItem.id}');
      
      // Get audio URL from extras or the source itself
      String audioUrl = '';
      
      // First try to get from extras
      if (mediaItem.extras != null) {
        audioUrl = mediaItem.extras!['url']?.toString() ?? 
                   mediaItem.extras!['audio']?.toString() ?? 
                   mediaItem.extras!['audioUrl']?.toString() ?? '';
        if (audioUrl.isNotEmpty) {
          print('💾 [MUSIC MANAGER] Got URL from extras: $audioUrl');
        }
      }
      
      // If not in extras, try from the source URI
      if (audioUrl.isEmpty && currentSource is UriAudioSource) {
        audioUrl = currentSource.uri.toString();
        print('💾 [MUSIC MANAGER] Got URL from UriAudioSource: $audioUrl');
      }
      
      if (audioUrl.isEmpty) {
        print('❌ [MUSIC MANAGER] Could not get audio URL');
        return;
      }
      
      // Also save the current position for resume
      final currentPosition = audioPlayer.position.inMilliseconds;
      print('💾 [MUSIC MANAGER] Current position: ${currentPosition}ms');
      
      // Get content ID from album field (we store it there in buildAudioSource)
      final contentId = mediaItem.album ?? '';
      print('💾 [MUSIC MANAGER] Content ID: $contentId');
      
      await MiniplayerRestorationService.saveMiniplayerState(
        currentItem: mediaItem,
        audioUrl: audioUrl,
        thumbnailUrl: mediaItem.artUri?.toString(),
        artistName: mediaItem.artist,
        description: mediaItem.displaySubtitle,
        durationInSeconds: mediaItem.duration?.inSeconds,
        currentPositionMs: currentPosition,
        contentId: contentId,
        currentIndex: currentIndex,
        totalTracks: totalTracks,
      );
      
      print('✅ [MUSIC MANAGER] State saved - Episode: ${mediaItem.title}, Position: ${currentPosition}ms');
      
    } catch (e, stackTrace) {
      print('❌ [MUSIC MANAGER] Error in _saveFromCurrentAudioSource: $e');
      print('❌ [MUSIC MANAGER] Stack trace: $stackTrace');
    }
  }
  
  CarouselController pageController = CarouselController();
  late ProgressDialog prDialog = ProgressDialog(context);
  late ProfileProvider profileProvider;

/* Music */
  void setInitialMusic(
      int cPosition,
      dynamic contenttype,
      dynamic dataList,
      String audioId,
      dynamic callApi,
      dynamic isContinueWatching,
      int stoptime,
      String isBuy,
      int isPaid,
      String musicType,
      String artistId) async {
    dynamic songUrl, imageUrl, title;

    print('🎵 [MUSIC MANAGER] ===== setInitialMusic CALLED =====');
    print('🎵 [MUSIC MANAGER] Position: $cPosition');
    print('🎵 [MUSIC MANAGER] Audio ID: $audioId');
    print('🎵 [MUSIC MANAGER] Content Type: $contenttype');
    print('🎵 [MUSIC MANAGER] DataList length: ${dataList?.length ?? 0}');
    
    // Stop any currently playing audio first
    try {
      print('🎵 [MUSIC MANAGER] Current audioPlayer state: playing=${audioPlayer.playing}, processingState=${audioPlayer.processingState}');
      if (audioPlayer.playing) {
        print('🎵 [MUSIC MANAGER] Stopping currently playing audio...');
        await audioPlayer.stop();
      }
      
      // Clear restored mode since we're loading a full playlist now
      MiniplayerRestorationService.clearRestoredMode();
      
    } catch (e) {
      print('🎵 [MUSIC MANAGER] Error stopping audio: $e');
    }
    
    currentlyPlaying.value = audioPlayer;
    playlist = ConcatenatingAudioSource(children: []);
    episodeDataList = dataList.toList();

    final int totalEpisodes = episodeDataList?.length ?? 0;
    print('🎵 [MUSIC MANAGER] Episode data list length: $totalEpisodes');
    print('🎵 [MUSIC MANAGER] Will add ALL $totalEpisodes episodes to playlist');

    // Add ALL episodes to the playlist so next/previous buttons work
    for (int i = 0; i < totalEpisodes; i++) {
      songUrl = episodeDataList?[i].audio.toString() ?? "";
      imageUrl = episodeDataList?[i].image.toString() ?? "";
      title = episodeDataList?[i].name.toString() ?? "";

      if (i == cPosition) {
        print('🎵 [MUSIC MANAGER] Adding episode $i: $title (CURRENT)');
      }

      await playlist.add(
        buildAudioSource(
            image: imageUrl ?? "",
            audioUrl: songUrl ?? "",
            extraDetails: episodeDataList?[i].toMap() ?? {},
            episodeId: episodeDataList?[i].id.toString() ?? "",
            displaydiscription:
                episodeDataList?[i].description.toString() ?? "",
            title: title ?? "",
            contentId: audioId,
            contentType: contenttype ?? "",
            isContinueWatching: isContinueWatching ?? "",
            musicType: musicType,
            artistID: artistId),
      );
    }
    
    print('🎵 [MUSIC MANAGER] ✅ Playlist now has ${playlist.length} items');
    print('🎵 [MUSIC MANAGER] Starting playback at index: $cPosition');

    try {
      log("Enter Try");
      log("playing      :=====================> ${audioPlayer.playing}");
      log("audioSource  :=====================> ${audioPlayer.audioSource?.sequence.length}");
      log("playlist     :=====================> ${playlist.length}");
      
      // Set audio source with the correct initial index
      await audioPlayer.setAudioSource(playlist, initialIndex: cPosition);
      
      print('🎵 [MUSIC MANAGER] Audio source set successfully');
      print('🎵 [MUSIC MANAGER] audioPlayer.sequence.length: ${audioPlayer.audioSource?.sequence.length}');
      
      if (isContinueWatching == true) {
        log("History Play");
        seek(Duration(milliseconds: stoptime));
        play();
      } else {
        log("Simple Play");
        play();
      }

      // State will be saved automatically by the playerStateStream listener

      callApi();
    } catch (e) {
      log("Error loading audio source: $e");
      print('❌ [MUSIC MANAGER] Error loading audio source: $e');
    }
  }
  
  /// Save miniplayer state after audio starts playing
  void _saveMiniplayerStateAfterPlay(int position) async {
    try {
      print('💾 [MUSIC MANAGER] ===== _saveMiniplayerStateAfterPlay CALLED =====');
      print('💾 [MUSIC MANAGER] Position: $position');
      print('💾 [MUSIC MANAGER] episodeDataList: ${episodeDataList != null}');
      
      // Handle dynamic list properly
      final List? dataList = episodeDataList is List ? episodeDataList as List : null;
      print('💾 [MUSIC MANAGER] dataList length: ${dataList?.length ?? 0}');
      
      if (dataList == null || dataList.isEmpty) {
        print('❌ [MUSIC MANAGER] episodeDataList is null or empty, cannot save state');
        return;
      }
      
      if (position < 0 || position >= dataList.length) {
        print('❌ [MUSIC MANAGER] Position $position is out of bounds');
        return;
      }
      
      final currentEpisode = dataList[position];
      print('💾 [MUSIC MANAGER] Current episode type: ${currentEpisode.runtimeType}');
      
      // Get audio URL from episode - try multiple field names
      String audioUrl = '';
      String imageUrl = '';
      String titleStr = 'Unknown';
      String episodeId = '';
      String description = '';
      int duration = 0;
      
      // Try to get values using dynamic access
      try {
        audioUrl = currentEpisode.audio?.toString() ?? '';
        print('💾 [MUSIC MANAGER] Got audio from .audio: $audioUrl');
      } catch (e) {
        print('💾 [MUSIC MANAGER] .audio field error: $e');
      }
      
      try {
        imageUrl = currentEpisode.image?.toString() ?? '';
        print('💾 [MUSIC MANAGER] Got image: $imageUrl');
      } catch (e) {
        print('💾 [MUSIC MANAGER] .image field error: $e');
      }
      
      try {
        titleStr = currentEpisode.name?.toString() ?? 'Unknown';
        print('💾 [MUSIC MANAGER] Got title: $titleStr');
      } catch (e) {
        print('💾 [MUSIC MANAGER] .name field error: $e');
      }
      
      try {
        episodeId = currentEpisode.id?.toString() ?? '';
        print('💾 [MUSIC MANAGER] Got episodeId: $episodeId');
      } catch (e) {
        print('💾 [MUSIC MANAGER] .id field error: $e');
      }
      
      try {
        description = currentEpisode.description?.toString() ?? '';
      } catch (e) {
        print('💾 [MUSIC MANAGER] .description field error: $e');
      }
      
      // If audio URL still empty, try toMap
      if (audioUrl.isEmpty) {
        try {
          final episodeMap = currentEpisode.toMap();
          if (episodeMap != null) {
            audioUrl = episodeMap['audio']?.toString() ?? 
                       episodeMap['audioUrl']?.toString() ?? 
                       episodeMap['url']?.toString() ?? '';
            print('💾 [MUSIC MANAGER] Got audio URL from map: $audioUrl');
          }
        } catch (e) {
          print('💾 [MUSIC MANAGER] toMap error: $e');
        }
      }
      
      print('💾 [MUSIC MANAGER] Final Audio URL: $audioUrl');
      
      if (audioUrl.isEmpty) {
        print('❌ [MUSIC MANAGER] Audio URL is empty, cannot save state');
        return;
      }
      
      if (episodeId.isEmpty) {
        print('❌ [MUSIC MANAGER] Episode ID is empty, cannot save state');
        return;
      }
      
      // Create MediaItem for saving
      final mediaItem = MediaItem(
        id: episodeId,
        title: titleStr,
        artUri: imageUrl.isNotEmpty ? Uri.tryParse(imageUrl) : null,
        album: '',
        artist: '',
      );
      
      print('💾 [MUSIC MANAGER] MediaItem created - ID: ${mediaItem.id}, Title: ${mediaItem.title}');
      
      // Save the state
      await MiniplayerRestorationService.saveMiniplayerState(
        currentItem: mediaItem,
        audioUrl: audioUrl,
        thumbnailUrl: imageUrl,
        artistName: '',
        description: description,
        durationInSeconds: duration,
        currentPositionMs: 0,
        contentId: '',
        currentIndex: position,
        totalTracks: dataList.length,
      );
      
      print('✅ [MUSIC MANAGER] Miniplayer state saved successfully');
      
    } catch (e, stackTrace) {
      print('❌ [MUSIC MANAGER] Error saving miniplayer state: $e');
      print('❌ [MUSIC MANAGER] Stack trace: $stackTrace');
    }
  }

  /// Clear miniplayer state when audio stops
  void clearMiniplayerState() async {
    print('🧹 [MUSICMANAGER] clearMiniplayerState() called');
    print('🧹 [MUSICMANAGER] Stack trace:');
    print(StackTrace.current.toString().split('\n').take(10).join('\n'));
    await MiniplayerRestorationService.clearAllState();
  }

  /// Restore miniplayer from previous session
  Future<bool> restoreMiniplayer() async {
    try {
      log('🎵 [RESTORE] Attempting to restore miniplayer...');
      
      final audioData = await MiniplayerRestorationService.restoreMiniplayerState();
      if (audioData == null) {
        log('🎵 [RESTORE] No data to restore');
        return false;
      }
      
      log('🎵 [RESTORE] Audio data retrieved, setting up player...');
      
      final success = await MiniplayerRestorationService.setupAudioPlayerWithRestoredData(
        audioPlayer: audioPlayer,
        audioData: audioData,
      );
      
      log('🎵 [RESTORE] Setup returned: $success');
      
      if (success) {
        // ⭐ CRITICAL: Set currentlyPlaying BEFORE returning
        log('🎵 [RESTORE] Setting currentlyPlaying.value...');
        currentlyPlaying.value = audioPlayer;
        log('✅ [RESTORE] currentlyPlaying set to audioPlayer');
        log('✅ [RESTORE] audioPlayer.playing = ${audioPlayer.playing}');
        log('✅ [RESTORE] audioPlayer.processingState = ${audioPlayer.processingState}');
        
        // Give UI a moment to update
        await Future.delayed(const Duration(milliseconds: 100));
        
        log('✅ [RESTORE] Miniplayer restored successfully');
        return true;
      } else {
        log('❌ [RESTORE] Failed to setup audio player');
        await MiniplayerRestorationService.cleanupAfterRestoration(success: false);
        return false;
      }
    } catch (e, stackTrace) {
      log('❌ [RESTORE] Error restoring miniplayer: $e');
      log('❌ [RESTORE] Stack trace: $stackTrace');
      return false;
    }
  }

// /* Music */
//   void setDownloadInitialMusic(
//       int cPosition,
//       dynamic contenttype,
//       dynamic dataList,
//       String audioId,
//       dynamic callApi,
//       dynamic isContinueWatching,
//       int stoptime,
//       String isBuy,
//       int isPaid,
//       String musicType,
//       String artistId) async {
//     dynamic songUrl, imageUrl, title;
//     dynamic tempFile;

//     currentlyPlaying.value = audioPlayer;
//     playlist = ConcatenatingAudioSource(children: []);
//     episodeDataList = dataList.toList();

//     /* Decrypt & Play START ******************** */
//     tempFile = await Utils.decryptUsingFFMPEG([
//       File(episodeDataList?[cPosition].savedFile.toString() ?? ""),
//       episodeDataList?[cPosition].securityKey ?? "",
//       episodeDataList?[cPosition].securityKey ?? "",
//       context,
//     ]);

//     if (tempFile != null) {
//       printLog("tempFile ===isolate===> $tempFile");

//       songUrl = tempFile;
//       imageUrl = episodeDataList?[cPosition].image.toString() ?? "";
//       title = episodeDataList?[cPosition].name.toString() ?? "";
//       printLog(
//           "Case 1 - songUrl: $songUrl, imageUrl: $imageUrl, title: $title");

//       printLog("songUrl ==== ${tempFile?.path}");

//       await playlist.add(
//         buildAudioFile(
//             image: imageUrl ?? "",
//             audioUrl: tempFile?.path ?? "",
//             extraDetails: episodeDataList?[cPosition].toMap() ?? {},
//             episodeId: episodeDataList?[cPosition].id.toString() ?? "",
//             displaydiscription:
//                 episodeDataList?[cPosition].description.toString() ?? "",
//             title: title ?? "",
//             contentId: audioId,
//             contentType: contenttype ?? "",
//             isContinueWatching: isContinueWatching ?? "",
//             musicType: musicType,
//             artistID: artistId),
//       );

//       try {
//         log("Enter Try");
//         log("playing      :=====================> ${audioPlayer.playing}");
//         log("audioSource  :=====================> ${audioPlayer.audioSource?.sequence.length}");
//         log("playlist     :=====================> ${playlist.length}");
//         // Preloading audio is not currently supported on Linux.
//         await audioPlayer.setAudioSource(playlist, initialIndex: cPosition);
//         // if (isContinueWatching == true) {
//         log("History Play");
//         seek(Duration(milliseconds: stoptime));
//         play();
//         // } else {
//         //   log("Simple Play");
//         //   play();
//         // }

//         callApi();
//       } catch (e) {
//         log("Error loading audio source: $e");
//       }
//     }
//   }

  void setDownloadInitialMusic(
      int cPosition,
      dynamic contenttype,
      dynamic dataList,
      String audioId,
      dynamic callApi,
      dynamic isContinueWatching,
      int stoptime,
      String isBuy,
      int isPaid,
      String musicType,
      String artistId,
      Function callback) async {
    final downloadProvider =
        Provider.of<DownLoadProvider>(context, listen: false);
    await downloadProvider.setDecryptLoading(true);

    // Utils().showProgressNew(context);
    dynamic songUrl, imageUrl, title;
    printLog("contenttype Value is == $contenttype");
    printLog("contenttype Value is isBuy == $isBuy");
    printLog("contenttype Value is isPaid == $isPaid");
    currentlyPlaying.value = audioPlayer;
    playlist = ConcatenatingAudioSource(children: []);
    episodeDataList = dataList.toList();

    for (int i = 0; i < (episodeDataList?.length ?? 0); i++) {
      dynamic tempFile = await Utils.decryptUsingFFMPEG(context, [
        File(episodeDataList?[i].savedFile.toString() ?? ""),
        episodeDataList?[i].securityKey ?? "",
        episodeDataList?[i].securityKey ?? "",
        context,
      ]);

      if (tempFile != null) {
        printLog("tempFile ===isolate===> $tempFile");

        songUrl = tempFile;
        imageUrl = episodeDataList?[i].image.toString() ?? "";
        title = episodeDataList?[i].name.toString() ?? "";
        printLog(
            "Case 1 - songUrl: $songUrl, imageUrl: $imageUrl, title: $title");

        printLog("songUrl ==== ${tempFile?.path}");

        await playlist.add(
          buildAudioFile(
              image: imageUrl ?? "",
              audioUrl: tempFile?.path ?? "",
              extraDetails: {
                ...episodeDataList?[i].toMap() ?? {},
                'url': tempFile?.path ?? "",  // ⭐ ADD URL TO EXTRAS FOR DOWNLOADS
              },
              episodeId: episodeDataList?[i].id.toString() ?? "",
              displayDescription:
                  episodeDataList?[i].description.toString() ?? "",
              title: title ?? "",
              contentId: audioId,
              contentType: "download",
              isContinueWatching: isContinueWatching ?? "",
              musicType: musicType,
              artistID: artistId),
        );
      }
    }

    await callback();
    await downloadProvider.setDecryptLoading(false);

    try {
      log("Enter Try");
      log("playing      :=====================> ${audioPlayer.playing}");
      log("audioSource  :=====================> ${audioPlayer.audioSource?.sequence.length}");
      log("playlist     :=====================> ${playlist.length}");
      // Preloading audio is not currently supported on Linux.
      await audioPlayer.setAudioSource(playlist, initialIndex: cPosition);
      _attachCompletionListenerIfNeeded();
      // if (isContinueWatching == true) {
      log("History Play");
      seek(Duration(milliseconds: stoptime));
      play();
      // } else {
      //   log("Simple Play");
      //   play();
      // }

      callApi();
      
      // State will be saved automatically by the playerStateStream listener
    } catch (e) {
      log("Error loading audio source: $e");
    }
  }

  void play() async {
    log('▶️ [PLAY] Starting audio playback');
    await audioPlayer.play();
    // State will be saved by the playerStateStream listener in _attachSaveStateListener
  }

  void pause() {
    audioPlayer.pause();
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
  }

  void dispose() {
    audioPlayer.dispose();
  }

  clearMusicPlayer() async {
    episodeDataList = [];
    playlist = ConcatenatingAudioSource(children: []);
    for (var i = 0; i < playlist.length; i++) {
      playlist.removeAt(i);
    }
    playlist.clear();
  }

  // ================= In-App Review =================
  void _attachCompletionListenerIfNeeded() {
    if (_completionListenerAttached) return;
    _completionListenerAttached = true;
    audioPlayer.playerStateStream.listen((state) async {
      // if (state.processingState == ProcessingState.completed) {
      //   await _onAudioCompletedForReview();
      // }
    });
  }

  // Future<void> _onAudioCompletedForReview() async {
  //   try {
  //     final playCount = await _incrementPlayCount();
  //     // Example threshold: after 3 completed plays
  //     if (playCount >= 3) {
  //       final inAppReview = InAppReview.instance;
  //       if (await inAppReview.isAvailable()) {
  //         await inAppReview.requestReview();
  //       } else {
  //         // Fallback: open store listing (iOS requires your real App Store ID)
  //         try {
  //           await inAppReview.openStoreListing(
  //             appStoreId: null, // TODO: set your App Store ID
  //           );
  //         } catch (_) {}
  //       }
  //     }
  //   } catch (e) {
  //     log('In-app review error: $e');
  //   }
  // }

  Future<int> _incrementPlayCount() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('review_play_count') ?? 0;
    final next = current + 1;
    await prefs.setInt('review_play_count', next);
    return next;
  }
}