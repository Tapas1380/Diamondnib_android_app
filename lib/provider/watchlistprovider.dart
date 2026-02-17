import 'package:diamondnib/model/getwishlistmodel.dart';
import 'package:diamondnib/model/successmodel.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class WatchlistProvider extends ChangeNotifier {
  GetWishListModel watchlistModel = GetWishListModel();
  SuccessModel successModel = SuccessModel();

  bool loading = false, loadMore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;
  List<Result>? watchDataList = [];
  int selectedIndex = 0;

  setSelectedTab(index) {
    selectedIndex = index;
    notifyListeners();
  }

  Future<void> getWatchlist(contentType, pageNo) async {
    printLog("getWatchlist userID :==> ${Constant.userID}");
    loading = true;
    watchlistModel = await ApiService().watchlist(contentType, pageNo);
    if (watchlistModel.status == 200) {
      setContentDataPaginationData(
          watchlistModel.totalRows,
          watchlistModel.totalPage,
          watchlistModel.currentPage,
          watchlistModel.morePage);
      if (watchlistModel.result != null &&
          (watchlistModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (watchlistModel.result?.length ?? 0); i++) {
          watchDataList?.add(watchlistModel.result?[i] ?? Result());
        }
        final Map<int, Result> postMap = {};
        watchDataList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        watchDataList = postMap.values.toList();
        setLoadMore(false);
      }
    }
    printLog("get_bookmark_video status :==> ${watchlistModel.status}");
    printLog("get_bookmark_video message :==> ${watchlistModel.message}");
    loading = false;
    notifyListeners();
  }

  setContentDataPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? isMorePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.isMorePage = isMorePage;
    notifyListeners();
  }

  Future<void> setBookMark(
      BuildContext context, position, videoType, videoId) async {
    loading = true;
    printLog("setBookMark videoType :==> $videoType");
    printLog("setBookMark videoId :==> $videoId");
    printLog(
        "watchlistModel videoId :==> ${(watchDataList?[position].id ?? 0)}");
    if ((watchDataList?[position].isBookmark ?? 0) == 0) {
      watchDataList?[position].isBookmark = 1;
      Utils.showSnackbar(context, "success", "addwatchlistmessage", true);
    } else {
      watchDataList?[position].isBookmark = 0;
      watchDataList?.removeAt(position);
      Utils.showSnackbar(context, "success", "removewatchlistmessage", true);
    }
    loading = false;
    notifyListeners();
    getAddBookMark(videoType, videoId);
  }

  Future<void> getAddBookMark(videoType, videoId) async {
    printLog("getAddBookMark videoType :==> $videoType");
    printLog("getAddBookMark videoId :==> $videoId");
    successModel = await ApiService().addRemoveBookmark(videoType, videoId);
    printLog("add_remove_bookmark status :==> ${successModel.status}");
    printLog("add_remove_bookmark message :==> ${successModel.message}");
  }

  clearProvider() {
    printLog("<================ clearProvider ================>");
    watchlistModel = GetWishListModel();
    successModel = SuccessModel();
    selectedIndex = 0;
    watchDataList = [];
  }

  setLoading(bool isLoading) {
    loading = isLoading;
  }

  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }
}
