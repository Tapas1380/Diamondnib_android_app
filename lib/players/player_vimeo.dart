import 'package:diamondnib/provider/playerprovider.dart';
import 'package:diamondnib/utils/color.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vimeo_video_player/vimeo_video_player.dart';

class PlayerVimeo extends StatefulWidget {
  final int? videoId, videoType, typeId, stopTime, contentID;
  final String? playType, videoUrl, vUploadType, videoThumb;
  const PlayerVimeo(
      this.contentID,
      this.playType,
      this.videoId,
      this.videoType,
      this.typeId,
      // this.otherId,
      this.videoUrl,
      this.stopTime,
      this.vUploadType,
      this.videoThumb,
      {super.key});

  @override
  State<PlayerVimeo> createState() => PlayerVimeoState();
}

class PlayerVimeoState extends State<PlayerVimeo> {
  String? vUrl;
  late PlayerProvider playerProvider;
  int? playerCPosition, videoDuration;

  @override
  void initState() {
    playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    super.initState();
    vUrl = widget.videoUrl;
    if (!(vUrl ?? "").contains("https://vimeo.com/")) {
      vUrl = "https://vimeo.com/$vUrl";
    }
    printLog("vUrl===> $vUrl");

    _addVideoView();
  }

  _addVideoView() async {
    // if (widget.playType == "Video" || widget.playType != "Show") {
    //   /* Add Video view */
    playerProvider.getAddContentPlay(
        1, widget.videoId.toString(), 2, widget.contentID.toString());
    // }
  }

  @override
  void dispose() {
    if (!(kIsWeb) || !(Constant.isTV)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: onBackPressed,
      child: Scaffold(
        backgroundColor: black,
        body: SafeArea(
          child: Stack(
            children: [
              VimeoVideoPlayer(
                url: vUrl ?? "",
                autoPlay: true,
                systemUiOverlay: const [],
                deviceOrientation: const [
                  DeviceOrientation.landscapeLeft,
                  DeviceOrientation.landscapeRight,
                ],
                startAt: Duration(milliseconds: widget.stopTime ?? 0),
                onProgress: (timePoint) {
                  playerCPosition = timePoint.inMilliseconds;
                  printLog("playerCPosition :===> $playerCPosition");
                },
                onFinished: () async {
                  /* Remove From Continue */
                  await playerProvider.removeFromContinue(
                      widget.contentID, 1, "${widget.videoId}", 2);
                },
              ),
              if (!kIsWeb)
                Positioned(
                  top: 15,
                  left: 15,
                  child: SafeArea(
                    child: InkWell(
                      onTap: () {
                        onBackPressed(false);
                      },
                      focusColor: gray.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      child: Utils.buildBackBtnDesign(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> onBackPressed(didPop) async {
    if (didPop) return;
    if (!(kIsWeb) || !(Constant.isTV)) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    printLog("onBackPressed playerCPosition :===> $playerCPosition");
    printLog("onBackPressed videoDuration :===> $videoDuration");
    printLog("onBackPressed playType :===> ${widget.playType}");
    // if (widget.playType == "Video" || widget.playType == "Show") {
    if ((playerCPosition ?? 0) > 0) {
      /* Add to Continue */
      await playerProvider.addToContinue(
          widget.contentID, 1, "$playerCPosition", "${widget.videoId}", 2);
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    } else {
      if (!mounted) return;
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      }
    }
    // } else {
    //   if (!mounted) return Future.value(false);
    //   Navigator.pop(context, false);
    //   return Future.value(true);
    // }
  }
}
