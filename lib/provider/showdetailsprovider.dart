// import 'package:diamondnib/model/audioepisodebycontentmodel.dart';
import 'package:diamondnib/model/commentmodel.dart' as review;
import 'package:diamondnib/model/commentmodel.dart';
import 'package:diamondnib/model/contentdetailmodel.dart';
import 'package:diamondnib/model/episodebycontentmodel.dart';
import 'package:diamondnib/model/episodebyseasonmodel.dart';
import 'package:diamondnib/model/sectiondetailmodel.dart';
import 'package:diamondnib/model/successmodel.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class ShowDetailsProvider extends ChangeNotifier {
  SuccessModel successModel = SuccessModel();
  SuccessModel episodeBuyModel = SuccessModel();
  SuccessModel addcontenttoplayModel = SuccessModel();
  SectionDetailModel sectionDetailModel = SectionDetailModel();
  EpisodeBySeasonModel episodeBySeasonModel = EpisodeBySeasonModel();
  ContentDetailsModel contentdetailsModel = ContentDetailsModel();
  EpisodeByContentModel videobycontentmodel = EpisodeByContentModel();
  EpisodeByContentModel audiobycontentmodel = EpisodeByContentModel();

  CommentModel getReviewModel = CommentModel();
  SuccessModel addreviewModel = SuccessModel();
  SuccessModel editreviewModel = SuccessModel();
  SuccessModel deletereviewModel = SuccessModel();
  List<review.Result>? reviewList = [];

  bool loading = false;
  bool detailsLoading = false;
  bool reviewloading = false;
  int seasonPos = 0, mCurrentEpiPos = 0;
  String tabClickedOn = "episodes";
  String tabNovelClickedOn = "chapters";
  int? totalRows, totalPage, currentPage;
  bool loadmore = false;
  bool isMorePage = false;

  setLoading(isLoading) {
    loading = isLoading;
    detailsLoading = isLoading;
    reviewloading = isLoading;
    notifyListeners();
  }

  Future<void> getContentDetails(contentId, contentType) async {
    printLog("API Calling");
    detailsLoading = true;
    contentdetailsModel = await ApiService().contentDetails(
      contentId,
      contentType,
    );

    detailsLoading = false;
    notifyListeners();
  }

  Future<void> getEpisodeBuy(
    contentType,
    episodeID,
    audioBookType,
    contentID,
    coin,
  ) async {
    loading = true;
    episodeBuyModel = await ApiService().buyEpisode(
      contentType,
      episodeID,
      audioBookType,
      contentID,
      coin,
    );
    printLog("API Calling == ${episodeBuyModel.toJson()}");

    loading = false;
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

  Future<void> getVideoByContent(contentId, pageno) async {
    loading = true;
    // videobycontentmodel = EpisodeByContentModel();
    videobycontentmodel =
        await ApiService().episodeVideoByContent(contentId, pageno);
    printLog("videobycontentmodel  ${videobycontentmodel.toJson()}");
    loading = false;
    notifyListeners();
  }

  Future<void> getAudioByContent(contentId, pageno) async {
    loading = true;
    // audiobycontentmodel = EpisodeByContentModel();
    audiobycontentmodel =
        await ApiService().episodeAudioByContent(contentId, pageno);
    printLog("audiobycontentmodel  ${audiobycontentmodel.toJson()}");
    loading = false;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  getReviews(contentId, contentType, pageNo) async {
    reviewloading = true;
    getReviewModel =
        await ApiService().getreviews(contentId, contentType, pageNo);
    setaudioPaginationData(getReviewModel.totalRows, getReviewModel.totalPage,
        getReviewModel.currentPage, getReviewModel.morePage);
    if (getReviewModel.result != null &&
        (getReviewModel.result?.length ?? 0) > 0) {
      if (getReviewModel.result != null &&
          (getReviewModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (getReviewModel.result?.length ?? 0); i++) {
          reviewList?.add(getReviewModel.result?[i] ?? review.Result());
        }
        final Map<int, review.Result> postMap = {};
        reviewList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        reviewList = postMap.values.toList();

        setLoadMore(false);
      }
    }
    printLog("getReviewModel == ${getReviewModel.status}");
    printLog("getReviewModel == ${getReviewModel.message}");
    reviewloading = false;
    notifyListeners();
  }

  setaudioPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? isMorePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.isMorePage = isMorePage ?? false;

    notifyListeners();
  }

  Future<void> getAddReviews(contentID, comment, contenttype, rating) async {
    loading = true;
    addreviewModel =
        await ApiService().addreviews(contentID, comment, contenttype, rating);
    printLog("addreviewModel == ${addreviewModel.toJson()}");
    loading = false;
    notifyListeners();
  }

  getEditReviews(contentID, comment, rating) async {
    loading = true;
    editreviewModel =
        await ApiService().editreviews(contentID, comment, rating);
    printLog("editreviewModel == ${editreviewModel.toJson()}");
    loading = false;
    notifyListeners();
  }

  getdeleteReviews(
    contentID,
  ) async {
    loading = true;
    deletereviewModel = await ApiService().deletereviews(
      contentID,
    );
    printLog("deletereviewModel == ${deletereviewModel.toJson()}");

    loading = false;
    notifyListeners();
  }

  Future<void> getSectionDetails(
      typeId, videoType, videoId, upcomingType) async {
    loading = true;
    sectionDetailModel = SectionDetailModel();
    sectionDetailModel = await ApiService()
        .sectionDetails(typeId, videoType, videoId, upcomingType);
    loading = false;
    notifyListeners();
  }

  setEpisodeBySeason(episodeModel) async {
    episodeBySeasonModel = EpisodeBySeasonModel();
    episodeBySeasonModel = episodeModel;
    printLog(
        "setEpisodeBySeason episodeBySeasonModel ================> ${episodeBySeasonModel.result?.length}");
    await getLastWatchedEpisode();
    notifyListeners();
  }

  getLastWatchedEpisode() {
    for (var i = 0; i < (episodeBySeasonModel.result?.length ?? 0); i++) {
      if ((episodeBySeasonModel.result?[i].stopTime ?? 0) > 0) {
        if (episodeBySeasonModel.result?[i].videoDuration != null) {
          if ((episodeBySeasonModel.result?[i].videoDuration ?? 0) > 0 &&
              (episodeBySeasonModel.result?[i].videoDuration ?? 0) !=
                  (episodeBySeasonModel.result?[i].stopTime ?? 0) &&
              (episodeBySeasonModel.result?[i].videoDuration ?? 0) >
                  (episodeBySeasonModel.result?[i].stopTime ?? 0)) {
            mCurrentEpiPos = i;
            return;
          } else {
            mCurrentEpiPos = 0;
          }
        }
      }
    }
    if ((episodeBySeasonModel.result?.length ?? 0) > 0 &&
        mCurrentEpiPos == -1) {
      mCurrentEpiPos = 0;
    }
    printLog("mCurrentEpiPos ========> $mCurrentEpiPos");
  }

  Future<void> setBookMark(BuildContext context, contentType, contentId) async {
    loading = true;
    if ((contentdetailsModel.result?[0].isBookMark ?? 0) == 0) {
      contentdetailsModel.result?[0].isBookMark = 1;
      Utils.showSnackbar(context, "success", "addwatchlistmessage", true);
    } else {
      contentdetailsModel.result?[0].isBookMark = 0;
      Utils.showSnackbar(context, "success", "removewatchlistmessage", true);
    }
    loading = false;
    notifyListeners();
    getAddBookMark(contentType, contentId);
  }

  Future<void> getAddBookMark(contentType, contentId) async {
    printLog("getAddBookMark videoType :==> $contentType");
    printLog("getAddBookMark videoId :==> $contentId");
    successModel = await ApiService().addRemoveBookmark(contentType, contentId);
    printLog("add_remove_bookmark status :==> ${successModel.status}");
    printLog("add_remove_bookmark message :==> ${successModel.message}");
  }

  setSeasonPosition(int position) async {
    printLog("setSeasonPosition ===> $position");
    mCurrentEpiPos = -1;
    await getLastWatchedEpisode();
    seasonPos = position;
    notifyListeners();
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
    episodeBySeasonModel = EpisodeBySeasonModel();
    videobycontentmodel = EpisodeByContentModel();
    audiobycontentmodel = EpisodeByContentModel();
    successModel = SuccessModel();
    contentdetailsModel = ContentDetailsModel();
    seasonPos = 0;
    mCurrentEpiPos = -1;
    tabClickedOn = "episodes";
    tabNovelClickedOn = "chapters";
    reviewList = [];
  }
}
