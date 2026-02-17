import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:diamondnib/model/download_item.dart';
import 'package:diamondnib/model/downloadaudiobook.dart';
import 'package:diamondnib/pages/musicdetails.dart';
import 'package:diamondnib/provider/downloadprovider.dart';
import 'package:diamondnib/provider/episodeprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/dimens.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/widget/myfileimage.dart';
import 'package:diamondnib/widget/myimage.dart';
import 'package:diamondnib/widget/mytext.dart';
import 'package:diamondnib/widget/nodata.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive/hive.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class MyChapterDownloads extends StatefulWidget {
  final int id, contentType;
  final String title;
  const MyChapterDownloads(
      {super.key,
      required this.id,
      required this.title,
      required this.contentType});

  @override
  State<MyChapterDownloads> createState() => _MyChapterDownloadsState();
}

class _MyChapterDownloadsState extends State<MyChapterDownloads> {
  late DownLoadProvider downloadProvider;
  /* Create Instance And Initilize Hive */
  late ProgressDialog prDialog;

  late Box<DownloadEpisodeItem> episodeBox;
  List<DownloadEpisodeItem>? myEpisodeList;
  late Box<AudioBookBox> downloadBox;
  List<AudioBookBox>? downloadBoxList;

  BuildContext? _dialogContext;

  @override
  void initState() {
    prDialog = ProgressDialog(context);

    printLog("ContentType == ${widget.contentType}");
    downloadProvider = Provider.of<DownLoadProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getData();
    });
    super.initState();
  }

  @override
  void dispose() {
    downloadProvider.downLoadclearProvider();
    super.dispose();
  }

  void openPDF(String filePath) {
    final file = File(filePath);
    printLog("File(widget.filePath)== $file");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            leading: InkWell(
              onTap: () {
                Navigator.maybePop(context);
              },
              child: Utils().backBtn(25, 25, 20),
            ),
          ),
          body: PopScope(
            onPopInvoked: (didPop) async {
              Navigator.maybePop(context);
            },
            child: SfPdfViewer.file(file),
          ),
        ),
      ),
    );
  }

  _getData() async {
    /* Initilize Hive */
    if (!kIsWeb) {
      if (widget.contentType == 1) {
        if (Constant.userID != null) {
          episodeBox = Hive.box<DownloadEpisodeItem>(
              '${Constant.audioEpisodeDownloadBox}_${Constant.userID}');
          downloadBox = Hive.box<AudioBookBox>(
              '${Constant.hiveAudioBookDetailsDownloadBox}_${Constant.userID}');
        } else {
          episodeBox =
              Hive.box<DownloadEpisodeItem>(Constant.audioEpisodeDownloadBox);
          downloadBox =
              Hive.box<AudioBookBox>(Constant.hiveAudioBookDetailsDownloadBox);
        }
      } else {
        if (Constant.userID != null) {
          episodeBox = Hive.box<DownloadEpisodeItem>(
              '${Constant.novelChapterDownloadBox}_${Constant.userID}');
          downloadBox = Hive.box<AudioBookBox>(
              '${Constant.hiveNovelDownloadBox}_${Constant.userID}');
        } else {
          episodeBox =
              Hive.box<DownloadEpisodeItem>(Constant.novelChapterDownloadBox);
          downloadBox = Hive.box<AudioBookBox>(Constant.hiveNovelDownloadBox);
        }
      }
    }

    myEpisodeList = [];
    myEpisodeList = episodeBox.values.where((episodeItem) {
      return (episodeItem.bookId == widget.id);
    }).toList();
    printLog("myEpisodeList ================> ${myEpisodeList?.length}");
    printLog(
        "myEpisodeList =====????===========> ${jsonEncode(myEpisodeList)}");

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: appbgcolor,
        appBar: Utils.myAppBarWithBack(context, widget.title, true, false),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: _buildDownloadList(),
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

  Widget _buildDownloadList() {
    return Consumer<EpisodeProvider>(
      builder: (context, downloadProvider, child) {
        if (myEpisodeList != null) {
          if ((myEpisodeList?.length ?? 0) > 0) {
            return Stack(children: [
              AlignedGridView.count(
                shrinkWrap: true,
                crossAxisCount: 1,
                crossAxisSpacing: 0,
                mainAxisSpacing: 8,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myEpisodeList?.length ?? 0,
                itemBuilder: (BuildContext context, int position) {
                  return _buildDownloadItem(position);
                },
              ),
              Positioned(child: Consumer<DownLoadProvider>(
                builder: (context, value, child) {
                  if (value.decryptloading) {
                    if (_dialogContext == null) {
                      Future.microtask(() => showPleaseWaitDialog(context));
                    }
                  } else {
                    if (_dialogContext != null) {
                      Navigator.of(_dialogContext!).pop();
                      _dialogContext = null; // Reset the dialog context
                    }
                  }
                  return const SizedBox.shrink();
                },
              ))
            ]);
          } else {
            return const NoData(title: 'no_downloads', subTitle: '');
          }
        } else {
          return const NoData(title: 'no_downloads', subTitle: '');
        }
      },
    );
  }

  Widget waitingDialog() {
    return AlertDialog(
      backgroundColor: transparentColor,
      elevation: 0,
      contentPadding: const EdgeInsets.all(5),
      content: Container(
        height: 80,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        decoration: Utils.setBackground(white, 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Utils.pageLoader(),
            const SizedBox(width: 20),
            Expanded(
              child: Container(
                alignment: Alignment.centerLeft,
                child: MyText(
                  color: colorPrimary,
                  text: "Please Wait",
                  fontstyle: FontStyle.normal,
                  fontsizeNormal: 14,
                  maxline: 1,
                  fontsizeWeb: 15,
                  overflow: TextOverflow.ellipsis,
                  fontweight: FontWeight.w600,
                  textalign: TextAlign.start,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showPleaseWaitDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        _dialogContext = context;
        return waitingDialog();
      },
    );
  }

  Widget _buildDownloadItem(int position) {
    printLog(
        "landscapeImg  ======== ${myEpisodeList?[position].landscapeImg ?? ""}");
    printLog(
        "portraitImg  ======== ${myEpisodeList?[position].portraitImg ?? ""}");

    // Get the current item ID to track its download status

    return Consumer<DownLoadProvider>(
      builder: (context, downloadProvider, child) {
        // Load the download status for the current item ID
        // int downloadProgress = downloadProvider.downloadPercentage;
        // bool isDownloading = downloadProvider.isLoading;
        // final progress = downloadProvider
        //     .getDownloadProgress(myEpisodeList?[position].id ?? 0);
        // final isDownloading =
        //     downloadProvider.isDownloading(myEpisodeList?[position].id ?? 0);
        final progress = downloadProvider
                .downloadProgressMap[myEpisodeList?[position].id ?? 0]
                ?.progress ??
            0;
        final isDownloading = downloadProvider
                .downloadProgressMap[myEpisodeList?[position].id ?? 0]
                ?.isDownloading ??
            false;

        // Load the download status for the current item
        downloadProvider.loadDownloadStatus(myEpisodeList?[position].id ?? 0);

        return
            // Stack(
            //   children: [
            isDownloading
                ? Stack(
                    children: [
                      Container(
                        height: 80,
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        width: MediaQuery.of(context).size.width,
                        // constraints: const BoxConstraints(maxHeight: 200),
                        color: colorPrimary,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            if (isDownloading) {
                              Utils.showSnackbar(
                                  context, "info", "please_wait", true);
                            }
                            // else {
                            //   File? tempFile;

                            //   if (myEpisodeList?[position].contentType == 2) {
                            //     await Future.delayed(
                            //       Duration.zero,
                            //       () {
                            //         Utils().showProgressNew(
                            //           context,
                            //         );
                            //       },
                            //     );

                            //     final receivePort = ReceivePort();
                            //     var rootToken = RootIsolateToken.instance!;
                            //     final isolate =
                            //         await Isolate.spawn(Utils.decryptFile, [
                            //       File(
                            //           myEpisodeList?[position].savedFile ?? ""),
                            //       myEpisodeList?[position].securityKey ?? "",
                            //       receivePort.sendPort,
                            //       rootToken
                            //     ]);
                            //     if (!mounted) return;

                            //     receivePort.listen((message) async {
                            //       await Future.delayed(
                            //         Duration.zero,
                            //         () {
                            //           Utils().hideProgressNew(
                            //             context,
                            //           );
                            //         },
                            //       );
                            //       if (message != null) {
                            //         tempFile = message;
                            //         printLog(
                            //             "tempFile ===isolate===> $tempFile");

                            //         receivePort.close();
                            //         isolate.kill(priority: Isolate.immediate);
                            //         if (tempFile != null) {
                            //           printLog(
                            //               "tempFile ===isolate===> $tempFile");

                            //           openPDF(tempFile?.path.toString() ?? "");
                            //           printLog(
                            //               "songUrl ==== ${tempFile?.path}");
                            //         }
                            //       }
                            //     });
                            //     /* ********************** Decrypt Without Freez END */
                            //   } else {
                            //     playAudio(
                            //         playingType: myEpisodeList?[position]
                            //                 .contentType
                            //                 .toString() ??
                            //             "",
                            //         episodeid: myEpisodeList?[position]
                            //                 .id
                            //                 .toString() ??
                            //             "",
                            //         contentid: myEpisodeList?[position]
                            //                 .contentId
                            //                 .toString() ??
                            //             "",
                            //         position: position,
                            //         sectionBannerList: myEpisodeList ?? [],
                            //         contentName: myEpisodeList?[position]
                            //                 .title
                            //                 .toString() ??
                            //             "",
                            //         isBuy: "1",
                            //         sectionId: "");
                            //   }
                            // }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: MyFileImage(
                                  height: 60,
                                  width: 60,
                                  imagePath:
                                      myEpisodeList?[position].image ?? "",
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Flexible(
                                child: Container(
                                  constraints: BoxConstraints(
                                    minHeight: Dimens.heightDownload,
                                  ),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MyText(
                                          color: colorAccent,
                                          text: myEpisodeList?[position].name ??
                                              "",
                                          textalign: TextAlign.start,
                                          maxline: 2,
                                          overflow: TextOverflow.ellipsis,
                                          fontsizeNormal: 12,
                                          fontweight: FontWeight.w600,
                                          fontstyle: FontStyle.normal,
                                        ),
                                        const SizedBox(height: 3),
                                        MyText(
                                          color: white,
                                          text: myEpisodeList?[position]
                                                  .description ??
                                              "",
                                          textalign: TextAlign.start,
                                          maxline: 1,
                                          overflow: TextOverflow.ellipsis,
                                          fontsizeNormal: 12,
                                          fontweight: FontWeight.w500,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              if (isDownloading)
                                // LinearProgressIndicator(
                                //   value: downloadProgress / 100,
                                //   backgroundColor: Colors.grey[300],
                                //   color: Colors.blue,
                                // )
                                MyText(
                                  color: blue,
                                  text: "${(progress).toString()}%",
                                  textalign: TextAlign.start,
                                  maxline: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontsizeNormal: 12,
                                  fontweight: FontWeight.w500,
                                  fontstyle: FontStyle.normal,
                                )
                              else
                                Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                    color: primaryLight,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: black,
                                    size: 18,
                                  ),
                                ),
                              _buildWatchBtn(position, false),
                              InkWell(
                                onTap: () async {
                                  // printLog(
                                  //     "Clicked on position =============> $position");
                                  // bool isDeleted =
                                  //     await deleteFromDownloads(position);
                                  // printLog(
                                  //     "isDeleted =============> $isDeleted");
                                },
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  margin:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.delete,
                                    color: white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 80,
                        color: isDownloading
                            ? black.withOpacity(0.5)
                            : transparentColor,
                      )
                    ],
                  )
                : Container(
                    height: 80,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    width: MediaQuery.of(context).size.width,
                    // constraints: const BoxConstraints(maxHeight: 200),
                    color: colorPrimary,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        if (isDownloading) {
                          Utils.showSnackbar(
                              context, "info", "please_wait", true);
                        } else {
                          File? tempFile;

                          if (myEpisodeList?[position].contentType == 2) {
                            await Future.delayed(
                              Duration.zero,
                              () {
                                Utils().showProgressNew(
                                  context,
                                );
                              },
                            );

                            final receivePort = ReceivePort();
                            var rootToken = RootIsolateToken.instance!;
                            final isolate =
                                await Isolate.spawn(Utils.decryptFile, [
                              File(myEpisodeList?[position].savedFile ?? ""),
                              myEpisodeList?[position].securityKey ?? "",
                              receivePort.sendPort,
                              rootToken
                            ]);
                            if (!mounted) return;

                            receivePort.listen((message) async {
                              await Future.delayed(
                                Duration.zero,
                                () {
                                  Utils().hideProgressNew(
                                    context,
                                  );
                                },
                              );
                              if (message != null) {
                                tempFile = message;
                                printLog("tempFile ===isolate===> $tempFile");

                                receivePort.close();
                                isolate.kill(priority: Isolate.immediate);
                                if (tempFile != null) {
                                  printLog("tempFile ===isolate===> $tempFile");

                                  openPDF(tempFile?.path.toString() ?? "");
                                  printLog("songUrl ==== ${tempFile?.path}");
                                }
                              }
                            });
                            /* ********************** Decrypt Without Freez END */
                          } else {
                            playAudio(
                                playingType: myEpisodeList?[position]
                                        .contentType
                                        .toString() ??
                                    "",
                                episodeid:
                                    myEpisodeList?[position].id.toString() ??
                                        "",
                                contentid: myEpisodeList?[position]
                                        .contentId
                                        .toString() ??
                                    "",
                                position: position,
                                sectionBannerList: myEpisodeList ?? [],
                                contentName:
                                    myEpisodeList?[position].title.toString() ??
                                        "",
                                isBuy: "1",
                                sectionId: "");
                          }
                        }
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: MyFileImage(
                              height: 60,
                              width: 60,
                              imagePath: myEpisodeList?[position].image ?? "",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Flexible(
                            child: Container(
                              constraints: BoxConstraints(
                                minHeight: Dimens.heightDownload,
                              ),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MyText(
                                      color: colorAccent,
                                      text: myEpisodeList?[position].name ?? "",
                                      textalign: TextAlign.start,
                                      maxline: 2,
                                      overflow: TextOverflow.ellipsis,
                                      fontsizeNormal: 12,
                                      fontweight: FontWeight.w600,
                                      fontstyle: FontStyle.normal,
                                    ),
                                    const SizedBox(height: 3),
                                    MyText(
                                      color: white,
                                      text: myEpisodeList?[position]
                                              .description ??
                                          "",
                                      textalign: TextAlign.start,
                                      maxline: 1,
                                      overflow: TextOverflow.ellipsis,
                                      fontsizeNormal: 12,
                                      fontweight: FontWeight.w500,
                                      fontstyle: FontStyle.normal,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (isDownloading)
                            // LinearProgressIndicator(
                            //   value: downloadProgress / 100,
                            //   backgroundColor: Colors.grey[300],
                            //   color: Colors.blue,
                            // )
                            MyText(
                              color: blue,
                              text: "${(progress).toString()}%",
                              textalign: TextAlign.start,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              fontsizeNormal: 12,
                              fontweight: FontWeight.w500,
                              fontstyle: FontStyle.normal,
                            )
                          else
                            Container(
                              height: 20,
                              width: 20,
                              decoration: BoxDecoration(
                                color: primaryLight,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(
                                Icons.check,
                                color: black,
                                size: 18,
                              ),
                            ),
                          _buildWatchBtn(position, true),
                          InkWell(
                            onTap: () async {
                              // printLog(
                              //     "Clicked on position =============> $position");
                              // bool isDeleted =
                              //     await deleteFromDownloads(position);
                              // printLog("isDeleted =============> $isDeleted");
                              deleteConfirmDialog(position);
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              margin: const EdgeInsets.only(
                                  left: 5, right: 5, bottom: 5),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.delete,
                                color: white,
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                      //   Container(
                      //     height: 80,
                      //     color:
                      //         isDownloading ? black.withOpacity(0.5) : transparentColor,
                      //   )
                      // ],
                      // ),
                    ),
                  );
        //   Container(
        //     height: 80,
        //     color: isDownloading ? black.withOpacity(0.5) : transparentColor,
        //   )
        // ],
        // );
      },
    );
  }

  Widget _buildWatchBtn(position, bool isOnTap) {
    return InkWell(
      onTap: () async {
        if (isOnTap) {
          File? tempFile;

          if (myEpisodeList?[position].contentType == 2) {
            await Future.delayed(
              Duration.zero,
              () {
                Utils().showProgressNew(
                  context,
                );
              },
            );

            final receivePort = ReceivePort();
            var rootToken = RootIsolateToken.instance!;
            final isolate = await Isolate.spawn(Utils.decryptFile, [
              File(myEpisodeList?[position].savedFile ?? ""),
              myEpisodeList?[position].securityKey ?? "",
              receivePort.sendPort,
              rootToken
            ]);
            if (!mounted) return;

            receivePort.listen((message) async {
              await Future.delayed(
                Duration.zero,
                () {
                  Utils().hideProgressNew(
                    context,
                  );
                },
              );
              if (message != null) {
                tempFile = message;
                printLog("tempFile ===isolate===> $tempFile");

                receivePort.close();
                isolate.kill(priority: Isolate.immediate);
                if (tempFile != null) {
                  printLog("tempFile ===isolate===> $tempFile");

                  openPDF(tempFile?.path.toString() ?? "");
                  printLog("songUrl ==== ${tempFile?.path}");
                }
              }
            });
            /* ********************** Decrypt Without Freez END */
          } else {
            playAudio(
                playingType:
                    myEpisodeList?[position].contentType.toString() ?? "",
                episodeid: myEpisodeList?[position].id.toString() ?? "",
                contentid: myEpisodeList?[position].contentId.toString() ?? "",
                position: position,
                sectionBannerList: myEpisodeList ?? [],
                contentName: myEpisodeList?[position].title.toString() ?? "",
                isBuy: "1",
                sectionId: "");
          }
        } else {
          Utils.showSnackbar(context, "info", "please_wait", true);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 5),
        child: myEpisodeList?[position].contentType == 2
            ? MyText(
                text: "readnow",
                multilanguage: true,
                fontsizeNormal: 10,
                fontsizeWeb: 11,
                color: white,
                fontstyle: FontStyle.normal,
                fontweight: FontWeight.w400,
                maxline: 2,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.start,
              )
            : const Icon(
                Icons.play_arrow_rounded,
                size: 30,
                color: white,
              ),
      ),
    );
  }

  _buildVideoMoreDialog(position) {
    showModalBottomSheet(
      context: context,
      backgroundColor: black,
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
                  /* Title */
                  MyText(
                    text: myEpisodeList?[position].title ?? "",
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

                  /* Watch Now / Resume */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () async {
                      File? tempFile;
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }

                      if (myEpisodeList?[position].contentType == 2) {
                        Utils().showProgressNew(
                          context,
                        );

                        final receivePort = ReceivePort();
                        var rootToken = RootIsolateToken.instance!;
                        final isolate = await Isolate.spawn(Utils.decryptFile, [
                          File(myEpisodeList?[position].savedFile ?? ""),
                          myEpisodeList?[position].securityKey ?? "",
                          receivePort.sendPort,
                          rootToken
                        ]);
                        if (!context.mounted) return;

                        Utils().hideProgressNew(
                          context,
                        );

                        receivePort.listen((message) async {
                          if (message != null) {
                            tempFile = message;
                            printLog("tempFile ===isolate===> $tempFile");

                            receivePort.close();
                            isolate.kill(priority: Isolate.immediate);
                            if (tempFile != null) {
                              printLog("tempFile ===isolate===> $tempFile");

                              openPDF(tempFile?.path.toString() ?? "");
                              printLog("songUrl ==== ${tempFile?.path}");
                            }
                          }
                        });
                        /* ********************** Decrypt Without Freez END */
                      } else {
                        playAudio(
                            playingType: myEpisodeList?[position]
                                    .contentType
                                    .toString() ??
                                "",
                            episodeid:
                                myEpisodeList?[position].id.toString() ?? "",
                            contentid:
                                myEpisodeList?[position].contentId.toString() ??
                                    "",
                            position: position,
                            sectionBannerList: myEpisodeList ?? [],
                            contentName:
                                myEpisodeList?[position].title.toString() ?? "",
                            isBuy: "1",
                            sectionId: "");
                      }
                      await Future.delayed(
                        Duration.zero,
                        () {
                          setState(() {});
                        },
                      );
                    },
                    child: _buildDialogItems(
                      icon: "ic_play.png",
                      title: myEpisodeList?[position].contentType == 2
                          ? "readnow"
                          : "watch_now",
                      isMultilang: true,
                    ),
                  ),

                  /* Download Add/Delete */
                  InkWell(
                    borderRadius: BorderRadius.circular(5),
                    onTap: () async {
                      printLog("Clicked on position =============> $position");
                      bool isDeleted = await deleteFromDownloads(position);
                      printLog("isDeleted =============> $isDeleted");
                      if (isDeleted) {
                        if (!context.mounted) return;
                        Navigator.pop(context);
                      }
                    },
                    child: _buildDialogItems(
                      icon: myEpisodeList?[position].isDownload == 1
                          ? "ic_delete.png"
                          : "ic_download.png",
                      title: myEpisodeList?[position].isDownload == 1
                          ? "delete_download"
                          : "download",
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

  // Future<bool> deleteFromDownloads(position) async {
  //   printLog("deleteFromDownloads pos ===> $position");
  //   printLog("deleteFromDownloads id ====> ${downloadBox.get(position)?.id}");
  //   if (!mounted) return false;
  //   /* Remove from Hive START ***************** */
  //   printLog(
  //       "downloadBox length :======> ${downloadBox.values.toList().length}");
  //   printLog(
  //       "episodeBox length :=======> ${episodeBox.values.toList().length}");
  //   /* Episode Delete */
  //   for (int i = 0; i < episodeBox.values.toList().length; i++) {
  //     final myEpisodeData = episodeBox.getAt(i);
  //     printLog("myEpisodeData ====> $myEpisodeData");
  //     if (myEpisodeData != null &&
  //         myEpisodeData.id == myEpisodeList?[position].id &&
  //         myEpisodeData.id == myEpisodeList?[position].id) {
  //       printLog("myDownloadsList showId ====> ${myEpisodeList?[position].id}");
  //       printLog("myEpisodeData showId ======> ${myEpisodeData.id}");
  //       if (myEpisodeData.savedFile != null && myEpisodeData.savedFile != "") {
  //         try {
  //           File filePath = File(myEpisodeData.savedFile ?? "");
  //           File filePortImgPath = File(myEpisodeData.image ?? "");
  //           // File fileLandImgPath = File(myEpisodeData.image ?? "");
  //           printLog("myEpisodeData filePath =============> $filePath");
  //           printLog("myEpisodeData filePortImgPath ======> $filePortImgPath");
  //           // printLog("myEpisodeData fileLandImgPath ======> $fileLandImgPath");
  //           bool? isFileExists = await filePath.exists();
  //           bool? isPortImgFileExists = await filePortImgPath.exists();
  //           // bool? isLandImgFileExists = await fileLandImgPath.exists();
  //           printLog("myEpisodeData isFileExists =========> $isFileExists");
  //           printLog(
  //               "myEpisodeData isPortImgFileExists ==> $isPortImgFileExists");
  //           // printLog(
  //           //     "myEpisodeData isLandImgFileExists ==> $isLandImgFileExists");
  //           if (isFileExists) {
  //             await filePath.delete();
  //           }
  //           if (isPortImgFileExists) {
  //             await filePortImgPath.delete();
  //           }
  //           // if (isLandImgFileExists) {
  //           //   await fileLandImgPath.delete();
  //           // }
  //         } on Exception catch (exception) {
  //           printLog("Episode DeleteFile Exception ==> $exception");
  //         }
  //       }
  //       await episodeBox.deleteAt(i);
  //       if (episodeBox.isEmpty) {
  //         episodeBox.clear();
  //         if ((myEpisodeData.savedDir ?? "").isNotEmpty) {
  //           try {
  //             String dirPath = myEpisodeData.savedDir ?? "";
  //             printLog("dirPath ==> $dirPath");
  //             File dirFolder = File(dirPath);
  //             printLog("File existsSync ==> ${dirFolder.existsSync()}");
  //             dirFolder.deleteSync(recursive: true);
  //           } on Exception catch (exception) {
  //             printLog("Episode Delete Exception ==> $exception");
  //           }
  //         }
  //       }
  //     }
  //   }
  //   if (episodeBox.values.toList().isEmpty) {
  //     episodeBox.clear();
  //   }
  //   printLog("episodeBox length :=======> ${episodeBox.length}");
  //   printLog(
  //       "episodeBox length :=======> ${episodeBox.values.toList().length}");
  //   if (downloadBox.values.toList().isNotEmpty &&
  //       (episodeBox.values.toList().isEmpty || episodeBox.isEmpty)) {
  //     /* Video/Show Delete */
  //     for (int i = 0; i < downloadBox.values.toList().length; i++) {
  //       final myDownloadData = downloadBox.getAt(i);
  //       if (myDownloadData != null && myDownloadData.id == widget.id) {
  //         printLog("myDownloadsList showId =======> ${widget.id}");
  //         printLog("myDownloadData showId ========> ${myDownloadData.id}");

  //         await downloadBox.deleteAt(i);
  //         if (downloadBox.isEmpty) {
  //           downloadBox.clear();
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
  //     } // Check if all chapters of the audio book are deleted
  //     if (episodeBox.values.toList().isEmpty) {
  //       // Delete the audio book from the downloadBox
  //       for (int i = 0; i < downloadBox.values.toList().length; i++) {
  //         final myDownloadData = downloadBox.getAt(i);
  //         if (myDownloadData != null && myDownloadData.id == widget.id) {
  //           await downloadBox.deleteAt(i);
  //           if (downloadBox.isEmpty) {
  //             downloadBox.clear();
  //             if ((myDownloadData.savedDir ?? "").isNotEmpty) {
  //               try {
  //                 String dirPath = myDownloadData.savedDir ?? "";
  //                 printLog("dirPath ==> $dirPath");
  //                 File dirFolder = File(dirPath);
  //                 printLog("File existsSync ==> ${dirFolder.existsSync()}");
  //                 dirFolder.deleteSync(recursive: true);
  //               } on Exception catch (exception) {
  //                 printLog("All Delete Exception ==> $exception");
  //               }
  //             }
  //           }
  //         }
  //       }
  //     }

  //     printLog("downloadBox length :======> ${downloadBox.length}");
  //     if (downloadBox.length == 0) {
  //       downloadBox.clear();
  //       if (!mounted) return false;
  //       if (Navigator.canPop(context)) {
  //         Navigator.pop(context);
  //       }
  //     }
  //   }
  //   await downloadProvider.notifyProvider();
  //   /* ******************* Remove from Hive END */
  //   myEpisodeList?.removeAt(position);
  //   setState(() {});
  //   return true;
  // }

  Future<bool> deleteFromDownloads(int position) async {
    printLog("deleteFromDownloads pos ===> $position");

    if (!mounted) return false;

    // Get the episode that will be deleted
    final episodeToDelete = myEpisodeList?[position];
    if (episodeToDelete == null) return false;

    // Episode Deletion Logic
    for (int i = 0; i < episodeBox.values.length; i++) {
      final episode = episodeBox.getAt(i);

      // If the episode matches the one to delete
      if (episode != null && episode.id == episodeToDelete.id) {
        // Delete the files associated with the episode
        if (episode.savedFile != null && episode.savedFile!.isNotEmpty) {
          try {
            File filePath = File(episode.savedFile!);
            if (await filePath.exists()) {
              await filePath.delete();
            }
          } catch (exception) {
            printLog("Episode file deletion error: $exception");
          }
        }

        if (episode.image != null && episode.image!.isNotEmpty) {
          try {
            File imagePath = File(episode.image!);
            if (await imagePath.exists()) {
              await imagePath.delete();
            }
          } catch (exception) {
            printLog("Episode image deletion error: $exception");
          }
        }

        // Delete the episode from the Hive box
        await episodeBox.deleteAt(i);
        break;
      }
    }

    // After deleting the episode, check if there are any episodes left for this audiobook
    bool areAnyEpisodesLeftForAudiobook = episodeBox.values.any(
      (episode) =>
          episode.bookId == widget.id, // Checking for the specific audiobook ID
    );

    // If no episodes are left for the current audiobook, delete the audiobook from downloadBox
    if (!areAnyEpisodesLeftForAudiobook) {
      // Loop through the downloadBox to find the corresponding audiobook
      for (int i = 0; i < downloadBox.values.length; i++) {
        final audiobook = downloadBox.getAt(i);

        if (audiobook != null && audiobook.id == widget.id) {
          try {
            // Delete the audiobook from the Hive box
            await downloadBox.deleteAt(i);

            // If there is a saved directory, delete that folder
            if (audiobook.savedDir != null && audiobook.savedDir!.isNotEmpty) {
              File dirFolder = File(audiobook.savedDir!);
              if (dirFolder.existsSync()) {
                dirFolder.deleteSync(recursive: true);
              }
            }
          } catch (exception) {
            printLog("Audiobook deletion error: $exception");
          }
          break;
        }
      }
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    }

    await downloadProvider.notifyProvider();

    // Remove the deleted episode from the list in the UI
    myEpisodeList?.removeAt(position);
    setState(() {});
    if (!mounted) return false;
    // Pop the screen after the audiobook is deleted

    return true;
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
            color: white,
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

  /* PlayAudio Player */
  Future<void> playAudio(
      {required String playingType,
      required String episodeid,
      required String contentid,
      String? podcastimage,
      String? contentUserid,
      required int position,
      required List<DownloadEpisodeItem>? sectionBannerList,
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
        widget.title,
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

  deleteConfirmDialog(position) {
    showDialog<void>(
      context: context,
      // backgroundColor: colorPrimaryDark,
      // isScrollControlled: true,
      // shape: const RoundedRectangleBorder(
      //   borderRadius: BorderRadius.vertical(
      //     top: Radius.circular(0),
      //   ),
      // ),
      // clipBehavior: Clip.antiAliasWithSaveLayer,
      barrierDismissible: true,
      useSafeArea: true,

      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: Wrap(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(23),
                color: colorPrimaryDark,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            color: white,
                            text: "areyousurewanrtodelete",
                            fontsizeWeb: 12,
                            multilanguage: true,
                            textalign: TextAlign.start,
                            fontsizeNormal: 12,
                            fontweight: FontWeight.w500,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildDialogBtn(
                            title: 'cancel',
                            isPositive: false,
                            isMultilang: true,
                            onClick: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                            },
                          ),
                          const SizedBox(width: 20),
                          _buildDialogBtn(
                            title: 'yes',
                            isPositive: true,
                            isMultilang: true,
                            onClick: () async {
                              printLog(
                                  "Clicked on position =============> $position");
                              bool isDeleted =
                                  await deleteFromDownloads(position);
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              }
                              printLog("isDeleted =============> $isDeleted");
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
        );
      },
    ).then((value) {
      if (!context.mounted) return;
      Utils.loadAds(context);
      setState(() {});
    });
  }

  Widget _buildDialogBtn({
    required String title,
    required bool isPositive,
    required bool isMultilang,
    required Function() onClick,
  }) {
    return InkWell(
      onTap: onClick,
      child: Container(
        constraints: const BoxConstraints(minWidth: 75),
        height: 50,
        padding: const EdgeInsets.only(left: 10, right: 10),
        alignment: Alignment.center,
        decoration: Utils.setBGWithBorder(isPositive ? white : transparentColor,
            isPositive ? transparentColor : gray, 5, 0.5),
        child: MyText(
          color: isPositive ? black : white,
          text: title,
          multilanguage: isMultilang,
          textalign: TextAlign.center,
          fontsizeWeb: 15,
          fontsizeNormal: 16,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          fontweight: FontWeight.w500,
          fontstyle: FontStyle.normal,
        ),
      ),
    );
  }
}
