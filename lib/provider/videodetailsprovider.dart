import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:diamondnib/model/sectiondetailmodel.dart';
import 'package:diamondnib/model/successmodel.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/webservice/apiservices.dart';



class VideoDetailsProvider extends ChangeNotifier {
  SuccessModel successModel = SuccessModel();
  SectionDetailModel sectionDetailModel = SectionDetailModel();

  bool loading = false;
  String tabClickedOn = "related";

  setLoading(isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  Future<void> getSectionDetails(
      typeId, videoType, videoId, upcomingType) async {
    printLog("getSectionDetails typeId :========> $typeId");
    printLog("getSectionDetails videoType :=====> $videoType");
    printLog("getSectionDetails videoId :=======> $videoId");
    printLog("getSectionDetails upcomingType :==> $upcomingType");
    loading = true;
    sectionDetailModel = await ApiService()
        .sectionDetails(typeId, videoType, videoId, upcomingType);
    printLog("section_detail status :==> ${sectionDetailModel.status}");
    printLog("section_detail message :==> ${sectionDetailModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> setBookMark(
      BuildContext context, typeId, videoType, videoId) async {
    if ((sectionDetailModel.result?.isBookmark ?? 0) == 0) {
      sectionDetailModel.result?.isBookmark = 1;
      Utils.showSnackbar(context, "success", "addwatchlistmessage", true);
    } else {
      sectionDetailModel.result?.isBookmark = 0;
      Utils.showSnackbar(context, "success", "removewatchlistmessage", true);
    }
    notifyListeners();
    getAddBookMark(typeId, videoType, videoId);
  }

  Future<void> getAddBookMark(typeId, videoType, videoId) async {
    printLog("getAddBookMark typeId :==> $typeId");
    printLog("getAddBookMark videoType :==> $videoType");
    printLog("getAddBookMark videoId :==> $videoId");
    successModel = await ApiService().addRemoveBookmark(videoType, videoId);
    printLog("add_remove_bookmark status :==> ${successModel.status}");
    printLog("add_remove_bookmark message :==> ${successModel.message}");
  }

  Future<void> removeFromContinue(
      contentId, contentType, contentEpisodeId, audiobookType) async {
    sectionDetailModel.result?.stopTime = 0;
    notifyListeners();

    successModel = await ApiService().removeContinueWatching(
        contentId, contentType, contentEpisodeId, audiobookType);
    printLog("removeFromContinue message :==> ${successModel.message}");
  }

  updateRentPurchase() {
    if (sectionDetailModel.result != null) {
      sectionDetailModel.result?.rentBuy == 1;
    }
  }

  updatePrimiumPurchase() {
    if (sectionDetailModel.result != null) {
      sectionDetailModel.result?.isBuy == 1;
    }
  }

  setTabClick(clickedOn) {
    printLog("clickedOn ===> $clickedOn");
    tabClickedOn = clickedOn;
    notifyListeners();
  }

  clearProvider() {
    printLog("<================ clearProvider ================>");
    sectionDetailModel = SectionDetailModel();
    successModel = SuccessModel();
    tabClickedOn = "related";
  }
}
