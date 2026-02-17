import 'package:diamondnib/main.dart';
import 'package:diamondnib/pages/audiobook.dart';
import 'package:diamondnib/pages/audiobookdetails.dart';
import 'package:diamondnib/pages/authorprofile.dart';
import 'package:diamondnib/pages/find.dart';
import 'package:diamondnib/pages/music.dart';
import 'package:diamondnib/pages/mywallet.dart';
import 'package:diamondnib/pages/mywatchlist.dart';
import 'package:diamondnib/pages/newthread.dart';
import 'package:diamondnib/pages/notification.dart';
import 'package:diamondnib/pages/novel.dart';
import 'package:diamondnib/pages/noveldetails.dart';
import 'package:diamondnib/pages/profile.dart';
import 'package:diamondnib/pages/seeall.dart';
import 'package:diamondnib/pages/splash.dart';
import 'package:diamondnib/pages/threads.dart';
import 'package:diamondnib/pages/videosbyid.dart';
import 'package:diamondnib/pages/viewall.dart';
import 'package:diamondnib/routes/routes_constant.dart';
import 'package:diamondnib/subscription/allpayment.dart';
import 'package:diamondnib/subscription/subscription.dart';
import 'package:diamondnib/tvpages/webaudiobook.dart';
import 'package:diamondnib/tvpages/webaudiobookdetails.dart';
import 'package:diamondnib/tvpages/weberrorpage.dart';
import 'package:diamondnib/tvpages/webhome.dart';
import 'package:diamondnib/tvpages/webmusic.dart';
import 'package:diamondnib/tvpages/webmusicviewall.dart';
import 'package:diamondnib/tvpages/webnovel.dart';
import 'package:diamondnib/tvpages/webnoveldetails.dart';
import 'package:diamondnib/tvpages/webthread.dart';
import 'package:diamondnib/tvpages/webvideosbyid.dart';
import 'package:diamondnib/tvpages/webviewall.dart';
import 'package:diamondnib/tvpages/webwishlist.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/webwidget/searchweb.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

class RoutesConfig {
  GoRouter goRouter = GoRouter(
      initialLocation: '/',
      navigatorKey: navigatorKey,
      observers: [
        routeObserver
      ], //HERE
      routes: [
        /* Initial route by Platform */
        GoRoute(
          name: RoutesConstant.homePage,
          path: '/',
          builder: (context, state) {
            if (kIsWeb || Constant.isTV) {
              return const WebHome(
                pageName: "",
              );
            }
            return const Splash();
          },
        ),

        /* Search */
        GoRoute(
          name: RoutesConstant.searchPage,
          path: '/${RoutesConstant.searchPage}',
          builder: (context, state) {
            if (state.extra != null && state.extra is String) {
              if (kIsWeb || Constant.isTV) {
                return const SearchWeb();
              }
              return const Find();
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /* Watchlist */
        GoRoute(
          name: RoutesConstant.myWishListPage,
          path: '/${RoutesConstant.myWishListPage}',
          builder: (context, state) {
            if (state.extra != null) {
              if (kIsWeb || Constant.isTV) {
                return const WebWishList();
              }
              return const MyWatchlist();
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /* Notifications */
        GoRoute(
          name: RoutesConstant.notifications,
          path: '/${RoutesConstant.notifications}',
          builder: (context, state) {
            if (state.extra != null) {
              if (kIsWeb || Constant.isTV) {
                return const Notifications();
              }
              return const Notifications();
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /* My Wallet */
        GoRoute(
          name: RoutesConstant.mywallet,
          path: '/${RoutesConstant.mywallet}',
          builder: (context, state) {
            if (state.extra != null) {
              if (kIsWeb || Constant.isTV) {
                return const MyWallet();
              }
              return const MyWallet();
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),
        /* Subscriptio */
        GoRoute(
          name: RoutesConstant.subscriptionPage,
          path: '/${RoutesConstant.subscriptionPage}',
          builder: (context, state) {
            if (state.extra != null) {
              if (kIsWeb || Constant.isTV) {
                return const Subscription();
              }
              return const Subscription();
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /* AudioBook Details Page */
        GoRoute(
          name: RoutesConstant.audiobookDetailPage,
          path: '/${RoutesConstant.audiobookDetailPage}',
          builder: (context, state) {
            int? contentId, contentType;
            Map<String, dynamic> extraData = {};
            if (state.extra != null && state.extra is Map<String, dynamic>) {
              extraData = state.extra as Map<String, dynamic>;
              contentId = extraData['contentid'];
              contentType = extraData['contenttype'];
              if (kIsWeb || Constant.isTV) {
                return WebAudioBookDetails(int.parse(contentId.toString()),
                    int.parse(contentType.toString()));
              }
              return AudioBookDetails(int.parse(contentId.toString()),
                  int.parse(contentType.toString()));
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /* Novel Details Page */
        GoRoute(
          name: RoutesConstant.novelDetailPage,
          path: '/${RoutesConstant.novelDetailPage}',
          builder: (context, state) {
            int? contentId, contentType;
            Map<String, dynamic> extraData = {};
            if (state.extra != null && state.extra is Map<String, dynamic>) {
              extraData = state.extra as Map<String, dynamic>;
              contentId = extraData['contentid'];
              contentType = extraData['contenttype'];
              if (kIsWeb || Constant.isTV) {
                return WebNovelDetails(int.parse(contentId.toString()),
                    int.parse(contentType.toString()));
              }
              return NovelDetails(int.parse(contentId.toString()),
                  int.parse(contentType.toString()));
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /* Novel  Page */
        GoRoute(
          name: RoutesConstant.novelPage,
          path: '/${RoutesConstant.novelPage}',
          builder: (context, state) {
            if (state.extra != null && state.extra is Map<String, dynamic>) {
              if (kIsWeb || Constant.isTV) {
                return const WebNovel();
              }
              return const Novel(
                pageName: '',
              );
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /* AudioBook  Page */
        GoRoute(
          name: RoutesConstant.audioBookPage,
          path: '/${RoutesConstant.audioBookPage}',
          builder: (context, state) {
            if (state.extra != null && state.extra is Map<String, dynamic>) {
              if (kIsWeb || Constant.isTV) {
                return const WebAudioBook();
              }
              return const AudioBooks(
                pageName: '',
              );
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /* Threads  Page */
        GoRoute(
          name: RoutesConstant.threadPage,
          path: '/${RoutesConstant.threadPage}',
          builder: (context, state) {
            if (state.extra != null && state.extra is Map<String, dynamic>) {
              if (kIsWeb || Constant.isTV) {
                return const WebThreads();
              }
              return const Threads();
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /* Music  Page */
        GoRoute(
          name: RoutesConstant.musicPage,
          path: '/${RoutesConstant.musicPage}',
          builder: (context, state) {
            if (state.extra != null && state.extra is Map<String, dynamic>) {
              if (kIsWeb || Constant.isTV) {
                return const WebMusic();
              }
              return const Music();
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /* Thread Create  Page */
        GoRoute(
          name: RoutesConstant.threadCreatePage,
          path: '/${RoutesConstant.threadCreatePage}',
          builder: (context, state) {
            if (state.extra != null) {
              if (kIsWeb || Constant.isTV) {
                return const CreateThread();
              }
              return const CreateThread();
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /* Web Music Viewall  Page */
        GoRoute(
          name: RoutesConstant.webmusicviewallpage,
          path: '/${RoutesConstant.webmusicviewallpage}',
          builder: (context, state) {
            final String? title, sectionId, screenLayout, contenttype;
            Map<String, dynamic> extraData = {};
            if (state.extra != null && state.extra is Map<String, dynamic>) {
              extraData = state.extra as Map<String, dynamic>;
              sectionId = extraData['sectionid'] as String;
              contenttype = extraData['contenttype'];
              screenLayout = extraData['screenlayout'] as String;
              title = extraData['title'] as String;
              if (kIsWeb || Constant.isTV) {
                return WebMusicViewAll(
                  contentType: contenttype.toString(),
                  title: title.toString(),
                  isRent: false,
                  sectionId: sectionId,
                  screenLayout: screenLayout,
                );
              }
              return SeeAll(
                title: title.toString(),
                isRent: false,
                sectionId: sectionId,
              );
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /*  Viewall  Page */
        GoRoute(
          name: RoutesConstant.webviewallpage,
          path: '/${RoutesConstant.webviewallpage}',
          builder: (context, state) {
            final String? title, screenLayout;
            final int? sectionId;
            Map<String, dynamic> extraData = {};
            if (state.extra != null && state.extra is Map<String, dynamic>) {
              extraData = state.extra as Map<String, dynamic>;
              sectionId = extraData['sectionid'];
              screenLayout = extraData['screenlayout'] as String;
              title = extraData['title'] as String;
              if (kIsWeb || Constant.isTV) {
                return WebViewAll(
                  title: title.toString(),
                  sectionId: sectionId,
                  screenLayout: screenLayout,
                );
              }
              return ViewAll(
                title: title.toString(),
                sectionId: sectionId,
                screenLayout: screenLayout,
              );
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /*  AuthorProfile  Page */
        GoRoute(
          name: RoutesConstant.authorprofilepage,
          path: '/${RoutesConstant.authorprofilepage}',
          builder: (context, state) {
            final int? authorid;
            Map<String, dynamic> extraData = {};
            if (state.extra != null && state.extra is Map<String, dynamic>) {
              extraData = state.extra as Map<String, dynamic>;
              authorid = extraData['authorid'];
              if (kIsWeb || Constant.isTV) {
                return AuthorProfile(
                  artistID: authorid,
                );
              }
              return AuthorProfile(
                artistID: authorid,
              );
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /*  MyProfile otheruser  Page */
        GoRoute(
          name: RoutesConstant.myProfilePage,
          path: '/${RoutesConstant.myProfilePage}',
          builder: (context, state) {
            final String? type, userid;
            Map<String, dynamic> extraData = {};
            if (state.extra != null && state.extra is Map<String, dynamic>) {
              extraData = state.extra as Map<String, dynamic>;
              type = extraData['type'];
              userid = extraData['userid'];
              if (kIsWeb || Constant.isTV) {
                return MyProfile(
                  type: type,
                  userid: userid,
                );
              }
              return MyProfile(
                type: type,
                userid: userid,
              );
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /*  Web Videos By Category And Language Page */
        GoRoute(
          name: RoutesConstant.videoByCatPage,
          path: '/${RoutesConstant.videoByCatPage}',
          builder: (context, state) {
            final String? appBarTitle, screenLayout;
            final int? typeid, itemid;
            Map<String, dynamic> extraData = {};
            if (state.extra != null && state.extra is Map<String, dynamic>) {
              extraData = state.extra as Map<String, dynamic>;
              typeid = extraData['typeid'];
              itemid = extraData['itemid'];
              screenLayout = extraData['screenlayout'] as String;
              appBarTitle = extraData['appBarTitle'] as String;
              if (kIsWeb || Constant.isTV) {
                return WebVideosByID(
                    itemid ?? 0, typeid ?? 0, appBarTitle, screenLayout);
              }
              return VideosByID(
                  itemid ?? 0, typeid ?? 0, appBarTitle, screenLayout);
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),

        /* All Payments Page */
        GoRoute(
          name: RoutesConstant.paymentPage,
          path: '/${RoutesConstant.paymentPage}',
          builder: (context, state) {
            Map<String, dynamic> extraData = {};
            final String? payType,
                itemId,
                price,
                itemTitle,
                typeId,
                videoType,
                productPackage,
                currency,
                coins;
            if (state.extra != null && state.extra is Map<String, dynamic>) {
              extraData = state.extra as Map<String, dynamic>;
              coins = extraData['coins'] as String;
              itemId = extraData['itemid'] as String;
              payType = extraData['paytype'] as String;
              price = extraData['price'] as String;
              itemTitle = extraData['title'] as String;
              typeId = extraData['typeid'] as String;
              videoType = extraData['videotype'] as String;
              productPackage = extraData['productpackage'] as String;
              currency = extraData['currency'] as String;

              return AllPayment(
                payType: payType,
                itemId: itemId,
                price: price,
                itemTitle: itemTitle,
                typeId: typeId,
                videoType: videoType,
                productPackage: productPackage,
                currency: currency,
                coin: coins,
              );
            } else {
              return WebErrorPage(state.error!);
            }
          },
        ),
      ]);
}
