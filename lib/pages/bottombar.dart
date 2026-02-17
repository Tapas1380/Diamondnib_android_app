import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:diamondnib/pages/audiobook.dart';
import 'package:diamondnib/pages/home.dart';
import 'package:diamondnib/pages/music.dart';
import 'package:diamondnib/pages/nointernet.dart';
import 'package:diamondnib/pages/novel.dart';
import 'package:diamondnib/pages/threads.dart';
import 'package:diamondnib/provider/connectivityprovider.dart';
import 'package:diamondnib/provider/generalprovider.dart';
import 'package:diamondnib/provider/profileprovider.dart';
import 'package:diamondnib/services/miniplayer_restoration_service.dart';
import 'package:diamondnib/utils/adhelper.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/musicmanager.dart';
import 'package:diamondnib/utils/sharedpre.dart';
import 'package:diamondnib/utils/strings.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;

import 'musicdetails.dart';

ValueNotifier<AudioPlayer?> currentlyPlaying = ValueNotifier(null);
const double playerMinHeight = kIsWeb ? 100 : 70;
late ConnectivityProvider connectivityProvider;
const miniplayerPercentageDeclaration = 0.7;

class Bottombar extends StatefulWidget {
  const Bottombar({super.key});

  @override
  State<Bottombar> createState() => BottombarState();
}

class BottombarState extends State<Bottombar> {
  SharedPre sharedPre = SharedPre();
  int selectedIndex = 0;
  DateTime? currentBackPressTime;

  static List<Widget> widgetOptions = <Widget>[
    const Home(pageName: ""),
    const AudioBooks(
      pageName: '',
    ),
    const Novel(
      pageName: '',
    ),
    const Threads(),
    const Music(),
  ];

  @override
  void initState() {
    print('🏠 [BOTTOMBAR] initState called');
    connectivityProvider =
        Provider.of<ConnectivityProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🏠 [BOTTOMBAR] postFrameCallback executing');
      _getData();
      _restoreMiniplayerIfNeeded();
      /* Check Internet Connection */
      connectivityProvider.connectivity.onConnectivityChanged.listen(
        (result) {
          if (result.isNotEmpty) {
            printLog('connectivityResult =======> ${result[0].name}');
            if (result[0] == ConnectivityResult.mobile ||
                result[0] == ConnectivityResult.wifi) {
            } else {
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const NoInternet()),
                (Route<dynamic> route) => route.isFirst,
              );
              return;
            }
          }
        },
      );
    });
  }

  /// Restore miniplayer from previous session
  Future<void> _restoreMiniplayerIfNeeded() async {
    print('🎵 [BOTTOMBAR] ===== _restoreMiniplayerIfNeeded METHOD CALLED =====');
    try {
      print('🎵 [BOTTOMBAR] Checking if miniplayer should be restored...');
      print('🎵 [BOTTOMBAR] currentlyPlaying.value BEFORE: ${currentlyPlaying.value}');
      
      // Debug the saved state first
      await MiniplayerRestorationService.debugSavedState();
      
      // Check if we should restore
      final shouldRestore = await MiniplayerRestorationService.wasMiniplayerPlaying();
      print('🎵 [BOTTOMBAR] Should restore: $shouldRestore');
      
      if (!shouldRestore) {
        print('🎵 [BOTTOMBAR] No miniplayer to restore');
        return;
      }
      
      // Get the saved audio data
      final audioData = await MiniplayerRestorationService.restoreMiniplayerState();
      
      if (audioData == null) {
        print('🎵 [BOTTOMBAR] No audio data found for restoration');
        return;
      }
      
      print('🎵 [BOTTOMBAR] Audio data found, attempting restoration...');
      print('🎵 [BOTTOMBAR] Title: ${audioData['title']}');
      print('🎵 [BOTTOMBAR] Audio URL: ${audioData['audioUrl']}');
      
      // Setup the audio player with the restored data
      final audioUrl = audioData['audioUrl'] as String?;
      final title = audioData['title'] as String? ?? 'Unknown';
      final thumbnailUrl = audioData['thumbnailUrl'] as String? ?? '';
      final audioId = audioData['id'] as String? ?? '';
      
      if (audioUrl == null || audioUrl.isEmpty) {
        print('❌ [BOTTOMBAR] Audio URL is empty, cannot restore');
        await MiniplayerRestorationService.cleanupAfterRestoration(success: false);
        return;
      }
      
      // Import and use the global audio player
      final player = audioPlayer;
      
      // Create the audio source
      final source = AudioSource.uri(
        Uri.parse(audioUrl),
        tag: MediaItem(
          id: audioId,
          title: title,
          artUri: thumbnailUrl.isNotEmpty ? Uri.tryParse(thumbnailUrl) : null,
          album: audioData['album'] as String? ?? '',
          artist: audioData['artistName'] as String? ?? '',
        ),
      );
      
      print('🎵 [BOTTOMBAR] Setting audio source...');
      
      try {
        await player.setAudioSource(source);
        currentlyPlaying.value = player;
        
        print('✅ [BOTTOMBAR] Audio player restored successfully');
        print('🎵 [BOTTOMBAR] currentlyPlaying.value AFTER: ${currentlyPlaying.value}');
        
        // Cleanup
        await MiniplayerRestorationService.cleanupAfterRestoration(success: true);
        
        // Update UI
        if (mounted) {
          setState(() {});
        }
        
      } catch (e) {
        print('❌ [BOTTOMBAR] Error setting audio source: $e');
        await MiniplayerRestorationService.cleanupAfterRestoration(success: false);
      }
      
    } catch (e, stackTrace) {
      print('❌ [BOTTOMBAR] Error in _restoreMiniplayerIfNeeded: $e');
      print('❌ [BOTTOMBAR] Stack trace: $stackTrace');
    }
  }

  _getData() async {
    final generalsetting = Provider.of<GeneralProvider>(context, listen: false);
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    if (connectivityProvider.isOnline) {
      if (Constant.userID != null) {
        await profileProvider.getProfile(context);
      } else {
        Utils.updatePremium("0");
        Utils.loadAds(context);
      }
      if (!mounted) return;
      await generalsetting.getGeneralsetting(context);
      if (!kIsWeb && !Platform.isIOS) {
        await getOnesignalNotification();
      } else {
        printLog("iOS: Skipping OneSignal init; using Firebase Messaging only");
      }
    }
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  getOnesignalNotification() async {
    String onesignalID = await sharedPre.read('onesignal_apid');
    if (!kIsWeb && !Platform.isIOS) {
      printLog("Has onesignalID ==> $onesignalID");
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      // Initialize OneSignal
      OneSignal.initialize(onesignalID);
      OneSignal.Notifications.requestPermission(true);
      OneSignal.Notifications.addPermissionObserver((state) {
        printLog("Has permission ==> $state");
      });
      OneSignal.User.pushSubscription.addObserver((state) {
        printLog(
            "pushSubscription state ==> ${state.current.jsonRepresentation()}");
      });
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        /// preventDefault to not display the notification
        event.preventDefault();
        // Do async work
        /// notification.display() to display after preventing default
        event.notification.display();
      });
    }
  }

  void _onItemTapped(int index) {
    // Update the UI immediately for better responsiveness
    if (selectedIndex != index) {
      setState(() {
        selectedIndex = index;
      });
    }
    
    // Show fullscreen ad after updating UI
    AdHelper.showFullscreenAd(context, Constant.interstialAdType, () {
      // This callback runs after the ad is shown
      if (mounted && selectedIndex != index) {
        setState(() {
          selectedIndex = index;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: onBackPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(children: [
          Center(
            child: widgetOptions[selectedIndex],
          ),
          selectedIndex == 3
              ? const SizedBox.shrink()
              : Align(
                  alignment: Alignment.bottomCenter,
                  child: Utils.buildMusicPanel(context)),
        ]),
        bottomNavigationBar: BottomAppBar(
          color: colorPrimary,
          padding: const EdgeInsets.all(5),
          elevation: 5,
          child: BottomNavigationBar(
            backgroundColor: colorPrimary,
            selectedLabelStyle: GoogleFonts.montserrat(
              fontSize: 10,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
              color: colorAccent,
            ),
            unselectedLabelStyle: GoogleFonts.montserrat(
              fontSize: 10,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
              color: colorAccent,
            ),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 5,
            currentIndex: selectedIndex,
            unselectedItemColor: gray,
            selectedItemColor: colorAccent,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                backgroundColor: black,
                label: bottomView1,
                activeIcon: _buildBottomNavIcon(
                    iconName: 'ic_home', iconColor: colorAccent),
                icon: _buildBottomNavIcon(iconName: 'ic_home', iconColor: gray),
              ),
              BottomNavigationBarItem(
                backgroundColor: black,
                label: bottomView2,
                activeIcon: _buildBottomNavIcon(
                    iconName: 'ic_audiobook', iconColor: colorAccent),
                icon: _buildBottomNavIcon(
                    iconName: 'ic_audiobook', iconColor: gray),
              ),
              BottomNavigationBarItem(
                backgroundColor: black,
                label: bottomView3,
                activeIcon: _buildBottomNavIcon(
                    iconName: 'ic_novel', iconColor: colorAccent),
                icon:
                    _buildBottomNavIcon(iconName: 'ic_novel', iconColor: gray),
              ),
              BottomNavigationBarItem(
                backgroundColor: black,
                label: bottomView4,
                activeIcon: _buildBottomNavIcon(
                    iconName: 'ic_thread', iconColor: colorAccent),
                icon:
                    _buildBottomNavIcon(iconName: 'ic_thread', iconColor: gray),
              ),
              BottomNavigationBarItem(
                backgroundColor: black,
                label: bottomView5,
                activeIcon: _buildBottomNavIcon(
                    iconName: 'ic_music', iconColor: colorAccent),
                icon:
                    _buildBottomNavIcon(iconName: 'ic_music', iconColor: gray),
              ),
            ],
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavIcon(
      {required String iconName, required Color? iconColor}) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: Image.asset(
          "assets/images/$iconName.png",
          width: 22,
          height: 22,
          color: iconColor,
        ),
      ),
    );
  }

  Future<void> onBackPressed(didPop) async {
    if (didPop) return;
    if (selectedIndex == 0) {
      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
        currentBackPressTime = now;
        Utils.showSnackbar(context, "", "exit_warning", true);
        return;
      }
      SystemNavigator.pop();
    } else {
      _onItemTapped(0);
    }
  }
}