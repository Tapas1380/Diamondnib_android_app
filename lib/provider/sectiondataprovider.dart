import 'package:diamondnib/model/audiosectionlistmodel.dart';
import 'package:diamondnib/model/sectionbannermodel.dart';
import 'package:diamondnib/model/sectionlistmodel.dart' as sectiondata;
import 'package:diamondnib/model/sectionlistmodel.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class SectionDataProvider extends ChangeNotifier {
  SectionBannerModel sectionBannerModel = SectionBannerModel();
  SectionListModel sectionListModel = SectionListModel();
  AudioSectionListModel audiosectionListModel = AudioSectionListModel();
  List<sectiondata.Result>? sectionListData = [];

  bool loadingBanner = false, loadingSection = false;
  int? cBannerIndex = 0, lastTabPosition;
  int? totalrows, totalPage, currentPage;
  bool? isMorePage;

  bool loadmore = false;

  Future<void> getSectionBanner(typeId, isHomePage) async {
    printLog("getSectionBanner typeId :==> $typeId");
    printLog("getSectionBanner isHomePage :==> $isHomePage");
    loadingBanner = true;
    sectionBannerModel =
        await ApiService().homesectionBanner(typeId, isHomePage);
    printLog("get_banner status :==> ${sectionBannerModel.status}");
    printLog("get_banner message :==> ${sectionBannerModel.message}");
    loadingBanner = false;
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

  Future<void> getSectionList(typeId, isHomePage, pageno) async {
    printLog("getSectionList typeId :==> $typeId");
    printLog("getSectionList isHomePage :==> $isHomePage");
    loadingSection = true;

    sectionListModel =
        await ApiService().sectionList(typeId, isHomePage, pageno);
    printLog("section_list status :==> ${sectionListModel.status}");
    printLog("section_list message :==> ${sectionListModel.message}");
    if (sectionListModel.status == 200) {
      setPodcastPaginationData(
          sectionListModel.totalRows,
          sectionListModel.totalPage,
          sectionListModel.currentPage,
          sectionListModel.morePage);
      if (sectionListModel.result != null &&
          (sectionListModel.result?.length ?? 0) > 0) {
        if (sectionListModel.result != null &&
            (sectionListModel.result?.length ?? 0) > 0) {
          for (var i = 0; i < (sectionListModel.result?.length ?? 0); i++) {
            sectionListData
                ?.add(sectionListModel.result?[i] ?? sectiondata.Result());
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

  Future<void> getAudioSectionList(typeId, isHomePage, pageno) async {
    printLog("getSectionList typeId :==> $typeId");
    printLog("getSectionList isHomePage :==> $isHomePage");
    loadingSection = true;
    audiosectionListModel =
        await ApiService().audiosectionList(typeId, isHomePage, pageno);
    printLog("section_list status :==> ${sectionListModel.status}");
    printLog("Audio section_list message :==> ${sectionListModel.message}");
    loadingSection = false;
    notifyListeners();
  }

  clearProvider() {
    printLog("<================ clearProvider ================>");
    loadingBanner = false;
    loadingSection = false;
    currentPage = 0;
    sectionListData = [];
    // sectionListModel = SectionListModel();
    cBannerIndex = 0;
    lastTabPosition = 0;
  }
}
