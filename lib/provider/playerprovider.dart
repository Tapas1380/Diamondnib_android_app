import 'package:diamondnib/model/successmodel.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class PlayerProvider extends ChangeNotifier {
  SuccessModel successModel = SuccessModel();
  SuccessModel videoViewSuccessModel = SuccessModel();
  SuccessModel addcontenttoplayModel = SuccessModel();

  bool loading = false;
  String currentSubtitle = "";
  String currentQuality = "";

  double _progress = 0.0;

  double get progress => _progress;

  void setDecryptProgress(double newProgress) {
    _progress = newProgress;
    notifyListeners(); // Notify listeners of the change
  }

  setCurrentSubtitle(String subtitleName) {
    currentSubtitle = subtitleName;
    notifyListeners();
  }

  setCurrentQuality(String qualityName) {
    currentQuality = qualityName;
    notifyListeners();
  }

  Future<void> getAddContentPlay(
    contentType,
    episodeID,
    audioBookType,
    contentID,
  ) async {
    loading = true;
    addcontenttoplayModel = await ApiService().addToPlay(
      contentType,
      episodeID,
      audioBookType,
      contentID,
    );

    loading = false;
    notifyListeners();
  }

  Future<void> addVideoView(videoId, videoType, otherId) async {
    printLog("addVideoView videoId :====> $videoId");
    printLog("addVideoView otherId :====> $otherId");
    printLog("addVideoView videoType :==> $videoType");
    loading = true;
    videoViewSuccessModel =
        await ApiService().videoView(videoId, videoType, otherId);
    printLog("addVideoView message :==> ${videoViewSuccessModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> addToContinue(
      contentId, contentType, stopTime, contentEpisodeId, audiobookType) async {
    printLog("addToContinue stopTime :==> $stopTime");
    printLog("addToContinue contentId :==> $contentId");
    printLog("addToContinue contentType :==> $contentType");
    printLog("addToContinue contentEpisodeId :==> $contentEpisodeId");
    printLog("addToContinue audiobookType :==> $audiobookType");
    loading = true;
    successModel = await ApiService().addContinueWatching(
        contentId, contentType, stopTime, contentEpisodeId, audiobookType);
    printLog("addToContinue message :==> ${successModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> removeFromContinue(
      contentId, contentType, contentEpisodeId, audiobookType) async {
    loading = true;
    successModel = await ApiService().removeContinueWatching(
        contentId, contentType, contentEpisodeId, audiobookType);
    printLog("remove_continue_watching message :==> ${successModel.message}");
    loading = false;
    notifyListeners();
  }

  clearProvider() {
    printLog("<================ clearProvider ================>");
    successModel = SuccessModel();
    videoViewSuccessModel = SuccessModel();
    currentSubtitle = "";
    loading = false;
  }
}
