import 'package:diamondnib/model/artistprofilemodel.dart';
import 'package:diamondnib/model/commentmodel.dart';
import 'package:diamondnib/model/contentdetailmodel.dart';
import 'package:diamondnib/model/episodebycontentmodel.dart' as novel;
import 'package:diamondnib/model/episodebycontentmodel.dart';
import 'package:diamondnib/model/novelsectionlistmodel.dart' as sectiondata;
import 'package:diamondnib/model/novelsectionlistmodel.dart';
import 'package:diamondnib/model/sectionbannermodel.dart';
import 'package:diamondnib/model/successmodel.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/webservice/apiservices.dart';
import 'package:flutter/material.dart';
import 'package:diamondnib/model/commentmodel.dart' as review;

class NovelSectionDataProvider extends ChangeNotifier {
  NovelSectionListModel novelsectionListModel = NovelSectionListModel();
  ContentDetailsModel contentdetailsModel = ContentDetailsModel();
  EpisodeByContentModel novelchaptermodel = EpisodeByContentModel();
  CommentModel getReviewModel = CommentModel();
  SuccessModel addremovefollowModel = SuccessModel();
  SectionBannerModel sectionBannerModel = SectionBannerModel();
  SuccessModel addreviewModel = SuccessModel();
  SuccessModel editreviewModel = SuccessModel();
  SuccessModel deletereviewModel = SuccessModel();
  ArtistProfileModel artistProfileModel = ArtistProfileModel();
  SuccessModel successModel = SuccessModel();
  SuccessModel episodeBuyModel = SuccessModel();
  SuccessModel addcontenttoplayModel = SuccessModel();
  List<sectiondata.Result>? sectionListData = [];
  bool loadingBanner = false, loadingSection = false;
  int seasonPos = 0, mCurrentEpiPos = -1;
  int? cBannerIndex = 0, lastTabPosition;
  String tabNovelClickedOn = "chapters";
  bool loading = false;
  bool reviewloading = false;
  int? totalrows, totalPage, currentPage;
  bool? isMorePage;
  List<novel.Result>? novelList = [];
  int? noveltotalRows, noveltotalPage, novelcurrentPage;
  bool novelisMorePage = false;
  List<review.Result>? reviewList = [];
  bool loadmore = false;
  bool? doComment;

  int? reviewtotalrows, reviewtotalPage, reviewcurrentPage;
  bool? reviewisMorePage;

  setLoading(bool flagLoading) {
    loading = flagLoading;
    loadingSection = flagLoading;
    reviewloading = flagLoading;
    loadingBanner = flagLoading;
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

  checkIsBuy(bool checkIsBuy) {
    doComment = checkIsBuy;
    printLog('doComment == $doComment');
  }

  Future<void> getSectionBanner(typeId, isHomePage) async {
    printLog("getSectionBanner typeId :==> $typeId");
    printLog("getSectionBanner isHomePage :==> $isHomePage");
    loadingBanner = true;
    sectionBannerModel =
        await ApiService().novelsectionBanner(typeId, isHomePage);
    printLog("get_banner status :==> ${sectionBannerModel.status}");
    printLog("get_banner message :==> ${sectionBannerModel.message}");
    loadingBanner = false;
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

    loading = false;
    notifyListeners();
  }

  Future<void> getAddContentPlay(
    contentType,
    episodeID,
    audioBookType,
    contentID,
  ) async {
    printLog(" addcontenttoplayModel contentType == $contentType");
    printLog(" addcontenttoplayModel episodeID == $episodeID");
    printLog(" addcontenttoplayModel audioBookType == $audioBookType");

    printLog(" addcontenttoplayModel contentID == $contentID");
    loading = true;
    addcontenttoplayModel = await ApiService().addToPlay(
      contentType,
      episodeID,
      audioBookType,
      contentID,
    );
    printLog(
        " addcontenttoplayModel result == ${addcontenttoplayModel.result}");
    printLog(
        " addcontenttoplayModel status == ${addcontenttoplayModel.status}");
    printLog(
        " addcontenttoplayModel message == ${addcontenttoplayModel.message}");

    loading = false;
    notifyListeners();
  }

  Future<void> getNovelChapterdetails(contentId, pageno) async {
    loading = true;
    // audiobycontentmodel = EpisodeByContentModel();
    novelchaptermodel = await ApiService().episodeByBook(contentId, pageno);
    setaudioPaginationData(
        novelchaptermodel.totalRows,
        novelchaptermodel.totalPage,
        novelchaptermodel.currentPage,
        novelchaptermodel.morePage);
    if (novelchaptermodel.result != null &&
        (novelchaptermodel.result?.length ?? 0) > 0) {
      if (novelchaptermodel.result != null &&
          (novelchaptermodel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (novelchaptermodel.result?.length ?? 0); i++) {
          novelList?.add(novelchaptermodel.result?[i] ?? novel.Result());
        }
        final Map<int, novel.Result> postMap = {};
        novelList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        novelList = postMap.values.toList();

        setLoadMore(false);
      }
    }
    loading = false;
    notifyListeners();
  }

  setNovelTabClick(clickedOn) {
    printLog("clickedOn ===> $clickedOn");
    tabNovelClickedOn = clickedOn;
    notifyListeners();
  }

  setTabPosition(position) {
    lastTabPosition = position;
    notifyListeners();
  }

  setCurrentBanner(index) {
    cBannerIndex = index;
    notifyListeners();
  }

  Future<void> getContentDetails(contentId, contentType) async {
    printLog("API Calling");
    loading = true;
    // contentdetailsModel = ContentDetailsModel();
    contentdetailsModel = await ApiService().contentDetails(
      contentId,
      contentType,
    );

    loading = false;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  setPodcastPaginationData(
      int? totalrows, int? totalPage, int? currentPage, bool? isMorePage) {
    this.currentPage = currentPage;
    this.totalrows = totalrows;
    this.totalPage = totalPage;
    this.isMorePage = isMorePage;
    printLog("isMorePage ++ $isMorePage");
    printLog("totalrows ++ $totalrows");
    printLog("totalPage ++ $totalPage");
    printLog("currentPage ++ $currentPage");

    notifyListeners();
  }

  setaudioPaginationData(int? noveltotalRows, int? noveltotalPage,
      int? novelcurrentPage, bool? novelisMorePage) {
    this.novelcurrentPage = novelcurrentPage;
    this.noveltotalRows = noveltotalRows;
    this.noveltotalPage = noveltotalPage;
    this.novelisMorePage = novelisMorePage!;

    notifyListeners();
  }

  Future<void> getNovelSectionList(typeId, isHomePage, pageno) async {
    loadingSection = true;
    novelsectionListModel =
        await ApiService().novelsectionList(typeId, isHomePage, pageno);
    printLog(
        "novelsectionListModel status :==> ${novelsectionListModel.status}");
    printLog(
        "novelsectionListModel message :==> ${novelsectionListModel.message}");
    if (novelsectionListModel.status == 200) {
      setPodcastPaginationData(
          novelsectionListModel.totalRows,
          novelsectionListModel.totalPage,
          novelsectionListModel.currentPage,
          novelsectionListModel.morePage);
      if (novelsectionListModel.result != null &&
          (novelsectionListModel.result?.length ?? 0) > 0) {
        if (novelsectionListModel.result != null &&
            (novelsectionListModel.result?.length ?? 0) > 0) {
          for (var i = 0;
              i < (novelsectionListModel.result?.length ?? 0);
              i++) {
            sectionListData
                ?.add(novelsectionListModel.result?[i] ?? sectiondata.Result());
          }
          final Map<int, sectiondata.Result> postMap = {};
          sectionListData?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          sectionListData = postMap.values.toList();

          setLoadMore(false);
        }
      }
    }
    loadingSection = false;
    notifyListeners();
  }

  getReviews(contentId, contentType, pageNo) async {
    reviewloading = true;
    getReviewModel =
        await ApiService().getreviews(contentId, contentType, pageNo);
    printLog("getReviewModel == ${getReviewModel.toJson()}");
    setReviewPAginationData(getReviewModel.totalRows, getReviewModel.totalPage,
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
    reviewloading = false;
    notifyListeners();
  }

  setReviewPAginationData(int? reviewtotalrows, int? reviewtotalPage,
      int? reviewcurrentPage, bool? reviewisMorePage) {
    this.reviewcurrentPage = reviewcurrentPage;
    this.reviewtotalrows = reviewtotalrows;
    this.reviewtotalPage = reviewtotalPage;
    this.reviewisMorePage = reviewisMorePage;

    notifyListeners();
  }

  Future<void> getAddReviews(contentID, comment, contenttype, rating) async {
    loading = true;
    addreviewModel =
        await ApiService().addreviews(contentID, comment, contenttype, rating);
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

  getAddremoveFollow(
    artistID,
  ) async {
    // printLog("addremovefollowModel Calling");
    addremovefollowModel = await ApiService().addremovefollow(artistID);
    printLog("addremovefollowModel == ${addremovefollowModel.toJson()}");
  }

  addremovefollowdirect(id) async {
    printLog(
        "isFoloow before the click ==${contentdetailsModel.result?[0].isFollow}");
    if (contentdetailsModel.result?[0].isFollow == 0) {
      contentdetailsModel.result?[0].isFollow = 1;
      printLog(
          "isFoloow after the click ==${contentdetailsModel.result?[0].isFollow}");
    } else {
      contentdetailsModel.result?[0].isFollow = 0;
      printLog(
          "isFoloow after the click ==${contentdetailsModel.result?[0].isFollow}");
      if ((contentdetailsModel.result?[0].isFollow ?? 0) > 0) {}
    }
    notifyListeners();
    await getAddremoveFollow(id);
  }

  addremovefollow(id) async {
    printLog(
        "isFoloow before the click ==${artistProfileModel.result?[0].isFollow}");
    if (artistProfileModel.result?[0].isFollow == 0) {
      artistProfileModel.result?[0].isFollow = 1;
      printLog(
          "isFoloow after the click ==${artistProfileModel.result?[0].isFollow}");
    } else {
      artistProfileModel.result?[0].isFollow = 0;
      printLog(
          "isFoloow after the click ==${artistProfileModel.result?[0].isFollow}");
      if ((artistProfileModel.result?[0].isFollow ?? 0) > 0) {}
    }
    notifyListeners();
    getAddremoveFollow(id);
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

  clearProvider() {
    printLog("<================ clearProvider ================>");
    loadingBanner = false;
    loadingSection = false;
    // sectionBannerModel = SectionBannerModel();
    // novelsectionListModel = NovelSectionListModel();
    cBannerIndex = 0;
    lastTabPosition = 0;
    currentPage = 0;
    sectionListData = [];
    novelList = [];
    reviewList = [];
    tabNovelClickedOn = "chapters";
  }
}
