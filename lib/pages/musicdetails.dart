import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:diamondnib/model/download_item.dart';
import 'package:diamondnib/pages/bottombar.dart';
import 'package:diamondnib/provider/connectivityprovider.dart';
import 'package:diamondnib/provider/downloadprovider.dart';
import 'package:diamondnib/provider/episodeprovider.dart';
import 'package:diamondnib/provider/musicdetailprovider.dart';
import 'package:diamondnib/provider/musicprovider.dart';
import 'package:diamondnib/subscription/audiobuy.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/dimens.dart';
import 'package:diamondnib/utils/musicmanager.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/musicutils.dart';
import 'package:diamondnib/widget/myfileimage.dart';
import 'package:diamondnib/widget/myimage.dart';
import 'package:diamondnib/widget/mymarqueetext.dart';
import 'package:diamondnib/widget/mynetworkimg.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:diamondnib/widget/nodata.dart';
import 'dart:async';
import 'package:diamondnib/services/audio_position_service.dart';
import 'package:diamondnib/services/audio_position_service.dart';
import 'package:diamondnib/services/miniplayer_restoration_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:rxdart/rxdart.dart';
// import 'package:diamondnib/utils/review_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

AudioPlayer audioPlayer = AudioPlayer();
late MusicManager musicManager;

Stream<PositionData> get positionDataStream {
  return Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          audioPlayer.positionStream,
          audioPlayer.bufferedPositionStream,
          audioPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero))
      .asBroadcastStream();
}

final ValueNotifier<double> playerExpandProgress =
    ValueNotifier(playerMinHeight);

final MiniplayerController controller = MiniplayerController();

class MusicDetails extends StatefulWidget {
  final bool ishomepage;
  final dynamic contentid;
  final String episodeid, contenttype, stoptime;
  const MusicDetails({
    super.key,
    required this.ishomepage,
    required this.contenttype,
    required this.contentid,
    required this.episodeid,
    required this.stoptime,
  });

  @override
  State<MusicDetails> createState() => _MusicDetailsState();
}

class _MusicDetailsState extends State<MusicDetails>
    with WidgetsBindingObserver {
  late ScrollController _scrollcontroller;
  late ConnectivityProvider connectivityProvider;
  late Box<DownloadEpisodeItem> episodeBox;
  List<DownloadEpisodeItem>? myEpisodeList;

  late MusicDetailProvider musicDetailProvider;
  late DownLoadProvider downloadProvider;

  late MusicProvider musicProvider;
  int currentstoptime = 0;

  // final ReviewHelper _reviewHelper = ReviewHelper();

  final String _positionKey = 'last_audio_position';
  final String _audioIdKey = 'last_audio_id';
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();

    printLog("contentid == ${widget.episodeid}");
    ambiguate(WidgetsBinding.instance)?.addObserver(this);

    // Initialize musicManager here
    musicManager = MusicManager(context);

    // do NOT access MediaQuery here — compute effectiveMinHeight after first frame
    musicProvider = Provider.of<MusicProvider>(context, listen: false);
    musicDetailProvider = Provider.of<MusicDetailProvider>(context, listen: false);
    downloadProvider = Provider.of<DownLoadProvider>(context, listen: false);
    connectivityProvider = Provider.of<ConnectivityProvider>(context, listen: false);
    _scrollcontroller = ScrollController();

  _initAudioPositionHandling();

  // Post-frame callback for actions that require MediaQuery or mounted context
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // compute effective min height including bottom inset
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final newMin = playerMinHeight + bottomInset;
    playerExpandProgress.value = newMin; // update notifier so Miniplayer uses correct min height

    // debug and initialize saved positions / resume logic
    await _debugAllSavedPositions();
    await _testPositionService();
    await _handleAppStartResume();

    // Load data
    if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre == "download") {
      await _getDownloadData();
    } else {
      getApi();
    }

    // ensure UI updates after async tasks
    if (mounted) setState(() {});
  });

  _scrollcontroller.addListener(_scrollListener);
}

void _checkAudioPlayerState() {
  print('🎵 DEBUG: === AUDIO PLAYER STATE CHECK ===');
  print('🎵 DEBUG: Sequence State: ${audioPlayer.sequenceState}');
  print('🎵 DEBUG: Current Source: ${audioPlayer.sequenceState?.currentSource}');
  print('🎵 DEBUG: Current Index: ${audioPlayer.currentIndex}');
  print('🎵 DEBUG: Has Previous: ${audioPlayer.hasPrevious}');
  print('🎵 DEBUG: Has Next: ${audioPlayer.hasNext}');
  print('🎵 DEBUG: Playing: ${audioPlayer.playing}');
  print('🎵 DEBUG: Processing State: ${audioPlayer.processingState}');
  
  final currentItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
  if (currentItem != null) {
    print('🎵 DEBUG: Current MediaItem:');
    print('🎵 DEBUG:   - ID: ${currentItem.id}');
    print('🎵 DEBUG:   - Title: ${currentItem.title}');
    print('🎵 DEBUG:   - Album: ${currentItem.album}');
    print('🎵 DEBUG:   - Artist: ${currentItem.artist}');
    print('🎵 DEBUG:   - Extras: ${currentItem.extras}');
  } else {
    print('🎵 DEBUG: ❌ No current MediaItem found');
  }
  print('🎵 DEBUG: === END STATE CHECK ===');
}
  
// Add this debug method to your _MusicDetailsState class

// Add this method to debug and find the correct field names
void _debugEpisodeFields() {
  print('🔍 DEBUG: Checking available episode fields...');
  
  // Check online episodes
  if (musicDetailProvider.podcastEpisodeList != null && 
      musicDetailProvider.podcastEpisodeList!.isNotEmpty) {
    final firstEpisode = musicDetailProvider.podcastEpisodeList!.first;
    print('=== ONLINE EPISODE FIELDS ===');
    print('ID: ${firstEpisode.id}');
    print('Title: ${firstEpisode.title}');
    print('Name: ${firstEpisode.name}');
    
    // Try to print all available properties using toJson() if available
    try {
      if (firstEpisode.toJson != null) {
        final json = firstEpisode.toJson();
        json?.forEach((key, value) {
          print('$key: $value');
        });
      }
    } catch (e) {
      print('Cannot access toJson(): $e');
    }
    
    // Manually check common duration field names
    print('=== CHECKING DURATION FIELDS ===');
    _checkField(firstEpisode, 'duration');
    _checkField(firstEpisode, 'audioDuration');
    _checkField(firstEpisode, 'musicDuration');
    _checkField(firstEpisode, 'length');
    _checkField(firstEpisode, 'totalDuration');
    _checkField(firstEpisode, 'time');
    _checkField(firstEpisode, 'audio_length');
    _checkField(firstEpisode, 'music_length');
  }
  
  // Check downloaded episodes
  if (downloadProvider.myEpisodeList != null && 
      downloadProvider.myEpisodeList!.isNotEmpty) {
    final firstDownloadEpisode = downloadProvider.myEpisodeList!.first;
    print('=== DOWNLOADED EPISODE FIELDS ===');
    print('ID: ${firstDownloadEpisode.id}');
    print('Title: ${firstDownloadEpisode.title}');
    print('Name: ${firstDownloadEpisode.name}');
    
    try {
      if (firstDownloadEpisode.toJson != null) {
        final json = firstDownloadEpisode.toJson();
        json?.forEach((key, value) {
          print('$key: $value');
        });
      }
    } catch (e) {
      print('Cannot access toJson(): $e');
    }
    
    print('=== CHECKING DURATION FIELDS ===');
    _checkField(firstDownloadEpisode, 'duration');
    _checkField(firstDownloadEpisode, 'audioDuration');
    _checkField(firstDownloadEpisode, 'musicDuration');
    _checkField(firstDownloadEpisode, 'length');
    _checkField(firstDownloadEpisode, 'totalDuration');
    _checkField(firstDownloadEpisode, 'time');
    _checkField(firstDownloadEpisode, 'audio_length');
    _checkField(firstDownloadEpisode, 'music_length');
  }
}

Future<void> _handleAppStartResume() async {
  try {
    print('🎵 DEBUG: ===== _handleAppStartResume STARTED =====');
    
    final currentItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
    print('🎵 DEBUG: Current Item: ${currentItem?.title ?? "NULL"}');
    print('🎵 DEBUG: Current Item ID: ${currentItem?.id ?? "NULL"}');
    
    if (currentItem == null) {
      print('🎵 DEBUG: ❌ No current item found');
      return;
    }
    
    // Get saved position
    final savedPosition = await AudioPositionService.getPosition(currentItem.id);
    print('🎵 DEBUG: Saved position: ${savedPosition.inSeconds} seconds');
    
    // If we have a significant saved position, seek to it IMMEDIATELY
    if (savedPosition.inSeconds > 10) {
      print('🎵 DEBUG: 🎯 APP START RESUME - Seeking to ${savedPosition.inSeconds}s immediately');
      
      // Stop any current playback
      if (audioPlayer.playing) {
        await audioPlayer.stop();
      }
      
      // Set the audio source first if not set
      if (audioPlayer.sequenceState == null && currentItem.extras?['url'] != null) {
        await audioPlayer.setAudioSource(
          AudioSource.uri(
            Uri.parse(currentItem.extras!['url']),
            tag: currentItem,
          ),
        );
      }
      
      // Wait for audio to be ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Seek to saved position
      await audioPlayer.seek(savedPosition);
      
      print('🎵 DEBUG: ✅ App start resume completed - ready to play from ${savedPosition.inSeconds}s');
      
      // Show resume indicator
      // if (mounted) {
      //   _showResumeIndicator(savedPosition);
      // }
    } else {
      print('🎵 DEBUG: ℹ️ No significant saved position (${savedPosition.inSeconds}s)');
    }
    
    print('🎵 DEBUG: ===== _handleAppStartResume COMPLETED =====');
  } catch (e, stackTrace) {
    print('🎵 DEBUG: ❌ ERROR in _handleAppStartResume: $e');
    print('🎵 DEBUG: Stack trace: $stackTrace');
  }
}



void _checkField(dynamic episode, String fieldName) {
  try {
    final value = _getFieldValue(episode, fieldName);
    if (value != null) {
      print('✅ FOUND: $fieldName = $value');
    }
  } catch (e) {
    // Field doesn't exist or can't be accessed
    print('⚠️ Error accessing field $fieldName: $e');
  }
}


dynamic _getFieldValue(dynamic episode, String fieldName) {
  try {
    if (episode == null) return null;
    
    // If it's a Map, try to access the field directly
    if (episode is Map) {
      return episode[fieldName];
    }
    
    // Try toMap() method if it exists
    try {
      final toMap = episode.toMap;
      if (toMap is Function) {
        final map = toMap();
        if (map is Map) {
          return map[fieldName];
        }
      }
    } catch (_) {}
    
    // Try direct property access using noSuchMethod
    try {
      return _getProperty(episode, fieldName);
    } catch (_) {}
    
    return null;
  } catch (e) {
    return null;
  }
}
// Helper method to get property value without reflection
dynamic _getProperty(dynamic object, String propertyName) {
  if (object == null) return null;
  
  try {
    // Try direct property access using noSuchMethod
    return object.noSuchMethod(
      Invocation.getter(Symbol(propertyName)),
      returnValue: null,
    );
  } on NoSuchMethodError {
    // If direct access fails, try to access via a method
    try {
      return object.invoke(propertyName, []);
    } catch (_) {
      return null;
    }
  } catch (_) {
    return null;
  }
}

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      printLog('Error initializing SharedPreferences: $e');
    }
  }

  // Variables to track locked episodes
  int? _lastValidIndex; // Track the last unlocked episode index

void _initAudioPositionHandling() {
  // Set up audio completion listener
  audioPlayer.playerStateStream.listen((playerState) async {
    if (playerState.processingState == ProcessingState.completed) {
      // _reviewHelper.handlePlayCompletion();
      
      // Clear the saved position when audio completes
      final currentItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
      if (currentItem?.id != null) {
        await AudioPositionService.clearPosition(currentItem!.id);
        print('🗑️ Position cleared for completed audio: ${currentItem.id}');
      }
    }
  });
  
  // Set up listener to check purchase status when track changes via next/previous buttons
  int? lastCheckedIndex;
  audioPlayer.currentIndexStream.listen((index) async {
    if (index != null) {
      // Initialize _lastValidIndex on first track if not set
      if (_lastValidIndex == null) {
        _lastValidIndex = index;
        print('🔒 Initialized _lastValidIndex to: $index');
      }
      
      // Prevent duplicate checks for the same index
      if (lastCheckedIndex == index) return;
      
      // Small delay to ensure the track has actually started loading
      await Future.delayed(const Duration(milliseconds: 100));
      final currentItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
      
      print('🔒 ===== TRACK CHANGE DETECTED =====');
      print('🔒 Track changed to index: $index');
      print('🔒 Current item: ${currentItem?.title} (ID: ${currentItem?.id})');
      
      if (currentItem != null) {
        // Check the episode list data first
        bool isLockedInList = false;
        bool foundInList = false;
        
        // Try MusicDetailProvider.podcastEpisodeList FIRST
        if (musicDetailProvider.podcastEpisodeList != null && musicDetailProvider.podcastEpisodeList!.isNotEmpty) {
          print('🔒 Searching in musicDetailProvider.podcastEpisodeList (${musicDetailProvider.podcastEpisodeList?.length } items)');
          for (var episode in musicDetailProvider.podcastEpisodeList!) {
            if (episode.id.toString() == currentItem.id) {
              foundInList = true;
              // Found the episode in the list - check its current status
              final isPaid = (episode.isAudioPaid == 1);
              final isNotBought = (episode.isBuy == 0 || episode.isBuy?.toString() == '0');
              isLockedInList = isPaid && isNotBought;
              print('🔒 ✅ Found episode in musicDetailProvider:');
              print('🔒   - ID: ${episode.id}, Title: ${episode.name}');
              print('🔒   - isAudioPaid: ${episode.isAudioPaid}, isBuy: ${episode.isBuy}');
              print('🔒   - LOCKED: $isLockedInList');
              
              // 🔓 Update MediaItem extras with fresh data
              if (currentItem.extras != null && isNotBought == false) {
                print('🔒 ✅ Updating MediaItem: is_buy=${episode.isBuy}');
                (currentItem.extras as Map)['is_buy'] = episode.isBuy;
              }
              break;
            }
          }
        }
        
        // FALLBACK: Try EpisodeProvider.audioList if not found  
        if (!foundInList && mounted) {
          final episodeProvider = context.read<EpisodeProvider>();
          if (episodeProvider.audioList != null && episodeProvider.audioList!.isNotEmpty) {
            print('🔒 Episode not in musicDetailProvider, checking EpisodeProvider.audioList (${episodeProvider.audioList?.length} items)');
            for (var episode in episodeProvider.audioList!) {
              if (episode.id.toString() == currentItem.id) {
                foundInList = true;
                final isPaid = (episode.isAudioPaid == 1);
                final isNotBought = (episode.isBuy == 0 || episode.isBuy?.toString() == '0');
                isLockedInList = isPaid && isNotBought;
                print('🔒 ✅ Found episode in EpisodeProvider:');
                print('🔒   - ID: ${episode.id}, Title: ${episode.name}');
                print('🔒   - isAudioPaid: ${episode.isAudioPaid}, isBuy: ${episode.isBuy}');
                print('🔒   - LOCKED: $isLockedInList');
                
                // 🔓 Update MediaItem extras
                if (currentItem.extras != null && isNotBought == false) {
                  print('🔒 ✅ Updating MediaItem: is_buy=${episode.isBuy}');
                  (currentItem.extras as Map)['is_buy'] = episode.isBuy;
                }
                break;
              }
            }
          }
        }
        
        // FINAL FALLBACK: Check MediaItem extras if not found in either list
        if (!foundInList && currentItem.extras != null) {
          final isAudioPaid = currentItem.extras!['is_audio_paid'];
          final isBuy = currentItem.extras!['is_buy'];
          final isPaid = (isAudioPaid == 1 || isAudioPaid == '1' || isAudioPaid?.toString() == '1');
          final isNotBought = (isBuy == 0 || isBuy == '0' || isBuy?.toString() == '0');
          isLockedInList = isPaid && isNotBought;
          print('🔒 Episode not in any list, using MediaItem.extras:');
          print('🔒   - is_audio_paid: $isAudioPaid, is_buy: $isBuy');
          print('🔒   - LOCKED: $isLockedInList');
        }
        
        // If locked, prevent player from staying on this track
        if (isLockedInList) {
          print('🔒 ⚠️ Episode is LOCKED! Preventing playback...');
          
          // Stop the audio completely
          await audioPlayer.stop();
          
          // Seek back to the last valid (unlocked) episode
          if (_lastValidIndex != null && _lastValidIndex != index) {
            print('🔒 Seeking back to last valid index: $_lastValidIndex');
            await audioPlayer.seek(Duration.zero, index: _lastValidIndex);
          }
          
          // Show simple warning message
          if (mounted) {
            Utils.showToast("This episode is locked. Please purchase to listen.");
          }
          
          //  Don't update lastCheckedIndex here - we want to check again if user tries to skip to this locked episode
          return;
        } else {
          print('🔒 ✅ Episode is unlocked (checked from episode list)');
          // Update last valid index to current unlocked episode
          _lastValidIndex = index;
          lastCheckedIndex = index;
        }
      }
      print('🔒 ===== END TRACK CHANGE (isLocked=isLockedInList) =====');
    }
  });
  
  // Set up periodic position saving
  Timer.periodic(const Duration(seconds: 3), (timer) async {
    if (audioPlayer.playing && audioPlayer.processingState == ProcessingState.ready) {
      final currentItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
      if (currentItem?.id != null) {
        final position = audioPlayer.position;
        final duration = audioPlayer.duration;
        
        // Only save if position is valid and we're not at the very beginning or end
        if (position.inSeconds > 5 && 
            duration != null && 
            position < duration - const Duration(seconds: 5)) {
          await AudioPositionService.savePosition(currentItem!.id, position);
        }
      }
    }
  });
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) async {
  super.didChangeAppLifecycleState(state);
  
  if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
    // Save position when app goes to background
    final currentItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
    if (currentItem?.id != null && audioPlayer.playing) {
      final position = audioPlayer.position;
      if (position.inSeconds > 0) {
        await AudioPositionService.savePosition(currentItem!.id, position);
        print('💾 Position saved on background: ${position.inSeconds}s');
      }
    }
  }
}

Future<void> _debugAllSavedPositions() async {
  try {
    print('🎵 DEBUG: ===== CHECKING ALL SAVED POSITIONS =====');
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    int audioPosCount = 0;
    keys.forEach((key) {
      if (key.startsWith('audio_position_')) {
        final value = prefs.getInt(key);
        final audioId = key.replaceFirst('audio_position_', '');
        print('🎵 DEBUG: 📁 $audioId: ${value}ms (${value! / 1000} seconds)');
        audioPosCount++;
      }
    });
    
    if (audioPosCount == 0) {
      print('🎵 DEBUG: ❌ No audio positions found in SharedPreferences');
    } else {
      print('🎵 DEBUG: ✅ Found $audioPosCount saved audio positions');
    }
    print('🎵 DEBUG: ===== END POSITION CHECK =====');
  } catch (e) {
    print('🎵 DEBUG: ❌ Error checking saved positions: $e');
  }
}

Future<void> _handleInitialPlayback() async {
  try {
    print('🎵 DEBUG: ===== _handleInitialPlayback STARTED =====');
    
    final currentItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
    print('🎵 DEBUG: Current Item: ${currentItem?.title ?? "NULL"}');
    print('🎵 DEBUG: Current Item ID: ${currentItem?.id ?? "NULL"}');
    
    if (currentItem == null) {
      print('🎵 DEBUG: ❌ No current item found');
      return;
    }
    
    // Get saved position
    final savedPosition = await AudioPositionService.getPosition(currentItem.id);
    print('🎵 DEBUG: Saved position: ${savedPosition.inSeconds} seconds');
    
    // Get current position
    final currentPosition = audioPlayer.position;
    print('🎵 DEBUG: Current position: ${currentPosition.inSeconds} seconds');
    
    // If we have a significant saved position and audio is playing from beginning, seek immediately
    if (savedPosition.inSeconds > 10 && currentPosition.inSeconds < 5) {
      print('🎵 DEBUG: 🎯 IMMEDIATE RESUME - Seeking to ${savedPosition.inSeconds}s');
      
      // Seek immediately without stopping playback
      await audioPlayer.seek(savedPosition);
      
      // Show professional resume indicator
      // if (mounted) {
      //   _showResumeIndicator(savedPosition);
      // }
      
      print('🎵 DEBUG: ✅ Immediate resume completed');
    } else if (savedPosition.inSeconds > 10) {
      print('🎵 DEBUG: ℹ️ Audio already near saved position, no resume needed');
    } else {
      print('🎵 DEBUG: ℹ️ No significant saved position (${savedPosition.inSeconds}s)');
    }
    
    print('🎵 DEBUG: ===== _handleInitialPlayback COMPLETED =====');
  } catch (e, stackTrace) {
    print('🎵 DEBUG: ❌ ERROR in _handleInitialPlayback: $e');
    print('🎵 DEBUG: Stack trace: $stackTrace');
  }
}

// void _showResumeIndicator(Duration resumePosition) {
//   // Show a subtle snackbar without blocking UI
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(
//       content: Row(
//         children: [
//           Icon(Icons.replay_circle_filled, color: Colors.green),
//           SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               'Resumed from ${_formatDuration(resumePosition)}',
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//           ),
//         ],
//       ),
//       duration: const Duration(seconds: 2),
//       backgroundColor: Colors.grey[900],
//       behavior: SnackBarBehavior.floating,
//       margin: EdgeInsets.all(10),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//     ),
//   );
// }



// Add this method after _showResumeIndicator method
Widget _buildEpisodeProgressIndicator(String episodeId, int totalDurationInSeconds) {
  return FutureBuilder<Duration>(
    future: AudioPositionService.getPosition(episodeId),
    builder: (context, snapshot) {
      if (snapshot.hasData && snapshot.data != null) {
        final savedPosition = snapshot.data!;
        final totalDuration = Duration(seconds: totalDurationInSeconds);
        
        // Only show progress if there's a significant saved position and it's not near the end
        if (savedPosition.inSeconds > 10 && 
            savedPosition < totalDuration - const Duration(seconds: 10)) {
          
          final progress = savedPosition.inSeconds / totalDuration.inSeconds;
          
          return Container(
            margin: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress bar
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(colorAccent),
                  minHeight: 2,
                ),
                // Time indicator
                Text(
                  'Resume from ${_formatDuration(savedPosition)}',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          );
        }
      }
      return const SizedBox.shrink();
    },
  );
}

Future<String?> _findAudioUrlById(String audioId) async {
  try {
    print('🎵 DEBUG: Searching for audio URL for ID: $audioId');
    
    // Check musicDetailProvider first (online episodes)
    if (musicDetailProvider.podcastEpisodeList != null) {
      for (var episode in musicDetailProvider.podcastEpisodeList!) {
        if (episode.id.toString() == audioId) {
          // Based on your musicmanager.dart, try these field names
          String? foundUrl = episode.music ?? episode.audio;
          if (foundUrl != null && foundUrl.isNotEmpty) {
            print('🎵 DEBUG: ✅ Found URL in podcastEpisodeList: $foundUrl');
            return foundUrl;
          }
        }
      }
    }
    
    // Check downloadProvider if needed
    if (downloadProvider.myEpisodeList != null) {
      for (var episode in downloadProvider.myEpisodeList!) {
        if (episode.id.toString() == audioId) {
          // For downloads, the URL is the file path after decryption
          // We'll need to use the music manager to handle this
          print('🎵 DEBUG: ✅ Found download episode, will need to use music manager');
          return "download://${episode.id}"; // Special marker for downloads
        }
      }
    }
    
    print('🎵 DEBUG: ❌ Could not find URL for ID: $audioId');
    return null;
    
  } catch (e) {
    print('🎵 DEBUG: ❌ Error finding URL: $e');
    return null;
  }
}
 
  _getDownloadData() async {
    /* Initilize Hive */
    if (!kIsWeb) {
      if (Constant.userID != null) {
        episodeBox = Hive.box<DownloadEpisodeItem>(
            '${Constant.audioEpisodeDownloadBox}_${Constant.userID}');
      } else {
        episodeBox =
            Hive.box<DownloadEpisodeItem>(Constant.audioEpisodeDownloadBox);
      }
    }
    await downloadProvider.makeDownloadPlayslits(int.parse(widget.contentid));

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  getApi() async {
    if (connectivityProvider.isOnline) {
      printLog(
          "(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre = ${(audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.displayDescription}");
      if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.genre ==
          "3") {
        await _fetchDataPlaylist(
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.album
                    .toString() ??
                "",
            musicDetailProvider.podcastcurrentPage ?? 0);
      } else {
        await _fetchDataPodcast(
            (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                    ?.album
                    .toString() ??
                "",
            musicDetailProvider.podcastcurrentPage ?? 0);
      }
      
      // ⭐ CHECK IF WE NEED TO RELOAD PLAYLIST (after restoration)
      await _reloadPlaylistIfNeeded();
    }
  }
  
  /// Reload full playlist if player is in restored mode (only has 1 track)
  Future<void> _reloadPlaylistIfNeeded() async {
    try {
      // Check if we're in restored mode or have only 1 track
      final sequenceLength = audioPlayer.audioSource?.sequence.length ?? 0;
      final isRestoredMode = MiniplayerRestorationService.isInRestoredMode;
      
      print('🔄 [RELOAD CHECK] Sequence length: $sequenceLength, Restored mode: $isRestoredMode');
      
      // Only reload if we have 1 track AND we have more episodes available
      if (sequenceLength <= 1 && musicDetailProvider.podcastEpisodeList != null && 
          (musicDetailProvider.podcastEpisodeList?.length ?? 0) > 1) {
        
        print('🔄 [RELOAD] Reloading full playlist with ${musicDetailProvider.podcastEpisodeList?.length} episodes');
        
        // Find the current episode index in the list
        final currentItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
        final currentEpisodeId = currentItem?.id;
        final currentPosition = audioPlayer.position;
        final wasPlaying = audioPlayer.playing;
        
        int currentIndex = 0;
        if (currentEpisodeId != null && musicDetailProvider.podcastEpisodeList != null) {
          for (int i = 0; i < musicDetailProvider.podcastEpisodeList!.length; i++) {
            if (musicDetailProvider.podcastEpisodeList![i].id.toString() == currentEpisodeId) {
              currentIndex = i;
              break;
            }
          }
        }
        
        print('🔄 [RELOAD] Current episode ID: $currentEpisodeId, Index: $currentIndex');
        print('🔄 [RELOAD] Current position: ${currentPosition.inSeconds}s, Was playing: $wasPlaying');
        
        // Get content info from current item
        final contentId = currentItem?.album ?? '';
        final contentType = currentItem?.genre ?? '';
        
        // Stop current playback first
        if (wasPlaying) {
          await audioPlayer.pause();
        }
        
        // Build playlist manually without auto-play
        final playlist = ConcatenatingAudioSource(children: []);
        final episodes = musicDetailProvider.podcastEpisodeList!;
        
        for (int i = 0; i < episodes.length; i++) {
          final episode = episodes[i];
          await playlist.add(
            buildAudioSource(
              image: episode.image?.toString() ?? '',
              audioUrl: episode.audio?.toString() ?? '',
              extraDetails: episode.toMap(),
              episodeId: episode.id.toString(),
              displaydiscription: episode.description?.toString() ?? '',
              title: episode.name?.toString() ?? '',
              contentId: contentId,
              contentType: contentType,
              isContinueWatching: false,
              musicType: 'music',
              artistID: '0',
            ),
          );
        }
        
        // Set audio source at correct index WITHOUT auto-play
        await audioPlayer.setAudioSource(playlist, initialIndex: currentIndex);
        
        // Seek to the saved position
        if (currentPosition.inMilliseconds > 0) {
          await audioPlayer.seek(currentPosition);
        }
        
        // Resume playback only if it was playing before
        if (wasPlaying) {
          await audioPlayer.play();
        }
        
        // Clear restored mode flag
        MiniplayerRestorationService.clearRestoredMode();
        
        print('✅ [RELOAD] Full playlist reloaded with ${playlist.length} items');
      }
    } catch (e, stackTrace) {
      print('❌ [RELOAD] Error reloading playlist: $e');
      print('❌ [RELOAD] Stack trace: $stackTrace');
    }
  }

  // Method to handle audio playback with resume functionality
  // Note: This method is now handled by _playAudio
  
  // Helper method to format duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:${twoDigits(duration.inSeconds.remainder(60))}';
    }
  }
  
  // Method to handle audio playback with resume functionality
Future<void> _playAudio(MediaItem mediaItem, String audioUrl) async {
  try {
    print('🎵 DEBUG: _playAudio STARTED for ${mediaItem.title}');
    
    // If audio source is already set up, just play without resetting
    if (audioPlayer.audioSource != null && audioPlayer.processingState != ProcessingState.idle) {
      print('🎵 DEBUG: Audio source already set, just playing');
      if (!audioPlayer.playing) {
        await audioPlayer.play();
      }
      return;
    }
    
    // Only set up new audio source if not already set
    print('🎵 DEBUG: Setting up new audio source');
    await audioPlayer.setAudioSource(
      AudioSource.uri(
        Uri.parse(audioUrl),
        tag: mediaItem,
      ),
      preload: true,
    );
    
    // Start playback
    if (!audioPlayer.playing) {
      await audioPlayer.play();
    }
    
    print('🎵 DEBUG: _playAudio COMPLETED');
    
  } catch (e, stackTrace) {
    print('🎵 DEBUG: ERROR in _playAudio: $e');
    print('🎵 DEBUG: Stack trace: $stackTrace');
  }
}

_checkPremiumPlayPause() async {
  final currentItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
  
  if (currentItem?.extras?['is_audio_paid'] == 1 &&
      currentItem?.extras?['is_buy'] == 0) {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => AudioBuy(
          coins: currentItem?.extras?['is_audio_coin'],
          contentid: widget.contentid,
          episodeName: currentItem?.extras?['name'],
          episodeid: widget.episodeid,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
    );
  } else {
    if (audioPlayer.playing) {
      audioPlayer.pause();
    } else {
      audioPlayer.play();
    }
  }
}
  _scrollListener() async {
    if (!_scrollcontroller.hasClients) return;
    if (_scrollcontroller.offset >=
            _scrollcontroller.position.maxScrollExtent &&
        !_scrollcontroller.position.outOfRange) {
      await musicDetailProvider.setLoadMore(true);
      if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
              ?.genre ==
          "3") {
        if ((musicDetailProvider.playlistcurrentPage ?? 0) <
            (musicDetailProvider.playlisttotalPage ?? 0)) {
          _fetchDataPlaylist(
              (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.album
                      .toString() ??
                  "",
              musicDetailProvider.playlistcurrentPage);
        }
      } else {
        if ((musicDetailProvider.podcastcurrentPage ?? 0) <
            (musicDetailProvider.podcasttotalPage ?? 0)) {
          _fetchDataPodcast(
              (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.album
                      .toString() ??
                  "",
              musicDetailProvider.podcastcurrentPage);
        }
      }
    }
  }

  Future<void> _fetchDataPodcast(podcastId, int? nextPage) async {
    printLog("isMorePage  ======> ${musicDetailProvider.podcastisMorePage}");
    printLog("currentPage ======> ${musicDetailProvider.podcastcurrentPage}");
    printLog("totalPage   ======> ${musicDetailProvider.podcasttotalPage}");
    printLog("nextpage   ======> $nextPage");
    printLog("Call MyCourse");
    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await musicDetailProvider.setLoadMore(true);

    if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
            ?.displayDescription
            .toString() ==
        "searchMusic") {
      musicDetailProvider.getSearchVideo((nextPage ?? 0) + 1);
    } else {
      await musicDetailProvider.getEpisodeByPodcast(
          podcastId, (nextPage ?? 0) + 1);
    }
  }

  Future<void> _fetchDataPlaylist(podcastId, int? nextPage) async {
    printLog("nextpage   ======> $nextPage");

    printLog("Pageno:== ${(nextPage ?? 0) + 1}");
    await musicDetailProvider.setLoadMore(true);
    if ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
            ?.displayDescription
            .toString() ==
        "author") {
      await musicDetailProvider.getEpisodeByAuthorMusic(
          (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.artist,
          (nextPage ?? 0) + 1);
    } else {
      await musicDetailProvider.getEpisodeByMusic(
          Constant.musicsectionId, (nextPage ?? 0) + 1);
    }
  }

  @override
  void dispose() {
    // Save the current position before disposing
    _saveCurrentPosition();
    
    // ⭐ CRITICAL: DON'T clear miniplayer state on dispose
    // This method is called when the app closes OR when navigating away
    // We only want to clear state when user explicitly dismisses the miniplayer
    // The state will persist and allow restoration on next app launch
    
    musicDetailProvider.clearProvider();
    ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _scrollcontroller.dispose();
    super.dispose();
  }
  
  Future<void> _saveCurrentPosition() async {
    try {
      final currentItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
      if (currentItem?.id != null && audioPlayer.playing) {
        final position = audioPlayer.position;
        if (position.inSeconds > 0) {
          await AudioPositionService.savePosition(currentItem!.id, position);
          print('💾 Position saved: ${position.inSeconds}s');
        }
      }
    } catch (e) {
      printLog('Error saving position: $e');
    }
  }

@override
Widget build(BuildContext context) {
  final media = MediaQuery.of(context);

  // Keep miniplayer minHeight fixed to constant playerMinHeight (avoid too-small collapsed height)
  // Ensure ValueNotifier is in sync so Miniplayer uses correct min height immediately.
  playerExpandProgress.value = playerMinHeight;

  // Reserve bottom padding for expanded content so it won't be hidden by the miniplayer
  final double contentBottomPadding = playerMinHeight;

  return SizedBox(
    width: media.size.width,
    child: Miniplayer(
      valueNotifier: playerExpandProgress,
      minHeight: playerMinHeight, // use fixed constant to avoid gesture-bar overlap
      duration: const Duration(milliseconds: 360),
      maxHeight: media.size.height,
      controller: controller,
      elevation: 4,
      backgroundColor: colorPrimary, // same as app background to avoid white seams
      curve: Curves.easeInOutCubicEmphasized,
      onDismiss: () {},
      onDismissed: () async {
        currentlyPlaying.value = null;
        try {
          if (Constant.userID != null && connectivityProvider.isOnline) {
            await musicDetailProvider.addToContinue(widget.contentid, widget.contenttype, currentstoptime, 0, 0);
          }
        } catch (e) {
          // swallow errors here so UI won't crash on dismiss
          print('Error saving continue state on dismiss: $e');
        }

        // ⭐ ONLY clear state if user explicitly dismisses, not on app close
        // Clear miniplayer restoration state
        musicManager.clearMiniplayerState();
        
        currentlyPlaying.value = null;
        try {
          await audioPlayer.pause();
          await audioPlayer.stop();
          await audioPlayer.dispose();
        } catch (_) {}
        audioPlayer = AudioPlayer();
        if (mounted) setState(() {});
        try {
          musicManager.clearMusicPlayer();
          musicDetailProvider.clearProvider();
        } catch (_) {}
      },
      builder: (height, percentage) {
        final bool isCollapsed = percentage < miniplayerPercentageDeclaration;

        if (!isCollapsed) {
          // ---------- EXPANDED (full) VIEW ----------
          return Container(
            color: colorPrimary, // keep consistent background to avoid white seams
            child: SafeArea(
              bottom: false, // do not add additional bottom safe area here (miniplayer already reserved)
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: contentBottomPadding),
                      child: kIsWeb ? webBuildMusicPage() : buildMusicPage(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // ---------- COLLAPSED (mini) VIEW ----------
        // percentage-based opacity & progress height (can be adjusted)
        final percentageMiniplayer = percentageFromValueInRange(
          min: playerMinHeight,
          max: media.size.height,
          value: height,
        );

        final double elementOpacity = 1 - 1 * percentageMiniplayer;
        final double progressIndicatorHeight = 2 - 2 * percentageMiniplayer;

        // Put collapsed UI in a simple Container (not Scaffold) to avoid extra paddings or white areas.
        return Container(
          color: colorPrimary, // ensures no white background above/below
          height: height,
          child: Listener(
            behavior: HitTestBehavior.opaque, // ensures the panel receives pointer events
            onPointerDown: (_) {
              // optional debug: print('miniplayer pointer down');
            },
            child: _buildMusicPanel(
              height,
              elementOpacity,
              progressIndicatorHeight,
              playerMinHeight, // pass the fixed collapsed height value
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildAppBar() {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FittedBox(
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: 11,
                  child: Utils().backBtn(25, 25, 20),
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: MyText(
              fontsizeWeb: 16,
              color: white,
              text: "playingstart",
              maxline: 1,
              fontsizeNormal: 16,
              multilanguage: true,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
              fontstyle: FontStyle.normal,
            ),
          ),
          const SizedBox(width: 45),
        ],
      ),
    );
  }

  Widget buildMusicPage() {
    return NestedScrollView(
      controller: _scrollcontroller,
      floatHeaderSlivers: false,
      physics: const ScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      scrollDirection: Axis.vertical,
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          /* UserProfile Section */
          SliverAppBar(
            floating: false,
            forceElevated: false,
            snap: false,
            elevation: 0,
            expandedHeight: MediaQuery.of(context).size.height * 0.72,
            automaticallyImplyLeading: false,
            backgroundColor: colorPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Music Image With Song Title
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                         StreamBuilder<SequenceState?>(
    stream: audioPlayer.sequenceStateStream,
    builder: (context, snapshot) {
      final currentItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
      // REMOVED: Automatic playback logic - now handled by _handleInitialPlayback
      return Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(width: 3.0, color: white),
            bottom: BorderSide(width: 3.0, color: white),
          ),
        ),
        child: (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre == "download"
            ? MyFileImage(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.30,
                imagePath: (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.extras?['image'].toString() ?? '',
                fit: BoxFit.fill,
              )
            : MyNetworkImage(
                imgWidth: MediaQuery.of(context).size.width,
                imgHeight: MediaQuery.of(context).size.height * 0.30,
                imageUrl: ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.artUri).toString(),
                fit: BoxFit.fill,
              ),
      );
    }),
                          const SizedBox(height: 15),
                          StreamBuilder<SequenceState?>(
                              stream: audioPlayer.sequenceStateStream,
                              builder: (context, snapshot) {
                                return Container(
                                  height: 35,
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                  child: MyMarqueeText(
                                      text: ((audioPlayer
                                                  .sequenceState
                                                  ?.currentSource
                                                  ?.tag as MediaItem?)
                                              ?.title)
                                          .toString(),
                                      fontsize: Dimens.textBig,
                                      color: white),
                                );
                              }),
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    // All Buttons
                    Container(
                      // height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                            child: StreamBuilder<PositionData>(
                              stream: positionDataStream,
                              builder: (context, snapshot) {
                                final positionData = snapshot.data;
                                return ProgressBar(
                                  progress:
                                      positionData?.position ?? Duration.zero,
                                  buffered: positionData?.bufferedPosition ??
                                      Duration.zero,
                                  total:
                                      positionData?.duration ?? Duration.zero,
                                  progressBarColor: white,
                                  baseBarColor: colorAccent,
                                  bufferedBarColor: gray,
                                  thumbColor: white,
                                  barHeight: 2.0,
                                  thumbRadius: 5.0,
                                  timeLabelPadding: 5.0,
                                  timeLabelType: TimeLabelType.totalTime,
                                  timeLabelTextStyle: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontStyle: FontStyle.normal,
                                    color: white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  onSeek: (duration) {
                                    audioPlayer.seek(duration);
                                  },
                                );
                              },
                            ),
                          ),
                          // DEBUG BUTTONS - REMOVE AFTER TESTING

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Privious Audio Setup
                              StreamBuilder<SequenceState?>(
                                stream: audioPlayer.sequenceStateStream,
                                builder: (context, snapshot) => IconButton(
                                  iconSize: 40,
                                  icon: const Icon(
                                    Icons.skip_previous_rounded,
                                    color: white,
                                  ),
                                  onPressed: audioPlayer.hasPrevious
                                      ? audioPlayer.seekToPrevious
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 15),
                              // 10 Second Privious
                              StreamBuilder<PositionData>(
                                stream: positionDataStream,
                                builder: (context, snapshot) {
                                  final positionData = snapshot.data;
                                  return InkWell(
                                      onTap: () {
                                        tenSecNextOrPrevious(
                                            positionData?.position.inSeconds
                                                    .toString() ??
                                                "",
                                            false);
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.replay_10_outlined,
                                          size: 30,
                                          color: white,
                                        ),
                                      ));
                                },
                              ),
                              const SizedBox(width: 15),
                              // Pause and Play Controll
                          // Pause and Play Controll
StreamBuilder<PlayerState>(
  stream: audioPlayer.playerStateStream,
  builder: (context, snapshot) {
    final playerState = snapshot.data;
    final processingState = playerState?.processingState;
    final playing = playerState?.playing;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: const EdgeInsets.all(8.0),
        width: 50.0,
        height: 50.0,
        child: const CircularProgressIndicator(
          color: colorAccent,
        ),
      );
    } else if (playing != true) {
      return Container(
        decoration: BoxDecoration(
          color: colorAccent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.play_arrow_rounded,
            color: white,
          ),
          color: white,
          iconSize: 50.0,
          onPressed: () async {
            // Simply play - don't reset audio source
            await audioPlayer.play();
          },
        ),
      );
    } else if (processingState != ProcessingState.completed) {
      return Container(
        decoration: BoxDecoration(
          color: colorAccent,
          borderRadius: BorderRadius.circular(50),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.pause_rounded,
            color: white,
          ),
          iconSize: 50.0,
          color: white,
          // onPressed: audioPlayer.pause,
          //tps
         onPressed: () {
        audioPlayer.pause();
      },
      //tps
        ),
      );
    } else {
      return IconButton(
        icon: const Icon(
          Icons.replay_rounded,
          color: white,
        ),
        iconSize: 60.0,
        onPressed: () => audioPlayer.seek(
            Duration.zero,
            index: audioPlayer.effectiveIndices!.first),
      );
    }
  },
),
                              const SizedBox(width: 15),
                              // 10 Second Next
                              StreamBuilder<PositionData>(
                                stream: positionDataStream,
                                builder: (context, snapshot) {
                                  final positionData = snapshot.data;

                                  return InkWell(
                                      onTap: () {
                                        tenSecNextOrPrevious(
                                            positionData?.position.inSeconds
                                                    .toString() ??
                                                "",
                                            true);
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.forward_10_outlined,
                                          size: 30,
                                          color: white,
                                        ),
                                      ));
                                },
                              ),
                              const SizedBox(width: 15),
                              // Next Audio Play
                              StreamBuilder<SequenceState?>(
                                stream: audioPlayer.sequenceStateStream,
                                builder: (context, snapshot) => IconButton(
                                  iconSize: 40.0,
                                  icon: const Icon(
                                    Icons.skip_next_rounded,
                                    color: white,
                                  ),
                                  onPressed: audioPlayer.hasNext
                                      ? audioPlayer.seekToNext
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          // const SizedBox(height: 10),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 55,
                            decoration: const BoxDecoration(
                                // color: colorAccent,
                                ),
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Volumn Costome Set
                                IconButton(
                                  iconSize: 30.0,
                                  icon: const Icon(Icons.volume_up),
                                  color: white,
                                  onPressed: () {
                                    showSliderDialog(
                                      context: context,
                                      title: "Adjust volume",
                                      divisions: 10,
                                      min: 0.0,
                                      max: 2.0,
                                      value: audioPlayer.volume,
                                      stream: audioPlayer.volumeStream,
                                      onChanged: audioPlayer.setVolume,
                                    );
                                  },
                                ),
                                // Audio Speed Costomized
                                StreamBuilder<double>(
                                  stream: audioPlayer.speedStream,
                                  builder: (context, snapshot) => IconButton(
                                    icon: Text(
                                      overflow: TextOverflow.ellipsis,
                                      "${snapshot.data?.toStringAsFixed(1)}x",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: white,
                                          fontSize: 14),
                                    ),
                                    onPressed: () {
                                      showSliderDialog(
                                        context: context,
                                        title: "Adjust speed",
                                        divisions: 10,
                                        min: 0.5,
                                        max: 2.0,
                                        value: audioPlayer.speed,
                                        stream: audioPlayer.speedStream,
                                        onChanged: audioPlayer.setSpeed,
                                      );
                                    },
                                  ),
                                ),
                                // Loop Node Button
                                StreamBuilder<LoopMode>(
                                  stream: audioPlayer.loopModeStream,
                                  builder: (context, snapshot) {
                                    final loopMode =
                                        snapshot.data ?? LoopMode.off;
                                    const icons = [
                                      Icon(Icons.repeat,
                                          color: white, size: 30.0),
                                      Icon(Icons.repeat,
                                          color: colorAccent, size: 30.0),
                                      Icon(Icons.repeat_one,
                                          color: colorAccent, size: 30.0),
                                    ];
                                    const cycleModes = [
                                      LoopMode.off,
                                      LoopMode.all,
                                      LoopMode.one,
                                    ];
                                    final index = cycleModes.indexOf(loopMode);
                                    return IconButton(
                                      icon: icons[index],
                                      onPressed: () {
                                        audioPlayer.setLoopMode(cycleModes[
                                            (cycleModes.indexOf(loopMode) + 1) %
                                                cycleModes.length]);
                                      },
                                    );
                                  },
                                ),
                                // Suffle Button
                                StreamBuilder<bool>(
                                  stream: audioPlayer.shuffleModeEnabledStream,
                                  builder: (context, snapshot) {
                                    final shuffleModeEnabled =
                                        snapshot.data ?? false;
                                    return IconButton(
                                      iconSize: 30.0,
                                      icon: shuffleModeEnabled
                                          ? const Icon(Icons.shuffle,
                                              color: colorAccent)
                                          : const Icon(Icons.shuffle,
                                              color: white),
                                      onPressed: () async {
                                        final enable = !shuffleModeEnabled;
                                        if (enable) {
                                          await audioPlayer.shuffle();
                                        }
                                        await audioPlayer
                                            .setShuffleModeEnabled(enable);
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                    // Bottom Sheet
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.genre)
                  .toString() ==
              "2"
          ? const SizedBox.shrink()
          : Consumer<MusicDetailProvider>(
              builder: (context, seactionprovider, child) {
              return Container(
                decoration: const BoxDecoration(
                  color: colorPrimaryDark,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 60,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 1,
                              child: InkWell(
                                onTap: () {
                                  seactionprovider.changeMusicTab("episode");
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  // height: 50,
                                  alignment: Alignment.center,
                                  // color: colorAccent,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      MyText(
                                          fontsizeWeb: Dimens.textDesc,
                                          color: white,
                                          text: "listofaudio",
                                          multilanguage: true,
                                          textalign: TextAlign.center,
                                          fontsizeNormal: Dimens.textDesc,
                                          // inter: false,
                                          maxline: 6,
                                          fontweight: FontWeight.w600,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal),
                                      seactionprovider.istype == "episode"
                                          ? Container(
                                              width: 100,
                                              height: 1,
                                              color: colorAccent,
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ((audioPlayer.sequenceState?.currentSource?.tag
                                          as MediaItem?)
                                      ?.genre)
                                  .toString() ==
                              "download"
                          ? buildPodcastEpisodeDownload()
                          : buildPodcastEpisode()
                    ],
                  ),
                ),
              );
            }),
    );
  }

 Widget webBuildMusicPage() {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          children: [
            // Music Image With Song Title
            Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),
                  StreamBuilder<SequenceState?>(
                    stream: audioPlayer.sequenceStateStream,
                    builder: (context, snapshot) {
                      final currentItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
                      if (currentItem?.extras?['is_audio_paid'] == 1 &&
                          currentItem?.extras?['is_buy'] == 0) {
                        audioPlayer.pause();
                      } else if (currentItem?.extras?['url'] != null) {
                        _playAudio(currentItem!, currentItem.extras!['url']).then((_) {
                          // Handle completion if needed
                        });
                      } else {
                        audioPlayer.playing
                            ? audioPlayer.play()
                            : audioPlayer.pause();
                      }
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          // border: Border(
                          //   top: BorderSide(width: 3.0, color: white),
                          //   bottom: BorderSide(width: 3.0, color: white),
                          // ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: MyNetworkImage(
                            imgWidth:
                                MediaQuery.of(context).size.width * 0.35,
                            imgHeight:
                                MediaQuery.of(context).size.height * 0.35,
                            imageUrl: ((audioPlayer.sequenceState
                                        ?.currentSource?.tag as MediaItem?)
                                    ?.artUri)
                                .toString(),
                            fit: BoxFit.fill,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<SequenceState?>(
                      stream: audioPlayer.sequenceStateStream,
                      builder: (context, snapshot) {
                        return Container(
                          height: 35,
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: MyMarqueeText(
                              text: ((audioPlayer.sequenceState?.currentSource
                                          ?.tag as MediaItem?)
                                      ?.title)
                                  .toString(),
                              fontsize: Dimens.textBig,
                              color: white),
                        );
                      }),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                    child: StreamBuilder<PositionData>(
                      stream: positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data;
                        return ProgressBar(
                          progress: positionData?.position ?? Duration.zero,
                          buffered:
                              positionData?.bufferedPosition ?? Duration.zero,
                          total: positionData?.duration ?? Duration.zero,
                          progressBarColor: white,
                          baseBarColor: colorAccent,
                          bufferedBarColor: gray,
                          thumbColor: white,
                          barHeight: 2.0,
                          thumbRadius: 5.0,
                          timeLabelPadding: 5.0,
                          timeLabelType: TimeLabelType.totalTime,
                          timeLabelTextStyle: GoogleFonts.inter(
                            fontSize: 12,
                            fontStyle: FontStyle.normal,
                            color: white,
                            fontWeight: FontWeight.w700,
                          ),
                          onSeek: (duration) {
                            audioPlayer.seek(duration);
                          },
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Privious Audio Setup
                      StreamBuilder<SequenceState?>(
                        stream: audioPlayer.sequenceStateStream,
                        builder: (context, snapshot) => IconButton(
                          iconSize: 40,
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            color: white,
                          ),
                          onPressed: audioPlayer.hasPrevious
                              ? audioPlayer.seekToPrevious
                              : null,
                        ),
                      ),
                      const SizedBox(width: 15),
                      // 10 Second Privious
                      StreamBuilder<PositionData>(
                        stream: positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data;
                          return InkWell(
                              onTap: () {
                                tenSecNextOrPrevious(
                                    positionData?.position.inSeconds
                                            .toString() ??
                                        "",
                                    false);
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(5),
                                child: Icon(
                                  Icons.replay_10_outlined,
                                  size: 30,
                                  color: white,
                                ),
                              ));
                        },
                      ),
                      const SizedBox(width: 15),
                      // Pause and Play Controll
                      StreamBuilder<PlayerState>(
                        stream: audioPlayer.playerStateStream,
                        builder: (context, snapshot) {
                          final playerState = snapshot.data;
                          final processingState = playerState?.processingState;
                          final playing = playerState?.playing;
                          if (processingState == ProcessingState.loading ||
                              processingState == ProcessingState.buffering) {
                            return Container(
                              margin: const EdgeInsets.all(8.0),
                              width: 50.0,
                              height: 50.0,
                              child: const CircularProgressIndicator(
                                color: colorAccent,
                              ),
                            );
                          } else if (playing != true) {
                            return Container(
                              decoration: BoxDecoration(
                                color: colorAccent,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: white,
                                ),
                                color: white,
                                iconSize: 50.0,
                                // onPressed: audioPlayer.play,

                                onPressed: () async {
                                  final currentItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
                                  if (currentItem?.extras?['url'] != null) {
                                    await _playAudio(currentItem!, currentItem.extras!['url']);
                                  } else {
                                    audioPlayer.play();
                                  }
                                },
                              ),
                            );
                          } else if (processingState != ProcessingState.completed) {
                            return Container(
                              decoration: BoxDecoration(
                                color: colorAccent,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.pause_rounded,
                                  color: white,
                                ),
                                iconSize: 50.0,
                                color: white,
                                // onPressed: audioPlayer.pause,
                                onPressed: () async {
                                  final currentItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
                                  if (currentItem?.extras?['url'] != null) {
                                    await _playAudio(currentItem!, currentItem.extras!['url']);
                                  } else {
                                    audioPlayer.pause();
                                  }
                                },
                              ),
                            );
                          } else {
                            return IconButton(
                              icon: const Icon(
                                Icons.replay_rounded,
                                color: white,
                              ),
                              iconSize: 60.0,
                              onPressed: () => audioPlayer.seek(
                                  Duration.zero,
                                  index: audioPlayer.effectiveIndices!.first),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 15),
                      // 10 Second Next
                      StreamBuilder<PositionData>(
                        stream: positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data;

                          return InkWell(
                              onTap: () {
                                tenSecNextOrPrevious(
                                    positionData?.position.inSeconds
                                            .toString() ??
                                        "",
                                    true);
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(5),
                                child: Icon(
                                  Icons.forward_10_outlined,
                                  size: 30,
                                  color: white,
                                ),
                              ));
                        },
                      ),
                      const SizedBox(width: 15),
                      // Next Audio Play
                      StreamBuilder<SequenceState?>(
                        stream: audioPlayer.sequenceStateStream,
                        builder: (context, snapshot) => IconButton(
                          iconSize: 40.0,
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: white,
                          ),
                          onPressed: audioPlayer.hasNext
                              ? audioPlayer.seekToNext
                              : null,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 55,
                    decoration: BoxDecoration(
                        color: colorAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30)),
                    margin:
                        const EdgeInsets.only(top: 15, left: 10, right: 10),
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Volumn Costome Set
                        IconButton(
                          iconSize: 30.0,
                          icon: const Icon(Icons.volume_up),
                          color: white,
                          onPressed: () {
                            showSliderDialog(
                              context: context,
                              title: "Adjust volume",
                              divisions: 10,
                              min: 0.0,
                              max: 2.0,
                              value: audioPlayer.volume,
                              stream: audioPlayer.volumeStream,
                              onChanged: audioPlayer.setVolume,
                            );
                          },
                        ),
                        // Audio Speed Costomized
                        StreamBuilder<double>(
                          stream: audioPlayer.speedStream,
                          builder: (context, snapshot) => IconButton(
                            icon: Text(
                              overflow: TextOverflow.ellipsis,
                              "${snapshot.data?.toStringAsFixed(1)}x",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: white,
                                  fontSize: 14),
                            ),
                            onPressed: () {
                              showSliderDialog(
                                context: context,
                                title: "Adjust speed",
                                divisions: 10,
                                min: 0.5,
                                max: 2.0,
                                value: audioPlayer.speed,
                                stream: audioPlayer.speedStream,
                                onChanged: audioPlayer.setSpeed,
                              );
                            },
                          ),
                        ),
                        // Loop Node Button
                        StreamBuilder<LoopMode>(
                          stream: audioPlayer.loopModeStream,
                          builder: (context, snapshot) {
                            final loopMode = snapshot.data ?? LoopMode.off;
                            const icons = [
                              Icon(Icons.repeat, color: white, size: 30.0),
                              Icon(Icons.repeat,
                                  color: colorAccent, size: 30.0),
                              Icon(Icons.repeat_one,
                                  color: colorAccent, size: 30.0),
                            ];
                            const cycleModes = [
                              LoopMode.off,
                              LoopMode.all,
                              LoopMode.one,
                            ];
                            final index = cycleModes.indexOf(loopMode);
                            return IconButton(
                              icon: icons[index],
                              onPressed: () {
                                audioPlayer.setLoopMode(cycleModes[
                                    (cycleModes.indexOf(loopMode) + 1) %
                                        cycleModes.length]);
                              },
                            );
                          },
                        ),
                        // Suffle Button
                        StreamBuilder<bool>(
                          stream: audioPlayer.shuffleModeEnabledStream,
                          builder: (context, snapshot) {
                            final shuffleModeEnabled = snapshot.data ?? false;
                            return IconButton(
                              iconSize: 30.0,
                              icon: shuffleModeEnabled
                                  ? const Icon(Icons.shuffle,
                                      color: colorAccent)
                                  : const Icon(Icons.shuffle, color: white),
                              onPressed: () async {
                                final enable = !shuffleModeEnabled;
                                if (enable) {
                                  await audioPlayer.shuffle();
                                }
                                await audioPlayer.setShuffleModeEnabled(enable);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
Future<void> _testPositionService() async {
  final currentItem = audioPlayer.sequenceState?.currentSource?.tag as MediaItem?;
  if (currentItem?.id != null) {
    final savedPosition = await AudioPositionService.getPosition(currentItem!.id);
    print('=== POSITION DEBUG ===');
    print('Current Item ID: ${currentItem.id}');
    print('Saved Position: ${savedPosition.inSeconds} seconds');
    print('Audio Playing: ${audioPlayer.playing}');
    print('=== END DEBUG ===');
  }
}


Widget _buildMusicPanel(
  double dynamicPanelHeight,
  double elementOpacity,
  double progressIndicatorHeight,
  double effectiveMinHeight,
) {
  // IMPORTANT: Use the audioPlayer.sequenceStateStream as the single source of truth
  return StreamBuilder<SequenceState?>(
    stream: audioPlayer.sequenceStateStream,
    builder: (context, seqSnapshot) {
      final seqState = seqSnapshot.data;
      // Extract current MediaItem defensively from the sequence state snapshot
      final MediaItem? currentItem = (seqState?.currentSource?.tag is MediaItem)
          ? seqState?.currentSource?.tag as MediaItem?
          : null;

      // If no item present, show a stable placeholder to avoid blank UI
      if (currentItem == null) {
        return Container(
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(color: colorPrimary),
          child: Column(
            children: [
              Expanded(
                child: Opacity(
                  opacity: elementOpacity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: kIsWeb ? 120 : 80,
                        height: dynamicPanelHeight,
                        margin: const EdgeInsets.only(right: 8),
                        alignment: Alignment.center,
                        color: Colors.black12,
                        child: const Icon(Icons.audiotrack, color: white),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                color: white,
                                text: "No track loaded",
                                fontsizeNormal: 14,
                                fontsizeWeb: 14,
                                multilanguage: false,
                              ),
                              const SizedBox(height: 2),
                              MyText(
                                color: white,
                                text: "",
                                fontsizeNormal: 12,
                                fontsizeWeb: 12,
                                multilanguage: false,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 12),
                        child: IconButton(
                          icon: const Icon(Icons.play_arrow_rounded, color: Colors.white54),
                          onPressed: null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: progressIndicatorHeight,
                color: white.withOpacity(0.05),
              ),
            ],
          ),
        );
      }

      // Build the panel with currentItem coming from the stream snapshot
      return Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(color: colorPrimary),
        child: Column(
          children: [
            // Main content row (artwork, title, controls)
            Expanded(
              child: Opacity(
                opacity: elementOpacity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Artwork
                    Container(
                      width: kIsWeb ? 120 : 80,
                      height: dynamicPanelHeight,
                      padding: const EdgeInsets.fromLTRB(10, 3, 5, 3),
                      margin: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (currentItem.genre == "download")
                            ? MyFileImage(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                imagePath: currentItem.extras?['image']?.toString() ?? '',
                                fit: BoxFit.fill,
                              )
                            : MyNetworkImage(
                                imgWidth: MediaQuery.of(context).size.width,
                                imgHeight: MediaQuery.of(context).size.height,
                                imageUrl: (currentItem.artUri ?? '').toString(),
                                fit: BoxFit.fill,
                              ),
                      ),
                    ),

                    // Title & subtitle
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 20,
                            child: MyMarqueeText(
                              text: currentItem.title ?? '',
                              fontsize: Dimens.textBig,
                              color: white,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                          MyText(
                            color: white,
                            text: currentItem.displaySubtitle ?? '',
                            textalign: TextAlign.left,
                            fontsizeNormal: 12,
                            fontsizeWeb: 12,
                            multilanguage: false,
                            maxline: 1,
                            fontweight: FontWeight.w400,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ),

                    // Controls (compact)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Previous
                          IconButton(
                            iconSize: 26.0,
                            icon: const Icon(Icons.skip_previous_rounded, color: white),
                            onPressed: audioPlayer.hasPrevious
                                ? () async {
                                    try {
                                      // try seeking to previous, await completion
                                      await audioPlayer.seekToPrevious();
                                      // sometimes the stream emission is slightly delayed; force a rebuild after a short delay
                                      Future.delayed(const Duration(milliseconds: 150), () {
                                        if (mounted) setState(() {});
                                      });
                                    } catch (e) {
                                      print('Error seeking to previous: $e');
                                    }
                                  }
                                : null,
                          ),

                          // Play / Pause
                          StreamBuilder<PlayerState>(
                            stream: audioPlayer.playerStateStream,
                            builder: (context, playerSnapshot) {
                              final playerState = playerSnapshot.data;
                              final processingState = playerState?.processingState;
                              final playing = playerState?.playing;

                              if (processingState == ProcessingState.loading ||
                                  processingState == ProcessingState.buffering) {
                                return Container(
                                  margin: const EdgeInsets.all(8.0),
                                  width: 36.0,
                                  height: 36.0,
                                  child: Utils.pageLoader(),
                                );
                              } else if (playing != true) {
                                return Container(
                                  decoration: BoxDecoration(color: colorAccent, borderRadius: BorderRadius.circular(50)),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () async {
                                      // Simply play - don't reset audio source
                                      await audioPlayer.play();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(Icons.play_arrow_rounded, color: white, size: 26),
                                    ),
                                  ),
                                );
                              } else if (processingState != ProcessingState.completed) {
                                return Container(
                                  decoration: BoxDecoration(color: colorAccent, borderRadius: BorderRadius.circular(50)),
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () async {
                                      await audioPlayer.pause();
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(Icons.pause_rounded, color: white, size: 26),
                                    ),
                                  ),
                                );
                              } else {
                                return IconButton(
                                  icon: const Icon(Icons.replay_rounded, color: white),
                                  iconSize: 36.0,
                                  onPressed: () => audioPlayer.seek(Duration.zero, index: audioPlayer.effectiveIndices!.first),
                                );
                              }
                            },
                          ),

                          // Next
                          IconButton(
                            iconSize: 26.0,
                            icon: const Icon(Icons.skip_next_rounded, color: white),
                            onPressed: audioPlayer.hasNext
                                ? () async {
                                    try {
                                      // Seek to next and await
                                      await audioPlayer.seekToNext();
                                      // Force a small rebuild in case stream update lags slightly
                                      Future.delayed(const Duration(milliseconds: 150), () {
                                        if (mounted) setState(() {});
                                      });
                                    } catch (e) {
                                      print('Error seeking to next: $e');
                                    }
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Progress bar
            StreamBuilder<PositionData>(
              stream: positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return ProgressBar(
                  progress: positionData?.position ?? Duration.zero,
                  buffered: positionData?.bufferedPosition ?? Duration.zero,
                  total: positionData?.duration ?? Duration.zero,
                  progressBarColor: white,
                  baseBarColor: colorAccent,
                  bufferedBarColor: white.withOpacity(0.24),
                  barCapShape: BarCapShape.square,
                  barHeight: progressIndicatorHeight,
                  thumbRadius: 0.0,
                  timeLabelLocation: TimeLabelLocation.none,
                );
              },
            ),
          ],
        ),
      );
    },
  );
}


Future<void> _resumeAndPlay() async {
  try {
    final seqState = audioPlayer.sequenceState;
    final MediaItem? currentItem = seqState?.currentSource?.tag is MediaItem ? seqState?.currentSource?.tag as MediaItem : null;
    if (currentItem == null) {
      // nothing to resume
      return;
    }
    final savedPosition = await AudioPositionService.getPosition(currentItem.id);
    if (!audioPlayer.playing && savedPosition.inSeconds > 10) {
      await audioPlayer.seek(savedPosition);
    }
    if (!audioPlayer.playing) {
      await audioPlayer.play();
    }
  } catch (e) {
    print('Error in _resumeAndPlay: $e');
    // best-effort fallback
    try { await audioPlayer.play(); } catch (_) {}
  }
}


Widget buildPodcastEpisode() {
  return Consumer<MusicDetailProvider>(
      builder: (context, musicDetailProvider, child) {
    if (musicDetailProvider.loading &&
        musicDetailProvider.loadmore == false) {
      return Container();
    } else {
      if (musicDetailProvider.epidoseByPodcastModel.status == 200 &&
          musicDetailProvider.podcastEpisodeList != null) {
        if ((musicDetailProvider.podcastEpisodeList?.length ?? 0) > 0) {
          return ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 1,
            maxItemsPerRow: 1,
            horizontalGridSpacing: 10,
            verticalGridSpacing: 10,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(
                musicDetailProvider.podcastEpisodeList?.length ?? 0, (index) {
              printLog(
                  "buildPodcastEpisode buildPodcastEpisode = ${musicDetailProvider.podcastEpisodeList?.length}");
              return InkWell(
                onTap: () async {
                  audioPlayer.pause();

                  if (musicDetailProvider
                          .podcastEpisodeList?[index].isAudioPaid ==
                      1) {
                    if (musicDetailProvider
                            .podcastEpisodeList?[index].isBuy ==
                        1) {
                      musicManager.setInitialMusic(
                          index,
                          musicDetailProvider
                                  .podcastEpisodeList?[index].contentType
                                  .toString() ??
                              "",
                          musicDetailProvider.podcastEpisodeList,
                          musicDetailProvider
                                  .podcastEpisodeList?[index].contentId
                                  .toString() ??
                              "",
                          addView(
                            musicDetailProvider
                                    .podcastEpisodeList?[index].contentType
                                    .toString() ??
                                "",
                            ((audioPlayer.sequenceState?.currentSource?.tag
                                        as MediaItem?)
                                    ?.id)
                                .toString(),
                            musicDetailProvider
                                    .podcastEpisodeList?[index].contentId
                                    .toString() ??
                                "",
                          ),
                          false,
                          0,
                          musicDetailProvider.podcastEpisodeList?[index]
                                      .contentType ==
                                  3
                              ? "1"
                              : (audioPlayer.sequenceState?.currentSource?.tag
                                          as MediaItem?)
                                      ?.extras?['is_buy']
                                      .toString() ??
                                  '',
                          musicDetailProvider
                                  .podcastEpisodeList?[index].isAudioPaid ??
                              0,
                          "music",
                          "0");
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AudioBuy(
                                    coins: musicDetailProvider
                                        .podcastEpisodeList?[index]
                                        .isAudioCoin,
                                    contentid: musicDetailProvider
                                        .podcastEpisodeList?[index].contentId
                                        .toString(),
                                    episodeName: musicDetailProvider
                                        .podcastEpisodeList?[index].name,
                                    episodeid: musicDetailProvider
                                        .podcastEpisodeList?[index].id
                                        .toString(),
                                  )));
                    }
                  } else {
                    musicManager.setInitialMusic(
                        index,
                        musicDetailProvider
                                .podcastEpisodeList?[index].contentType
                                .toString() ??
                            "",
                        musicDetailProvider.podcastEpisodeList,
                        musicDetailProvider
                                .podcastEpisodeList?[index].contentId
                                .toString() ??
                            "",
                        addView(
                          musicDetailProvider
                                  .podcastEpisodeList?[index].contentType
                                  .toString() ??
                              "",
                          ((audioPlayer.sequenceState?.currentSource?.tag
                                      as MediaItem?)
                                  ?.id)
                              .toString(),
                          musicDetailProvider
                                  .podcastEpisodeList?[index].contentId
                                  .toString() ??
                              "",
                        ),
                        false,
                        0,
                        musicDetailProvider
                                    .podcastEpisodeList?[index].contentType ==
                                3
                            ? "1"
                            : (audioPlayer.sequenceState?.currentSource?.tag
                                        as MediaItem?)
                                    ?.extras?['is_buy']
                                    .toString() ??
                                '',
                        musicDetailProvider
                                .podcastEpisodeList?[index].isAudioPaid ??
                            0,
                        "music",
                        "0");
                  }
                },
                child: Container(
                  color: ((audioPlayer.sequenceState?.currentSource?.tag
                                      as MediaItem?)
                                  ?.id)
                              .toString() ==
                          musicDetailProvider.podcastEpisodeList?[index].id
                              .toString()
                      ? colorAccent.withOpacity(0.10)
                      : colorPrimaryDark,
                  height: 75, // CHANGED: Increased from 75 to 85
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  child: Row(children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: colorAccent),
                          ),
                          child: MyNetworkImage(
                            fit: BoxFit.fill,
                            imgWidth: 70,
                            imageUrl: ((musicDetailProvider
                                        .podcastEpisodeList?[index]
                                        .portraitImg) ==
                                    null)
                                ? (musicDetailProvider
                                        .podcastEpisodeList?[index].image
                                        .toString() ??
                                    "")
                                : musicDetailProvider
                                        .podcastEpisodeList?[index]
                                        .portraitImg
                                        .toString() ??
                                    "",
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: ((audioPlayer.sequenceState?.currentSource
                                                ?.tag as MediaItem?)
                                            ?.id)
                                        .toString() ==
                                    musicDetailProvider
                                        .podcastEpisodeList?[index].id
                                        .toString()
                                ? MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "music.gif")
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                              fontsizeWeb: Dimens.textMedium,
                              color: white,
                              multilanguage: false,
                              text: ((musicDetailProvider
                                          .podcastEpisodeList?[index].name) ==
                                      null)
                                  ? (musicDetailProvider
                                          .podcastEpisodeList?[index].title
                                          .toString() ??
                                      "")
                                  : musicDetailProvider
                                          .podcastEpisodeList?[index].name
                                          .toString() ??
                                      "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textMedium,
                              maxline: 1,
                              fontweight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                          MyText(
                              color: white,
                              multilanguage: false,
                              text: musicDetailProvider
                                      .podcastEpisodeList?[index].description
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textSmall,
                              fontsizeWeb: Dimens.textSmall,
                              maxline: 1,
                              fontweight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                          // ADD THIS: Progress indicator for each episode
                         
                        ],
                      ),
                    ),
                  ]),
                ),
              );
            }),
          );
        } else {
          printLog(
              "buildPodcastEpisode buildPodcastEpisode = ${musicDetailProvider.podcastEpisodeList?.length}");
          return const NoData(title: "", subTitle: "");
        }
      } else {
        printLog(
            "buildPodcastEpisode buildPodcastEpisode = ${musicDetailProvider.podcastEpisodeList?.length}");
        return const NoData(title: "", subTitle: "");
      }
    }
  });
}


  Widget buildPodcastEpisodeDownload() {
  return Consumer<DownLoadProvider>(
    builder: (context, downloadProvider, child) {
      if (downloadProvider.downLoadloading) {
        return Container();
      } else {
        if (downloadProvider.myEpisodeList != null &&
            (downloadProvider.myEpisodeList?.length ?? 0) > 0) {
          return ResponsiveGridList(
            minItemWidth: 120,
            minItemsPerRow: 1,
            maxItemsPerRow: 1,
            horizontalGridSpacing: 10,
            verticalGridSpacing: 10,
            listViewBuilderOptions: ListViewBuilderOptions(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(
                downloadProvider.myEpisodeList?.length ?? 0, (index) {
              printLog(
                  "buildPodcastEpisode buildPodcastEpisode = ${downloadProvider.myEpisodeList?.length}");
              return InkWell(
                onTap: () async {
                  audioPlayer.pause();

                  musicManager.setDownloadInitialMusic(
                    index,
                    downloadProvider.myEpisodeList?[index].contentType
                            .toString() ??
                        "",
                    downloadProvider.myEpisodeList,
                    downloadProvider.myEpisodeList?[index].contentId
                            .toString() ??
                        "",
                    // addView(
                    //   myEpisodeList?[index].contentType.toString() ?? "",
                    //   ((audioPlayer.sequenceState?.currentSource?.tag
                    //               as MediaItem?)
                    //           ?.id)
                    //       .toString(),
                    //   myEpisodeList?[index].contentId.toString() ?? "",
                    // ),
                    () {},
                    false,
                    0,
                    downloadProvider.myEpisodeList?[index].contentType == 3
                        ? "1"
                        : downloadProvider.myEpisodeList?[index].isBuy
                                .toString() ??
                            '',
                    downloadProvider.myEpisodeList?[index].isAudioPaid ?? 0,
                    "music",
                    "0",
                    () {
                      setState(() {
                        printLog("setState Callign ");
                      });
                    },
                  );
                },
                child: Container(
                  color: ((audioPlayer.sequenceState?.currentSource?.tag
                                      as MediaItem?)
                                  ?.id)
                              .toString() ==
                          downloadProvider.myEpisodeList?[index].id.toString()
                      ? colorAccent.withOpacity(0.10)
                      : colorPrimaryDark,
                  height: 75, // CHANGED: Increased from 75 to 85
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                  child: Row(children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: colorAccent),
                          ),
                          child: MyFileImage(
                            fit: BoxFit.fill,
                            width: 70,
                            imagePath: ((downloadProvider
                                        .myEpisodeList?[index]
                                        .landscapeImg) ==
                                    null)
                                ? (downloadProvider
                                        .myEpisodeList?[index].image
                                        .toString() ??
                                    "")
                                : downloadProvider
                                        .myEpisodeList?[index].portraitImg
                                        .toString() ??
                                    "",
                          ),
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: ((audioPlayer.sequenceState?.currentSource
                                                ?.tag as MediaItem?)
                                            ?.id)
                                        .toString() ==
                                    downloadProvider.myEpisodeList?[index].id
                                        .toString()
                                ? MyImage(
                                    width: 30,
                                    height: 30,
                                    imagePath: "music.gif")
                                : const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                              fontsizeWeb: Dimens.textMedium,
                              color: white,
                              multilanguage: false,
                              text: ((downloadProvider
                                          .myEpisodeList?[index].name) ==
                                      null)
                                  ? (downloadProvider
                                          .myEpisodeList?[index].name
                                          .toString() ??
                                      "")
                                  : downloadProvider
                                          .myEpisodeList?[index].title
                                          .toString() ??
                                      "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textMedium,
                              maxline: 1,
                              fontweight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                          MyText(
                              color: white,
                              multilanguage: false,
                              text: downloadProvider
                                      .myEpisodeList?[index].description
                                      .toString() ??
                                  "",
                              textalign: TextAlign.left,
                              fontsizeNormal: Dimens.textSmall,
                              fontsizeWeb: Dimens.textSmall,
                              maxline: 1,
                              fontweight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal),
                          // ADD THIS: Progress indicator for each episode
                         
                        ],
                      ),
                    ),
                  ]),
                ),
              );
            }),
          );
        } else {
          return const NoData(title: "", subTitle: "");
        }
      }
    },
  );
}

  Widget detailItemPodcast() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['name'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textBig,
              // inter: false,
              fontsizeWeb: Dimens.textBig,
              maxline: 5,
              fontweight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          const SizedBox(height: 20),
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['description'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textMedium,
              // inter: false,
              maxline: 100,
              fontsizeWeb: Dimens.textMedium,
              fontweight: FontWeight.w400,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          const SizedBox(height: 20),
          MyText(
              fontsizeWeb: Dimens.textTitle,
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['podcasts_name'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textTitle,
              // inter: false,
              maxline: 2,
              fontweight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
        ],
      ),
    );
  }

  Widget detailItemRadioPlaylist() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['title'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textBig,
              fontsizeWeb: Dimens.textBig,
              // inter: false,
              maxline: 5,
              fontweight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          const SizedBox(height: 20),
          MyText(
              color: white,
              text:
                  (audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)
                      ?.extras?['description'],
              multilanguage: false,
              textalign: TextAlign.left,
              fontsizeNormal: Dimens.textMedium,
              fontsizeWeb: Dimens.textMedium,
              // inter: false,
              maxline: 100,
              fontweight: FontWeight.w400,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal),
          ((audioPlayer.sequenceState?.currentSource?.tag as MediaItem?)?.genre)
                      .toString() ==
                  "playlist"
              ? MyText(
                  color: white,
                  text: (audioPlayer.sequenceState?.currentSource?.tag
                          as MediaItem?)
                      ?.extras?['channel_name'],
                  multilanguage: false,
                  textalign: TextAlign.left,
                  fontsizeNormal: Dimens.textMedium,
                  fontsizeWeb: Dimens.textMedium,
                  // inter: false,
                  maxline: 100,
                  fontweight: FontWeight.w400,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

/* 10 Second Next And Previous Functionality */
// bool isnext = true > next Audio Seek
// bool isnext = false > previous Audio Seek
  tenSecNextOrPrevious(String audioposition, bool isnext) {
    dynamic firstHalf = Duration(seconds: int.parse(audioposition));
    const secondHalf = Duration(seconds: 10);
    Duration movePosition;
    if (isnext == true) {
      movePosition = firstHalf + secondHalf;
    } else {
      movePosition = firstHalf - secondHalf;
    }

    musicManager.seek(movePosition);
  }

  addView(contentType, episodeID, contentId) async {
    final musicDetailProvider =
        Provider.of<MusicDetailProvider>(context, listen: false);
    await musicDetailProvider.getAddContentPlay(3, episodeID, 1, contentId);
  }

/* Music And PodcastEpisode Like */
  like() async {}
}