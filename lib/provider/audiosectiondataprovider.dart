import 'package:diamondnib/model/audiosectionlistmodel.dart' as sectiondata;
import 'package:diamondnib/model/audiosectionlistmodel.dart';
import 'package:diamondnib/model/sectionbannermodel.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class AudioSectionDataProvider extends ChangeNotifier {
  AudioSectionListModel audiosectionListModel = AudioSectionListModel();
  List<sectiondata.Result>? sectionListData = [];
  SectionBannerModel sectionBannerModel = SectionBannerModel();
  bool loadingBanner = false, loadingSection = false;
  int? cBannerIndex = 0, lastTabPosition;

  int? totalrows, totalPage, currentPage;
  bool? isMorePage;

  bool loadmore = false;

  setLoading(bool flagLoading) {
    loadingBanner = flagLoading;
    loadingSection = flagLoading;
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

  Future<void> getSectionBanner(typeId, isHomePage) async {
    printLog("getSectionBanner typeId :==> $typeId");
    printLog("getSectionBanner isHomePage :==> $isHomePage");
    loadingBanner = true;
    sectionBannerModel =
        await ApiService().audiobooksectionBanner(typeId, isHomePage);
    printLog("get_banner status :==> ${sectionBannerModel.status}");
    printLog("get_banner message :==> ${sectionBannerModel.message}");
    loadingBanner = false;
    notifyListeners();
  }

  Future<void> getAudioSectionList(typeId, isHomePage, pageno) async {
    printLog("getSectionList typeId :==> $typeId");
    printLog("getSectionList isHomePage :==> $isHomePage");
    loadingSection = true;
    audiosectionListModel =
        await ApiService().audiosectionList(typeId, isHomePage, pageno);
    printLog("section_list status :==> ${audiosectionListModel.status}");
    printLog("section_list message :==> ${audiosectionListModel.message}");
    if (audiosectionListModel.status == 200) {
      setPodcastPaginationData(
          audiosectionListModel.totalRows,
          audiosectionListModel.totalPage,
          audiosectionListModel.currentPage,
          audiosectionListModel.morePage);
      if (audiosectionListModel.result != null &&
          (audiosectionListModel.result?.length ?? 0) > 0) {
        if (audiosectionListModel.result != null &&
            (audiosectionListModel.result?.length ?? 0) > 0) {
          for (var i = 0;
              i < (audiosectionListModel.result?.length ?? 0);
              i++) {
            sectionListData
                ?.add(audiosectionListModel.result?[i] ?? sectiondata.Result());
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

  clearProvider() {
    printLog("<================ clearProvider ================>");
    loadingBanner = false;
    loadingSection = false;
    // audiosectionListModel = AudioSectionListModel();
    cBannerIndex = 0;
    lastTabPosition = 0;
    currentPage = 0;
    sectionListData = [];
    audiosectionListModel = AudioSectionListModel();
    sectionBannerModel = SectionBannerModel();
    totalPage = 0;
  }
}
