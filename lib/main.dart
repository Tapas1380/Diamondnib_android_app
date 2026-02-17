import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:diamondnib/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/routes/routes_config.dart';
import 'package:diamondnib/model/download_item.dart';
import 'package:diamondnib/model/downloadaudiobook.dart';
import 'package:diamondnib/pages/musicdetails.dart';
import 'package:diamondnib/pages/splash.dart';
import 'package:diamondnib/provider/audiosectiondataprovider.dart';
import 'package:diamondnib/provider/avatarprovider.dart';
import 'package:diamondnib/provider/channelsectionprovider.dart';
import 'package:diamondnib/provider/connectivityprovider.dart';
import 'package:diamondnib/provider/downloadprovider.dart';
import 'package:diamondnib/provider/musicdetailprovider.dart';
import 'package:diamondnib/provider/musicprovider.dart';
import 'package:diamondnib/provider/notificationprovider.dart';
import 'package:diamondnib/provider/novelsectiondataprovider.dart';
import 'package:diamondnib/provider/rewardprovider.dart';
import 'package:diamondnib/provider/seallprovider.dart';
import 'package:diamondnib/provider/threadprovider.dart';
import 'package:diamondnib/provider/episodeprovider.dart';
import 'package:diamondnib/provider/findprovider.dart';
import 'package:diamondnib/provider/generalprovider.dart';
import 'package:diamondnib/provider/homeprovider.dart';
import 'package:diamondnib/provider/paymentprovider.dart';
import 'package:diamondnib/provider/playerprovider.dart';
import 'package:diamondnib/provider/profileprovider.dart';
import 'package:diamondnib/provider/searchprovider.dart';
import 'package:diamondnib/provider/sectiondataprovider.dart';
import 'package:diamondnib/provider/showdetailsprovider.dart';
import 'package:diamondnib/provider/subscriptionprovider.dart';
import 'package:diamondnib/provider/videobyidprovider.dart';
import 'package:diamondnib/provider/videodetailsprovider.dart';
import 'package:diamondnib/provider/watchlistprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/musicmanager.dart';
import 'package:diamondnib/utils/sharedpre.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_locales/flutter_locales.dart';

import 'package:diamondnib/services/fcm_service.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:diamondnib/utils/deeplinkhandler.dart';


const platform = MethodChannel('com.diamondnib.app/deeplink');
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize deep link handler for Android
  await DeepLinkHandler.init();
  
  await JustAudioBackground.init(
    androidNotificationChannelId: Constant.appPackageName,
    androidNotificationChannelName: Constant.appName,
    notificationColor: colorPrimaryDark,
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
  );
  
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
    /* Initialize Hive Start */
    final appDocumentDir = await getApplicationDocumentsDirectory();
    printLog("appDocumentDir Path ==> ${appDocumentDir.path}");
    Hive.init(appDocumentDir.path);
    Hive.registerAdapter(DownloadEpisodeItemAdapter());
    Hive.registerAdapter(AudioBookBoxAdapter());
    /* Initialize Hive End */
  }
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // ADD FCM INITIALIZATION
    await FCMService.initialize();
    
    // Subscribe to all_users topic for push notifications
    if (!kIsWeb) {
      await FCMService.subscribeToTopic('all_users');
    }
    
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      printLog('Firebase already initialized');
    } else {
      printLog('Firebase initialization error: $e');
    }
  }
  
  await Locales.init([
    'en',
    'af',
    'ar',
    'de',
    'es',
    'fr',
    'gu',
    'hi',
    'id',
    'nl',
    'pt',
    'sq',
    'tr',
    'vi'
  ]);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => AvatarProvider()),
        ChangeNotifierProvider(create: (_) => ChannelSectionProvider()),
        ChangeNotifierProvider(create: (_) => EpisodeProvider()),
        ChangeNotifierProvider(create: (_) => FindProvider()),
        ChangeNotifierProvider(create: (_) => GeneralProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => SectionDataProvider()),
        ChangeNotifierProvider(create: (_) => ShowDetailsProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => VideoByIDProvider()),
        ChangeNotifierProvider(create: (_) => VideoDetailsProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
        ChangeNotifierProvider(create: (_) => AudioSectionDataProvider()),
        ChangeNotifierProvider(create: (_) => NovelSectionDataProvider()),
        ChangeNotifierProvider(create: (_) => ThreadProvider()),
        ChangeNotifierProvider(create: (_) => SeeAllProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProvider(create: (_) => MusicDetailProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => RewardProvider()),
        ChangeNotifierProvider(create: (_) => DownLoadProvider()),
      ],
      child: const MyApp(),
    ),
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPre sharedPre = SharedPre();

  @override
  void initState() {
    // if (!kIsWeb) Utils.enableScreenCapture();
    if (!kIsWeb) _getDeviceInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _getData();
      _checkInitialDeepLink();
      _setupDeepLinkListener();
    });
    musicManager = MusicManager(context);
    
    // ADD FCM HANDLERS AND TOPIC SUBSCRIPTION
    _setupFCMHandlers();
    _subscribeToBroadcastTopics();
    
    super.initState();
  }

  // Setup method channel listener for deep links
  void _setupDeepLinkListener() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink') {
        final deepLink = call.arguments as String?;
        _handleIncomingDeepLink(deepLink);
      }
    });
  }

  // Handle incoming deep link  
  void _handleIncomingDeepLink(String? deepLink) {
    if (deepLink == null || deepLink.isEmpty) return;
    printLog("_MyAppState: Received deep link: $deepLink");
    try {
      final uri = Uri.parse(deepLink);
      
      int? contentId;
      int contentType = 1;
      
      // Handle custom scheme: diamondnib://audiobook/123?type=1
      if (uri.scheme == 'diamondnib' && uri.host == 'audiobook') {
        if (uri.pathSegments.isNotEmpty) {
          contentId = int.tryParse(uri.pathSegments[0]);
        } else if (uri.path.isNotEmpty && uri.path != '/') {
          // Handle case where path is like /123
          contentId = int.tryParse(uri.path.replaceAll('/', ''));
        }
        contentType = int.tryParse(uri.queryParameters['type'] ?? '1') ?? 1;
      }
      // Handle web URL: https://diamondnib.com/audiobook/123?type=1
      else if (uri.scheme == 'https' && uri.host.contains('diamondnib.com')) {
        final segments = uri.pathSegments;
        if (segments.length >= 2 && segments[0] == 'audiobook') {
          contentId = int.tryParse(segments[1]);
        }
        contentType = int.tryParse(uri.queryParameters['type'] ?? '1') ?? 1;
      }
      
      if (contentId != null && contentId > 0) {
        printLog('Deep link parsed: contentId=$contentId, type=$contentType');
        
        // Store in Constant for later use
        Constant.deepLinkContentId = contentId;
        Constant.deepLinkContentType = contentType;
        Constant.shouldOpenAudioDetails = true;
        
        printLog('Stored deep link data in Constant');
        
        // Try to navigate immediately if navigator is ready
        if (navigatorKey.currentState != null) {
          printLog('Navigator ready, navigating now via DeepLinkHandler');
          DeepLinkHandler.checkPendingDeepLink(navigatorKey.currentContext!);
        }
      }
    } catch (e) {
      printLog('Error handling deep link: $e');
    }
  }

  // ADD THIS: Method to check for initial deep link
  Future<void> _checkInitialDeepLink() async {
  try {
    final PendingDynamicLinkData? initialData =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? initialUri = initialData?.link;
    if (initialUri != null) {
      _handleIncomingDeepLink(initialUri.toString());
    }
    
    // Listen for dynamic links when app is in foreground
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      final Uri uri = dynamicLinkData.link;
      printLog('Dynamic link received: $uri');
      _handleIncomingDeepLink(uri.toString());
    }).onError((error) {
      printLog('DynamicLinks: onLink error => ' + error.toString());
    });
  } catch (e) {
    printLog("Main: Error checking initial deep link: $e");
  }
}
  

  // ADD FCM HANDLER SETUP METHOD
  void _setupFCMHandlers() {
    // Handle notification clicks
    FCMService.onNotificationOpened = (Map<String, dynamic> data) {
      _handleNotificationNavigation(data);
    };

    // Handle foreground notifications
    FCMService.onNotificationReceived = (RemoteMessage message) {
      printLog('FCM: Foreground notification received: ${message.notification?.title}');
      printLog('FCM: Notification data: ${message.data}');
    };
  }

  // ADD TOPIC SUBSCRIPTION METHOD
  Future<void> _subscribeToBroadcastTopics() async {
    if (!kIsWeb) {
      try {
        // Subscribe to general broadcast topic (all users)
        await FCMService.subscribeAllUsersToGeneralTopic();
        
        // Subscribe to audio-specific topics
        await FCMService.subscribeToAudioTopics();
        
        printLog('FCM: Successfully subscribed to broadcast topics');
      } catch (e) {
        printLog('FCM: Error subscribing to broadcast topics: $e');
      }
    }
  }

  // ADD NOTIFICATION NAVIGATION HANDLER
  void _handleNotificationNavigation(Map<String, dynamic> data) {
    printLog('FCM: Handling notification navigation with data: $data');
    
    // Handle audio notifications
    if (data['type'] == 'audio') {
      final audioId = data['id'];
      
      printLog('FCM: Navigating to audio player with ID: $audioId');
      
      // Navigate to your audio player screen
      // Example:
      // navigatorKey.currentState?.pushNamed(
      //   '/audio_player', 
      //   arguments: {'audioId': audioId, 'title': audioTitle}
      // );
    }
    
    // Handle announcement notifications
    else if (data['type'] == 'announcement') {
      printLog('FCM: Handling announcement notification');
      // navigatorKey.currentState?.pushNamed('/announcements');
    }
  }

  _getData() async {
    Constant.userID = await sharedPre.read('userid');
    printLog('Constant userID =====> ${Constant.userID}');

    // ADD FCM TOKEN RETRIEVAL
    String? fcmToken = await FCMService.getCurrentToken();
    if (fcmToken != null) {
      printLog('FCM Token: $fcmToken');
      printLog('FCM: User is subscribed to broadcast topics');
    }

    /* Initialize Hive */
    if (!kIsWeb) {
      await Utils.initializeHiveBoxes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
      },
      child: LocaleBuilder(
        builder: (locale) {
          if (kIsWeb) {
            return _buildForWeb(locale: locale);
          } else {
            return _buildForOther(locale: locale);
          }
        },
      ),
    );
  }

  Widget _buildForOther({required Locale? locale}) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        primaryColor: Colors.yellow,
        primaryColorDark: Colors.black,
        primaryColorLight: Colors.yellow[100],
        scaffoldBackgroundColor: Colors.white,
      ).copyWith(
        scrollbarTheme: const ScrollbarThemeData().copyWith(
          thumbColor: MaterialStateProperty.all(Colors.white),
          trackVisibility: MaterialStateProperty.all(true),
          trackColor: MaterialStateProperty.all(Colors.transparent),
        ),
      ),
      title: Constant.appName,
      localizationsDelegates: Locales.delegates,
      supportedLocales: Locales.supportedLocales,
      locale: locale,
      localeResolutionCallback:
          (Locale? locale, Iterable<Locale> supportedLocales) {
        return locale;
      },
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 360, name: MOBILE),
            const Breakpoint(start: 361, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1000, name: DESKTOP),
            const Breakpoint(start: 1001, end: double.infinity, name: '4K'),
          ],
        );
      },
      home: const Splash(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
          PointerDeviceKind.trackpad
        },
      ),
    );
  }

  Widget _buildForWeb({required Locale? locale}) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: RoutesConfig().goRouter,
      theme: ThemeData(
        primaryColor: Colors.yellow,
        primaryColorDark: Colors.black,
        primaryColorLight: Colors.yellow[100],
        scaffoldBackgroundColor: Colors.white,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: kIsWeb
              ? {
                  for (final platform in TargetPlatform.values)
                    platform: const NoTransitionsBuilder(),
                }
              : const {
                  TargetPlatform.android: ZoomPageTransitionsBuilder(),
                  TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
                },
        ),
      ).copyWith(
        scrollbarTheme: const ScrollbarThemeData().copyWith(
          thumbColor: MaterialStateProperty.all(Colors.white),
          trackVisibility: MaterialStateProperty.all(true),
          trackColor: MaterialStateProperty.all(Colors.white.withOpacity(0.5)),
        ),
      ),
      title: Constant.appName,
      localizationsDelegates: Locales.delegates,
      supportedLocales: Locales.supportedLocales,
      locale: locale,
      localeResolutionCallback:
          (Locale? locale, Iterable<Locale> supportedLocales) {
        return locale;
      },
      builder: (context, child) {
        return ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 360, name: MOBILE),
            const Breakpoint(start: 361, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1000, name: DESKTOP),
            const Breakpoint(start: 1001, end: double.infinity, name: '4K'),
          ],
        );
      },
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
          PointerDeviceKind.trackpad
        },
      ),
    );
  }

  _getDeviceInfo() async {
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      Constant.isTV =
          androidInfo.systemFeatures.contains('android.software.leanback');
      if (kDebugMode) {
        print("isTV =======================> ${Constant.isTV}");
      }
    }
  }
}

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    return child!;
  }
}