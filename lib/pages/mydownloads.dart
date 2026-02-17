import 'dart:convert';
import 'package:diamondnib/model/downloadaudiobook.dart';
import 'package:diamondnib/pages/musicdetails.dart';
import 'package:diamondnib/pages/mychapterdownloads.dart';
import 'package:diamondnib/provider/downloadprovider.dart';
import 'package:diamondnib/provider/episodeprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/myfileimage.dart';
import 'package:diamondnib/widget/myimage.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:diamondnib/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class MyDownloads extends StatefulWidget {
  const MyDownloads({super.key});

  @override
  State<MyDownloads> createState() => _MyDownloadsState();
}

class _MyDownloadsState extends State<MyDownloads>
    with TickerProviderStateMixin {
  /* Create Instance And Initilize Hive */
  late Box<AudioBookBox> audioBookdownloadBox;
  late DownLoadProvider downloadProvider;

  List<AudioBookBox>? myAudioBookDetailsDownloadsList;
  late Box<AudioBookBox> novelDownloadBox;

  List<AudioBookBox>? myNovelDetailsDownloadsList;
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    downloadProvider = Provider.of<DownLoadProvider>(context, listen: false);
    controllerEvent();
    // Call _getData() only after the widget has been built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
  }

  controllerEvent() {
    _controller = TabController(length: 2, vsync: this, initialIndex: 0);
    _controller.addListener(() {
      downloadProvider.setTabPosition(_controller.index);
      printLog("Selected Index: ${_controller.index}");
    });
  }

  void _getData() async {
    // Check if user is logged in and fetch data from Hive
    if (Constant.userID != null) {
      audioBookdownloadBox = Hive.box<AudioBookBox>(
          '${Constant.hiveAudioBookDetailsDownloadBox}_${Constant.userID}');
      novelDownloadBox = Hive.box<AudioBookBox>(
          '${Constant.hiveNovelDownloadBox}_${Constant.userID}');
    } else {
      audioBookdownloadBox =
          Hive.box<AudioBookBox>(Constant.hiveAudioBookDetailsDownloadBox);
      novelDownloadBox = Hive.box<AudioBookBox>(Constant.hiveNovelDownloadBox);
    }

    // Fetch audio book downloads
    myAudioBookDetailsDownloadsList = audioBookdownloadBox.values.toList();
    myNovelDetailsDownloadsList = novelDownloadBox.values.toList();

    // Update the UI
    if (context.mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    downloadProvider.downalodClearProvider();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: appbgcolor,
        appBar: Utils.myAppBarWithBack(context, "downloads", true, true),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  // child: _buildAudioDownloadList(),
                  child: Consumer<DownLoadProvider>(
                    builder: (context, downloadProvider, child) {
                      return _buildTabs();
                    },
                  ),
                ),
              ),
              /* AdMob Banner */
              Container(
                child: Utils.showBannerAd(context),
              ),
            ],
          ),
        ),
      ),
      Utils.buildMusicPanel(context)
    ]);
  }

  Widget _buildTabs() {
    return Column(
      children: [
        TabBar(
          controller: _controller,
          labelPadding: const EdgeInsets.all(5),
          unselectedLabelColor: white,
          indicatorColor: transparentColor,
          labelColor: colorAccent,
          tabs: [
            Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              decoration: BoxDecoration(
                  color: _controller.index == 0
                      ? colorPrimaryLight
                      : colorPrimaryDark,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  MyImage(
                    imagePath: "ic_audiobook.png",
                    height: 30,
                    width: 30,
                    color: white,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        fontsizeWeb: 15,
                        color: white,
                        text: "AudioBook",
                        fontsizeNormal: 14,
                      ),
                      MyText(
                        fontsizeWeb: 15,
                        color: colorAccent,
                        fontweight: FontWeight.w600,
                        text:
                            " (${myAudioBookDetailsDownloadsList?.length.toString() ?? ""})",
                        fontsizeNormal: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
              decoration: BoxDecoration(
                  color: _controller.index == 1
                      ? colorPrimaryLight
                      : colorPrimaryDark,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                children: [
                  MyImage(
                    imagePath: "ic_novel.png",
                    height: 25,
                    width: 25,
                    color: white,
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                        fontsizeWeb: 15,
                        color: white,
                        text: "Novel",
                        fontsizeNormal: 14,
                      ),
                      MyText(
                        fontsizeWeb: 15,
                        color: colorAccent,
                        fontweight: FontWeight.w600,
                        text:
                            " (${myNovelDetailsDownloadsList?.length.toString() ?? ""})",
                        fontsizeNormal: 14,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        _tabbarview(),
      ],
    );
  }

  Widget _tabbarview() {
    switch (downloadProvider.selectedTab) {
      case 0:
        return _buildAudioDownloadList();
      case 1:
        return _buildNovelDownloadList();

      default:
        return _buildAudioDownloadList();
    }
  }

  Widget _buildAudioDownloadList() {
    return Consumer<EpisodeProvider>(
      builder: (context, downloadProvider, child) {
        if (myAudioBookDetailsDownloadsList != null) {
          if ((myAudioBookDetailsDownloadsList?.length ?? 0) > 0) {
            return AlignedGridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 0,
              mainAxisSpacing: 8,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myAudioBookDetailsDownloadsList?.length ?? 0,
              itemBuilder: (BuildContext context, int position) {
                if (myAudioBookDetailsDownloadsList?[position].contentType ==
                    1) {
                  return _buildAudioDownloadItem(position);
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          } else {
            return const NoData(title: 'no_downloads', subTitle: '');
          }
        } else {
          return const NoData(title: 'no_downloads', subTitle: '');
        }
      },
    );
  }

  Widget _buildNovelDownloadList() {
    return Consumer<EpisodeProvider>(
      builder: (context, downloadProvider, child) {
        if (myNovelDetailsDownloadsList != null) {
          if ((myNovelDetailsDownloadsList?.length ?? 0) > 0) {
            return AlignedGridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              crossAxisSpacing: 0,
              scrollDirection: Axis.vertical,
              mainAxisSpacing: 8,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: myNovelDetailsDownloadsList?.length ?? 0,
              itemBuilder: (BuildContext context, int position) {
                if (myNovelDetailsDownloadsList?[position].contentType == 2) {
                  return _buildNovelDownloadItem(position);
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          } else {
            return const NoData(title: 'no_downloads', subTitle: '');
          }
        } else {
          return const NoData(title: 'no_downloads', subTitle: '');
        }
      },
    );
  }

  Widget _buildNovelDownloadItem(position) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 5, 10),
      width: MediaQuery.of(context).size.width,
      // constraints: const BoxConstraints(maxHeight: 150),
      // color: colorPrimary,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyChapterDownloads(
                      title: myNovelDetailsDownloadsList?[position].title ?? "",
                      contentType:
                          myNovelDetailsDownloadsList?[position].contentType ??
                              0,
                      id: myNovelDetailsDownloadsList?[position].id ??
                          0))).then(
            (value) {
              _getData();
            },
          );
        },
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                Container(
                  constraints: const BoxConstraints(
                    // minHeight: 50,
                    maxWidth: 100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: MyFileImage(
                      height: 100,
                      width: 100,
                      imagePath:
                          myNovelDetailsDownloadsList?[position].portraitImg ??
                              "",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // _buildWatchBtn(position)
              ],
            ),
            Container(
              constraints: BoxConstraints(
                // minHeight: Dimens.heightWatchlist,
                maxWidth: MediaQuery.of(context).size.width * 0.66,
              ),
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(8),
                    child: MyText(
                      color: white,
                      text: myNovelDetailsDownloadsList?[position].title ?? "",
                      textalign: TextAlign.start,
                      maxline: 2,
                      overflow: TextOverflow.ellipsis,
                      fontsizeNormal: 13,
                      fontweight: FontWeight.w600,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                  // Positioned(
                  //   bottom: 10,
                  //   right: 10,
                  //   child: InkWell(
                  //     onTap: () async {
                  //       _buildVideoMoreDialog(position);
                  //     },
                  //     child: Container(
                  //       width: 25,
                  //       height: 25,
                  //       alignment: Alignment.center,
                  //       padding: const EdgeInsets.all(6),
                  //       child: const Icon(
                  //         Icons.more_vert_rounded,
                  //         color: white,
                  //         size: 22,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioDownloadItem(position) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 5, 10),
      width: MediaQuery.of(context).size.width,
      // constraints: const BoxConstraints(maxHeight: 150),
      // color: colorPrimary,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MyChapterDownloads(
                      title: myAudioBookDetailsDownloadsList?[position].title ??
                          "",
                      contentType: myAudioBookDetailsDownloadsList?[position]
                              .contentType ??
                          0,
                      id: myAudioBookDetailsDownloadsList?[position].id ??
                          0))).then(
            (value) {
              _getData();
            },
          );
        },
        child: Column(
          children: [
            Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                Container(
                  constraints: const BoxConstraints(
                    // minHeight: 50,
                    maxWidth: 100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: MyFileImage(
                      height: 110,
                      width: 110,
                      imagePath: myAudioBookDetailsDownloadsList?[position]
                              .portraitImg ??
                          "",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // _buildWatchBtn(position)
              ],
            ),
            Container(
              constraints: BoxConstraints(
                // minHeight: Dimens.heightWatchlist,
                maxWidth: MediaQuery.of(context).size.width * 0.66,
              ),
              child: Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.all(8),
                    child: MyText(
                      color: white,
                      text: myAudioBookDetailsDownloadsList?[position].title ??
                          "",
                      textalign: TextAlign.start,
                      maxline: 2,
                      overflow: TextOverflow.ellipsis,
                      fontsizeNormal: 12,
                      fontweight: FontWeight.w600,
                      fontstyle: FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<bool> deleteFromDownloads(position) async {
  //   printLog("deleteFromDownloads pos ===> $position");
  //   printLog(
  //       "deleteFromDownloads id ====> ${audioBookdownloadBox.get(position)}");
  //   if (!mounted) return false;
  //   /* Remove from Hive START ***************** */
  //   printLog(
  //       "downloadBox length :======> ${audioBookdownloadBox.values.toList().length}");

  //   if (audioBookdownloadBox.values.toList().isNotEmpty) {
  //     /* Video/Show Delete */
  //     for (int i = 0; i < audioBookdownloadBox.values.toList().length; i++) {
  //       final myDownloadData = audioBookdownloadBox.getAt(i);
  //       if (myDownloadData != null &&
  //           myDownloadData.id ==
  //               myAudioBookDetailsDownloadsList?[position].id &&
  //           myDownloadData.contentType ==
  //               myAudioBookDetailsDownloadsList?[position].contentType) {
  //         printLog(
  //             "myDownloadsList showId =======> ${myAudioBookDetailsDownloadsList?[position].id}");
  //         printLog("myDownloadData showId ========> ${myDownloadData.id}");

  //         if (myDownloadData.savedFile != null &&
  //             myDownloadData.savedFile != "") {
  //           try {
  //             File filePath = File(myDownloadData.savedFile ?? "");
  //             File filePortImgPath = File(myDownloadData.portraitImg ?? "");
  //             File fileLandImgPath = File(myDownloadData.landscapeImg ?? "");
  //             printLog("myDownloadData filePath =============> $filePath");
  //             printLog(
  //                 "myDownloadData filePortImgPath ======> $filePortImgPath");
  //             printLog(
  //                 "myDownloadData fileLandImgPath ======> $fileLandImgPath");
  //             bool? isFileExists = await filePath.exists();
  //             bool? isPortImgFileExists = await filePortImgPath.exists();
  //             bool? isLandImgFileExists = await fileLandImgPath.exists();
  //             printLog("myDownloadData isFileExists =========> $isFileExists");
  //             printLog(
  //                 "myDownloadData isPortImgFileExists ==> $isPortImgFileExists");
  //             printLog(
  //                 "myDownloadData isLandImgFileExists ==> $isLandImgFileExists");
  //             if (isFileExists) {
  //               await filePath.delete();
  //             }
  //             if (isPortImgFileExists) {
  //               await filePortImgPath.delete();
  //             }
  //             if (isLandImgFileExists) {
  //               await fileLandImgPath.delete();
  //             }
  //           } on Exception catch (exception) {
  //             printLog("Video DeleteFile Exception ==> $exception");
  //           }
  //         }
  //         await audioBookdownloadBox.deleteAt(i);
  //         if (audioBookdownloadBox.isEmpty) {
  //           audioBookdownloadBox.clear();
  //           if ((myDownloadData.savedDir ?? "").isNotEmpty) {
  //             try {
  //               String dirPath = myDownloadData.savedDir ?? "";
  //               printLog("dirPath ==> $dirPath");
  //               File dirFolder = File(dirPath);
  //               printLog("File existsSync ==> ${dirFolder.existsSync()}");
  //               dirFolder.deleteSync(recursive: true);
  //             } on Exception catch (exception) {
  //               printLog("All Delete Exception ==> $exception");
  //             }
  //           }
  //         }
  //       }
  //     }
  //     printLog("downloadBox length :======> ${audioBookdownloadBox.length}");
  //   } else {
  //     audioBookdownloadBox.clear();
  //   }
  //   /* ******************* Remove from Hive END */
  //   myAudioBookDetailsDownloadsList?.removeAt(position);
  //   setState(() {});
  //   return true;
  // }

  /* PlayAudio Player */
  Future<void> playAudio(
      {required String playingType,
      required String episodeid,
      required String contentid,
      String? podcastimage,
      String? contentUserid,
      required int position,
      required List<AudioBookBox>? sectionBannerList,
      dynamic playlistImages,
      required String contentName,
      required String? isBuy,
      required dynamic sectionId}) async {
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
    // if (playingType == "2") {
    if (Constant.userID != null) {
      Constant.musicsectionId = sectionId.toString();
      musicManager.setDownloadInitialMusic(
        position,
        playingType,
        sectionBannerList,
        contentid,
        // addView(playingType, contentid),
        () {},
        false,
        0,
        isBuy ?? "",
        1,
        "music",
        "0",
        () {
          setState(() {
            printLog("setState Callign ");
          });
        },
      );
    } else {
      Utils.openLogin(context: context, isHome: true, isReplace: false);
    }
  }
}
