import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:diamondnib/pages/authorprofile.dart';
import 'package:diamondnib/pages/find.dart';
import 'package:diamondnib/pages/musicdetails.dart';
import 'package:diamondnib/pages/mywallet.dart';

import 'package:diamondnib/pages/notification.dart';
import 'package:diamondnib/pages/profile.dart';
import 'package:diamondnib/pages/setting.dart';
import 'package:diamondnib/pages/videosbyid.dart';
import 'package:diamondnib/pages/viewall.dart';
import 'package:diamondnib/provider/profileprovider.dart';
import 'package:diamondnib/provider/generalprovider.dart';
import 'package:diamondnib/provider/showdetailsprovider.dart';
import 'package:diamondnib/pages/subscription_page.dart';
import 'package:diamondnib/shimmer/shimmerutils.dart';
import 'package:diamondnib/utils/adhelper.dart';
import 'package:diamondnib/utils/sharedpre.dart';

import 'package:diamondnib/utils/strings.dart';
import 'package:diamondnib/webwidget/footerweb.dart';
import 'package:diamondnib/model/genresmodel.dart' as type;
import 'package:diamondnib/model/sectionlistmodel.dart' show Datum;
import 'package:diamondnib/model/sectionlistmodel.dart' as list;
import 'package:diamondnib/model/sectionbannermodel.dart' as banner;
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/dimens.dart';

import 'package:diamondnib/widget/myusernetworkimg.dart';
import 'package:diamondnib/widget/nodata.dart';
import 'package:diamondnib/provider/homeprovider.dart';
import 'package:diamondnib/provider/sectiondataprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/widget/myimage.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/mynetworkimg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:go_router/go_router.dart';
import 'package:diamondnib/routes/routes_constant.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class Home extends StatefulWidget {
  final String? pageName;
  const Home({super.key, required this.pageName});

  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> with WidgetsBindingObserver {

  late ProfileProvider profileProvider;
  late SectionDataProvider sectionDataProvider;
  final FirebaseAuth auth = FirebaseAuth.instance;
  SharedPre sharedPref = SharedPre();
  bool _showSubscriptionIcon = true;
  CarouselController carouselController = CarouselController();

  int _subscriptionVisibilityRetryCount = 0;

  final tabScrollController = ScrollController();
  late ScrollController _scrollController;
  late ListObserverController observerController;
  late HomeProvider homeProvider;
  int? videoId, videoType, typeId;
  String? currentPage,
      langCatName,
      aboutUsUrl,
      privacyUrl,
      termsConditionUrl,
      refundPolicyUrl,
      mSearchText;
  static bool _popupShownInApp = false; // static => once per app run
  bool _isPopupShown = false;

bool _hasResumedFromBackground = false;      // becomes true when app resumes from background
bool _hasShownPopupOnColdStart = false;  
  // Helper to format Duration as mm:ss
  String _formatDuration(Duration d) {
    final int minutes = d.inMinutes;
    final int seconds = d.inSeconds.remainder(60);
    final String s = seconds.toString().padLeft(2, '0');
    return '$minutes:$s';
  }

  _onItemTapped(String page) async {
    printLog("_onItemTapped -----------------> $page");
    if (page != "") {
      await setSelectedTab(-1);
    }
    setState(() {
      currentPage = page;
    });
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }
  @override
  void initState() {
    super.initState();

    // Register lifecycle observer so we can show popup on resume
    WidgetsBinding.instance.addObserver(this);

    sectionDataProvider =
        Provider.of<SectionDataProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    observerController =
        ListObserverController(controller: tabScrollController);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener); 

    currentPage = widget.pageName ?? "";
    profileProvider.getProfile(context);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      homeProvider.setLoading(true);
      sectionDataProvider.setLoading(true);

      final generalProvider =
          Provider.of<GeneralProvider>(context, listen: false);
      await generalProvider.getGeneralsetting(context);

      _subscriptionVisibilityRetryCount = 0;
      _loadSubscriptionVisibility(retryIfMissing: true);
      _getData(1);
    });

    if (!kIsWeb) {
      OneSignal.Notifications.addClickListener(_handleNotificationOpened);
    }
  }

  Future<void> _loadSubscriptionVisibility({bool retryIfMissing = false}) async {
    final keysToCheck = <String>[
      'subscription',
      'subscription_enable',
      'subscription_enabled',
      'subscription_status',
      'premium',
      'premium_enable',
      'premium_enabled',
      'premium_status',
    ];

    String? raw;
    for (final k in keysToCheck) {
      raw = await sharedPref.read(k);
      if (raw != null && raw.toString().isNotEmpty) {
        break;
      }
    }

    if (retryIfMissing && (raw == null || raw.toString().isEmpty)) {
      if (_subscriptionVisibilityRetryCount < 5) {
        _subscriptionVisibilityRetryCount++;
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          _loadSubscriptionVisibility(retryIfMissing: true);
        });
      }
    }

    bool nextValue = true;
    if (raw != null) {
      final v = raw.toString().trim().toLowerCase();
      if (v == '0' || v == 'false' || v == 'no' || v == 'off') {
        nextValue = false;
      } else if (v == '1' || v == 'true' || v == 'yes' || v == 'on') {
        nextValue = true;
      }
    }

    if (!mounted) return;
    setState(() {
      _showSubscriptionIcon = nextValue;
    });
  }

  // What to do when the user opens/taps on a notification
  _handleNotificationOpened(OSNotificationClickEvent result) {
    /* id, video_type, type_id */

    printLog(
        "setNotificationOpenedHandler additionalData ===> ${result.notification.additionalData.toString()}");
    printLog(
        "setNotificationOpenedHandler video_id ===> ${result.notification.additionalData?['id']}");
    printLog(
        "setNotificationOpenedHandler upcoming_type ===> ${result.notification.additionalData?['upcoming_type']}");
    printLog(
        "setNotificationOpenedHandler video_type ===> ${result.notification.additionalData?['video_type']}");
    printLog(
        "setNotificationOpenedHandler type_id ===> ${result.notification.additionalData?['type_id']}");

    if (result.notification.additionalData?['id'] != null &&
        result.notification.additionalData?['upcoming_type'] != null &&
        result.notification.additionalData?['video_type'] != null &&
        result.notification.additionalData?['type_id'] != null) {
      String? videoID =
          result.notification.additionalData?['id'].toString() ?? "";
      String? upcomingType =
          result.notification.additionalData?['upcoming_type'].toString() ?? "";
      String? videoType =
          result.notification.additionalData?['video_type'].toString() ?? "";
      String? typeID =
          result.notification.additionalData?['type_id'].toString() ?? "";
      printLog("videoID =======> $videoID");
      printLog("upcomingType ==> $upcomingType");
      printLog("videoType =====> $videoType");
      printLog("typeID ========> $typeID");

      Utils.openDetails(
        context: context,
        videoId: int.parse(videoID),
        videoType: int.parse(videoType),
      );
    }
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (sectionDataProvider.currentPage ?? 0) <
            (sectionDataProvider.totalPage ?? 0)) {
      sectionDataProvider.setLoadMore(true);

      _fetchData(
          sectionDataProvider.currentPage ?? 0, homeProvider.selectedIndex);
    }
  }

  _fetchData(pageno, position) {
    printLog("POsition IS ==$position");
    getTabData(position, homeProvider.genresModel.result, pageno + 1);
  }

  _getData(pageno) async {
    await homeProvider.getGenres();

    if (!homeProvider.loading) {
      if (homeProvider.genresModel.status == 200 &&
          homeProvider.genresModel.result != null) {
        if ((homeProvider.genresModel.result?.length ?? 0) > 0) {
          await _fetchData(0, 0);
        }
      }
    }
    if (!kIsWeb) {
      await Utils.initializeHiveBoxes();
    }
    await Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
    Utils.getCurrencySymbol();

    // ---------- Show purchase popup ONCE per app run after Home finishes loading ----------
      if (!HomeState._popupShownInApp &&
        !_hasShownPopupOnColdStart &&
        !_hasResumedFromBackground &&
        mounted) {
      // mark so it won't show again this app run / cold start
      HomeState._popupShownInApp = true;
      _hasShownPopupOnColdStart = true;

      // small delay to ensure layout finished and dialog won't be dismissed by subsequent builds
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _showPurchasePopup();
      });
    }
    // -------------------------------------------------------------------------------------


  }

  Future<void> setSelectedTab(int tabPos) async {
    printLog("setSelectedTab tabPos ====> $tabPos");
    if (!mounted) return;
    await homeProvider.setSelectedTab(tabPos);
    printLog(
        "setSelectedTab selectedIndex ====> ${homeProvider.selectedIndex}");
    printLog(
        "setSelectedTab lastTabPosition ====> ${sectionDataProvider.lastTabPosition}");
    if (sectionDataProvider.lastTabPosition == tabPos) {
      return;
    } else {
      sectionDataProvider.setTabPosition(tabPos);
    }
  }

  Future<void> getTabData(
      int position, List<type.Result>? sectionTypeList, pageno) async {
    printLog("getTabData position ====> $position");
    await setSelectedTab(position);

    sectionDataProvider.getSectionBanner(
        position == 0 ? "0" : (sectionTypeList?[position - 1].id),
        position == 0 ? "1" : "2");
    sectionDataProvider.getSectionList(
        position == 0 ? "0" : (sectionTypeList?[position - 1].id),
        position == 0 ? "1" : "2",
        pageno);
    printLog("POsition IS ==$position");
  }

  openDetailPage(
    String pageName,
    int videoId,
    int videoType,
  ) async {
    printLog("pageName =======> $pageName");
    printLog("videoId ========> $videoId");

    printLog("videoType ======> $videoType");
    if (pageName != "" && (kIsWeb || Constant.isTV)) {
      await setSelectedTab(-1);
    }
    if (!mounted) return;
    Utils.openDetails(
      context: context,
      videoId: videoId,
      videoType: videoType,
    );
  }

   @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // unregister observer
    _scrollController.dispose();
    sectionDataProvider.clearProvider();
    homeProvider.selectedIndex = 0;
    super.dispose();
  }

   @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // mark that the app was resumed from background so we don't show popup again
      _hasResumedFromBackground = true;
      _subscriptionVisibilityRetryCount = 0;
      _loadSubscriptionVisibility(retryIfMissing: true);
    }
  }

  // Popup method: shows dialog and navigates to wallet on Buy
 // Full-screen popup with video background and wallet navigation (null-safe)
Future<void> _showPurchasePopup() async {
  if (_isPopupShown) return;
  _isPopupShown = true;

  final String? videoUrl = await sharedPref.read('home_popup_video');
  if (videoUrl == null || videoUrl.isEmpty) {
    _isPopupShown = false;
    return;
  }

  VideoPlayerController? controller;

  try {
    final cacheManager = DefaultCacheManager();
    final file = await cacheManager.getSingleFile(videoUrl);
    controller = VideoPlayerController.file(file);
    await controller.initialize();
    controller.setLooping(true);
    controller.setVolume(1.0);
    await controller.play();
  } catch (e) {
    printLog('Video load/init failed: $e');
  }

  // If controller is null or not initialized, bail out safely
  if (controller == null || !controller.value.isInitialized) {
    _isPopupShown = false;
    // Make sure any partially created controller is cleaned up
    try {
      await controller?.pause();
      controller?.dispose();
    } catch (_) {}
    return;
  }

  // non-null controller for dialog usage
  final ctrl = controller;

  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Coin Offer",
    barrierColor: Colors.black.withOpacity(0.85),
    transitionDuration: const Duration(milliseconds: 300),
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
          child: child);
    },
    pageBuilder: (context, anim1, anim2) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Background Video (cover)
              Positioned.fill(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SizedBox(
                    width: ctrl.value.size.width,
                    height: ctrl.value.size.height,
                    child: VideoPlayer(ctrl),
                  ),
                ),
              ),

              // Overlay content
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Close Button
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: GestureDetector(
                            onTap: () async {
                              try {
                                await ctrl.pause();
                                ctrl.dispose();
                              } catch (_) {}
                              _isPopupShown = false;
                              Navigator.of(context).pop();
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ),

                      // Center text + buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Unlock Premium Audio Experience 🎧',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Earn coins to access exclusive Diamondnib features and premium content.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 25),

                            // Buttons row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await ctrl.pause();
                                      ctrl.dispose();
                                    } catch (_) {}
                                    _isPopupShown = false;
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Later',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorAccent,
                                    foregroundColor: colorPrimaryDark,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 28, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                  ),
                                  onPressed: () async {
                                    try {
                                      await ctrl.pause();
                                      ctrl.dispose();
                                    } catch (e) {
                                      printLog('Error disposing controller: $e');
                                    }
                                    _isPopupShown = false;
                                    Navigator.of(context).pop();

                                    // Navigate to wallet
                                    try {
                                      GoRouter.of(context)
                                          .pushNamed(RoutesConstant.mywallet);
                                      return;
                                    } catch (_) {}
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const MyWallet()),
                                    );
                                  },
                                  child: const Text(
                                    'Earn Coins',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ).then((_) async {
    // Final cleanup — controller may be null (safety)
    try {
      await controller?.pause();
      controller?.dispose();
    } catch (_) {}
    _isPopupShown = false;
  });
}

  _scrollToCurrent() {
    printLog("selectedIndex ======> ${homeProvider.selectedIndex.toDouble()}");
    observerController.animateTo(
      index: homeProvider.selectedIndex,
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      body: SafeArea(
        child: (kIsWeb || Constant.isTV)
            ? _webAppBarWithDetails()
            : _mobileAppBarWithDetails(),
      ),
    );
  }

  Widget _mobileAppBarWithDetails() {
    return NestedScrollView(
      physics: const NeverScrollableScrollPhysics(),
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverAppBar(
              leading: Consumer<ProfileProvider>(
                builder: (context, value, child) {
                  return InkWell(
                    onTap: () {
                      if (Constant.userID == null) {
                        Utils.openLogin(
                            context: context, isHome: true, isReplace: false);
                      } else {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyProfile(
                                      type: 'myProfile',
                                    )));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 12, 8, 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        clipBehavior: Clip.antiAlias,
                        child: MyUserNetworkImage(
                          imageUrl: profileProvider.profileModel.status == 200
                              ? profileProvider.profileModel.result != null
                                  ? (profileProvider
                                          .profileModel.result?[0].image ??
                                      "")
                                  : ""
                              : "",
                          fit: BoxFit.cover,
                          imgHeight: 46,
                          imgWidth: 46,
                        ),
                      ),
                    ),
                  );
                },
              ),
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Find()))
                        .then((value) => _getData(1));
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    width: 20,
                    child: MyImage(
                      color: white,
                      imagePath: "ic_find.png",
                      height: 46,
                      width: 46,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Notifications()))
                        .then((value) => _getData(1));
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    width: 20,
                    child: const Icon(
                      Icons.notifications_active,
                      size: 28,
                      color: white,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Setting()))
                        .then((value) => _getData(1));
                  },
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    width: 20,
                    child: MyImage(
                      color: white,
                      imagePath: "ic_setting.png",
                      height: 46,
                      width: 46,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyWallet()))
                        .then((value) => _getData(1));
                  },
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                    width: 20,
                    child: const Icon(
                      Icons.wallet,
                      size: 28,
                      color: white,
                    ),
                  ),
                ),
                if (_showSubscriptionIcon)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SubscriptionPage(),
                        ),
                      ).then((value) => _getData(1));
                    },
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(5, 5, 10, 5),
                      width: 20,
                      child: const Icon(
                        Icons.diamond_outlined,
                        size: 28,
                        color: white,
                      ),
                    ),
                  ),
              ],
              automaticallyImplyLeading: false,
              backgroundColor: colorPrimary,
              toolbarHeight: 65,
              title: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                alignment: Alignment.center,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  splashColor: transparentColor,
                  highlightColor: transparentColor,
                  onTap: () async {
                    // await getTabData(0, homeProvider.genresModel.result, 1);
                    await _fetchData(0, 0);
                  },
                  child: MyText(
                    multilanguage: true,
                    color: white,
                    text: "home",
                    fontsizeNormal: 17,
                    fontweight: FontWeight.w700,
                  ),
                ),
              ), // This is the title in the app bar.
              pinned: false,
              expandedHeight: 0,
              forceElevated: innerBoxIsScrolled,
            ),
          ),
        ];
      },
      body: homeProvider.loading
          ? ShimmerUtils.buildHomeMobileShimmer(context)
          : (homeProvider.genresModel.status == 200)
              ? (homeProvider.genresModel.result != null ||
                      (homeProvider.genresModel.result?.length ?? 0) > 0)
                  ? Stack(
                      children: [
                        tabItem(homeProvider.genresModel.result),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.homeTabHeight,
                          padding: const EdgeInsets.only(top: 8, bottom: 0),
                          color: colorPrimary,
                          child: tabTitle(homeProvider.genresModel.result),
                        ),
                      ],
                    )
                  : const NoData(title: 'nodata', subTitle: '')
              : const NoData(title: 'nodata', subTitle: ''),
    );
  }

  Widget _webAppBarWithDetails() {
    if (homeProvider.loading) {
      return ShimmerUtils.buildHomeMobileShimmer(context);
    } else {
      if (homeProvider.genresModel.status == 200) {
        if (homeProvider.genresModel.result != null ||
            (homeProvider.genresModel.result?.length ?? 0) > 0) {
          return Stack(
            children: [
              // _clickToRedirect(pageName: currentPage ?? ""),
              tabItem(homeProvider.genresModel.result),
              // const CommonAppBar(),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget tabTitle(List<type.Result>? sectionTypeList) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tabScrollController.hasClients) {
        _scrollToCurrent();
      }
    });
    return ListViewObserver(
      controller: observerController,
      child: ListView.separated(
        itemCount: (sectionTypeList?.length ?? 0) + 1,
        shrinkWrap: true,
        controller: tabScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(13, 5, 13, 0),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              return InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () async {
                  printLog("index ===========> $index");
                  AdHelper.showFullscreenAd(context, Constant.interstialAdType,
                      () async {
                    if (kIsWeb) _onItemTapped("");
                    sectionDataProvider.sectionListData = [];
                    sectionDataProvider.sectionListModel = list.SectionListModel();

                    // await getTabData(index, homeProvider.genresModel.result, 1);
                    await _fetchData(
                      0,
                      index,
                    );
                  });
                },
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 35),
                  decoration: BoxDecoration(
                      color: homeProvider.selectedIndex == index
                          ? white.withOpacity(0.08)
                          : transparentColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border(
                          bottom: BorderSide(
                              width: 2,
                              color: homeProvider.selectedIndex == index
                                  ? colorAccent
                                  : transparentColor))),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                  child: MyText(
                    color: homeProvider.selectedIndex == index
                        ? colorAccent
                        : white,
                    multilanguage: false,
                    text: index == 0
                        ? "Home"
                        : index > 0
                            ? (sectionTypeList?[index - 1].name.toString() ??
                                "")
                            : "",
                    fontsizeNormal: 13,
                    fontweight: homeProvider.selectedIndex == index
                        ? FontWeight.w700
                        : FontWeight.w600,
                    fontsizeWeb: 15,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget tabItem(List<type.Result>? sectionTypeList) {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: RefreshIndicator(
        backgroundColor: white,
        color: colorAccent,
        displacement: 80,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 1500))
              .then((value) async {
            await _fetchData(
              0,
              homeProvider.selectedIndex > 0 ? (homeProvider.selectedIndex) : 0,
            );
            setState(() {});
          });
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: Dimens.homeTabHeight),

              /* Banner */
              Consumer<SectionDataProvider>(
                builder: (context, sectionDataProvider, child) {
                  if (sectionDataProvider.loadingBanner) {
                    if ((kIsWeb || Constant.isTV) &&
                        MediaQuery.of(context).size.width > 720) {
                      return ShimmerUtils.bannerWeb(context);
                    } else {
                      return ShimmerUtils.bannerMobile(context);
                    }
                  } else {
                    if (sectionDataProvider.sectionBannerModel.status == 200 &&
                        sectionDataProvider.sectionBannerModel.result != null) {
                      if ((kIsWeb || Constant.isTV) &&
                          MediaQuery.of(context).size.width > 720) {
                        return _webHomeBanner(
                            sectionDataProvider.sectionBannerModel.result);
                      } else {
                        printLog("Banner Shimmer Calling ");
                        return _mobileHomeBanner(
                            sectionDataProvider.sectionBannerModel.result);
                      }
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                },
              ),

              /* AdMob Banner */

              Utils.showBannerAd(context),

              /* Continue Watching & Remaining Sections */
              Consumer<SectionDataProvider>(
                builder: (context, sectionDataProvider, child) {
                  if (sectionDataProvider.loadingSection &&
                      sectionDataProvider.loadmore == false) {
                    return sectionShimmer();
                  } else {
                    if (sectionDataProvider.sectionListModel.status == 200) {
                      return ((sectionDataProvider.sectionListData?.length ??
                                  0) >
                              0)
                          ? setSectionByType(
                              sectionDataProvider.sectionListData)
                          : const SizedBox.shrink();
                    } else {
                      return const NoData(title: 'nodata', subTitle: '');
                    }
                  }
                },
              ),
              const SizedBox(height: 20),

              /* Web Footer */
              kIsWeb ? const FooterWeb() : const SizedBox.shrink(),
              Consumer<SectionDataProvider>(
                builder: (context, sectionDataProvider, child) {
                  if (sectionDataProvider.loadmore) {
                    return Container(
                      height: 50,
                      margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                      child: Utils.pageLoader(),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  /* Section Shimmer */
  Widget sectionShimmer() {
    return Column(
      children: [
        ListView.builder(
          itemCount: 10, // itemCount must be greater than 5
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            if (index == 2) {
              return ShimmerUtils.setHomeSections(context, "potrait");
            } else if (index == 3) {
              return ShimmerUtils.setHomeSections(context, "square");
            } else if (index == 4) {
              return ShimmerUtils.setHomeSections(context, "langGen");
            } else if (index == 5) {
              return ShimmerUtils.setHomeSections(context, "grid_landscape");
            } else if (index == 6) {
              return ShimmerUtils.setHomeSections(context, "verticalGrid");
            } else if (index == 7) {
              return ShimmerUtils.setHomeSections(context, "grid_view");
            } else if (index == 8) {
              return ShimmerUtils.setHomeSections(context, "big_square");
            } else if (index == 9) {
              return ShimmerUtils.setHomeSections(context, "small_square");
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }

  Widget _mobileHomeBanner(List<banner.Result>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return Stack(
        alignment: AlignmentDirectional.bottomCenter,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: Dimens.homeBanner,
            child: CarouselSlider.builder(
              itemCount: (sectionBannerList?.length ?? 0),
              carouselController: carouselController,
              options: CarouselOptions(
                initialPage: 0,
                height: Dimens.homeBanner,
                enlargeCenterPage: false,
                autoPlay: true,
                autoPlayCurve: Curves.linear,
                enableInfiniteScroll: true,
                autoPlayInterval:
                    Duration(milliseconds: Constant.bannerDuration),
                autoPlayAnimationDuration:
                    Duration(milliseconds: Constant.animationDuration),
                viewportFraction: 1.0,
                onPageChanged: (val, _) async {
                  await sectionDataProvider.setCurrentBanner(val);
                },
              ),
              itemBuilder:
                  (BuildContext context, int index, int pageViewIndex) {
                return InkWell(
                  focusColor: white,
                  borderRadius: BorderRadius.circular(0),
                  onTap: () {
                    printLog("Clicked on index ==> $index");

                    openDetailPage(
                      "showdetail",
                      sectionBannerList?[index].id ?? 0,
                      sectionBannerList?[index].contentType ?? 0,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.homeBanner,
                          child: MyNetworkImage(
                            imageUrl:
                                sectionBannerList?[index].landscapeImg ?? "",
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.homeBanner,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.center,
                              end: Alignment.bottomCenter,
                              colors: [
                                transparentColor,
                                transparentColor,
                                colorPrimary,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 40,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  openDetailPage(
                                    "showdetail",
                                    sectionBannerList?[index].id ?? 0,
                                    sectionBannerList?[index].contentType ?? 0,
                                  );
                                },
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 0,
                                    maxHeight: 45,
                                    minWidth: 0,
                                    maxWidth: 145,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: colorAccent,
                                    borderRadius: BorderRadius.circular(12),
                                    shape: BoxShape.rectangle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.play_arrow_rounded,
                                        color: white,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: MyText(
                                          color: white,
                                          maxline: 1,
                                          overflow: TextOverflow.ellipsis,
                                          multilanguage: true,
                                          text: "playnow",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: 14,
                                          fontsizeWeb: 18,
                                          fontweight: FontWeight.w700,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              InkWell(
                                onTap: () {
                                  openDetailPage(
                                    "showdetail",
                                    sectionBannerList?[index].id ?? 0,
                                    sectionBannerList?[index].contentType ?? 0,
                                  );
                                },
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 0,
                                    maxHeight: 45,
                                    minWidth: 0,
                                    maxWidth: 130,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: transparentColor,
                                    borderRadius: BorderRadius.circular(12),
                                    shape: BoxShape.rectangle,
                                    border: Border.all(
                                        color: white.withOpacity(0.6),
                                        width: 1),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Icon(
                                        Icons.info_outline,
                                        size: 20,
                                        color: white,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Expanded(
                                        child: MyText(
                                          color: white,
                                          maxline: 1,
                                          overflow: TextOverflow.ellipsis,
                                          multilanguage: true,
                                          text: "moreinfo",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: 14,
                                          fontsizeWeb: 18,
                                          fontweight: FontWeight.w600,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 20,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Consumer<SectionDataProvider>(
                  builder: (context, sectionDataProvider, child) {
                    return AnimatedSmoothIndicator(
                      count: (sectionBannerList?.length ?? 0),
                      activeIndex: sectionDataProvider.cBannerIndex ?? 0,
                      effect: const ScrollingDotsEffect(
                        spacing: 8,
                        radius: 4,
                        activeDotColor: colorAccent,
                        dotColor: white,
                        dotHeight: 8,
                        dotWidth: 8,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _webHomeBanner(List<banner.Result>? sectionBannerList) {
    if ((sectionBannerList?.length ?? 0) > 0) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: Dimens.homeWebBanner,
        child: CarouselSlider.builder(
          itemCount: (sectionBannerList?.length ?? 0),
          carouselController: carouselController,
          options: CarouselOptions(
            initialPage: 0,
            height: Dimens.homeWebBanner,
            enlargeCenterPage: false,
            autoPlay: true,
            autoPlayCurve: Curves.easeInOutQuart,
            enableInfiniteScroll: true,
            autoPlayInterval: Duration(milliseconds: Constant.bannerDuration),
            autoPlayAnimationDuration:
                Duration(milliseconds: Constant.animationDuration),
            viewportFraction: 0.95,
            onPageChanged: (val, _) async {
              await sectionDataProvider.setCurrentBanner(val);
            },
          ),
          itemBuilder: (BuildContext context, int index, int pageViewIndex) {
            return InkWell(
              focusColor: white,
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                printLog("Clicked on index ==> $index");
                openDetailPage(
                  // (sectionBannerList?[index].videoType ?? 0) == 2
                  //     ?
                  "showdetail",
                  // : "videodetail",
                  sectionBannerList?[index].id ?? 0,
                  sectionBannerList?[index].contentType ?? 0,
                );
              },
              child: Container(
                padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Stack(
                    alignment: AlignmentDirectional.centerEnd,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width *
                            (Dimens.webBannerImgPr),
                        height: Dimens.homeWebBanner,
                        child: MyNetworkImage(
                          imageUrl:
                              sectionBannerList?[index].landscapeImg ?? "",
                          fit: BoxFit.fill,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.homeWebBanner,
                        alignment: Alignment.centerLeft,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              colorPrimaryDark,
                              colorPrimaryDark,
                              colorPrimaryDark,
                              colorPrimaryDark,
                              transparentColor,
                              transparentColor,
                              transparentColor,
                              transparentColor,
                              transparentColor,
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.homeWebBanner,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  (1.0 - Dimens.webBannerImgPr),
                              constraints: const BoxConstraints(minHeight: 0),
                              padding:
                                  const EdgeInsets.fromLTRB(35, 50, 55, 35),
                              alignment: Alignment.centerLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    color: white,
                                    text: sectionBannerList?[index].title ?? "",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: 14,
                                    fontsizeWeb: 25,
                                    fontweight: FontWeight.w700,
                                    multilanguage: false,
                                    maxline: 2,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(height: 12),
                                  MyText(
                                    color: white,
                                    text: sectionBannerList?[index]
                                            .categoryName ??
                                        "",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: 14,
                                    fontweight: FontWeight.w600,
                                    fontsizeWeb: 15,
                                    multilanguage: false,
                                    maxline: 2,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: MyText(
                                      color: white,
                                      text: sectionBannerList?[index]
                                              .description ??
                                          "",
                                      textalign: TextAlign.start,
                                      fontsizeNormal: 14,
                                      fontweight: FontWeight.w600,
                                      fontsizeWeb: 15,
                                      multilanguage: false,
                                      maxline:
                                          (MediaQuery.of(context).size.width <
                                                  1000)
                                              ? 2
                                              : 5,
                                      overflow: TextOverflow.ellipsis,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget continueWatchingSmallSquare(
      int? upcomingType, List<list.Datum>? continueWatchingList) {
    if ((continueWatchingList?.length ?? 0) > 0) {
      return Container(
        padding: const EdgeInsets.all(5),
        color: appbgcolor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: Dimens.heightContiLandList,
              child: ListView.separated(
                itemCount: (continueWatchingList?.length ?? 0),
                shrinkWrap: true,
                padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                separatorBuilder: (context, index) => const SizedBox(
                  width: 5,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return SizedBox(
                    width: Dimens.widthContiLand,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          alignment: AlignmentDirectional.bottomStart,
                          children: [
                            InkWell(
                              focusColor: white,
                              borderRadius: BorderRadius.circular(4),
                              onTap: () {
                                printLog("Clicked on index ==> $index");

                                openDetailPage(
                                  "showdetail",
                                  continueWatchingList?[index].id ?? 0,
                                  continueWatchingList?[index].contentType ?? 0,
                                );
                              },
                              child: Container(
                                width: Dimens.widthContiLand,
                                height: Dimens.heightContiLand,
                                alignment: Alignment.center,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: MyNetworkImage(
                                    imageUrl: continueWatchingList?[index]
                                            .landscapeImg ??
                                        "",
                                    fit: BoxFit.fill,
                                    imgHeight:
                                        MediaQuery.of(context).size.height,
                                    imgWidth: MediaQuery.of(context).size.width,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 10, bottom: 8),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () async {
                                      // openPlayer("ContinueWatch", index,
                                      //     continueWatchingList);
                                    },
                                    child: Utils().playBtn(30, 30, 22),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        MyText(
                          color: white,
                          multilanguage: false,
                          text: ((continueWatchingList?[index]
                                          .title ??
                                      "")
                                  .isEmpty)
                              ? (continueWatchingList?[index].name.toString() ??
                                  "")
                              : continueWatchingList?[index].title.toString() ??
                                  "",
                          textalign: TextAlign.left,
                          fontsizeNormal: 12,
                          fontweight: FontWeight.w700,
                          fontsizeWeb: 11,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        MyText(
                          color: gray,
                          multilanguage: false,
                          text:
                              "${formatNumber(continueWatchingList?[index].totalUserPlay ?? 0)} Play",
                          textalign: TextAlign.left,
                          fontsizeNormal: 11,
                          fontweight: FontWeight.w500,
                          fontsizeWeb: 10,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget setSectionByType(List<list.Result>? sectionList) {
    return ListView.separated(
      separatorBuilder: (context, index) {
        return const SizedBox(height: 15);
      },
      itemCount: sectionList?.length ?? 0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        if (sectionList?[index].data != null &&
            (sectionList?[index].data?.length ?? 0) > 0) {
          return Container(
            padding: (sectionList?[index].screenLayout ?? "") == "banner_view"
                ? const EdgeInsets.only(top: 0)
                : const EdgeInsets.only(top: 5),
            color: appbgcolor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                (sectionList?[0].screenLayout ?? "") == "banner_view"
                    ? const SizedBox.shrink()
                    : index == 0
                        ? const SizedBox(
                            height: 25,
                          )
                        : const SizedBox.shrink(),
                (sectionList?[index].screenLayout ?? "") == "banner_view"
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: MyText(
                                color: white,
                                text:
                                    sectionList?[index].title.toString() ?? "",
                                textalign: TextAlign.left,
                                fontsizeNormal: 16,
                                fontweight: FontWeight.w700,
                                fontsizeWeb: 18,
                                multilanguage: false,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                            ),
                            sectionList?[index].viewAll == 1
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ViewAll(
                                                    screenLayout:
                                                        sectionList?[index]
                                                                .screenLayout
                                                                .toString() ??
                                                            "",
                                                    sectionId:
                                                        sectionList?[index].id,
                                                    title: sectionList?[index]
                                                            .title
                                                            .toString() ??
                                                        "",
                                                  )));
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 2, 10, 2),
                                      child: MyText(
                                        color: colorAccent,
                                        text: 'seeall',
                                        textalign: TextAlign.center,
                                        fontsizeNormal: 13,
                                        fontweight: FontWeight.w600,
                                        fontsizeWeb: 16,
                                        multilanguage: true,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink()
                          ],
                        ),
                      ),
                SizedBox(
                    height: (sectionList?[index].screenLayout ?? "") ==
                            "banner_view"
                        ? 0
                        : 5),
                setSectionData(sectionList: sectionList, index: index),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget setSectionData(
      {required List<list.Result>? sectionList, required int index}) {
    /* video_type =>  1-video,  2-show,  3-language,  4-category */

/* minSeries, top!0series, contemporyRomance,, newRelease,bestSellingStories */

    /* screen_layout =>  landscape, potrait, square */
    if ((sectionList?[index].screenLayout ?? "") == "landscape") {
      return contemporyRomance(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "list_view") {
      return top10series(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "grid_view") {
      return miniSeries(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "square") {
      return square(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "details_square") {
      return newRelease(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? 0) == "language") {
      return languageLayout(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "small_square") {
      return continueWatchingSmallSquare(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "portrait") {
      return portrait(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "round") {
      return author(1, sectionList?[index].data);
    } else if ((sectionList?[index].screenLayout ?? "") == "category") {
      return categories(1, sectionList?[index].data);
    } else {
      return landscape(1, sectionList?[index].data);
    }
  }

  Widget author(int? upcomingType, List<Datum>? sectionTypeList) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 160,
      decoration: const BoxDecoration(
        color: appbgcolor,
      ),
      child: ListView.separated(
        itemCount: sectionTypeList?.length ?? 0,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (BuildContext context, int index) {
          return Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              return InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () async {},
                child: SizedBox(
                  width: 90,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AuthorProfile(
                                  artistID: sectionTypeList?[index].id)));
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: MyNetworkImage(
                            imageUrl:
                                sectionTypeList?[index].image.toString() ?? "",
                            imgHeight: 80,
                            imgWidth: 80,
                            fit: BoxFit.fill,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        MyText(
                          textalign: TextAlign.center,
                          maxline: 2,
                          color: white,
                          text:
                              sectionTypeList?[index].userName.toString() ?? "",
                          fontsizeNormal: 12,
                          fontweight: FontWeight.w600,
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  double getRemainingDataHeight(
      int? length, String? videoType, String? layoutType) {
    // if (videoType == "1" || videoType == "2") {
    if (layoutType == "landscape") {
      return Dimens.heightcontemporyRomance;
    } else if (layoutType == "banner_view") {
      return Dimens.homeBanner;
    } else if (layoutType == "grid_view") {
      return Dimens.heightMiniSeries;
    } else if (layoutType == "list_view") {
      return Dimens.heighttop10Series;
    } else if (layoutType == "details_square") {
      return Dimens.newreleaseContainerheight;
    } else if (layoutType == "big_square") {
      return Dimens.heightbestSellingStries;
    } else if (layoutType == "language") {
      return Dimens.heightLangGen;
    } else if (layoutType == "potrait") {
      return Dimens.newreleaseContainerheight;
    } else if (layoutType == "square") {
      return Dimens.heightSquare;
    } else {
      return Dimens.heightLand;
    }
  }

  Widget landscape(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLand,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              printLog("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: Container(
              width: Dimens.widthLand,
              height: Dimens.heightLand,
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: MyNetworkImage(
                  imageUrl:
                      sectionDataList?[index].landscapeImg.toString() ?? "",
                  fit: BoxFit.fill,
                  imgHeight: MediaQuery.of(context).size.height,
                  imgWidth: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget portrait(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightPortCont,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              printLog("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: SizedBox(
              width: Dimens.widthPort,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: Dimens.widthPort,
                    height: Dimens.heightPort,
                    padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].portraitImg.toString() ??
                                "",
                        fit: BoxFit.fill,
                        imgHeight: MediaQuery.of(context).size.height,
                        imgWidth: MediaQuery.of(context).size.width,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MyText(
                    color: white,
                    text: sectionDataList?[index].title.toString() ?? "",
                    textalign: TextAlign.start,
                    fontsizeNormal: 14,
                    fontweight: FontWeight.w700,
                    fontsizeWeb: 15,
                    multilanguage: false,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget square(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightSquare,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              printLog("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: Container(
              width: Dimens.widthSquare,
              height: Dimens.heightSquare,
              alignment: Alignment.center,
              padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: MyNetworkImage(
                  imageUrl:
                      sectionDataList?[index].portraitImg.toString() ?? "",
                  fit: BoxFit.fill,
                  imgHeight: MediaQuery.of(context).size.height,
                  imgWidth: MediaQuery.of(context).size.width,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget languageLayout(int? typeId, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AlignedGridView.count(
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 2,
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return VideosByID(
                          sectionDataList?[index].id ?? 0,
                          typeId ?? 0,
                          sectionDataList?[index].title ?? "",
                          "ByLanguage",
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(5),
                  width: Dimens.containerWidthLan,
                  height: Dimens.containerHeightLan,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: NetworkImage(
                              sectionDataList?[index].image.toString() ?? ""))),
                  padding: EdgeInsets.all(Constant.isTV ? 2 : 4),
                  child: MyText(
                    color: white,
                    text: sectionDataList?[index].title.toString() ?? "",
                    textalign: TextAlign.center,
                    fontsizeNormal: 15,
                    fontweight: FontWeight.w700,
                    fontsizeWeb: 16,
                    multilanguage: false,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget newRelease(int? upcomingType, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: ListView.separated(
        itemCount: (sectionDataList?.length ?? 0) > 3
            ? 3
            : sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.vertical,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              printLog("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: MyNetworkImage(
                    imageUrl:
                        sectionDataList?[index].landscapeImg.toString() ?? "",
                    fit: BoxFit.fill,
                    imgHeight: Dimens.newreleaseimgwidth,
                    imgWidth: Dimens.newreleaseimgheight,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      color: white,
                      text: sectionDataList?[index].title.toString() ?? "",
                      textalign: TextAlign.left,
                      fontsizeNormal: 16,
                      fontweight: FontWeight.w600,
                      fontsizeWeb: 15,
                      multilanguage: false,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Utils().playIcon(gray, 18.0),
                        const SizedBox(
                          width: 8,
                        ),
                        MyText(
                          color: gray,
                          text:
                              "${formatNumber(sectionDataList?[index].totalUserPlay ?? 0)} Play",
                          textalign: TextAlign.left,
                          fontsizeNormal: 14,
                          fontweight: FontWeight.w600,
                          fontsizeWeb: 15,
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const Spacer(),
                        Container(
                          height: 26,
                          width: 70,
                          decoration: const BoxDecoration(
                              color: yellow,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(24))),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 5,
                              ),
                              // MyImage(
                              //   imagePath: "Star.png",
                              //   height: 18,
                              //   width: 18,
                              // ),
                              const Icon(
                                Icons.star,
                                size: 20,
                                color: colorPrimaryDark,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: MyText(
                                  color: colorPrimaryDark,
                                  text: sectionDataList?[index]
                                          .avgRating
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.left,
                                  fontsizeNormal: 12,
                                  fontweight: FontWeight.w600,
                                  fontsizeWeb: 15,
                                  multilanguage: false,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MyText(
                      color: white,
                      text:
                          sectionDataList?[index].description.toString() ?? "",
                      textalign: TextAlign.left,
                      fontsizeNormal: 12,
                      fontweight: FontWeight.w400,
                      fontsizeWeb: 15,
                      multilanguage: false,
                      maxline: 3,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ))
              ],
            ),
          );
        },
      ),
    );
  }

  Widget miniSeries(int? upcomingType, List<Datum>? sectionDataList) {
    return Container(
      color: appbgcolor,
      width: MediaQuery.of(context).size.width,
      height: (sectionDataList?.length) == 1
          ? Dimens.heightMiniSeries / 3
          : (sectionDataList?.length) == 2
              ? Dimens.heightMiniSeries / 2
              : Dimens.heightMiniSeries,
      child: AlignedGridView.count(
        crossAxisCount: (sectionDataList?.length ?? 0) > 4
            ? 4
            : (sectionDataList?.length ?? 0),
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 15, right: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              printLog("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: Container(
              height: Dimens.containerHeightMiniSeries,
              width: Dimens.containerwidthMiniSeries,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.only(left: 10),
              color: colorPrimary,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: MyNetworkImage(
                      imageUrl:
                          sectionDataList?[index].landscapeImg.toString() ?? "",
                      fit: BoxFit.fill,
                      imgHeight: Dimens.imgheightMiniSeries,
                      imgWidth: Dimens.imgwidthMiniSeries,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        color: white,
                        text: sectionDataList?[index].title.toString() ?? "",
                        textalign: TextAlign.left,
                        fontsizeNormal: 15,
                        fontweight: FontWeight.w600,
                        fontsizeWeb: 15,
                        multilanguage: false,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            // padding: const EdgeInsets.all(5),
                            height: 18,
                            width: 18,
                            decoration: BoxDecoration(
                                color: colorAccent,
                                borderRadius: BorderRadius.circular(50)),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 15,
                              color: white,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          MyText(
                            color: gray,
                            text:
                                "${formatNumber(sectionDataList?[index].totalUserPlay ?? 0)} Play",
                            textalign: TextAlign.left,
                            fontsizeNormal: 14,
                            fontweight: FontWeight.w600,
                            fontsizeWeb: 15,
                            multilanguage: false,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ],
                  ))
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget top10series(int? upcomingType, List<Datum>? sectionDataList) {
    return Container(
      color: appbgcolor,
      width: MediaQuery.of(context).size.width,
      // height: Dimens.heightMiniSeries,
      child: AlignedGridView.count(
        padding: const EdgeInsets.all(15),
        crossAxisCount: 2,
        itemCount:
            (sectionDataList?.length ?? 0) > 10 ? 10 : sectionDataList?.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              printLog("Clicked on index ==> $index");
              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: Container(
              margin: const EdgeInsets.all(10),
              child: Stack(children: [
                RotationTransition(
                  alignment: Alignment.bottomCenter,
                  turns: const AlwaysStoppedAnimation(12 / 360),
                  child: Container(
                    width: Dimens.top10imgwidth,
                    height: MediaQuery.of(context).size.height * 0.17,
                    margin: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: colorPrimaryLight,
                      borderRadius: BorderRadius.all(
                        Radius.circular(7),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].landscapeImg.toString() ??
                                "",
                        fit: BoxFit.fill,
                        imgHeight: Dimens.top10imgHeight,
                        imgWidth: Dimens.top10imgwidth,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 15,
                  top: 10,
                  child: Stack(
                    children: <Widget>[
                      Text(
                        (index + 1).toString(),
                        style: TextStyle(
                          fontSize: 40,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 6
                            ..color = colorAccent,
                        ),
                      ),
                      Text(
                        (index + 1).toString(),
                        style: const TextStyle(
                          fontSize: 40,
                          color: white,
                        ),
                      ),
                    ],
                  ),
                )
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget contemporyRomance(int? upcomingType, List<Datum>? sectionDataList) {
    return Container(
      color: appbgcolor,
      width: MediaQuery.of(context).size.width,
      height: (sectionDataList?.length ?? 0) == 1
          ? Dimens.heightcontemporyRomance / 2
          : Dimens.heightcontemporyRomance,
      child: AlignedGridView.count(
        crossAxisCount: (sectionDataList?.length ?? 0) > 2
            ? 2
            : (sectionDataList?.length ?? 0),
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 15, right: 20),
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              printLog("Clicked on index ==> $index");

              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: Container(
              margin: const EdgeInsets.all(10),
              width: Dimens.imgwidthcontempory,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: MyNetworkImage(
                        imageUrl:
                            sectionDataList?[index].landscapeImg.toString() ??
                                "",
                        fit: BoxFit.fill,
                        imgHeight: Dimens.imgheightcontempory,
                        imgWidth: Dimens.imgwidthcontempory,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyText(
                    color: white,
                    text: sectionDataList?[index].title.toString() ?? "",
                    textalign: TextAlign.left,
                    fontsizeNormal: 15,
                    fontweight: FontWeight.w600,
                    fontsizeWeb: 15,
                    multilanguage: false,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyText(
                    color: colorAccent,
                    text:
                        "${formatNumber(sectionDataList?[index].totalUserPlay ?? 0)} Play",
                    textalign: TextAlign.left,
                    fontsizeNormal: 14,
                    fontweight: FontWeight.w600,
                    fontsizeWeb: 15,
                    multilanguage: false,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget categories(int? upCmingType, List<Datum>? sectionTypeList) {
    return Container(
      height: 130,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: appbgcolor,
      ),
      child: ListView.separated(
        itemCount: sectionTypeList?.length ?? 0,
        shrinkWrap: true,
        controller: tabScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(13, 2, 13, 0),
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Consumer<HomeProvider>(
            builder: (context, homeProvider, child) {
              return InkWell(
                borderRadius: BorderRadius.circular(25),
                onTap: () async {
                  printLog("index ===========> $index");
                  AdHelper.showFullscreenAd(context, Constant.interstialAdType,
                      () async {
                    if (kIsWeb) _onItemTapped("");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return VideosByID(
                            sectionTypeList?[index].id ?? 0,
                            1,
                            sectionTypeList?[index].title ?? "",
                            "ByCategory",
                          );
                        },
                      ),
                    );
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 15),
                  child: Card(
                    color: colorPrimary,
                    elevation: 10,
                    shadowColor: colorAccent,
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      white,
                                      colorAccent.withOpacity(0.5)
                                    ]),
                                borderRadius: BorderRadius.circular(50)),
                            child: MyNetworkImage(
                              imageUrl: sectionTypeList?[index]
                                      .portraitImg
                                      .toString() ??
                                  "",
                              imgHeight: 30,
                              imgWidth: 22,
                              fit: BoxFit.fill,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          MyText(
                            color: white,
                            multilanguage: false,
                            text:
                                (sectionTypeList?[index].name.toString() ?? ""),
                            fontsizeNormal: 12,
                            fontweight: FontWeight.w600,
                            fontsizeWeb: 14,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            textalign: TextAlign.center,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget genresLayout(int? typeId, List<Datum>? sectionDataList) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: Dimens.heightLangGen,
      child: ListView.separated(
        itemCount: sectionDataList?.length ?? 0,
        shrinkWrap: true,
        physics:
            const PageScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.only(left: 20, right: 20),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (context, index) => const SizedBox(width: 5),
        itemBuilder: (BuildContext context, int index) {
          return Stack(
            alignment: AlignmentDirectional.bottomStart,
            children: [
              InkWell(
                focusColor: white,
                borderRadius: BorderRadius.circular(4),
                onTap: () {
                  printLog("Clicked on index ==> $index");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return VideosByID(
                          sectionDataList?[index].id ?? 0,
                          typeId ?? 0,
                          sectionDataList?[index].title ?? "",
                          "ByCategory",
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  width: Dimens.widthLangGen,
                  height: Dimens.heightLangGen,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(Constant.isTV ? 2 : 0),
                  child: Stack(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: MyNetworkImage(
                          imageUrl:
                              sectionDataList?[index].portraitImg.toString() ??
                                  "",
                          fit: BoxFit.fill,
                          imgHeight: MediaQuery.of(context).size.height,
                          imgWidth: MediaQuery.of(context).size.width,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(0),
                        width: MediaQuery.of(context).size.width,
                        height: Dimens.heightLangGen,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.center,
                            end: Alignment.bottomCenter,
                            colors: [
                              transparentColor,
                              transparentColor,
                              colorPrimary,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(3),
                child: MyText(
                  color: white,
                  text: sectionDataList?[index].title.toString() ?? "",
                  textalign: TextAlign.center,
                  fontsizeNormal: 14,
                  fontweight: FontWeight.w600,
                  fontsizeWeb: 15,
                  multilanguage: false,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget bestSellingStories(int? upcomingType, List<Datum>? sectionDataList) {
    return Container(
      color: appbgcolor,
      width: MediaQuery.of(context).size.width,
      // height: Dimens.heightbestSellingStries,
      child: AlignedGridView.count(
        crossAxisCount: 2,
        itemCount: (sectionDataList?.length ?? 0) > 4
            ? 4
            : (sectionDataList?.length ?? 0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 10, right: 10),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            focusColor: white,
            borderRadius: BorderRadius.circular(4),
            onTap: () {
              printLog("Clicked on index ==> $index");

              openDetailPage(
                "showdetail",
                sectionDataList?[index].id ?? 0,
                sectionDataList?[index].contentType ?? 0,
              );
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              width: Dimens.imgwidthcontempory,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: MyNetworkImage(
                      imageUrl:
                          sectionDataList?[index].landscapeImg.toString() ?? "",
                      fit: BoxFit.fill,
                      imgHeight: Dimens.imgheightbestSellingStories,
                      imgWidth: Dimens.imgwidthbestSellingStories,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyText(
                    color: white,
                    text: sectionDataList?[index].title.toString() ?? "",
                    textalign: TextAlign.left,
                    fontsizeNormal: 14,
                    fontweight: FontWeight.w500,
                    fontsizeWeb: 15,
                    multilanguage: false,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  MyText(
                    color: gray,
                    text:
                        "${formatNumber(sectionDataList?[index].totalUserPlay ?? 0)} Play",
                    textalign: TextAlign.left,
                    fontsizeNormal: 12,
                    fontweight: FontWeight.w500,
                    fontsizeWeb: 15,
                    multilanguage: false,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

/* PlayAudio Player */
  Future<void> playAudio({
    required String playingType,
    required String episodeid,
    required String contentid,
    String? podcastimage,
    String? contentUserid,
    required int position,
    required List<Datum>? sectionBannerList,
    dynamic playlistImages,
    required String contentName,
    required String? isBuy,
    required int? isAudioPaid,
  }) async {
    printLog("playingType =====>>>>>> ? $playingType");
    printLog("episodeid =====>>>>>> ? $episodeid");
    printLog("contentid =====>>>>>> ? $contentid");
    printLog("podcastimage =====>>>>>> ? $podcastimage");
    printLog("contentUserid =====>>>>>> ? $contentUserid");
    printLog("position =====>>>>>> ? $position");
    printLog(
        "sectionBannerList =====>>>>>> ? ${jsonEncode(sectionBannerList)}");
    printLog("playlistImages =====>>>>>> ? $playlistImages");
    printLog("contentName =====>>>>>> ? $contentName");

    /* Only Music Direct Play*/
    if (Constant.userID != null) {
      musicManager.setInitialMusic(
          position,
          playingType,
          sectionBannerList,
          contentid,
          addView(playingType, episodeid, contentid),
          false,
          0,
          isBuy ?? "",
          isAudioPaid ?? 0,
          "audioBook",
          "0");
    } else {
      Utils.showToast(loginfirst);
      Utils.openLogin(context: context, isHome: false, isReplace: false);
    }
  }

  addView(contentType, episodeid, contentId) async {
    final audiototalplayprovider =
        Provider.of<ShowDetailsProvider>(context, listen: false);
    await audiototalplayprovider.getAddContentPlay(1, episodeid, 1, contentId);
  }
}