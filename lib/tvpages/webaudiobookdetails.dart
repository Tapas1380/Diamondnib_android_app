import 'dart:convert';
import 'dart:io';

import 'package:diamondnib/pages/loginsocial.dart';
import 'package:diamondnib/pages/musicdetails.dart';
import 'package:diamondnib/provider/profileprovider.dart';
import 'package:diamondnib/provider/subscriptionprovider.dart';
import 'package:diamondnib/routes/routes_constant.dart';
import 'package:diamondnib/shimmer/shimmerutils.dart';
import 'package:diamondnib/subscription/allpayment.dart';
import 'package:diamondnib/utils/dimens.dart';
import 'package:diamondnib/utils/sharedpre.dart';
import 'package:diamondnib/webwidget/footerweb.dart';
import 'package:diamondnib/widget/episodebyseason.dart';
import 'package:diamondnib/widget/moredetails.dart';
import 'package:diamondnib/widget/nodata.dart';
import 'package:diamondnib/provider/episodeprovider.dart';
import 'package:diamondnib/provider/showdetailsprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/widget/myimage.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:diamondnib/utils/strings.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/mynetworkimg.dart';
import 'package:diamondnib/widget/videoepisodebycontent.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:social_share/social_share.dart';

import '../model/episodebycontentmodel.dart';

class WebAudioBookDetails extends StatefulWidget {
  final int contentId, contentType;
  const WebAudioBookDetails(this.contentId, this.contentType, {super.key});

  @override
  State<WebAudioBookDetails> createState() => WebAudioBookDetailsState();
}

class WebAudioBookDetailsState extends State<WebAudioBookDetails> {
  String? audioLanguages;
  // List<Cast>? directorList;
  late ShowDetailsProvider showDetailsProvider;
  late EpisodeProvider episodeProvider;
  late ScrollController _scrollController;
  double? ratingGiven;
  final commentController = TextEditingController();
  late ProfileProvider profileProvider;
  String? userName, userEmail, userMobileNo;
  SharedPre sharedPre = SharedPre();
  late ProgressDialog prDialog;
  @override
  void initState() {
    prDialog = ProgressDialog(context);
    showDetailsProvider =
        Provider.of<ShowDetailsProvider>(context, listen: false);
    episodeProvider = Provider.of<EpisodeProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    printLog("initState videoId ==> ${widget.contentId}");
    printLog("initState videoType ==> ${widget.contentType}");
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDetailsProvider.setLoading(true);
      episodeProvider.setLoading(true);
      _getData();
    });
    super.initState();
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  bool checkIsBuyOrNot() {
    // Iterate through the audioList
    for (var item in episodeProvider.audioList ?? []) {
      // Check if isBuy is true
      if (item.isBuy == 1) {
        episodeProvider.checkIsBuy(true);
        return true;
      } else {
        episodeProvider.checkIsBuy(false);
      }
    }
    return false;
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      printLog("AudioData Scroll Listner");
      if (showDetailsProvider.tabClickedOn == "episodes") {
        if ((episodeProvider.audiocurrentPage ?? 0) <
            (episodeProvider.audiototalPage ?? 0)) {
          episodeProvider.setLoadMore(true);
          await _fetchDataAudio((episodeProvider.audiocurrentPage ?? 0));
        }
      } else if (showDetailsProvider.tabClickedOn == "details") {
        if ((showDetailsProvider.currentPage ?? 0) <
            (showDetailsProvider.totalPage ?? 0)) {
          showDetailsProvider.setLoadMore(true);
          await fetchComments((showDetailsProvider.currentPage ?? 0));
        }
      } else {
        if ((episodeProvider.currentPage ?? 0) <
            (episodeProvider.totalPage ?? 0)) {
          await episodeProvider.videosetLoadMore(true);
          await _fetchDataVideo((episodeProvider.currentPage ?? 0));
        }
      }
    }
  }

  _fetchDataAudio(int? nextPage) {
    episodeProvider.getAudioByContent(widget.contentId, (nextPage ?? 0) + 1);
    if (nextPage == 0) {
      checkIsBuyOrNot();
    }
  }

  fetchComments(int? nextPage) {
    showDetailsProvider.getReviews(
        widget.contentId, widget.contentType, (nextPage ?? 0) + 1);
  }

  _fetchDataVideo(int? nextPage) {
    episodeProvider.getVideoByContent(widget.contentId, (nextPage ?? 0) + 1);
  }

  Future<void> _getData() async {
    Utils.getCurrencySymbol();
    profileProvider.getProfile(context);
    showDetailsProvider.getContentDetails(
      widget.contentId,
      widget.contentType,
    );
    _fetchDataAudio(0);
    _fetchDataVideo(0);
    fetchComments(0);
    _getUserData();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {
        printLog(
            "setState videoId ======================> ${widget.contentId}");
      });
    });
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
    showDetailsProvider.clearProvider();
    episodeProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        key: widget.key,
        backgroundColor: colorPrimary,
        body: SafeArea(
          child: Consumer<ShowDetailsProvider>(
            builder: (BuildContext context, ShowDetailsProvider value,
                Widget? child) {
              return _buildUIWithAppBar();
            },
          ),
        ),
      ),
      Utils.buildMusicPanel(context),
    ]);
  }

  Widget _buildUIWithAppBar() {
    if (showDetailsProvider.detailsLoading &&
        episodeProvider.loadmore == false) {
      return SingleChildScrollView(
        child: ((kIsWeb || Constant.isTV) &&
                MediaQuery.of(context).size.width > 720)
            ? ShimmerUtils.buildDetailWebShimmer(context, "video")
            : ShimmerUtils.buildDetailMobileShimmer(context, "video"),
      );
    } else {
      if (showDetailsProvider.contentdetailsModel.status == 200 &&
          showDetailsProvider.contentdetailsModel.result != null) {
        if ((kIsWeb || Constant.isTV) &&
            MediaQuery.of(context).size.width > 720) {
          return _buildWebData();
        } else {
          return _buildMobileData();
        }
      } else {
        return const NoData(title: 'nodata', subTitle: '');
      }
    }
  }

  Widget _buildWebData() {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              /* Poster */
              Container(
                constraints: BoxConstraints(
                  minHeight: Dimens.detailWebPoster,
                  minWidth: MediaQuery.of(context).size.width,
                ),
                child: Column(
                  children: [
                    /* Poster */
                    Container(
                      padding: const EdgeInsets.all(0),
                      height: Dimens.detailWebPoster,
                      width: MediaQuery.of(context).size.width,
                      child: Stack(children: [
                        MyNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: (showDetailsProvider.contentdetailsModel
                                          .result?[0].webBannerImg ??
                                      "")
                                  .isEmpty
                              ? (showDetailsProvider.contentdetailsModel
                                      .result?[0].landscapeImg
                                      .toString() ??
                                  "")
                              : (showDetailsProvider.contentdetailsModel
                                      .result?[0].webBannerImg
                                      .toString() ??
                                  ""),
                        ),
                        Container(
                          height: Dimens.detailWebPoster,
                          width: MediaQuery.of(context).size.width,
                          color: black.withOpacity(0.65),
                        ),
                        Positioned(
                          top: 25,
                          left: 25,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                            child: InkWell(
                              autofocus: true,
                              focusColor: gray.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(25),
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
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.all(8),
                                child: Utils().backBtn(18, 18, 12),
                              ),
                            ),
                          ),
                        ),
                        /* Included Features buttons */
                        Positioned.fill(
                          bottom: 30,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: InkWell(
                              onTap: () {
                                playAudio(
                                  playingType: showDetailsProvider
                                          .contentdetailsModel
                                          .result?[0]
                                          .contentType
                                          .toString() ??
                                      "",
                                  episodeid: episodeProvider
                                          .audiobycontentmodel.result?[0].id
                                          .toString() ??
                                      "",
                                  contentid: episodeProvider.audiobycontentmodel
                                          .result?[0].contentId
                                          .toString() ??
                                      "",
                                  position: 0,
                                  sectionBannerList: episodeProvider
                                          .audiobycontentmodel.result ??
                                      [],
                                  contentName: episodeProvider
                                          .audiobycontentmodel.result?[0].name
                                          .toString() ??
                                      "",
                                  isBuy: episodeProvider
                                          .audiobycontentmodel.result?[0].isBuy
                                          .toString() ??
                                      "",
                                  isAudioPaid: episodeProvider
                                      .audiobycontentmodel
                                      .result?[0]
                                      .isAudioPaid,
                                  isAudioCoin: episodeProvider
                                      .audiobycontentmodel
                                      .result?[0]
                                      .isAudioCoin,
                                );
                              },
                              child: Container(
                                constraints: const BoxConstraints(
                                  minHeight: 0,
                                  maxHeight: 45,
                                  minWidth: 0,
                                  maxWidth: 160,
                                ),
                                padding: const EdgeInsets.all(10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: colorAccent,
                                  borderRadius: BorderRadius.circular(5),
                                  shape: BoxShape.rectangle,
                                ),
                                child: MyText(
                                  color: white,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  multilanguage: true,
                                  text: "playnow",
                                  textalign: TextAlign.center,
                                  fontsizeNormal: 16,
                                  fontsizeWeb: 16,
                                  fontweight: FontWeight.w700,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),

                    /* Details */
                    Container(
                      // height: Dimens.detailWeb,
                      padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!kIsWeb)
                            Container(
                              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: InkWell(
                                autofocus: true,
                                focusColor: gray.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(25),
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
                                  width: 35,
                                  height: 35,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.all(8),
                                  child: Utils().backBtn(18, 18, 12),
                                ),
                              ),
                            ),

                          /* Small Poster, Main title, ReleaseYear, Duration, Age Restriction, Video Quality */
                          Container(
                            width: MediaQuery.of(context).size.width,
                            constraints: const BoxConstraints(minHeight: 0),
                            padding: const EdgeInsets.fromLTRB(
                                0, kIsWeb ? 20 : 0, 10, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                MyText(
                                  color: white,
                                  text: showDetailsProvider.contentdetailsModel
                                          .result?[0].title ??
                                      "",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 20,
                                  fontsizeWeb: 24,
                                  fontweight: FontWeight.w800,
                                  maxline: 2,
                                  multilanguage: false,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  constraints:
                                      const BoxConstraints(minWidth: 0),
                                  // child: _buildRentBtn(),
                                  child: _reviewAndPlay(),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                /* Category */
                                if (showDetailsProvider.contentdetailsModel
                                            .result?[0].categoryName !=
                                        null &&
                                    showDetailsProvider.contentdetailsModel
                                            .result?[0].categoryName !=
                                        "")
                                  Container(
                                    constraints:
                                        const BoxConstraints(minHeight: 0),
                                    margin: const EdgeInsets.only(top: 5),
                                    child: Row(
                                      children: [
                                        MyText(
                                          color: white,
                                          text: "category",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: 13,
                                          fontweight: FontWeight.w600,
                                          fontsizeWeb: 13,
                                          maxline: 1,
                                          multilanguage: true,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                        const SizedBox(width: 5),
                                        MyText(
                                          color: white,
                                          text: ":",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: 13,
                                          fontweight: FontWeight.w600,
                                          fontsizeWeb: 13,
                                          maxline: 1,
                                          multilanguage: false,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: MyText(
                                            color: white,
                                            text: showDetailsProvider
                                                    .contentdetailsModel
                                                    .result?[0]
                                                    .categoryName ??
                                                "",
                                            textalign: TextAlign.start,
                                            fontsizeNormal: 13,
                                            fontsizeWeb: 13,
                                            fontweight: FontWeight.w600,
                                            multilanguage: false,
                                            maxline: 5,
                                            overflow: TextOverflow.ellipsis,
                                            fontstyle: FontStyle.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(
                                  height: 20,
                                ),
                                /* Language */
                                Container(
                                  constraints:
                                      const BoxConstraints(minHeight: 0),
                                  margin: const EdgeInsets.only(top: 5),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText(
                                        color: white,
                                        text: "language_",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: 13,
                                        fontweight: FontWeight.w600,
                                        fontsizeWeb: 13,
                                        maxline: 1,
                                        multilanguage: true,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                      const SizedBox(width: 5),
                                      MyText(
                                        color: white,
                                        text: ":",
                                        textalign: TextAlign.center,
                                        fontsizeNormal: 13,
                                        fontweight: FontWeight.w600,
                                        fontsizeWeb: 13,
                                        maxline: 1,
                                        multilanguage: false,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        child: MyText(
                                          color: white,
                                          text: showDetailsProvider
                                                  .contentdetailsModel
                                                  .result?[0]
                                                  .languageName
                                                  .toString() ??
                                              "",
                                          textalign: TextAlign.start,
                                          fontsizeNormal: 13,
                                          fontweight: FontWeight.w600,
                                          fontsizeWeb: 13,
                                          multilanguage: false,
                                          maxline: 1,
                                          overflow: TextOverflow.ellipsis,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /* Description */
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  margin: const EdgeInsets.only(
                                      top: 20, bottom: 20),
                                  child: ExpandableText(
                                    showDetailsProvider.contentdetailsModel
                                            .result?[0].description ??
                                        "",
                                    animation: true,
                                    textAlign: TextAlign.start,
                                    expandOnTextTap: true,
                                    collapseOnTextTap: true,
                                    expandText: "Read more",
                                    maxLines: 3,
                                    linkColor: colorAccent,
                                    style: TextStyle(
                                      fontSize:
                                          (kIsWeb || Constant.isTV) ? 13 : 13,
                                      fontStyle: FontStyle.normal,
                                      color: white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
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

              /* Other Details */
              /* Related ~ More Details */
              Consumer<EpisodeProvider>(
                builder: (context, showDetailsProvider, child) {
                  return _buildTabs();
                },
              ),
              const SizedBox(height: 20),

              /* Web Footer */
              (kIsWeb) ? const FooterWeb() : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileData() {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            /* Poster */
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(0),
                  width: MediaQuery.of(context).size.width,
                  height: (kIsWeb || Constant.isTV)
                      ? Dimens.detailWebPoster
                      : Dimens.detailPoster,
                  child: Stack(children: [
                    MyNetworkImage(
                      fit: BoxFit.cover,
                      imageUrl: (showDetailsProvider.contentdetailsModel
                                      .result?[0].webBannerImg ??
                                  "")
                              .isEmpty
                          ? (showDetailsProvider
                                  .contentdetailsModel.result?[0].landscapeImg
                                  .toString() ??
                              "")
                          : (showDetailsProvider
                                  .contentdetailsModel.result?[0].webBannerImg
                                  .toString() ??
                              ""),
                    ),
                    Container(
                      height: Dimens.detailWebPoster,
                      width: MediaQuery.of(context).size.width,
                      color: black.withOpacity(0.65),
                    ),
                    /* Included Features buttons */
                    Positioned.fill(
                      bottom: 60,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: InkWell(
                          onTap: () {
                            playAudio(
                              playingType: showDetailsProvider
                                      .contentdetailsModel
                                      .result?[0]
                                      .contentType
                                      .toString() ??
                                  "",
                              episodeid: episodeProvider
                                      .audiobycontentmodel.result?[0].id
                                      .toString() ??
                                  "",
                              contentid: episodeProvider
                                      .audiobycontentmodel.result?[0].contentId
                                      .toString() ??
                                  "",
                              position: 0,
                              sectionBannerList:
                                  episodeProvider.audiobycontentmodel.result ??
                                      [],
                              contentName: episodeProvider
                                      .audiobycontentmodel.result?[0].name
                                      .toString() ??
                                  "",
                              isBuy: episodeProvider
                                      .audiobycontentmodel.result?[0].isBuy
                                      .toString() ??
                                  "",
                              isAudioPaid: episodeProvider
                                  .audiobycontentmodel.result?[0].isAudioPaid,
                              isAudioCoin: episodeProvider
                                  .audiobycontentmodel.result?[0].isAudioCoin,
                            );
                          },
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 0,
                              maxHeight: 45,
                              minWidth: 0,
                              maxWidth: 160,
                            ),
                            padding: const EdgeInsets.all(10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colorAccent,
                              borderRadius: BorderRadius.circular(5),
                              shape: BoxShape.rectangle,
                            ),
                            child: MyText(
                              color: white,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              multilanguage: true,
                              text: "playnow",
                              textalign: TextAlign.center,
                              fontsizeNormal: 16,
                              fontsizeWeb: 16,
                              fontweight: FontWeight.w700,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
                Positioned(
                  top: 25,
                  left: 25,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: InkWell(
                      autofocus: true,
                      focusColor: gray.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(25),
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
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8),
                        child: Utils().backBtn(18, 18, 12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            /* Other Details */
            Container(
              transform: Matrix4.translationValues(0, -kToolbarHeight, 0),
              child: Column(
                children: [
                  /* Small Poster, Main title, ReleaseYear, Duration, Age Restriction, Video Quality */
                  Container(
                    width: MediaQuery.of(context).size.width,
                    constraints: const BoxConstraints(minHeight: 85),
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 65,
                          height: 85,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: MyNetworkImage(
                              fit: BoxFit.fill,
                              imgHeight: 85,
                              imgWidth: 65,
                              imageUrl: showDetailsProvider.contentdetailsModel
                                          .result?[0].portraitImg !=
                                      ""
                                  ? (showDetailsProvider.contentdetailsModel
                                          .result?[0].portraitImg ??
                                      "")
                                  : "",
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              MyText(
                                color: white,
                                text: showDetailsProvider
                                        .contentdetailsModel.result?[0].title ??
                                    "",
                                multilanguage: false,
                                textalign: TextAlign.start,
                                fontsizeNormal: 20,
                                fontsizeWeb: 24,
                                fontweight: FontWeight.w800,
                                maxline: 2,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    constraints: const BoxConstraints(minWidth: 0),
                    child: _reviewAndPlay(),
                  ),

                  /* Description, IMDb, Languages & Subtitles */
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: const BoxConstraints(minHeight: 0),
                          margin: const EdgeInsets.only(top: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                color: white,
                                text: "category",
                                textalign: TextAlign.center,
                                fontsizeNormal: 13,
                                fontweight: FontWeight.w500,
                                fontsizeWeb: 15,
                                maxline: 1,
                                multilanguage: true,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(width: 5),
                              MyText(
                                color: white,
                                text: ":",
                                textalign: TextAlign.center,
                                fontsizeNormal: 13,
                                fontweight: FontWeight.w500,
                                fontsizeWeb: 15,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: MyText(
                                  color: white,
                                  text: showDetailsProvider.contentdetailsModel
                                          .result?[0].categoryName ??
                                      "",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 13,
                                  fontweight: FontWeight.w500,
                                  fontsizeWeb: 14,
                                  multilanguage: false,
                                  maxline: 5,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          constraints: const BoxConstraints(minHeight: 0),
                          margin: const EdgeInsets.only(top: 5),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                color: white,
                                text: "language_",
                                textalign: TextAlign.center,
                                fontsizeNormal: 13,
                                fontweight: FontWeight.w600,
                                fontsizeWeb: 13,
                                maxline: 1,
                                multilanguage: true,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(width: 5),
                              MyText(
                                color: white,
                                text: ":",
                                textalign: TextAlign.center,
                                fontsizeNormal: 13,
                                fontweight: FontWeight.w600,
                                fontsizeWeb: 13,
                                maxline: 1,
                                multilanguage: false,
                                overflow: TextOverflow.ellipsis,
                                fontstyle: FontStyle.normal,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: MyText(
                                  color: white,
                                  text: showDetailsProvider.contentdetailsModel
                                          .result?[0].languageName
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.start,
                                  fontsizeNormal: 13,
                                  fontweight: FontWeight.w600,
                                  fontsizeWeb: 13,
                                  multilanguage: false,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          constraints: const BoxConstraints(minHeight: 0),
                          alignment: Alignment.centerLeft,
                          child: ExpandableText(
                            showDetailsProvider.contentdetailsModel.result?[0]
                                    .description ??
                                "",
                            expandText: more,
                            collapseText: less_,
                            maxLines: 3,
                            linkColor: colorAccent,
                            expandOnTextTap: true,
                            collapseOnTextTap: true,
                            style: TextStyle(
                              fontSize: (kIsWeb || Constant.isTV) ? 13 : 14,
                              fontStyle: FontStyle.normal,
                              color: white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // /* Related ~ More Details */
                  Consumer<EpisodeProvider>(
                    builder: (context, showDetailsProvider, child) {
                      return _buildTabs();
                    },
                  ),
                  const SizedBox(height: 20),

                  /* Web Footer */
                  (kIsWeb) ? const FooterWeb() : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            constraints: BoxConstraints(
              maxWidth: (kIsWeb || Constant.isTV)
                  ? (MediaQuery.of(context).size.width * 0.5)
                  : MediaQuery.of(context).size.width,
            ),
            height: (kIsWeb || Constant.isTV) ? 35 : Dimens.detailTabs,
            child: Row(
              children: [
                /* episodes */
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () async {
                      await showDetailsProvider.setTabClick("episodes");
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyText(
                              color:
                                  showDetailsProvider.tabClickedOn != "episodes"
                                      ? gray
                                      : colorAccent,
                              text: "episodes",
                              multilanguage: true,
                              textalign: TextAlign.center,
                              fontsizeNormal: 16,
                              fontweight: FontWeight.w600,
                              fontsizeWeb: 16,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              showDetailsProvider.tabClickedOn == "episodes",
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 2,
                            color: colorAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Videos
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () async {
                      await showDetailsProvider.setTabClick("video");
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyText(
                              color: showDetailsProvider.tabClickedOn != "video"
                                  ? gray
                                  : colorAccent,
                              text: "video",
                              multilanguage: true,
                              textalign: TextAlign.center,
                              fontsizeNormal: 16,
                              fontweight: FontWeight.w600,
                              fontsizeWeb: 16,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: showDetailsProvider.tabClickedOn == "video",
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 2,
                            color: colorAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                /* More Details */
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () async {
                      await showDetailsProvider.setTabClick("details");
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyText(
                              color:
                                  showDetailsProvider.tabClickedOn != "details"
                                      ? gray
                                      : colorAccent,
                              text: "details",
                              textalign: TextAlign.center,
                              fontsizeNormal: 16,
                              fontweight: FontWeight.w600,
                              fontsizeWeb: 16,
                              multilanguage: true,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontstyle: FontStyle.normal,
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              showDetailsProvider.tabClickedOn == "details",
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 2,
                            color: colorAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          /* Data */
          (showDetailsProvider.tabClickedOn == "episodes")
              ? Container(
                  padding: ((kIsWeb || Constant.isTV) &&
                          MediaQuery.of(context).size.width > 720)
                      ? const EdgeInsets.fromLTRB(10, 0, 10, 0)
                      : const EdgeInsets.all(0),
                  child: (episodeProvider.audiobycontentmodel.result != null &&
                          (episodeProvider.audiobycontentmodel.result?.length ??
                                  0) >
                              0)
                      ? Container(
                          padding: ((kIsWeb || Constant.isTV) &&
                                  MediaQuery.of(context).size.width > 720)
                              ? const EdgeInsets.fromLTRB(20, 0, 20, 0)
                              : const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width,
                          constraints: const BoxConstraints(minHeight: 50),
                          child: Consumer<EpisodeProvider>(
                            builder: (context, episodeProvider, child) {
                              return EpisodeBySeason(
                                  widget.contentId,
                                  showDetailsProvider.seasonPos,
                                  showDetailsProvider
                                      .audiobycontentmodel.result,
                                  showDetailsProvider
                                      .audiobycontentmodel.result?[0],
                                  1,
                                  widget.contentType);
                            },
                          ),
                        )
                      : const SizedBox(
                          height: 250,
                          child: NoData(title: 'nodata', subTitle: '')),
                )
              : /* video */
              (showDetailsProvider.tabClickedOn == "video")
                  ? Container(
                      padding: ((kIsWeb || Constant.isTV) &&
                              MediaQuery.of(context).size.width > 720)
                          ? const EdgeInsets.fromLTRB(10, 0, 10, 0)
                          : const EdgeInsets.all(0),
                      child: (episodeProvider.videobycontentmodel.result !=
                                  null &&
                              (episodeProvider.videoList?.length ?? 0) > 0)
                          ? Container(
                              padding: ((kIsWeb || Constant.isTV) &&
                                      MediaQuery.of(context).size.width > 720)
                                  ? const EdgeInsets.fromLTRB(20, 0, 20, 0)
                                  : const EdgeInsets.all(0),
                              width: MediaQuery.of(context).size.width,
                              constraints: const BoxConstraints(minHeight: 50),
                              child: Consumer<EpisodeProvider>(
                                builder: (context, episodeProvider, child) {
                                  return VideoEpiosdeByContent(
                                    videoId: widget.contentId,
                                  );
                                },
                              ),
                            )
                          : const SizedBox(
                              height: 250,
                              child: NoData(title: 'nodata', subTitle: '')),
                    )
                  : (showDetailsProvider.tabClickedOn == "details")
                      ? MoreDetails(
                          type: 1,
                          contentid: showDetailsProvider
                                  .contentdetailsModel.result?[0].id ??
                              0,
                          contentype: showDetailsProvider
                                  .contentdetailsModel.result?[0].contentType ??
                              0,
                        )
                      : const SizedBox.shrink()
        ],
      ),
    );
  }

  Widget _reviewAndPlay() {
    return Container(
      alignment: Alignment.center,
      height: 60,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                  fontsizeWeb: 13,
                  fontsizeNormal: 13,
                  fontweight: FontWeight.w600,
                  color: white,
                  text: formatNumber(showDetailsProvider
                          .contentdetailsModel.result?[0].totalUserPlay ??
                      0)),
              const SizedBox(
                height: 5,
              ),
              MyText(
                  fontsizeWeb: 11,
                  fontsizeNormal: 11,
                  fontweight: FontWeight.w500,
                  color: gray,
                  text: "Play")
            ],
          ),
          const VerticalDivider(
            width: 50,
            color: white,
            thickness: 1,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                    padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: colorAccent,
                        borderRadius: BorderRadius.circular(14)),
                    child: MyText(
                        fontsizeWeb: 15,
                        fontsizeNormal: 15,
                        fontweight: FontWeight.w600,
                        color: white,
                        text: showDetailsProvider
                                .contentdetailsModel.result?[0].avgRating
                                .toString() ??
                            "")),
              ),
              const SizedBox(
                height: 5,
              ),
              MyText(
                  fontsizeWeb: 11,
                  fontsizeNormal: 11,
                  fontweight: FontWeight.w500,
                  color: gray,
                  text:
                      "${formatNumber(showDetailsProvider.contentdetailsModel.result?[0].totalReviews ?? 0)} Reviews")
            ],
          ),
          const VerticalDivider(
            color: white,
            thickness: 1,
            width: 50,
          ),
          InkWell(
            focusColor: gray.withOpacity(0.5),
            onTap: () async {
              printLog(
                  "isBookmark ====> ${showDetailsProvider.contentdetailsModel.result?[0].isBookMark ?? 0}");
              if (Constant.userID != null) {
                await showDetailsProvider.setBookMark(
                  context,
                  widget.contentType,
                  widget.contentId,
                );
              } else {
                if ((kIsWeb || Constant.isTV)) {
                  Utils.buildWebAlertDialog(context, "login", "");
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const LoginSocial(
                        ishome: false,
                      );
                    },
                  ),
                );
              }
              // });
            },
            borderRadius: BorderRadius.circular(5),
            child: Consumer<ShowDetailsProvider>(
              builder: (context, showDetailsProvider, child) {
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                            width: 35,
                            height: 35,
                            padding: const EdgeInsets.all(5),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: colorAccent,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              color: (showDetailsProvider.contentdetailsModel
                                              .result?[0].isBookMark ??
                                          0) ==
                                      0
                                  ? white
                                  : red,
                              Icons.favorite,
                              size: 25,
                            )),
                      ),
                      MyText(
                        color: white,
                        text: "favourite",
                        multilanguage: true,
                        fontsizeNormal: 10,
                        fontsizeWeb: 14,
                        fontweight: FontWeight.w500,
                        maxline: 2,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      )
                    ]);
              },
            ),
          ),
          const VerticalDivider(
            color: white,
            thickness: 1,
            width: 50,
          ),
          MyText(
              maxline: 3,
              fontsizeNormal: 15,
              fontweight: FontWeight.w600,
              color: white,
              fontsizeWeb: 15,
              text: showDetailsProvider
                      .contentdetailsModel.result?[0].languageName
                      .toString() ??
                  ""),
          const VerticalDivider(
            color: white,
            thickness: 1,
            width: 50,
          ),
          InkWell(
              onTap: () {
                // openReviewRatingDialog();
                _buildShareWithDialog();
              },
              child: MyImage(
                  imagePath: "ic_sharedetails.png", height: 32, width: 32))
        ],
      ),
    );
  }

  _buildShareWithDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorPrimaryDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(23),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MyText(
                    text: showDetailsProvider
                            .contentdetailsModel.result?[0].title ??
                        "",
                    multilanguage: false,
                    fontsizeNormal: 18,
                    fontsizeWeb: 18,
                    color: white,
                    fontstyle: FontStyle.normal,
                    fontweight: FontWeight.w700,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                  ),
                  const SizedBox(height: 17),

                  /* SMS */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
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
                      if (Platform.isAndroid) {
                        Utils.redirectToUrl(
                            'sms:?body=${Uri.encodeComponent("Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n")}');
                      } else if (Platform.isIOS) {
                        Utils.redirectToUrl(
                            'sms:&body=${Uri.encodeComponent("Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n")}');
                      }
                    },
                    child: _buildDialogItems(
                      icon: "ic_sms.png",
                      title: "sms",
                      isMultilang: true,
                    ),
                  ),

                  /* Instgram Stories */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
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
                      Utils.shareApp(Platform.isIOS
                          ? "Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                          : "Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                    },
                    child: _buildDialogItems(
                      icon: "ic_insta.png",
                      title: "instagram_stories",
                      isMultilang: true,
                    ),
                  ),

                  /* Copy Link */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
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
                      SocialShare.copyToClipboard(
                        text: Platform.isIOS
                            ? "Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                            : "Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n",
                      ).then((data) {
                        printLog(data);
                        Utils.showSnackbar(
                            context, "success", "link_copied", true);
                      });
                    },
                    child: _buildDialogItems(
                      icon: "ic_link.png",
                      title: "copy_link",
                      isMultilang: true,
                    ),
                  ),

                  /* More */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
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
                      Utils.shareApp(Platform.isIOS
                          ? "Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://apps.apple.com/us/app/${Constant.appName.toLowerCase()}/${Constant.appPackageName} \n"
                          : "Hey! I'm watching ${showDetailsProvider.contentdetailsModel.result?[0].title ?? ""}. Check it out now on ${Constant.appName}! \nhttps://play.google.com/store/apps/details?id=${Constant.appPackageName} \n");
                    },
                    child: _buildDialogItems(
                      icon: "ic_dots_h.png",
                      title: "more",
                      isMultilang: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDialogItems({
    required String icon,
    required String title,
    required bool isMultilang,
  }) {
    return Container(
      height: Dimens.minHtDialogContent,
      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MyImage(
            width: Dimens.dialogIconSize,
            height: Dimens.dialogIconSize,
            imagePath: icon,
            fit: BoxFit.contain,
            color: gray,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: MyText(
              text: title,
              multilanguage: isMultilang,
              fontsizeNormal: 14,
              fontsizeWeb: 15,
              color: white,
              fontstyle: FontStyle.normal,
              fontweight: FontWeight.w600,
              maxline: 1,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  /* Add Review - Reating START */
  openReviewRatingDialog() {
    showGeneralDialog<void>(
      barrierColor: black.withOpacity(0.9),
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Dialog(
            insetPadding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
            backgroundColor: white,
            alignment: Alignment.center,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Wrap(
              children: [
                _buildCommentDialog(),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      _getData();
    });
  }

  Widget _buildCommentDialog() {
    return AnimatedPadding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Container(
        padding: const EdgeInsets.all(5),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            /* Close Button */
            Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: MyText(
                      color: colorAccent,
                      text: "reviewandrating",
                      multilanguage: true,
                      textalign: TextAlign.start,
                      fontsizeNormal: 17,
                      fontsizeWeb: 17,
                      maxline: 1,
                      fontweight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(5),
                      onTap: () {
                        printLog("Clicked on Close!");
                        commentController.clear();
                        ratingGiven = null;
                        // detailprovider.resetCommentData();
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: black,
                            ),
                            borderRadius: BorderRadius.circular(50)),
                        child: Utils().closeBtn(colorPrimaryDark, 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 0.2, decoration: Utils.setBackground(gray, 1)),

            /* Add Rating */
            Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 25),
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MyText(
                    fontsizeWeb: 15,
                    color: colorAccent,
                    text: "give_ratings",
                    multilanguage: true,
                    textalign: TextAlign.center,
                    fontsizeNormal: 16,
                    maxline: 1,
                    fontweight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RatingBar(
                      initialRating: 0.0,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemSize: 30,
                      itemCount: 5,
                      ratingWidget: RatingWidget(
                        full: const Icon(
                          Icons.star,
                          color: colorAccent,
                        ),
                        half: const Icon(
                          Icons.star_half,
                          color: colorAccent,
                        ),
                        empty: const Icon(
                          Icons.star_border,
                          color: gray,
                        ),
                      ),
                      onRatingUpdate: (double value) {
                        ratingGiven = value;
                        printLog("ratingGiven => $ratingGiven");
                      },
                    ),
                  ),
                ],
              ),
            ),

            /* Add Review */
            Container(
              height: 150,
              decoration: Utils.setBGWithBorder(
                  yellow.withOpacity(0.2), gray.withOpacity(0.5), 8, 0.5),
              margin: const EdgeInsets.fromLTRB(20, 8, 20, 25),
              child: TextFormField(
                controller: commentController,
                scrollPhysics: const AlwaysScrollableScrollPhysics(),
                textAlign: TextAlign.start,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                onChanged: (value) async {
                  // await detailprovider.notifyProvider();
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: transparentColor,
                  border: InputBorder.none,
                  hintText: "Add comments...",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.normal,
                    color: gray,
                  ),
                  contentPadding: const EdgeInsets.only(left: 10, right: 10),
                ),
                obscureText: false,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal,
                  color: colorPrimaryDark,
                ),
              ),
            ),

            /* Submit button */
            FittedBox(
              child: Container(
                height: 35,
                alignment: Alignment.bottomRight,
                margin: const EdgeInsets.fromLTRB(20, 8, 20, 25),
                decoration: Utils.setBGWithBorder(colorAccent, gray, 5, 0.5),
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () async {
                    if (Constant.userID != null) {
                      printLog("Submit ratingGiven ===> $ratingGiven");
                      printLog(
                          "Submit comment =======> ${commentController.text}");
                      final commentprovider = Provider.of<ShowDetailsProvider>(
                          context,
                          listen: false);

                      if (commentController.text.isNotEmpty &&
                          commentController.text != "") {
                        Utils.showProgress(context, prDialog);
                        await commentprovider.getAddReviews(
                          showDetailsProvider.contentdetailsModel.result?[0].id,
                          commentController.text,
                          showDetailsProvider
                              .contentdetailsModel.result?[0].contentType,
                          ratingGiven ?? 0,
                        );
                        if (!mounted) return;
                        Utils().hideProgress(context);
                        commentController.clear();
                        if (kIsWeb) {
                          if (context.canPop()) {
                            context.pop();
                          }
                        } else {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        }
                        // setState(() {});
                        _getData();
                      } else {
                        Utils.showToast(pleaseaddcomment);
                      }
                    } else {
                      Utils.buildWebAlertDialog(context, "login", "")
                          .then((value) => _getData());
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Consumer<ShowDetailsProvider>(
                      builder: (context, homeProvider, child) {
                        return MyText(
                          color: (commentController.text.toString().isEmpty)
                              ? white
                              : white,
                          text: "submit",
                          multilanguage: true,
                          textalign: TextAlign.center,
                          fontsizeNormal: 14,
                          maxline: 1,
                          fontsizeWeb: 14,
                          fontweight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
    required List<Result>? sectionBannerList,
    dynamic playlistImages,
    required String contentName,
    required String? isBuy,
    required int? isAudioPaid,
    required dynamic isAudioCoin,
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
      if (isAudioPaid == 1) {
        if (isBuy == "0") {
          openSubscriptionDialog(
            position,
            isAudioCoin,
            contentName,
            episodeid,
            contentid,
          );
        } else {
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
      Utils.buildWebAlertDialog(context, "login", "")
          .then((value) => _getData());
    }
  }

  addView(contentType, episodeid, contentId) async {
    final audiototalplayprovider =
        Provider.of<ShowDetailsProvider>(context, listen: false);
    await audiototalplayprovider.getAddContentPlay(1, episodeid, 1, contentId);
  }

  /* ========= Open Player ========= */
  openBottomSheet(int index, coins, episodeName, episodeID, contentID) {
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
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25)),
                  child: MyImage(
                    fit: BoxFit.cover,
                    imagePath: 'coinsBanner.png',
                    height: 120,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    const Icon(
                      Icons.lock_open_rounded,
                      color: white,
                      size: 40,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    MyText(
                      color: white,
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
                                    context.pushNamed(
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
                              color: white,
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
                                  color: white,
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
                        color: white,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            MyText(
                              color: white,
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
                                  color: white,
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
                          if ((profileProvider
                                      .profileModel.result?[0].walletCoin ??
                                  0) >
                              coins) {
                            final episodebuyprovider =
                                Provider.of<ShowDetailsProvider>(context,
                                    listen: false);
                            Utils.showProgress(context, prDialog);
                            await episodebuyprovider.getEpisodeBuy(
                                1, episodeID, 1, contentID, coins);
                            if (episodebuyprovider.episodeBuyModel.status ==
                                200) {
                              Utils.showToast(successfullbuy);
                              if (!context.mounted) return;
                              Utils().hideProgress(context);
                              setState(() {
                                _getData();
                              });
                              if (kIsWeb) {
                                if (context.canPop()) {
                                  context.pop();
                                }
                              } else {
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                }
                              }
                            } else {
                              Utils.showToast(pleasetryagain);
                              if (!context.mounted) return;
                              Utils().hideProgress(context);
                            }
                          } else {
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
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) {
                          //       return const Subscription();
                          //     },
                          //   ),
                          // );
                          context.pushNamed(
                            RoutesConstant.subscriptionPage,
                            extra: "",
                          );
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
        }).whenComplete(() => _getData());
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

  openSubscriptionDialog(int index, coins, episodeName, episodeID, contentID) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                          alignment: Alignment.center,
                          height: 30,
                          width: 30,
                          // padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: white),
                          child: Utils().closeBtn(colorPrimaryDark, 16),
                        ),
                      ),
                    ),
                    ClipRRect(
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
                    Column(
                      children: [
                        const SizedBox(
                          height: 40,
                        ),
                        const Icon(
                          Icons.lock_open_rounded,
                          color: white,
                          size: 40,
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        MyText(
                          color: white,
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
                                        context.pushNamed(
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
                            color: white,
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
                              if ((profileProvider
                                          .profileModel.result?[0].walletCoin ??
                                      0) >
                                  coins) {
                                final episodebuyprovider =
                                    Provider.of<ShowDetailsProvider>(context,
                                        listen: false);
                                Utils.showProgress(context, prDialog);
                                await episodebuyprovider.getEpisodeBuy(
                                    1, episodeID, 1, contentID, coins);
                                if (episodebuyprovider.episodeBuyModel.status ==
                                    200) {
                                  Utils.showToast(successfullbuy);
                                  if (!context.mounted) return;
                                  Utils().hideProgress(context);
                                  setState(() {
                                    _getData();
                                    checkIsBuyOrNot();
                                  });
                                  if (kIsWeb) {
                                    if (context.canPop()) {
                                      context.pop();
                                    }
                                  } else {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  }
                                } else {
                                  Utils.showToast(pleasetryagain);
                                  if (!context.mounted) return;
                                  Utils().hideProgress(context);
                                }
                              } else {
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
                              // Navigator.push(
                              //   context,
                              //   PageRouteBuilder(
                              //     pageBuilder:
                              //         (context, animation, secondaryAnimation) {
                              //       return const Subscription();
                              //     },
                              //     transitionsBuilder: (context, animation,
                              //         secondaryAnimation, child) {
                              //       return child;
                              //     },
                              //   ),
                              // );
                              context.pushNamed(
                                RoutesConstant.subscriptionPage,
                                extra: "",
                              );
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
      },
    );
  }
}
