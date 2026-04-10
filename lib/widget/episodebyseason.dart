import 'dart:convert';
import 'dart:io';

// import 'package:diamondnib/utils/adhelper.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:diamondnib/model/download_item.dart';
import 'package:diamondnib/pages/musicdetails.dart';
import 'package:diamondnib/provider/connectivityprovider.dart';
import 'package:diamondnib/provider/downloadprovider.dart';
import 'package:diamondnib/provider/profileprovider.dart';
import 'package:diamondnib/provider/subscriptionprovider.dart';
import 'package:diamondnib/routes/routes_constant.dart';
import 'package:diamondnib/shimmer/shimmerwidget.dart';
import 'package:diamondnib/subscription/allpayment.dart';
import 'package:diamondnib/utils/dimens.dart';
import 'package:diamondnib/utils/sharedpre.dart';
import 'package:diamondnib/utils/strings.dart';
import 'package:diamondnib/webservice/apiservices.dart';
import 'package:diamondnib/widget/myimage.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:diamondnib/model/episodebycontentmodel.dart';
// import 'package:diamondnib/pages/loginsocial.dart';
import 'package:diamondnib/subscription/subscription.dart';
// import 'package:diamondnib/model/episodebycontentmodel.dart' as episode;
import 'package:diamondnib/provider/episodeprovider.dart';
import 'package:diamondnib/provider/musicdetailprovider.dart';
import 'package:diamondnib/provider/showdetailsprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/mynetworkimg.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class EpisodeBySeason extends StatefulWidget {
  final int? videoId, seasonPos, type, contentType;
  final List<Result>? seasonList;
  final Result? sectionDetails;
  const EpisodeBySeason(this.videoId, this.seasonPos, this.seasonList,
      this.sectionDetails, this.type, this.contentType,
      {super.key});

  @override
  State<EpisodeBySeason> createState() => _EpisodeBySeasonState();
}

class _EpisodeBySeasonState extends State<EpisodeBySeason> {
  late EpisodeProvider episodeProvider;
  late ShowDetailsProvider showdetailsprovider;
  late ProgressDialog prDialog;
  late ProfileProvider profileProvider;
  String? finalVUrl = "";
  // final MusicManager musicManager = MusicManager();
  late SubscriptionProvider subscriptionProvider;
  late DownLoadProvider downloadProvider;
  CarouselController pageController = CarouselController();
  String? userName, userEmail, userMobileNo;
  SharedPre sharedPre = SharedPre();
  late ConnectivityProvider connectivityProvider;
  late Box<DownloadEpisodeItem> downloadBox;

  @override
  void initState() {
    episodeProvider = Provider.of<EpisodeProvider>(context, listen: false);
    downloadProvider = Provider.of<DownLoadProvider>(context, listen: false);

    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    showdetailsprovider =
        Provider.of<ShowDetailsProvider>(context, listen: false);
    connectivityProvider =
        Provider.of<ConnectivityProvider>(context, listen: false);
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    // _scrollController = ScrollController();
    // _scrollController.addListener(_scrollListener);
    /* Initilize Hive */
    if (!kIsWeb) {
      if (Constant.userID != null) {
        downloadBox = Hive.box<DownloadEpisodeItem>(
            '${Constant.audioEpisodeDownloadBox}_${Constant.userID}');
      } else {
        downloadBox =
            Hive.box<DownloadEpisodeItem>(Constant.audioEpisodeDownloadBox);
      }
    }
    getAllEpisode();
    prDialog = ProgressDialog(context);

    super.initState();
  }

  _checkAndDownload(index) async {
    if (!connectivityProvider.isOnline) {
      Utils.showSnackbar(context, "fail", "no_internet", true);
      return;
    }
    if ((episodeProvider.audioList?[index].audio ?? "").isNotEmpty) {
      try {
        prepareAudioDownload(
          context,
          contentDetails: showdetailsprovider.contentdetailsModel.result?[0],
          episodePos: index,
          episodeDetails: episodeProvider.audioList?[index],
        );
      } catch (e) {
        printLog("Downloading... Exception ======> $e");
      }
    } else {
      if (!context.mounted) return;
      Utils.showSnackbar(context, "fail", "invalid_url", true);
    }
  }

  // _scrollListener() async {
  //   if (!_scrollController.hasClients) return;
  //   if (_scrollController.offset >=
  //           _scrollController.position.maxScrollExtent &&
  //       !_scrollController.position.outOfRange) {
  //     printLog("AudioData Scroll Listner");

  //     if ((episodeProvider.audiocurrentPage ?? 0) <
  //         (episodeProvider.audiototalPage ?? 0)) {
  //       episodeProvider.setLoadMore(true);
  //       await _fetchDataAudio((episodeProvider.audiocurrentPage ?? 0));
  //     }
  //   }
  // }

  getAllEpisode() async {
    // await profileProvider.getProfile(context);

    // await _fetchDataAudio(0);
    await subscriptionProvider.getPackages();
    await _getUserData();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  updateDataDialog({
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
  }) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    if (!mounted) return;
    dynamic result = await showModalBottomSheet<dynamic>(
      constraints: BoxConstraints(
          maxWidth: kIsWeb
              ? MediaQuery.of(context).size.width * 0.4
              : MediaQuery.of(context).size.width),
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Utils.dataUpdateDialog(
              context,
              isNameReq: isNameReq,
              isEmailReq: isEmailReq,
              isMobileReq: isMobileReq,
              nameController: nameController,
              emailController: emailController,
              mobileController: mobileController,
            ),
          ],
        );
      },
    );
    if (result != null) {
      await _getUserData();
      Future.delayed(Duration.zero).then((value) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  _getUserData() async {
    userName = await sharedPre.read("username");
    userEmail = await sharedPre.read("useremail");
    userMobileNo = await sharedPre.read("usermobile");
    printLog('getUserData userName ==> $userName');
    printLog('getUserData userEmail ==> $userEmail');
    printLog('getUserData userMobileNo ==> $userMobileNo');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildUIAudioOther();
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  Widget _buildUIAudioOther() {
    return Consumer<EpisodeProvider>(
      builder: (BuildContext context, episodeProvider, Widget? child) {
        if (episodeProvider.loading && episodeProvider.loadmore == false) {
          return audioShimmer();
        } else {
          return (episodeProvider.audiobycontentmodel.status == 200 &&
                  episodeProvider.audioList != null &&
                  (episodeProvider.audioList?.length ?? 0) > 0)
              ? Column(
                  children: [
                    ResponsiveGridList(
                      minItemWidth: 60,
                      verticalGridSpacing: 8,
                      horizontalGridSpacing: 8,
                      minItemsPerRow: 1,
                      maxItemsPerRow:
                          (kIsWeb && MediaQuery.of(context).size.width > 720)
                              ? 1
                              : 1,
                      listViewBuilderOptions: ListViewBuilderOptions(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                      children: List.generate(
                        (episodeProvider.audioList?.length ?? 0),
                        (index) {
                          return Container(
                            color: colorPrimary,
                            padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                            constraints: const BoxConstraints(minHeight: 60),
                            child: InkWell(
                              onTap: () {
                                playAudio(
                                  playingType: episodeProvider
                                          .audioList?[index].audioType
                                          .toString() ??
                                      "",
                                  episodeid: episodeProvider
                                          .audioList?[index].id
                                          .toString() ??
                                      "",
                                  contentid: episodeProvider
                                          .audioList?[index].contentId
                                          .toString() ??
                                      "",
                                  position: index,
                                  sectionBannerList:
                                      episodeProvider.audioList ?? [],
                                  contentName: episodeProvider
                                          .audioList?[index].name
                                          .toString() ??
                                      "",
                                  isBuy: episodeProvider.audioList?[index].isBuy
                                          .toString() ??
                                      "",
                                  isAudioPaid: episodeProvider
                                      .audioList?[index].isAudioPaid,
                                  isAudioCoin: episodeProvider
                                      .audioList?[index].isAudioCoin,
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyText(
                                    color: white,
                                    text: (index + 1).toString(),
                                    multilanguage: false,
                                    textalign: TextAlign.center,
                                    fontsizeNormal: 15,
                                    fontsizeWeb: 16,
                                    maxline: 1,
                                    fontweight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.all(2.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: MyNetworkImage(
                                            fit: BoxFit.fill,
                                            imgHeight: 50,
                                            imgWidth: 50,
                                            imageUrl: episodeProvider
                                                    .audioList?[index].image
                                                    .toString() ??
                                                "",
                                          ),
                                        ),
                                      ),
                                      (episodeProvider.audioList?[index]
                                                      .audioDuration !=
                                                  null &&
                                              (episodeProvider.audioList?[index]
                                                          .stopTime ??
                                                      0) >
                                                  0)
                                          ? Container(
                                              height: 2,
                                              width: 32,
                                              margin:
                                                  const EdgeInsets.only(top: 8),
                                              child: LinearPercentIndicator(
                                                padding:
                                                    const EdgeInsets.all(0),
                                                barRadius:
                                                    const Radius.circular(2),
                                                lineHeight: 2,
                                                percent: Utils.getPercentage(
                                                    episodeProvider
                                                            .audioList?[index]
                                                            .audioDuration ??
                                                        0,
                                                    episodeProvider
                                                            .audioList?[index]
                                                            .stopTime ??
                                                        0),
                                                backgroundColor: gray,
                                                progressColor: yellow,
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        MyText(
                                          color: white,
                                          text: episodeProvider
                                                  .audioList?[index].name ??
                                              "",
                                          textalign: TextAlign.start,
                                          fontstyle: FontStyle.normal,
                                          fontsizeNormal: 14,
                                          fontsizeWeb: 14,
                                          maxline: 1,
                                          overflow: TextOverflow.ellipsis,
                                          fontweight: FontWeight.w600,
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          // mainAxisAlignment:
                                          //     MainAxisAlignment.spaceBetween,
                                          children: [
                                            widget.type == 2
                                                ? const Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 8.0),
                                                    child: Icon(
                                                      Icons
                                                          .remove_red_eye_outlined,
                                                      size: 20,
                                                      color: white,
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                            MyText(
                                              color: white,
                                              text: formatNumber(
                                                episodeProvider
                                                        .audioList?[index]
                                                        .totalVideoPlayed ??
                                                    0,
                                              ),
                                              textalign: TextAlign.start,
                                              fontsizeNormal: 11,
                                              fontsizeWeb: 12,
                                              fontweight: FontWeight.w600,
                                              maxline: 1,
                                              overflow: TextOverflow.ellipsis,
                                              fontstyle: FontStyle.normal,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            widget.type == 1
                                                ? Container(
                                                    height: 4,
                                                    width: 4,
                                                    decoration: BoxDecoration(
                                                        color: white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(50)),
                                                  )
                                                : const SizedBox.shrink(),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: widget.type == 1
                                                  ? MyText(
                                                      color: white,
                                                      text: ((episodeProvider
                                                                      .audioList?[
                                                                          index]
                                                                      .audioDuration ??
                                                                  0) >
                                                              0)
                                                          ? Utils.convertToColonText(
                                                              episodeProvider
                                                                      .audioList?[
                                                                          index]
                                                                      .audioDuration ??
                                                                  0)
                                                          : "",
                                                      textalign:
                                                          TextAlign.start,
                                                      fontsizeNormal: 11,
                                                      fontsizeWeb: 12,
                                                      fontweight:
                                                          FontWeight.w600,
                                                      maxline: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontstyle:
                                                          FontStyle.normal,
                                                    )
                                                  : const SizedBox.shrink(),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            _buildDownloadWithSubCheck(index),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            // Container(
                                            //   height: 4,
                                            //   width: 4,
                                            //   decoration: BoxDecoration(
                                            //       color: white,
                                            //       borderRadius:
                                            //           BorderRadius
                                            //               .circular(
                                            //                   50)),
                                            // ),
                                            // const SizedBox(
                                            //   width: 10,
                                            // ),
                                            // MyText(
                                            //   color: white,
                                            //   text: "1 year Ago",
                                            //   textalign:
                                            //       TextAlign.start,
                                            //   fontsizeNormal: 11,
                                            //   fontsizeWeb: 12,
                                            //   fontweight:
                                            //       FontWeight.w600,
                                            //   maxline: 1,
                                            //   overflow:
                                            //       TextOverflow.ellipsis,
                                            //   fontstyle:
                                            //       FontStyle.normal,
                                            // ),
                                            // const SizedBox(
                                            //   width: 10,
                                            // ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  MyText(
                                    text: (episodeProvider.audioList?[index]
                                                    .isAudioPaid ??
                                                "") ==
                                            1
                                        ? (episodeProvider.audioList?[index]
                                                        .isBuy ??
                                                    "") ==
                                                1
                                            ? ""
                                            : "${episodeProvider.audioList?[index].isAudioCoin} Coins"
                                        : "",
                                    fontsizeNormal: 13,
                                    fontsizeWeb: 13,
                                    color: white,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      child: (episodeProvider.audioList?[index]
                                                      .isAudioPaid ??
                                                  "") ==
                                              1
                                          ? (episodeProvider.audioList?[index]
                                                          .isBuy ??
                                                      "") ==
                                                  1
                                              ? Utils().playBtn(22, 22, 15)
                                              : Container(
                                                  // padding:
                                                  //     const EdgeInsets.all(5),
                                                  height: 22,
                                                  width: 22,
                                                  decoration: BoxDecoration(
                                                      color: colorAccent,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                  child: const Icon(
                                                    Icons.lock_outline_sharp,
                                                    size: 15,
                                                    color: white,
                                                  ),
                                                )
                                          : Utils().playBtn(22, 22, 15),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Consumer<EpisodeProvider>(
                      builder: (context, episodeProvider, child) {
                        if (episodeProvider.loadmore) {
                          return Container(
                            height: 50,
                            margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                            child: Utils.pageLoader(),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                  ],
                )
              : const SizedBox.shrink();
        }
      },
    );
  }

  addView(contentType, episodeid, contentId) async {
    final audiototalplayprovider =
        Provider.of<EpisodeProvider>(context, listen: false);
    await audiototalplayprovider.getAddContentPlay(1, episodeid, 1, contentId);
  }

  addPlay(contentType, episodeid, contentId) async {
    final videototalplayprovider =
        Provider.of<EpisodeProvider>(context, listen: false);
    await videototalplayprovider.getAddContentPlay(1, episodeid, 2, contentId);
  }

  /* PlayAudio Player */
  Future<void> playAudio({
    required String playingType,
    required String episodeid,
    required String contentid,
    String? podcastimage,
    String? contentUserid,
    required int position,
    required List<Result>? sectionBannerList,
    dynamic playlistImages,
    required String contentName,
    required String? isBuy,
    required int? isAudioPaid,
    required int? isAudioCoin,
  }) async {
    printLog("🎵 ===== playAudio CALLED =====");
    printLog("playingType =====>>>>>> ? $playingType");
    printLog("episodeid =====>>>>>> ? $episodeid");
    printLog("contentid =====>>>>>> ? $contentid");
    printLog("isBuy =====>>>>>> ? $isBuy (type: ${isBuy.runtimeType})");
    printLog("isAudioPaid =====>>>>>> ? $isAudioPaid");
    printLog("isAudioCoin =====>>>>>> ? $isAudioCoin");
    printLog("contentName =====>>>>>> ? $contentName");

    if (Constant.userID != null) {
      // Check purchase status
      final isPaid = (isAudioPaid == 1);
      final isNotBought = (isBuy == "0" || isBuy == 0 || isBuy?.toString() == '0');
      
      printLog("🎵 Purchase check - isPaid: $isPaid, isNotBought: $isNotBought");
      
      if (isPaid && isNotBought) {
        printLog("🎵 ⛔ Episode is LOCKED - showing purchase dialog");
        if (kIsWeb) {
          openSubscriptionDialog(
            position,
            isAudioCoin,
            contentName,
            1,
            episodeid,
            contentid,
          );
        } else {
          openBottomSheet(
            position,
            isAudioCoin,
            contentName,
            1,
            episodeid,
            contentid,
          );
        }
      } else {
        printLog("🎵 ✅ Episode is UNLOCKED - starting playback");
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
      }
    } else {
      if (kIsWeb) {
        Utils.buildWebAlertDialog(context, "login", "")
            .then((value) => getAllEpisode());
      } else {
        Utils.openLogin(context: context, isHome: false, isReplace: false);
      }
    }
  }

  openBottomSheet(
      int index, coins, episodeName, audioBookType, episodeID, contentID) {
    showModalBottomSheet(
        backgroundColor: black,
        enableDrag: true,
        isScrollControlled: true,
        context: context,
        isDismissible: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (context) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                SizedBox(
                  width: kIsWeb
                      ? MediaQuery.of(context).size.width * 0.3
                      : MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25)),
                    child: MyImage(
                      fit: BoxFit.cover,
                      imagePath: 'coinsBanner.png',
                      height: 120,
                      width: kIsWeb
                          ? MediaQuery.of(context).size.width * 0.3
                          : MediaQuery.of(context).size.width,
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Icon(
                      Icons.lock_open_rounded,
                      color: gray,
                      size: 40,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    MyText(
                      color: yellow,
                      text: episodeName.toString(),
                      textalign: TextAlign.start,
                      fontsizeNormal: 15,
                      fontsizeWeb: 14,
                      multilanguage: false,
                      fontweight: FontWeight.w600,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Consumer<SubscriptionProvider>(
                  builder: (context, subscriptionProvider, child) {
                    if (subscriptionProvider.loading) {
                      printLog("Shimmer Calling");
                      return Container();
                    } else {
                      if (subscriptionProvider.subscriptionModel.status ==
                              200 &&
                          subscriptionProvider.subscriptionModel.result !=
                              null) {
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: subscriptionProvider
                              .subscriptionModel.result?.length,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () async {
                                if ((userName ?? "").isEmpty ||
                                    (userEmail ?? "").isEmpty ||
                                    (userMobileNo ?? "").isEmpty) {
                                  await updateDataDialog(
                                    isNameReq: (userName ?? "").isEmpty,
                                    isEmailReq: (userEmail ?? "").isEmpty,
                                    isMobileReq: (userMobileNo ?? "").isEmpty,
                                  );
                                  return;
                                } else {
                                  if (kIsWeb) {
                                    await context.pushNamed(
                                      RoutesConstant.paymentPage,
                                      extra: {
                                        'paytype': 'Package',
                                        'itemid': subscriptionProvider
                                                .subscriptionModel
                                                .result?[index]
                                                .id
                                                .toString() ??
                                            '',
                                        'price': subscriptionProvider
                                                .subscriptionModel
                                                .result?[index]
                                                .price
                                                .toString() ??
                                            '',
                                        'title': subscriptionProvider
                                                .subscriptionModel
                                                .result?[index]
                                                .name
                                                .toString() ??
                                            '',
                                        "coins": subscriptionProvider
                                            .subscriptionModel
                                            .result?[index]
                                            .coin
                                            .toString(),
                                        'videotype': '',
                                        'typeid': '',
                                        'currency': '',
                                        'productpackage': (!kIsWeb)
                                            ? (Platform.isIOS
                                                ? (subscriptionProvider
                                                        .subscriptionModel
                                                        .result?[index]
                                                        .iosProductPackage
                                                        .toString() ??
                                                    '')
                                                : (subscriptionProvider
                                                        .subscriptionModel
                                                        .result?[index]
                                                        .androidProductPackage
                                                        .toString() ??
                                                    ''))
                                            : '',
                                      },
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation,
                                            secondaryAnimation) {
                                          return AllPayment(
                                            payType: 'Package',
                                            itemId: subscriptionProvider
                                                    .subscriptionModel
                                                    .result?[index]
                                                    .id
                                                    .toString() ??
                                                '',
                                            price: subscriptionProvider
                                                    .subscriptionModel
                                                    .result?[index]
                                                    .price
                                                    .toString() ??
                                                '',
                                            itemTitle: subscriptionProvider
                                                    .subscriptionModel
                                                    .result?[index]
                                                    .name
                                                    .toString() ??
                                                '',
                                            coin: subscriptionProvider
                                                    .subscriptionModel
                                                    .result?[index]
                                                    .coin
                                                    .toString() ??
                                                "",
                                            typeId: '',
                                            videoType: '',
                                            productPackage: (!kIsWeb)
                                                ? (Platform.isIOS
                                                    ? (subscriptionProvider
                                                            .subscriptionModel
                                                            .result?[index]
                                                            .iosProductPackage
                                                            .toString() ??
                                                        '')
                                                    : (subscriptionProvider
                                                            .subscriptionModel
                                                            .result?[index]
                                                            .androidProductPackage
                                                            .toString() ??
                                                        ''))
                                                : '',
                                            currency: '',
                                          );
                                        },
                                        transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) {
                                          return child;
                                        },
                                      ),
                                    );
                                  }
                                }
                              },
                              child: Card(
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                elevation: 3,
                                color: colorPrimaryDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  color: grayDark,
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.only(
                                      left: 18, right: 18),
                                  constraints:
                                      const BoxConstraints(minHeight: 55),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: MyText(
                                          color: white,
                                          text: subscriptionProvider
                                                  .subscriptionModel
                                                  .result?[index]
                                                  .name ??
                                              "",
                                          textalign: TextAlign.start,
                                          fontsizeNormal: 15,
                                          fontsizeWeb: 24,
                                          maxline: 1,
                                          multilanguage: false,
                                          overflow: TextOverflow.ellipsis,
                                          fontweight: FontWeight.w600,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      MyText(
                                        color: white,
                                        text:
                                            "${Constant.currencySymbol} ${subscriptionProvider.subscriptionModel.result?[index].price.toString()} ",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: 14,
                                        fontsizeWeb: 22,
                                        maxline: 1,
                                        multilanguage: false,
                                        overflow: TextOverflow.ellipsis,
                                        fontweight: FontWeight.w500,
                                        fontstyle: FontStyle.normal,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }
                  },
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: gray,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                              color: black,
                              text: "Need To Unlock",
                              textalign: TextAlign.start,
                              fontsizeNormal: 15,
                              fontsizeWeb: 14,
                              multilanguage: false,
                              fontweight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                MyImage(
                                  imagePath: 'coin.png',
                                  height: 18,
                                  width: 18,
                                ),
                                MyText(
                                  color: black,
                                  text: "${coins.toString()} Coins",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 15,
                                  fontsizeWeb: 14,
                                  multilanguage: false,
                                  fontweight: FontWeight.w600,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const VerticalDivider(
                        width: 5,
                        thickness: 1,
                        indent: 15,
                        endIndent: 15,
                        color: black,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                              color: black,
                              text: "Current Balance",
                              textalign: TextAlign.start,
                              fontsizeNormal: 15,
                              fontsizeWeb: 14,
                              multilanguage: false,
                              fontweight: FontWeight.w600,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                MyImage(
                                  imagePath: 'coin.png',
                                  height: 18,
                                  width: 18,
                                ),
                                MyText(
                                  color: black,
                                  text:
                                      "${profileProvider.profileModel.result?[0].walletCoin.toString() ?? ""} Coins",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 15,
                                  fontsizeWeb: 14,
                                  multilanguage: false,
                                  fontweight: FontWeight.w600,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          debugPrint("=== BUY EPISODE CLICKED ===");
                          debugPrint("Episode ID: $episodeID");
                          debugPrint("Content ID: $contentID");
                          debugPrint("Coins required: $coins (type: ${coins.runtimeType})");
                          debugPrint("User wallet coins: ${profileProvider.profileModel.result?[0].walletCoin}");
                          
                          // Convert coins to int for proper comparison 
                          int requiredCoins = coins is int ? coins : int.tryParse(coins.toString()) ?? 0;
                          int userCoins = profileProvider.profileModel.result?[0].walletCoin ?? 0;
                          
                          debugPrint("Required coins (int): $requiredCoins, User coins (int): $userCoins");
                          
                          if (userCoins >= requiredCoins) {
                            final episodebuyprovider =
                                Provider.of<ShowDetailsProvider>(context,
                                    listen: false);
                            Utils.showProgress(context, prDialog);
                            
                            debugPrint("=== CALLING API TO BUY EPISODE ===");
                            await episodebuyprovider.getEpisodeBuy(
                                1, episodeID, audioBookType, contentID, coins);
                            
                            debugPrint("=== API RESPONSE: ${episodebuyprovider.episodeBuyModel.status} ===");
                            
                            if (episodebuyprovider.episodeBuyModel.status ==
                                200) {
                              Utils.showToast(successfullbuy);

                              if (!context.mounted) return;
                              Utils().hideProgress(context);

                              if (kIsWeb) {
                                if (context.canPop()) {
                                  context.pop();
                                }
                              } else {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              }
                              
                              debugPrint("=== UPDATING LOCAL DATA ===");
                              
                              // Update BOTH providers - critical for immediate playback!
                              episodeProvider.updateAudioEpisodeBuyStatus(episodeID);
                              
                              // 🔓 Also update MusicDetailProvider for lock check
                              final musicDetailProvider = Provider.of<MusicDetailProvider>(context, listen: false);
                              musicDetailProvider.updateAudioEpisodeBuyStatus(episodeID);
                              
                              // Refresh profile to update coin balance
                              debugPrint("=== REFRESHING PROFILE ===");
                              await profileProvider.getProfile(context);
                              
                              debugPrint("=== PURCHASE COMPLETE ===");
                            } else {
                              debugPrint("=== PURCHASE FAILED ===");
                              Utils.showToast(somethingwentwrong);
                              if (!context.mounted) return;
                              Utils().hideProgress(context);
                            }
                          } else {
                            debugPrint("=== INSUFFICIENT COINS ===");
                            Utils.showToast(addcoin);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(10),
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: lightGreen,
                              borderRadius: BorderRadius.circular(10)),
                          child: MyText(
                            color: white,
                            text: "buythisepisode",
                            textalign: TextAlign.start,
                            fontsizeNormal: 14,
                            fontsizeWeb: 14,
                            multilanguage: true,
                            fontweight: FontWeight.w600,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                          if (kIsWeb) {
                            context
                                .pushNamed(
                              RoutesConstant.subscriptionPage,
                              extra: "",
                            )
                                .then(
                              (value) {
                                getAllEpisode();
                              },
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const Subscription();
                                },
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.all(10),
                          height: 60,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: lightGreen,
                              borderRadius: BorderRadius.circular(10)),
                          child: MyText(
                            color: white,
                            text: "getmorecoin",
                            textalign: TextAlign.start,
                            fontsizeNormal: 15,
                            fontsizeWeb: 14,
                            multilanguage: true,
                            fontweight: FontWeight.w600,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  openSubscriptionDialog(
      int index, coins, episodeName, audioBookType, episodeID, contentID) {
    return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              insetPadding: const EdgeInsets.fromLTRB(100, 25, 100, 25),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              backgroundColor: colorPrimaryDark,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () {
                            if (kIsWeb) {
                              if (context.canPop()) {
                                context.pop();
                              }
                            } else {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            height: 30,
                            width: 30,
                            // padding: const EdgeInsets.all(8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: white),
                            child: Utils().closeBtn(colorPrimaryDark, 18),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: kIsWeb
                            ? MediaQuery.of(context).size.width * 0.3
                            : MediaQuery.of(context).size.width,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(25),
                              topRight: Radius.circular(25)),
                          child: MyImage(
                            fit: BoxFit.cover,
                            imagePath: 'coinsBanner.png',
                            height: 120,
                            width: kIsWeb
                                ? MediaQuery.of(context).size.width * 0.3
                                : MediaQuery.of(context).size.width,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Icon(
                            Icons.lock_open_rounded,
                            color: gray,
                            size: 40,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          MyText(
                            color: yellow,
                            text: episodeName.toString(),
                            textalign: TextAlign.start,
                            fontsizeNormal: 15,
                            fontsizeWeb: 14,
                            multilanguage: false,
                            fontweight: FontWeight.w600,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Consumer<SubscriptionProvider>(
                        builder: (context, subscriptionProvider, child) {
                          if (subscriptionProvider.loading) {
                            printLog("Shimmer Calling");
                            return Container();
                          } else {
                            if (subscriptionProvider.subscriptionModel.status ==
                                    200 &&
                                subscriptionProvider.subscriptionModel.result !=
                                    null) {
                              return ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: subscriptionProvider
                                    .subscriptionModel.result?.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () async {
                                      if ((userName ?? "").isEmpty ||
                                          (userEmail ?? "").isEmpty ||
                                          (userMobileNo ?? "").isEmpty) {
                                        await updateDataDialog(
                                          isNameReq: (userName ?? "").isEmpty,
                                          isEmailReq: (userEmail ?? "").isEmpty,
                                          isMobileReq:
                                              (userMobileNo ?? "").isEmpty,
                                        );
                                        return;
                                      } else {
                                        if (kIsWeb) {
                                          await context.pushNamed(
                                            RoutesConstant.paymentPage,
                                            extra: {
                                              'paytype': 'Package',
                                              'itemid': subscriptionProvider
                                                      .subscriptionModel
                                                      .result?[index]
                                                      .id
                                                      .toString() ??
                                                  '',
                                              'price': subscriptionProvider
                                                      .subscriptionModel
                                                      .result?[index]
                                                      .price
                                                      .toString() ??
                                                  '',
                                              'title': subscriptionProvider
                                                      .subscriptionModel
                                                      .result?[index]
                                                      .name
                                                      .toString() ??
                                                  '',
                                              "coins": subscriptionProvider
                                                  .subscriptionModel
                                                  .result?[index]
                                                  .coin
                                                  .toString(),
                                              'videotype': '',
                                              'typeid': '',
                                              'currency': '',
                                              'productpackage': (!kIsWeb)
                                                  ? (Platform.isIOS
                                                      ? (subscriptionProvider
                                                              .subscriptionModel
                                                              .result?[index]
                                                              .iosProductPackage
                                                              .toString() ??
                                                          '')
                                                      : (subscriptionProvider
                                                              .subscriptionModel
                                                              .result?[index]
                                                              .androidProductPackage
                                                              .toString() ??
                                                          ''))
                                                  : '',
                                            },
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                  secondaryAnimation) {
                                                return AllPayment(
                                                  payType: 'Package',
                                                  itemId: subscriptionProvider
                                                          .subscriptionModel
                                                          .result?[index]
                                                          .id
                                                          .toString() ??
                                                      '',
                                                  price: subscriptionProvider
                                                          .subscriptionModel
                                                          .result?[index]
                                                          .price
                                                          .toString() ??
                                                      '',
                                                  itemTitle:
                                                      subscriptionProvider
                                                              .subscriptionModel
                                                              .result?[index]
                                                              .name
                                                              .toString() ??
                                                          '',
                                                  coin: subscriptionProvider
                                                          .subscriptionModel
                                                          .result?[index]
                                                          .coin
                                                          .toString() ??
                                                      "",
                                                  typeId: '',
                                                  videoType: '',
                                                  productPackage: (!kIsWeb)
                                                      ? (Platform.isIOS
                                                          ? (subscriptionProvider
                                                                  .subscriptionModel
                                                                  .result?[
                                                                      index]
                                                                  .iosProductPackage
                                                                  .toString() ??
                                                              '')
                                                          : (subscriptionProvider
                                                                  .subscriptionModel
                                                                  .result?[
                                                                      index]
                                                                  .androidProductPackage
                                                                  .toString() ??
                                                              ''))
                                                      : '',
                                                  currency: '',
                                                );
                                              },
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                return child;
                                              },
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Card(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      elevation: 3,
                                      color: colorPrimaryDark,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Container(
                                        color: grayDark,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.only(
                                            left: 18, right: 18),
                                        constraints:
                                            const BoxConstraints(minHeight: 55),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: MyText(
                                                color: white,
                                                text: subscriptionProvider
                                                        .subscriptionModel
                                                        .result?[index]
                                                        .name ??
                                                    "",
                                                textalign: TextAlign.start,
                                                fontsizeNormal: 15,
                                                fontsizeWeb: 18,
                                                maxline: 1,
                                                multilanguage: false,
                                                overflow: TextOverflow.ellipsis,
                                                fontweight: FontWeight.w600,
                                                fontstyle: FontStyle.normal,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            MyText(
                                              color: white,
                                              text:
                                                  "${Constant.currencySymbol} ${subscriptionProvider.subscriptionModel.result?[index].price.toString()} ",
                                              textalign: TextAlign.center,
                                              fontsizeNormal: 14,
                                              fontsizeWeb: 16,
                                              maxline: 1,
                                              multilanguage: false,
                                              overflow: TextOverflow.ellipsis,
                                              fontweight: FontWeight.w500,
                                              fontstyle: FontStyle.normal,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          }
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.all(10),
                        alignment: Alignment.center,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: gray,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyText(
                                    color: black,
                                    text: "Need To Unlock",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: 15,
                                    fontsizeWeb: 14,
                                    multilanguage: false,
                                    fontweight: FontWeight.w600,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      MyImage(
                                        imagePath: 'coin.png',
                                        height: 18,
                                        width: 18,
                                      ),
                                      MyText(
                                        color: black,
                                        text: "${coins.toString()} Coins",
                                        textalign: TextAlign.start,
                                        fontsizeNormal: 15,
                                        fontsizeWeb: 14,
                                        multilanguage: false,
                                        fontweight: FontWeight.w600,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const VerticalDivider(
                              width: 5,
                              thickness: 1,
                              indent: 15,
                              endIndent: 15,
                              color: black,
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  MyText(
                                    color: black,
                                    text: "Current Balance",
                                    textalign: TextAlign.start,
                                    fontsizeNormal: 15,
                                    fontsizeWeb: 14,
                                    multilanguage: false,
                                    fontweight: FontWeight.w600,
                                    maxline: 1,
                                    overflow: TextOverflow.ellipsis,
                                    fontstyle: FontStyle.normal,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      MyImage(
                                        imagePath: 'coin.png',
                                        height: 18,
                                        width: 18,
                                      ),
                                      MyText(
                                        color: black,
                                        text:
                                            "${profileProvider.profileModel.result?[0].walletCoin.toString() ?? ""} Coins",
                                        textalign: TextAlign.start,
                                        fontsizeNormal: 15,
                                        fontsizeWeb: 14,
                                        multilanguage: false,
                                        fontweight: FontWeight.w600,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                debugPrint("=== BUY EPISODE CLICKED (WEB) ===");
                                debugPrint("Episode ID: $episodeID");
                                debugPrint("Content ID: $contentID");
                                debugPrint("Coins required: $coins (type: ${coins.runtimeType})");
                                debugPrint("User wallet coins: ${profileProvider.profileModel.result?[0].walletCoin}");
                                
                                // Convert coins to int for proper comparison
                                int requiredCoins = coins is int ? coins : int.tryParse(coins.toString()) ?? 0;
                                int userCoins = profileProvider.profileModel.result?[0].walletCoin ?? 0;
                                
                                debugPrint("Required coins (int): $requiredCoins, User coins (int): $userCoins");
                                
                                if (userCoins >= requiredCoins) {
                                  final episodebuyprovider =
                                      Provider.of<ShowDetailsProvider>(context,
                                          listen: false);
                                  Utils.showProgress(context, prDialog);
                                  
                                  debugPrint("=== CALLING API TO BUY EPISODE ===");
                                  await episodebuyprovider.getEpisodeBuy(
                                      1,
                                      episodeID,
                                      audioBookType,
                                      contentID,
                                      coins);
                                  
                                  debugPrint("=== API RESPONSE: ${episodebuyprovider.episodeBuyModel.status} ===");
                                  
                                  if (episodebuyprovider
                                          .episodeBuyModel.status ==
                                      200) {
                                    Utils.showToast(successfullbuy);

                                    if (!context.mounted) return;
                                    Utils().hideProgress(context);

                                    if (kIsWeb) {
                                      if (context.canPop()) {
                                        context.pop();
                                      }
                                    } else {
                                      if (Navigator.canPop(context)) {
                                        Navigator.pop(context);
                                      }
                                    }
                                    
                                    debugPrint("=== UPDATING LOCAL DATA ===");
                                    
                                    // Update BOTH providers - critical for immediate playback!
                                    episodeProvider.updateAudioEpisodeBuyStatus(episodeID);
                                    
                                    // 🔓 Also update MusicDetailProvider for lock check
                                    final musicDetailProvider = Provider.of<MusicDetailProvider>(context, listen: false);
                                    musicDetailProvider.updateAudioEpisodeBuyStatus(episodeID);
                                    
                                    // Refresh profile to update coin balance
                                    debugPrint("=== REFRESHING PROFILE ===");
                                    await profileProvider.getProfile(context);
                                    
                                    debugPrint("=== PURCHASE COMPLETE ===");
                                  } else {
                                    debugPrint("=== PURCHASE FAILED ===");
                                    Utils.showToast(somethingwentwrong);
                                    if (!context.mounted) return;
                                    Utils().hideProgress(context);
                                  }
                                } else {
                                  debugPrint("=== INSUFFICIENT COINS ===");
                                  Utils.showToast(addcoin);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.all(10),
                                height: 60,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: lightGreen,
                                    borderRadius: BorderRadius.circular(10)),
                                child: MyText(
                                  color: white,
                                  text: "buythisepisode",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 14,
                                  fontsizeWeb: 14,
                                  multilanguage: true,
                                  fontweight: FontWeight.w600,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                if (kIsWeb) {
                                  context
                                      .pushNamed(
                                    RoutesConstant.subscriptionPage,
                                    extra: "",
                                  )
                                      .then(
                                    (value) {
                                      getAllEpisode();
                                    },
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const Subscription();
                                      },
                                    ),
                                  ).then(
                                    (value) {
                                      getAllEpisode();
                                    },
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.all(10),
                                height: 60,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: lightGreen,
                                    borderRadius: BorderRadius.circular(10)),
                                child: MyText(
                                  color: white,
                                  text: "getmorecoin",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 15,
                                  fontsizeWeb: 14,
                                  multilanguage: true,
                                  fontweight: FontWeight.w600,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ));
        });
  }

  /* ========= Download ========= */
  Widget _buildDownloadWithSubCheck(index) {
    if ((episodeProvider.audioList?[index].isAudioPaid ?? 0) == 1) {
      if ((episodeProvider.audioList?[index].isBuy ?? 0) == 1) {
        return _buildDownloadBtn(index);
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return _buildDownloadBtn(index);
    }
  }

  // Widget _buildDownloadBtn(index) {
  //   return Consumer<DownLoadProvider>(
  //     builder: (context, downloadProvider, child) {
  //       bool isInDownload = false;
  //       if (!kIsWeb) {
  //         if (downloadBox.isOpen &&
  //             downloadBox.values.toList().isNotEmpty &&
  //             (downloadBox.values.toList().indexWhere((downloadItem) {
  //                   return (downloadItem.id ==
  //                           episodeProvider.audioList?[index].id &&
  //                       downloadItem.audioType ==
  //                           episodeProvider.audioList?[index].audioType);
  //                 })) !=
  //                 -1) {
  //           List<DownloadEpisodeItem> myDownloadList =
  //               downloadBox.values.where((downloadItem) {
  //             return (downloadItem.id == episodeProvider.audioList?[index].id &&
  //                 downloadItem.audioType ==
  //                     episodeProvider.audioList?[index].audioType);
  //           }).toList();
  //           printLog(
  //               "_buildDownloadBtn myDownloadList ====> ${myDownloadList.length}");
  //           if (myDownloadList.isNotEmpty) {
  //             isInDownload = (myDownloadList[0].isDownload == 1);
  //             printLog("_buildDownloadBtn isInDownload ======> $isInDownload");
  //           }
  //         }
  //       }
  //       return Container(
  //         alignment: Alignment.center,
  //         constraints:
  //             BoxConstraints(minWidth: (Dimens.featureSize + 25 /* Margin */)),
  //         child: InkWell(
  //           borderRadius: BorderRadius.circular(5),
  //           focusColor: gray.withOpacity(0.5),
  //           onTap: () async {
  //             if (Constant.userID != null) {
  //               if (!isInDownload) {
  //                 if ((downloadProvider.dProgress == 0 ||
  //                         downloadProvider.dProgress == -1) &&
  //                     !downloadProvider.loading &&
  //                     (downloadProvider.itemId == null ||
  //                         downloadProvider.itemId == 0)) {
  //                   // Navigator.push(
  //                   //     context,
  //                   //     MaterialPageRoute(
  //                   //         builder: (context) => const MyDownloads()));
  //                   _checkAndDownload(index);
  //                 } else {
  //                   Utils.showSnackbar(context, "info", "please_wait", true);
  //                 }
  //               } else {
  //                 // buildDownloadCompleteDialog();
  //               }
  //             } else {
  //               Utils.openLogin(
  //                   context: context, isHome: false, isReplace: false);
  //               // _getData();
  //             }
  //           },
  //           child: Container(
  //             padding: const EdgeInsets.all(5.0),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 if (downloadProvider.dProgress != 0 &&
  //                     downloadProvider.dProgress > 0 &&
  //                     downloadProvider.dProgress < 100 &&
  //                     !isInDownload &&
  //                     downloadProvider.itemId ==
  //                         episodeProvider.audioList?[index].id)
  //                   Container(
  //                     alignment: Alignment.center,
  //                     child: CircularPercentIndicator(
  //                       radius: (Dimens.featureIconSize / 2),
  //                       lineWidth: 2.0,
  //                       percent: (downloadProvider.dProgress / 100).toDouble(),
  //                       progressColor: colorAccent,
  //                     ),
  //                   )
  //                 else
  //                   Container(
  //                     alignment: Alignment.center,
  //                     child: MyImage(
  //                       width: Dimens.featureIconSize,
  //                       height: Dimens.featureIconSize,
  //                       color: white,
  //                       imagePath: isInDownload
  //                           ? "ic_download_done.png"
  //                           : "ic_download.png",
  //                     ),
  //                   ),
  //                 const SizedBox(height: 10),
  //                 if (downloadProvider.dProgress != 0 &&
  //                     downloadProvider.dProgress > 0 &&
  //                     downloadProvider.dProgress < 100 &&
  //                     !isInDownload &&
  //                     downloadProvider.itemId ==
  //                         episodeProvider.audioList?[index].id)
  //                   MyText(
  //                     color: gray,
  //                     text: "${downloadProvider.dProgress}%",
  //                     multilanguage: false,
  //                     fontsizeNormal: 10,
  //                     fontweight: FontWeight.w600,
  //                     fontsizeWeb: 14,
  //                     maxline: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                     textalign: TextAlign.center,
  //                     fontstyle: FontStyle.normal,
  //                   )
  //                 else
  //                   MyText(
  //                     color: gray,
  //                     text: isInDownload ? "complete" : "download",
  //                     multilanguage: true,
  //                     fontsizeNormal: 10,
  //                     fontweight: FontWeight.w600,
  //                     fontsizeWeb: 14,
  //                     maxline: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                     textalign: TextAlign.center,
  //                     fontstyle: FontStyle.normal,
  //                   ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildDownloadBtn(int index) {
    return Consumer<DownLoadProvider>(
      builder: (context, downloadProvider, child) {
        bool isInDownload = false;

        // Determine if the item is currently in the download list
        if (!kIsWeb) {
          if (downloadBox.isOpen &&
              downloadBox.values.isNotEmpty &&
              downloadBox.values.toList().any((downloadItem) {
                return downloadItem.id ==
                        episodeProvider.audioList?[index].id &&
                    downloadItem.audioType ==
                        episodeProvider.audioList?[index].audioType;
              })) {
            List<DownloadEpisodeItem> myDownloadList =
                downloadBox.values.where((downloadItem) {
              return downloadItem.id == episodeProvider.audioList?[index].id &&
                  downloadItem.audioType ==
                      episodeProvider.audioList?[index].audioType;
            }).toList();
            if (myDownloadList.isNotEmpty) {
              isInDownload = (myDownloadList[0].isDownload == 1);
            }
          }
        }

        // Button UI
        return Container(
          alignment: Alignment.center,
          // constraints: BoxConstraints(minWidth: (Dimens.featureSize + 25)),
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            focusColor: gray.withOpacity(0.5),
            onTap: () async {
              if (Constant.userID != null) {
                if (!isInDownload) {
                  if ((downloadProvider.dProgress == 0 ||
                          downloadProvider.dProgress == -1) &&
                      !downloadProvider.loading &&
                      (downloadProvider.itemId == null ||
                          downloadProvider.itemId == 0)) {
                    _checkAndDownload(index);
                  } else {
                    Utils.showSnackbar(context, "info", "please_wait", true);
                  }
                } else {
                  // buildDownloadCompleteDialog();
                }
              } else {
                Utils.openLogin(
                    context: context, isHome: false, isReplace: false);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Progress Indicator
                if (downloadProvider.dProgress > 0 &&
                    downloadProvider.dProgress < 100 &&
                    downloadProvider.itemId ==
                        episodeProvider.audioList?[index].id)
                  CircularPercentIndicator(
                    radius: (Dimens.featureIconSize / 2),
                    lineWidth: 2.0,
                    percent: (downloadProvider.dProgress / 100).toDouble(),
                    progressColor: colorAccent,
                  )
                else
                  MyImage(
                    width: Dimens.featureIconSize,
                    height: Dimens.featureIconSize,
                    color: white,
                    imagePath: isInDownload
                        ? "ic_download_done.png"
                        : "ic_download.png",
                  ),
                const SizedBox(height: 2),
                // Status Text
                MyText(
                  color: gray,
                  text: downloadProvider.dProgress > 0 &&
                          downloadProvider.dProgress < 100 &&
                          downloadProvider.itemId ==
                              episodeProvider.audioList?[index].id
                      ? "${downloadProvider.dProgress}%"
                      : isInDownload
                          ? Locales.string(context, "complete")
                          : Locales.string(context, "download"),
                  multilanguage: false,
                  fontsizeNormal: 10,
                  fontweight: FontWeight.w600,
                  fontsizeWeb: 14,
                  maxline: 2,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.center,
                  fontstyle: FontStyle.normal,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // buildDownloadCompleteDialog() {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: colorPrimaryDark,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
  //     ),
  //     clipBehavior: Clip.antiAliasWithSaveLayer,
  //     builder: (BuildContext context) {
  //       return Wrap(
  //         children: <Widget>[
  //           Container(
  //             padding: const EdgeInsets.all(23),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.start,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: <Widget>[
  //                 MyText(
  //                   text: "download_options",
  //                   multilanguage: true,
  //                   fontsizeNormal: 16,
  //                   color: white,
  //                   fontstyle: FontStyle.normal,
  //                   fontweight: FontWeight.w700,
  //                   maxline: 2,
  //                   overflow: TextOverflow.ellipsis,
  //                   textalign: TextAlign.start,
  //                 ),
  //                 const SizedBox(height: 5),
  //                 MyText(
  //                   text: "download_options_note",
  //                   multilanguage: true,
  //                   fontsizeNormal: 10,
  //                   color: gray,
  //                   fontstyle: FontStyle.normal,
  //                   fontweight: FontWeight.w500,
  //                   maxline: 5,
  //                   overflow: TextOverflow.ellipsis,
  //                   textalign: TextAlign.start,
  //                 ),
  //                 const SizedBox(height: 12),

  //                 /* To Download */
  //                 InkWell(
  //                   borderRadius: BorderRadius.circular(5),
  //                   focusColor: white,
  //                   onTap: () async {
  //                     if (Navigator.canPop(context)) {
  //                       Navigator.pop(context);
  //                     }
  //                     if (Constant.userID != null) {
  //                       // await Navigator.of(context).push(
  //                       //   MaterialPageRoute(
  //                       //     builder: (context) =>
  //                       //         const MyDownloads(viewFrom: ''),
  //                       //   ),
  //                       // );
  //                       setState(() {});
  //                     } else {
  //                       Utils.openLogin(
  //                           context: context, isHome: false, isReplace: false);
  //                       // _getData();
  //                     }
  //                   },
  //                   child: Container(
  //                     height: Dimens.minHtDialogContent,
  //                     padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
  //                     child: Row(
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       children: [
  //                         MyImage(
  //                           width: Dimens.dialogIconSize,
  //                           height: Dimens.dialogIconSize,
  //                           imagePath: "ic_setting.png",
  //                           fit: BoxFit.fill,
  //                           color: gray,
  //                         ),
  //                         const SizedBox(width: 20),
  //                         Expanded(
  //                           child: MyText(
  //                             text: "take_me_to_the_downloads_page",
  //                             multilanguage: true,
  //                             fontsizeNormal: 14,
  //                             color: white,
  //                             fontstyle: FontStyle.normal,
  //                             fontweight: FontWeight.w600,
  //                             maxline: 1,
  //                             overflow: TextOverflow.ellipsis,
  //                             textalign: TextAlign.start,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),

  //                 /* Delete */
  //                 InkWell(
  //                   borderRadius: BorderRadius.circular(5),
  //                   focusColor: white,
  //                   onTap: () async {
  //                     if (Navigator.canPop(context)) {
  //                       Navigator.pop(context);
  //                     }
  //                     await episodeProvider.addRemoveDownload(
  //                         context,
  //                         videoDetailsProvider.contentDetailModel.result?[0].id,
  //                         videoDetailsProvider
  //                             .contentDetailModel.result?[0].videoType,
  //                         videoDetailsProvider
  //                             .contentDetailModel.result?[0].subVideoType);
  //                   },
  //                   child: Container(
  //                     height: Dimens.minHtDialogContent,
  //                     padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
  //                     child: Row(
  //                       crossAxisAlignment: CrossAxisAlignment.center,
  //                       mainAxisAlignment: MainAxisAlignment.start,
  //                       children: [
  //                         MyImage(
  //                           width: Dimens.dialogIconSize,
  //                           height: Dimens.dialogIconSize,
  //                           imagePath: "ic_delete.png",
  //                           fit: BoxFit.fill,
  //                           color: gray,
  //                         ),
  //                         const SizedBox(width: 20),
  //                         Expanded(
  //                           child: MyText(
  //                             text: "delete_download",
  //                             multilanguage: true,
  //                             fontsizeNormal: 14,
  //                             color: white,
  //                             fontstyle: FontStyle.normal,
  //                             fontweight: FontWeight.w600,
  //                             maxline: 1,
  //                             overflow: TextOverflow.ellipsis,
  //                             textalign: TextAlign.start,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget audioShimmer() {
    return ListView.separated(
        shrinkWrap: true,
        itemCount: 3,
        padding: const EdgeInsets.all(10),
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 10,
          );
        },
        itemBuilder: (context, index) {
          return ShimmerWidget.roundrectborder(
            height: 80,
            width: MediaQuery.of(context).size.width,
          );
        });
  }
}
