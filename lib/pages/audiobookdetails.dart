import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:diamondnib/main.dart';
import 'package:diamondnib/pages/authorprofile.dart';
import 'package:diamondnib/pages/musicdetails.dart';
import 'package:diamondnib/provider/profileprovider.dart';
import 'package:diamondnib/provider/subscriptionprovider.dart';
import 'package:diamondnib/shimmer/shimmerwidget.dart';
import 'package:diamondnib/subscription/allpayment.dart';
import 'package:diamondnib/subscription/subscription.dart';
import 'package:diamondnib/utils/adhelper.dart';
import 'package:diamondnib/utils/sharedpre.dart';
import 'package:diamondnib/utils/strings.dart';
import 'package:diamondnib/widget/videoepisodebycontent.dart';
import 'package:diamondnib/pages/loginsocial.dart';
import 'package:diamondnib/shimmer/shimmerutils.dart';
import 'package:diamondnib/utils/dimens.dart';
import 'package:diamondnib/webwidget/footerweb.dart';
import 'package:diamondnib/widget/moredetails.dart';
import 'package:diamondnib/widget/nodata.dart';
import 'package:diamondnib/provider/episodeprovider.dart';
import 'package:diamondnib/provider/showdetailsprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/widget/episodebyseason.dart';
import 'package:diamondnib/widget/myimage.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/mynetworkimg.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:social_share/social_share.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../model/episodebycontentmodel.dart';

class AudioBookDetails extends StatefulWidget {
  final int contentId, contentType;
  const AudioBookDetails(this.contentId, this.contentType, {super.key});

  @override
  State<AudioBookDetails> createState() => AudioBookDetailsState();
}

class AudioBookDetailsState extends State<AudioBookDetails> with RouteAware {
  late ProgressDialog prDialog;

  final ReceivePort _port = ReceivePort();

  String? audioLanguages;
  late ShowDetailsProvider audioDetailsProvider;
  late EpisodeProvider episodeProvider;
  double? ratingGiven;
  final commentController = TextEditingController();
  late ProfileProvider profileProvider;
  late SubscriptionProvider subscriptionProvider;
  CarouselController pageController = CarouselController();
  late ScrollController _scrollController;
  String? userName, userEmail, userMobileNo;
  SharedPre sharedPre = SharedPre();

  String shareText = "Check out this awesome content!";
  String shareSubject = "Awesome Content";

  @override
  void initState() {
    if (!kIsWeb) {
      /* Download init ****/
      // _bindBackgroundIsolate();
      // FlutterDownloader.registerCallback(downloadCallback, step: 1);
      /* ****/
    }
    prDialog = ProgressDialog(context);

    audioDetailsProvider =
        Provider.of<ShowDetailsProvider>(context, listen: false);
    episodeProvider = Provider.of<EpisodeProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    subscriptionProvider =
        Provider.of<SubscriptionProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    // profileProvider.getProfile(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioDetailsProvider.setLoading(true);
      episodeProvider.setLoading(true);
      _getData();
    });
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      printLog("AudioData Scroll Listner");
      if (audioDetailsProvider.tabClickedOn == "episodes") {
        if ((episodeProvider.audiocurrentPage ?? 0) <
            (episodeProvider.audiototalPage ?? 0)) {
          episodeProvider.setLoadMore(true);
          await _fetchDataAudio((episodeProvider.audiocurrentPage ?? 0));
        }
      } else if (audioDetailsProvider.tabClickedOn == "details") {
        if ((audioDetailsProvider.currentPage ?? 0) <
            (audioDetailsProvider.totalPage ?? 0)) {
          audioDetailsProvider.setLoadMore(true);
          await fetchComments((audioDetailsProvider.currentPage ?? 0));
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

  _getUserData() async {
    userName = await sharedPre.read("username");
    userEmail = await sharedPre.read("useremail");
    userMobileNo = await sharedPre.read("usermobile");
    printLog('getUserData userName ==> $userName');
    printLog('getUserData userEmail ==> $userEmail');
    printLog('getUserData userMobileNo ==> $userMobileNo');
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

  fetchComments(int? nextPage) {
    audioDetailsProvider.getReviews(
        widget.contentId, widget.contentType, (nextPage ?? 0) + 1);
  }

  _fetchDataVideo(int? nextPage) {
    episodeProvider.getVideoByContent(widget.contentId, (nextPage ?? 0) + 1);
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  String formatNumber(int number) {
    return NumberFormat.compact().format(number);
  }

  Future<void> _getData() async {
    profileProvider.getProfile(context);
    audioDetailsProvider.getContentDetails(
      widget.contentId,
      widget.contentType,
    );
    _fetchDataAudio(0);
    _fetchDataVideo(0);
    fetchComments(0);
    subscriptionProvider.getPackages();
    _getUserData();
    // Future.delayed(Duration.zero).then((value) {
    //   if (!mounted) return;
    //   setState(() {
    //     printLog(
    //         "setState videoId ======================> ${widget.contentId}");
    //   });
    // });
  } /* Section Data Api */

  _fetchDataAudio(int? nextPage) {
    episodeProvider.getAudioByContent(widget.contentId, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    episodeProvider.clearProvider();
    printLog(
        "dispose isBroadcast ============================> ${_port.isBroadcast}");

    routeObserver.unsubscribe(this);
    printLog(
        "dispose isBroadcast ============================> ${_port.isBroadcast}");

    audioDetailsProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        key: widget.key,
        backgroundColor: colorPrimary,
        body: Consumer<ShowDetailsProvider>(
          builder:
              (BuildContext context, ShowDetailsProvider value, Widget? child) {
            return _buildUIWithAppBar();
          },
        ),
      ),
      Utils.buildMusicPanel(context),
    ]);
  }

  Widget _buildUIWithAppBar() {
    return (audioDetailsProvider.detailsLoading &&
            episodeProvider.loadmore == false)
        ? ((kIsWeb || Constant.isTV) && MediaQuery.of(context).size.width > 720)
            ? SingleChildScrollView(
                child: ShimmerUtils.buildDetailWebShimmer(context, "show"))
            : SingleChildScrollView(
                child: ShimmerUtils.buildDetailMobileShimmer(context, "show"))
        : (audioDetailsProvider.contentdetailsModel.status == 200 &&
                audioDetailsProvider.contentdetailsModel.result != null)
            ? (((kIsWeb || Constant.isTV) &&
                    MediaQuery.of(context).size.width > 720)
                ? _buildWebData()
                : _buildMobileData())
            : const NoData(title: 'nodata', subTitle: '');
  }

  Widget _buildMobileData() {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: RefreshIndicator(
        backgroundColor: white,
        color: colorAccent,
        displacement: 80,
        onRefresh: () async {
          await Future.delayed(const Duration(milliseconds: 1500))
              .then((value) {
            audioDetailsProvider.setLoading(true);
            Future.delayed(Duration.zero).then((value) {
              if (!mounted) return;
              setState(() {});
            });
            _getData();
          });
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              /* Poster */
              // ((showDetailsProvider.contentdetailsModel.result?[0].trailerUrl ?? "")
              //         .isNotEmpty)
              //     ? setUpTrailerView()
              // :
              _buildMobilePoster(),

              /* Other Details */
              Column(
                children: [
                  /* Small Poster, Main title, ReleaseYear, Duration, Age Restriction, Video Quality */
                  Container(
                    width: MediaQuery.of(context).size.width,
                    constraints: const BoxConstraints(minHeight: 45),
                    margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          color: white,
                          text: audioDetailsProvider
                                  .contentdetailsModel.result?[0].title ??
                              "",
                          multilanguage: false,
                          textalign: TextAlign.start,
                          fontsizeNormal: 18,
                          fontsizeWeb: 24,
                          fontweight: FontWeight.w600,
                          maxline: 2,
                          overflow: TextOverflow.ellipsis,
                          fontstyle: FontStyle.normal,
                        ),
                        const SizedBox(height: 10),
                        MyText(
                            maxline: 3,
                            fontsizeNormal: 12,
                            fontweight: FontWeight.w500,
                            color: white,
                            text: audioDetailsProvider
                                    .contentdetailsModel.result?[0].languageName
                                    .toString() ??
                                ""),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  /* review and play, Total Views  */
                  _reviewAndPlay(), const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    width: MediaQuery.of(context).size.width,
                    constraints: const BoxConstraints(minHeight: 0),
                    alignment: Alignment.centerLeft,
                    child: ExpandableText(
                      animation: true,
                      audioDetailsProvider
                              .contentdetailsModel.result?[0].description ??
                          "",
                      expandText: more,
                      collapseText: less_,
                      maxLines: (kIsWeb || Constant.isTV) ? 50 : 3,
                      linkColor: colorAccent,
                      expandOnTextTap: true,
                      collapseOnTextTap: true,
                      style: TextStyle(
                        fontSize: (kIsWeb || Constant.isTV) ? 15 : 14,
                        fontStyle: FontStyle.normal,
                        color: white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _author(),

                  /* AdMob Banner */
                  Utils.showBannerAd(context),
                  const SizedBox(height: 10),
                  // /* Related ~ More Details */
                  Consumer<EpisodeProvider>(
                    builder: (context, episodeProvider, child) {
                      if (episodeProvider.loading &&
                          episodeProvider.loadmore == false) {
                        return audioShimmer();
                      } else {
                        return _buildTabs();
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  /* Web Footer */
                  (kIsWeb) ? const FooterWeb() : const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _author() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return AuthorProfile(
                        artistID: audioDetailsProvider
                                .contentdetailsModel.result?[0].artistId
                                .toString() ??
                            "",
                      );
                    },
                  ),
                );
              },
              child: Row(children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: MyNetworkImage(
                      imageUrl: audioDetailsProvider
                              .contentdetailsModel.result?[0].artistImage
                              .toString() ??
                          "",
                      imgHeight: 40,
                      imgWidth: 40,
                      fit: BoxFit.fill,
                    )),
                const SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      color: white,
                      text: audioDetailsProvider
                              .contentdetailsModel.result?[0].artistName
                              .toString() ??
                          "",
                      textalign: TextAlign.center,
                      multilanguage: false,
                      fontweight: FontWeight.w500,
                      fontsizeNormal: 14,
                      fontsizeWeb: 16,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                    const SizedBox(height: 5),
                    MyText(
                      color: white,
                      text:
                          "${audioDetailsProvider.contentdetailsModel.result?[0].artistFollowers.toString() ?? ""} Followers",
                      textalign: TextAlign.center,
                      multilanguage: false,
                      fontweight: FontWeight.w400,
                      fontsizeNormal: 12,
                      fontsizeWeb: 16,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebData() {
    return Container(
      width: MediaQuery.of(context).size.width,
      constraints: const BoxConstraints.expand(),
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            /* Poster */
            ClipRRect(
              borderRadius: BorderRadius.circular(0),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Stack(
                alignment: AlignmentDirectional.centerEnd,
                children: [
                  /* Poster */
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width *
                        (Dimens.webBannerImgPr),
                    height: Dimens.detailWebPoster,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.detailWebPoster,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                colorPrimary,
                                transparentColor,
                                transparentColor,
                                transparentColor,
                                transparentColor,
                                transparentColor,
                                colorPrimary,
                              ],
                            ),
                          ),
                        ),
                        MyNetworkImage(
                          fit: BoxFit.fill,
                          imageUrl: audioDetailsProvider.contentdetailsModel
                                      .result?[0].landscapeImg !=
                                  ""
                              ? (audioDetailsProvider.contentdetailsModel
                                      .result?[0].landscapeImg ??
                                  "")
                              : (audioDetailsProvider.contentdetailsModel
                                      .result?[0].portraitImg ??
                                  ""),
                        ),
                        Container(
                          padding: const EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width,
                          height: Dimens.detailWebPoster,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                colorPrimary,
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

                  /* Gradient */
                  Container(
                    padding: const EdgeInsets.all(0),
                    width: MediaQuery.of(context).size.width,
                    height: Dimens.detailWebPoster,
                    alignment: Alignment.centerLeft,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          colorPrimary,
                          colorPrimary,
                          colorPrimary,
                          colorPrimary,
                          transparentColor,
                          transparentColor,
                          transparentColor,
                          transparentColor,
                        ],
                      ),
                    ),
                  ),

                  /* Details */
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: Dimens.detailWebPoster + 30,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            padding: const EdgeInsets.all(10),
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              constraints: const BoxConstraints(minHeight: 0),
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  MyText(
                                    color: white,
                                    text: audioDetailsProvider
                                            .contentdetailsModel
                                            .result?[0]
                                            .title ??
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
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      /* Category */
                                      (audioDetailsProvider
                                                      .contentdetailsModel
                                                      .result?[0]
                                                      .categoryName !=
                                                  null &&
                                              audioDetailsProvider
                                                      .contentdetailsModel
                                                      .result?[0]
                                                      .categoryName !=
                                                  "")
                                          ? Container(
                                              margin: const EdgeInsets.only(
                                                  right: 10),
                                              child: MyText(
                                                color: white,
                                                text: audioDetailsProvider
                                                        .contentdetailsModel
                                                        .result?[0]
                                                        .categoryName ??
                                                    "",
                                                textalign: TextAlign.center,
                                                fontsizeNormal: 13,
                                                fontsizeWeb: 13,
                                                fontweight: FontWeight.w600,
                                                multilanguage: false,
                                                maxline: 1,
                                                overflow: TextOverflow.ellipsis,
                                                fontstyle: FontStyle.normal,
                                              ),
                                            )
                                          : const SizedBox.shrink(),

                                      /* IMDb */
                                      // MyImage(
                                      //   width: 40,
                                      //   height: 15,
                                      //   imagePath: "imdb.png",
                                      // ),
                                      MyText(
                                        color: gray,
                                        text:
                                            "${audioDetailsProvider.contentdetailsModel.result?[0].avgRating ?? 0}",
                                        textalign: TextAlign.start,
                                        fontsizeNormal: 14,
                                        fontsizeWeb: 14,
                                        fontweight: FontWeight.w600,
                                        multilanguage: false,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        fontstyle: FontStyle.normal,
                                      ),
                                      /* IMDb */
                                    ],
                                  ),

                                  /* Language */
                                  const SizedBox(height: 5),
                                  Container(
                                    constraints:
                                        const BoxConstraints(minHeight: 0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText(
                                          color: white,
                                          text: "language_",
                                          textalign: TextAlign.center,
                                          fontsizeNormal: 13,
                                          fontweight: FontWeight.w500,
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
                                            text: audioLanguages ?? "",
                                            textalign: TextAlign.start,
                                            fontsizeNormal: 13,
                                            fontweight: FontWeight.w500,
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

                                  /* Subtitle */
                                  Consumer<EpisodeProvider>(
                                    builder: (context, episodeProvider, child) {
                                      if (Constant.subtitleUrls.isNotEmpty) {
                                        return Container(
                                          constraints: const BoxConstraints(
                                              minHeight: 0),
                                          margin: const EdgeInsets.only(top: 8),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              MyText(
                                                color: white,
                                                text: "subtitle",
                                                textalign: TextAlign.center,
                                                fontsizeNormal: 13,
                                                fontweight: FontWeight.w500,
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
                                                  text: "Available",
                                                  textalign: TextAlign.start,
                                                  fontsizeNormal: 13,
                                                  fontweight: FontWeight.w500,
                                                  fontsizeWeb: 13,
                                                  maxline: 1,
                                                  multilanguage: false,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontstyle: FontStyle.normal,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    },
                                  ),

                                  /* Description */
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin: const EdgeInsets.only(
                                            top: 15, bottom: 8),
                                        child: ExpandableText(
                                          audioDetailsProvider
                                                  .contentdetailsModel
                                                  .result?[0]
                                                  .description ??
                                              "",
                                          animation: true,
                                          textAlign: TextAlign.start,
                                          expandOnTextTap: true,
                                          collapseOnTextTap: true,
                                          expandText: "",
                                          maxLines: 10,
                                          linkColor: yellow,
                                          style: TextStyle(
                                            fontSize: (kIsWeb || Constant.isTV)
                                                ? 13
                                                : 14,
                                            fontStyle: FontStyle.normal,
                                            color: white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width *
                              Dimens.webBannerImgPr,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /* Included Features buttons */
            Container(
              alignment: Alignment.centerLeft,
              constraints: const BoxConstraints(minHeight: 0, minWidth: 0),
              margin: const EdgeInsets.fromLTRB(30, 10, 0, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  /* Continue Watching Button */
                  /* Watch Now button */
                  // (widget.contentType == 5)
                  //     ? _buildWatchTrailer()
                  //     : _buildWatchNow(),
                  const SizedBox(width: 10),

                  /* Rent Button */
                  if (widget.contentType != 5)
                    Container(
                      constraints: const BoxConstraints(minWidth: 0),
                      // child: _buildRentBtn(),
                    ),
                  if (widget.contentType != 5) const SizedBox(width: 10),
                ],
              ),
            ),
            const SizedBox(height: 10),

            /* Other Details */
            /* Related ~ More Details */
            Consumer<ShowDetailsProvider>(
              builder: (context, showDetailsProvider, child) {
                return _buildTabs();
              },
            ),
            const SizedBox(height: 20),

            /* Web Footer */
            (kIsWeb || Constant.isTV)
                ? const FooterWeb()
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobilePoster() {
    return Stack(
      alignment: Alignment.center,
      children: [
        /* Poster & Trailer player */
        Container(
          padding: const EdgeInsets.all(0),
          width: MediaQuery.of(context).size.width,
          height: (kIsWeb || Constant.isTV)
              ? Dimens.detailWebPoster
              : Dimens.detailPoster,
          child: MyNetworkImage(
            fit: BoxFit.fill,
            imageUrl: audioDetailsProvider
                    .contentdetailsModel.result?[0].portraitImg
                    .toString() ??
                "",
          ),
        ),
        Container(
          padding: const EdgeInsets.all(0),
          width: MediaQuery.of(context).size.width,
          height: (kIsWeb || Constant.isTV)
              ? Dimens.detailWebPoster
              : Dimens.detailPoster,
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
        InkWell(
          borderRadius: BorderRadius.circular(30),
          focusColor: white,
          onTap: () async {
            // openPlayer("Trailer");

            if ((episodeProvider.videoList?[0].video ?? "").isNotEmpty) {
              openPlayer(
                0,
                episodeProvider.videoList ?? [],
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Utils().playBtn(45, 45, 30),
          ),
        ),
        Positioned(
          bottom: 25,
          child: Row(
            children: [
              InkWell(
                onTap: () async {
                  // openPlayer("Trailer");
                  playAudio(
                    playingType: episodeProvider
                            .audiobycontentmodel.result?[0].audioType
                            .toString() ??
                        "",
                    episodeid: episodeProvider.audiobycontentmodel.result?[0].id
                            .toString() ??
                        "",
                    contentid: episodeProvider
                            .audiobycontentmodel.result?[0].contentId
                            .toString() ??
                        "",
                    position: 0,
                    sectionBannerList:
                        episodeProvider.audiobycontentmodel.result ?? [],
                    contentName: episodeProvider
                            .audiobycontentmodel.result?[0].name
                            .toString() ??
                        "",
                    isBuy: episodeProvider.audiobycontentmodel.result?[0].isBuy
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
                    maxWidth: 120,
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
                    fontsizeWeb: 18,
                    fontweight: FontWeight.w700,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Container(
                constraints: const BoxConstraints(
                  minHeight: 0,
                  maxHeight: 45,
                  minWidth: 0,
                  maxWidth: 130,
                ),
                padding: const EdgeInsets.all(8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: transparentColor,
                  borderRadius: BorderRadius.circular(5),
                  shape: BoxShape.rectangle,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // MyImage(
                    //   imagePath: "ic_info.png",
                    //   height: 12,
                    //   width: 12,
                    //   color: white,
                    // ),
                    const Icon(
                      Icons.info_outline,
                      size: 15,
                      color: white,
                    ),
                    MyText(
                      color: white,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      multilanguage: true,
                      text: "moreinfo",
                      textalign: TextAlign.center,
                      fontsizeNormal: 15,
                      fontsizeWeb: 18,
                      fontweight: FontWeight.w700,
                      fontstyle: FontStyle.normal,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!kIsWeb)
          Positioned(
            top: 45,
            left: 20,
            child: Utils.buildBackBtn(context),
          ),
      ],
    );
  }

  Widget _buildWatchTrailer() {
    return Container(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap: () async {
          // openPlayer("Trailer");
        },
        focusColor: white,
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            height: (kIsWeb || Constant.isTV) ? 40 : 55,
            constraints: BoxConstraints(
              maxWidth: (kIsWeb || Constant.isTV)
                  ? 180
                  : MediaQuery.of(context).size.width,
            ),
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
            decoration: BoxDecoration(
              color: colorAccent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Utils().playIcon(white, 18),
                const SizedBox(width: 15),
                Expanded(
                  child: MyText(
                    color: white,
                    text: "watch_trailer",
                    multilanguage: true,
                    textalign: TextAlign.start,
                    fontsizeNormal: 15,
                    fontweight: FontWeight.w600,
                    fontsizeWeb: 16,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildWatchNow() {
  //   return Consumer<EpisodeProvider>(
  //     builder: (context, episodeProvider, child) {
  //       if (audioDetailsProvider.mCurrentEpiPos != -1 &&
  //           (episodeProvider
  //                       .episodeBySeasonModel
  //                       .result?[audioDetailsProvider.mCurrentEpiPos]
  //                       .stopTime ??
  //                   0) >
  //               0 &&
  //           episodeProvider
  //                   .episodeBySeasonModel
  //                   .result?[audioDetailsProvider.mCurrentEpiPos]
  //                   .videoDuration !=
  //               null) {
  //         return Container(
  //           alignment: Alignment.centerLeft,
  //           child: InkWell(
  //             onTap: () async {
  //               // openPlayer("Show");
  //             },
  //             focusColor: white,
  //             borderRadius: BorderRadius.circular(5),
  //             child: Padding(
  //               padding: const EdgeInsets.all(2.0),
  //               child: Container(
  //                 height: (kIsWeb || Constant.isTV) ? 40 : 55,
  //                 constraints: BoxConstraints(
  //                   maxWidth: (kIsWeb || Constant.isTV)
  //                       ? 180
  //                       : MediaQuery.of(context).size.width,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: colorAccent,
  //                   borderRadius: BorderRadius.circular(5),
  //                 ),
  //                 child: Column(
  //                   children: [
  //                     Expanded(
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         children: [
  //                           const SizedBox(width: 20),
  //                           Utils().playIcon(white, 18),
  //                           const SizedBox(width: 15),
  //                           Expanded(
  //                             child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               mainAxisAlignment:
  //                                   MainAxisAlignment.spaceEvenly,
  //                               children: [
  //                                 MyText(
  //                                   color: white,
  //                                   text:
  //                                       "Continue Watching Episode ${(audioDetailsProvider.mCurrentEpiPos + 1)}",
  //                                   multilanguage: false,
  //                                   textalign: TextAlign.start,
  //                                   fontsizeNormal: 13,
  //                                   fontsizeWeb: 15,
  //                                   fontweight: FontWeight.w700,
  //                                   maxline: 1,
  //                                   overflow: TextOverflow.ellipsis,
  //                                   fontstyle: FontStyle.normal,
  //                                 ),
  //                                 Row(
  //                                   children: [
  //                                     MyText(
  //                                       color: white,
  //                                       text: Utils.remainTimeInMin(((episodeProvider
  //                                                       .episodeBySeasonModel
  //                                                       .result?[
  //                                                           audioDetailsProvider
  //                                                               .mCurrentEpiPos]
  //                                                       .videoDuration ??
  //                                                   0) -
  //                                               (episodeProvider
  //                                                       .episodeBySeasonModel
  //                                                       .result?[
  //                                                           audioDetailsProvider
  //                                                               .mCurrentEpiPos]
  //                                                       .stopTime ??
  //                                                   0))
  //                                           .abs()),
  //                                       textalign: TextAlign.start,
  //                                       fontsizeNormal: 10,
  //                                       fontsizeWeb: 12,
  //                                       multilanguage: false,
  //                                       fontweight: FontWeight.w500,
  //                                       maxline: 1,
  //                                       overflow: TextOverflow.ellipsis,
  //                                       fontstyle: FontStyle.normal,
  //                                     ),
  //                                     const SizedBox(width: 5),
  //                                     MyText(
  //                                       color: white,
  //                                       text: "left",
  //                                       textalign: TextAlign.start,
  //                                       fontsizeNormal: 10,
  //                                       fontsizeWeb: 12,
  //                                       multilanguage: true,
  //                                       fontweight: FontWeight.w500,
  //                                       maxline: 1,
  //                                       overflow: TextOverflow.ellipsis,
  //                                       fontstyle: FontStyle.normal,
  //                                     ),
  //                                   ],
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                           const SizedBox(width: 20),
  //                         ],
  //                       ),
  //                     ),
  //                     Container(
  //                       height: 4,
  //                       constraints: const BoxConstraints(minWidth: 0),
  //                       margin: const EdgeInsets.all(3),
  //                       child: LinearPercentIndicator(
  //                         padding: const EdgeInsets.all(0),
  //                         barRadius: const Radius.circular(2),
  //                         lineHeight: 4,
  //                         percent: Utils.getPercentage(
  //                             episodeProvider
  //                                     .episodeBySeasonModel
  //                                     .result?[
  //                                         audioDetailsProvider.mCurrentEpiPos]
  //                                     .videoDuration ??
  //                                 0,
  //                             episodeProvider
  //                                     .episodeBySeasonModel
  //                                     .result?[
  //                                         audioDetailsProvider.mCurrentEpiPos]
  //                                     .stopTime ??
  //                                 0),
  //                         backgroundColor: gray,
  //                         progressColor: yellow,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           );
  //       } else {
  //         return Container(
  //           alignment: Alignment.centerLeft,
  //           child: InkWell(
  //             onTap: () async {
  //               // openPlayer("Show");
  //             },
  //             focusColor: white,
  //             borderRadius: BorderRadius.circular(5),
  //             child: Padding(
  //               padding: const EdgeInsets.all(2.0),
  //               child: Container(
  //                 height: (kIsWeb || Constant.isTV) ? 40 : 55,
  //                 constraints: BoxConstraints(
  //                   maxWidth: (kIsWeb || Constant.isTV)
  //                       ? 180
  //                       : MediaQuery.of(context).size.width,
  //                 ),
  //                 padding: const EdgeInsets.fromLTRB(20, 2, 20, 2),
  //                 decoration: BoxDecoration(
  //                   color: colorAccent,
  //                   borderRadius: BorderRadius.circular(5),
  //                 ),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.start,
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     Utils().playIcon(white, 18),
  //                     const SizedBox(width: 15),
  //                     Expanded(
  //                       child: MyText(
  //                         color: white,
  //                         text: "Watch Episode 1",
  //                         multilanguage: false,
  //                         textalign: TextAlign.start,
  //                         fontsizeNormal: 14,
  //                         fontsizeWeb: 15,
  //                         fontweight: FontWeight.w700,
  //                         maxline: 2,
  //                         overflow: TextOverflow.ellipsis,
  //                         fontstyle: FontStyle.normal,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: (kIsWeb || Constant.isTV)
                  ? (MediaQuery.of(context).size.width * 0.5)
                  : MediaQuery.of(context).size.width,
            ),
            height: (kIsWeb || Constant.isTV) ? 35 : Dimens.detailTabs,
            child: Row(
              children: [
                /* Related */
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () async {
                      await audioDetailsProvider.setTabClick("episodes");
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyText(
                              color: audioDetailsProvider.tabClickedOn !=
                                      "episodes"
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
                              audioDetailsProvider.tabClickedOn == "episodes",
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
                      await audioDetailsProvider.setTabClick("video");
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyText(
                              color:
                                  audioDetailsProvider.tabClickedOn != "video"
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
                          visible: audioDetailsProvider.tabClickedOn == "video",
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
                      await audioDetailsProvider.setTabClick("details");
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: MyText(
                              color:
                                  audioDetailsProvider.tabClickedOn != "details"
                                      ? gray
                                      : colorAccent,
                              text: "review",
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
                              audioDetailsProvider.tabClickedOn == "details",
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
          (audioDetailsProvider.tabClickedOn == "episodes")
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
                                  audioDetailsProvider.seasonPos,
                                  audioDetailsProvider
                                      .audiobycontentmodel.result,
                                  audioDetailsProvider
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
              (audioDetailsProvider.tabClickedOn == "video")
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
                  : (audioDetailsProvider.tabClickedOn == "details")
                      ? MoreDetails(
                          type: 1,
                          contentid: audioDetailsProvider
                                  .contentdetailsModel.result?[0].id ??
                              0,
                          contentype: audioDetailsProvider
                                  .contentdetailsModel.result?[0].contentType ??
                              0,
                        )
                      : const SizedBox.shrink()
        ],
      ),
    );
  }

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

  double getDynamicHeight(String? videoType, String? layoutType) {
    if (videoType == "1" || videoType == "2") {
      if (layoutType == "landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "potrait") {
        return Dimens.heightPort;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    } else if (videoType == "3" || videoType == "4") {
      return Dimens.heightLangGen;
    } else {
      if (layoutType == "landscape") {
        return Dimens.heightLand;
      } else if (layoutType == "potrait") {
        return Dimens.heightPort;
      } else if (layoutType == "square") {
        return Dimens.heightSquare;
      } else {
        return Dimens.heightLand;
      }
    }
  }

 
/* ========= Share Dialog ========= */
_buildShareWithDialog() {
  // Get current content details
  String audioTitle = audioDetailsProvider.contentdetailsModel.result?[0].title ?? "";
  int contentId = widget.contentId;
  int contentType = widget.contentType;
  
  // Create universal link - this is the KEY to making it work across all platforms
  // Format: https://diamondnib.com/audiobook/123?type=1
  String universalLink = "https://diamondnib.com/audiobook/$contentId?type=$contentType";
  
  // Create share text with the CLICKABLE web URL (most important)
  String shareText = "🎧 Check out \"$audioTitle\" on Diamondnib!\n\n$universalLink\n\nDownload the app to listen!\n\n#AudioBook #Diamondnib";

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
                  text: audioTitle,
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
                const SizedBox(height: 5),
                MyText(
                  text: "Share this audio with your friends",
                  multilanguage: false,
                  fontsizeNormal: 14,
                  fontsizeWeb: 14,
                  color: white.withOpacity(0.7),
                  fontstyle: FontStyle.normal,
                  fontweight: FontWeight.w400,
                  maxline: 2,
                  overflow: TextOverflow.ellipsis,
                  textalign: TextAlign.start,
                ),
                const SizedBox(height: 12),

                /* Clickable Link Display */
                Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: colorAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorAccent, width: 1),
                  ),
                  child: Column(
                    children: [
                      MyText(
                        text: "Shareable Link",
                        multilanguage: false,
                        fontsizeNormal: 14,
                        color: white,
                        fontweight: FontWeight.w600,
                        textalign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.link, color: colorAccent, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: "Universal Link",
                                    multilanguage: false,
                                    fontsizeNormal: 12,
                                    color: colorAccent,
                                    fontweight: FontWeight.w600,
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () async {
                                      Clipboard.setData(ClipboardData(text: universalLink));
                                      Utils.showSnackbar(context, "success", "link_copied", true);
                                    },
                                    child: Text(
                                      universalLink,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: white.withOpacity(0.7),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      MyText(
                        text: "✅ This link works everywhere and opens your app if installed",
                        multilanguage: false,
                        fontsizeNormal: 11,
                        color: yellow,
                        textalign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                /* Explanation */
                Container(
                  padding: const EdgeInsets.all(15),
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: colorPrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: yellow, size: 18),
                          const SizedBox(width: 8),
                          MyText(
                            text: "How it works:",
                            multilanguage: false,
                            fontsizeNormal: 14,
                            color: yellow,
                            fontweight: FontWeight.w600,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      MyText(
                        text: "1️⃣ When users tap the link, it tries to open your app\n2️⃣ If app is installed → Opens directly to this audio\n3️⃣ If app not installed → Opens your website\n\nYour website should redirect to app store or display the audio.",
                        multilanguage: false,
                        fontsizeNormal: 12,
                        color: white.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),

                /* Share via Apps */
                InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () async {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    final composed = '🎧 Check out "$audioTitle" on Diamondnib!\n\n$universalLink\n\n#AudioBook #Diamondnib';
                    await Share.share(
                      composed,
                      subject: 'Check out "$audioTitle" on Diamondnib',
                      sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100),
                    );
                  },
                  child: _buildShareDialogItem(
                    icon: Icons.share,
                    title: "share_via_apps",
                    isMultilang: true,
                  ),
                ),

                /* Copy Link */
                InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () async {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    Clipboard.setData(ClipboardData(text: universalLink));
                    Utils.showSnackbar(context, "success", "link_copied", true);
                  },
                  child: _buildShareDialogItem(
                    icon: Icons.copy,
                    title: "copy_link",
                    isMultilang: true,
                  ),
                ),

                /* SMS */
                InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () async {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    
                    String smsUrl = Platform.isAndroid
                        ? 'sms:?body=${Uri.encodeComponent(shareText)}'
                        : 'sms:&body=${Uri.encodeComponent(shareText)}';
                    
                    try {
                      if (await canLaunchUrl(Uri.parse(smsUrl))) {
                        await launchUrl(Uri.parse(smsUrl));
                      }
                    } catch (e) {
                      printLog('Error launching SMS: $e');
                    }
                  },
                  child: _buildShareDialogItem(
                    icon: Icons.sms,
                    title: "sms",
                    isMultilang: true,
                  ),
                ),

                /* Email */
                InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () async {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    
                    String emailUrl = 'mailto:?subject=${Uri.encodeComponent("Check out: $audioTitle")}&body=${Uri.encodeComponent(shareText)}';
                    
                    try {
                      if (await canLaunchUrl(Uri.parse(emailUrl))) {
                        await launchUrl(Uri.parse(emailUrl));
                      }
                    } catch (e) {
                      printLog('Error launching Email: $e');
                    }
                  },
                  child: _buildShareDialogItem(
                    icon: Icons.mail,
                    title: "email",
                    isMultilang: true,
                  ),
                ),

                /* More Options */
                InkWell(
                  borderRadius: BorderRadius.circular(5),
                  onTap: () async {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                    final composed = '🎧 Check out "$audioTitle" on Diamondnib!\n\n$universalLink\n\n#AudioBook #Diamondnib';
                    await Share.share(composed, subject: 'Audio: $audioTitle');
                  },
                  child: _buildShareDialogItem(
                    icon: Icons.more_horiz,
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
Widget _buildShareDialogItem({
  required IconData icon,
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
        Icon(
          icon,
          color: gray,
          size: Dimens.dialogIconSize,
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


  Future<void> openPlayer(int position, List<Result>? dataList) async {
    if (Constant.userID == null) {
      Utils.openLogin(context: context, isHome: false, isReplace: false);
      return;
    }
    
    // Check bounds to prevent Range error
    if (episodeProvider.videoList == null || 
        position < 0 || 
        position >= (episodeProvider.videoList?.length ?? 0)) {
      printLog("Invalid position $position for videoList with length ${episodeProvider.videoList?.length ?? 0}");
      return;
    }
    
    if (dataList == null || 
        position < 0 || 
        position >= (dataList.length)) {
      printLog("Invalid position $position for dataList with length ${dataList?.length ?? 0}");
      return;
    }
    
    if (episodeProvider.videoList?[position].isVideoPaid.toString() == "1") {
      if (episodeProvider.videoList?[position].isBuy.toString() == "0") {
        openBottomSheet(
            position,
            episodeProvider.videoList?[position].isVideoCoin,
            episodeProvider.videoList?[position].name,
            episodeProvider.videoList?[position].id,
            episodeProvider.videoList?[position].contentId,
            "video");
      } else {
        Utils.openPlayer(
            context: context,
            playType: "video",
            videoId: dataList[position].id ?? 0,
            videoType: dataList[position].contentType ?? 0,
            videoUrl: dataList[position].video ?? "",
            uploadType: dataList[position].videoType.toString(),
            videoThumb: dataList[position].image ?? "",
            vStopTime: dataList[position].stopTime ?? 0,
            contentID: dataList[position].contentId ?? 0);
      }
    } else {
      Utils.openPlayer(
          context: context,
          playType: "video",
          videoId: dataList[position].id ?? 0,
          videoType: dataList[position].contentType ?? 0,
          videoUrl: dataList[position].video ?? "",
          uploadType: dataList[position].videoType.toString(),
          videoThumb: dataList[position].image ?? "",
          vStopTime: dataList[position].stopTime ?? 0,
          contentID: dataList[position].contentId ?? 0);
    }
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
                      onTap: () async {
                        printLog("Clicked on Close!");
                        commentController.clear();
                        ratingGiven = null;
                        // detailprovider.resetCommentData();

                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
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
                maxLines: 10,
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
                          audioDetailsProvider
                              .contentdetailsModel.result?[0].id,
                          commentController.text,
                          audioDetailsProvider
                              .contentdetailsModel.result?[0].contentType,
                          ratingGiven ?? 0,
                        );
                        if (!mounted) return;
                        Utils().hideProgress(context);
                        commentController.clear();

                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                        // setState(() {});
                        _getData();
                      } else {
                        Utils.showToast(pleaseaddcomment);
                      }
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginSocial(
                                    ishome: false,
                                  )));
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
  /* Add Review - Reating END */

  Widget _reviewAndPlay() {
    return Container(
      height: 50,
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                    fontsizeNormal: 13,
                    fontweight: FontWeight.w600,
                    color: white,
                    text: formatNumber(audioDetailsProvider
                            .contentdetailsModel.result?[0].totalUserPlay ??
                        0)),
                const SizedBox(
                  height: 5,
                ),
                MyText(
                    fontsizeNormal: 11,
                    fontweight: FontWeight.w500,
                    color: white.withOpacity(0.7),
                    text: "Play")
              ],
            ),
          ),
          const VerticalDivider(
            color: white,
            thickness: 1,
          ),
          Flexible(
            child: Column(
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
                          fontsizeNormal: 15,
                          fontweight: FontWeight.w600,
                          color: white,
                          text: audioDetailsProvider
                                  .contentdetailsModel.result?[0].avgRating
                                  .toString() ??
                              "")),
                ),
                const SizedBox(
                  height: 5,
                ),
                MyText(
                    fontsizeNormal: 11,
                    fontweight: FontWeight.w500,
                    color: white.withOpacity(0.7),
                    text:
                        "${formatNumber(audioDetailsProvider.contentdetailsModel.result?[0].totalReviews ?? 0)} Reviews")
              ],
            ),
          ),
          const VerticalDivider(
            color: white,
            thickness: 1,
          ),
          // Flexible(
          //   child: MyText(
          //       maxline: 3,
          //       fontsizeNormal: 15,
          //       fontweight: FontWeight.w600,
          //       color: white,
          //       text: showDetailsProvider
          //               .contentdetailsModel.result?[0].languageName
          //               .toString() ??
          //           ""),
          // ),
          Flexible(
            child: InkWell(
              focusColor: gray.withOpacity(0.5),
              onTap: () async {
                printLog(
                    "isBookmark ====> ${audioDetailsProvider.contentdetailsModel.result?[0].isBookMark ?? 0}");
                AdHelper.showFullscreenAd(
                  context,
                  Constant.rewardAdType,
                  () async {
                    if (Constant.userID != null) {
                      await audioDetailsProvider.setBookMark(
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
                  },
                );
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
          ),

          const VerticalDivider(
            color: white,
            thickness: 1,
          ),
          Flexible(
            child: InkWell(
                onTap: () async {
                  // openReviewRatingDialog();
                  _buildShareWithDialog();
                },
                child: MyImage(
                    imagePath: "ic_sharedetails.png", height: 32, width: 32)),
          )
        ],
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
    required int? isAudioCoin,
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
      // If audio is free (isAudioPaid != 1) OR user has already bought it (isBuy == "1"), play directly
      if (isAudioPaid != 1 || isBuy == "1") {
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
        // Show purchase dialog only if audio is paid AND user hasn't bought it
        openBottomSheet(
            position, isAudioCoin, contentName, episodeid, contentid, "audio");
      }
    } else {
      Utils.openLogin(context: context, isHome: false, isReplace: false);
    }
  }

  addView(contentType, episodeid, contentId) async {
    final audiototalplayprovider =
        Provider.of<ShowDetailsProvider>(context, listen: false);
    await audiototalplayprovider.getAddContentPlay(1, episodeid, 1, contentId);
  }

  openBottomSheet(int index, coins, episodeName, episodeID, contentID, type) {
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
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
                                    ),
                                  );
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
                              
                              // Close the bottom sheet first
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                              
                              // Refresh all data to show unlocked content immediately
                              await Future.delayed(const Duration(milliseconds: 500));
                              if (!mounted) return;
                              
                              // Clear and reload audio data
                              await _getData();
                              
                              // Force UI update
                              setState(() {});
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
                            text: type == "audio"
                                ? "buythisepisode"
                                : "buythisvideo",
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
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const Subscription();
                              },
                            ),
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

/* ========= DEEP LINK SETUP DOCUMENTATION ========= */
  
  /// This method documents how to set up deep linking for audio sharing
  /// STEP 1: Configure iOS Deep Linking
  /// File: ios/Runner/Info.plist
  /// Add this inside <dict>:
  /*
  <key>CFBundleURLTypes</key>
  <array>
    <dict>
      <key>CFBundleURLName</key>
      <string>com.diamondnib.app</string>
      <key>CFBundleURLSchemes</key>
      <array>
        <string>diamondnib</string>
      </array>
    </dict>
  </array>
  
  <!-- Universal Links for iOS -->
  <key>com.apple.developer.associated-domains</key>
  <array>
    <string>applinks:diamondnib.com</string>
  </array>
  */
  
  /// STEP 2: Configure Android Deep Linking
  /// File: android/app/src/main/AndroidManifest.xml
  /// Modify the MainActivity intent-filter:
  /*
  <intent-filter>
    <action android:name="android.intent.action.MAIN" />
    <category android:name="android.intent.category.LAUNCHER" />
  </intent-filter>
  
  <!-- Deep Link Scheme: diamondnib:// -->
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
      android:scheme="diamondnib"
      android:host="audiobook" />
  </intent-filter>
  
  <!-- App Links: https://diamondnib.com -->
  <intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
      android:scheme="https"
      android:host="diamondnib.com"
      android:pathPrefix="/audiobook" />
  </intent-filter>
  */
  
  /// STEP 3: Handle Deep Links in main.dart
  /// Add this code to your main.dart:
  /*
  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Handle deep links
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        // Android: Handle app links
        final intent = await getInitialIntent();
        if (intent != null) {
          _handleDeepLink(intent.data?.toString());
        }
      } else if (Platform.isIOS) {
        // iOS: Handle URL schemes
        if (Constant.initialLink != null) {
          _handleDeepLink(Constant.initialLink);
        }
      }
    }
    
    runApp(const MyApp());
  }
  
  void _handleDeepLink(String? deepLink) {
    if (deepLink == null) return;
    
    try {
      final uri = Uri.parse(deepLink);
      
      if (uri.scheme == 'diamondnib' && uri.host == 'audiobook') {
        // Extract contentId and type from path: diamondnib://audiobook/123?type=1
        final contentId = uri.pathSegments.isNotEmpty 
          ? int.tryParse(uri.pathSegments[0]) 
          : null;
        final contentType = uri.queryParameters['type'];
        
        if (contentId != null && contentType != null) {
          // Navigate to audio details page
          Constant.deepLinkContentId = contentId;
          Constant.deepLinkContentType = int.parse(contentType);
          Constant.shouldOpenAudioDetails = true;
        }
      } else if (uri.scheme == 'https' && uri.host == 'diamondnib.com') {
        // Handle universal link: https://diamondnib.com/audiobook/123?type=1
        final pathSegments = uri.pathSegments;
        if (pathSegments.length >= 2 && pathSegments[0] == 'audiobook') {
          final contentId = int.tryParse(pathSegments[1]);
          final contentType = uri.queryParameters['type'];
          
          if (contentId != null && contentType != null) {
            Constant.deepLinkContentId = contentId;
            Constant.deepLinkContentType = int.parse(contentType);
            Constant.shouldOpenAudioDetails = true;
          }
        }
      }
    } catch (e) {
      printLog('Error handling deep link: $e');
    }
  }
  */
  
  /// STEP 4: Add constants to Constant.dart
  /// Add these properties:
  /*
  static int? deepLinkContentId;
  static int? deepLinkContentType;
  static bool shouldOpenAudioDetails = false;
  static String? iosAppUrl = 'https://apps.apple.com/app/diamondnib/id1234567890';
  static String? androidAppUrl = 'https://play.google.com/store/apps/details?id=com.diamondnib.app';
  */
  
  /// STEP 5: Add website configuration
  /// Create assetlinks.json on your web server at: https://diamondnib.com/.well-known/assetlinks.json
  /*
  [
    {
      "relation": ["delegate_permission/common.handle_all_urls"],
      "target": {
        "namespace": "android_app",
        "package_name": "com.diamondnib.app",
        "sha256_cert_fingerprints": ["YOUR_ANDROID_SHA256_FINGERPRINT"]
      }
    }
  ]
  */
  
  /// Get your Android SHA256 fingerprint with:
  /// keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  
  /// STEP 6: Configure website redirect script
  /// Create a redirect script on: https://diamondnib.com/audiobook/{contentId}
  /// That detects the platform and redirects to:
  /// - iOS: Opens app with diamondnib://audiobook/{contentId}?type={contentType}
  /// - Android: Opens app with diamondnib://audiobook/{contentId}?type={contentType}
  /// - Web: Shows audio details page
  
  /// Example website HTML redirect:
  /*
  <!DOCTYPE html>
  <html>
  <head>
    <script>
      function redirectToApp() {
        const contentId = window.location.pathname.split('/')[2];
        const type = new URLSearchParams(window.location.search).get('type') || '1';
        const deepLink = 'diamondnib://audiobook/' + contentId + '?type=' + type;
        
        // Try to open the app
        window.location.href = deepLink;
        
        // If app is not installed, redirect to app store after 2 seconds
        setTimeout(() => {
          const userAgent = navigator.userAgent.toLowerCase();
          if (userAgent.includes('iphone') || userAgent.includes('ipad')) {
            window.location.href = 'https://apps.apple.com/app/diamondnib/id1234567890';
          } else {
            window.location.href = 'https://play.google.com/store/apps/details?id=com.diamondnib.app';
          }
        }, 2000);
      }
      
      // Redirect on page load
      window.onload = redirectToApp;
    </script>
  </head>
  <body>
    <p>Redirecting to Diamondnib...</p>
  </body>
  </html>
  */
}