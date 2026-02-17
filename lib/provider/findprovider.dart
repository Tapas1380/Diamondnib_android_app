import 'package:diamondnib/model/genresmodel.dart';
import 'package:diamondnib/model/langaugemodel.dart';
import 'package:diamondnib/model/sectiontypemodel.dart';
import 'package:diamondnib/model/successmodel.dart';
import 'package:diamondnib/utils/sharedpre.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class FindProvider extends ChangeNotifier {
  SuccessModel successModel = SuccessModel();
  SectionTypeModel sectionTypeModel = SectionTypeModel();
  LangaugeModel langaugeModel = LangaugeModel();
  GenresModel genresModel = GenresModel();

  bool loading = false, isGenSeeMore = true, isLangSeeMore = true;
  int setLanguageSize = 5, setGenresSize = 5;

  SharedPre sharePref = SharedPre();

  setLoading(isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  Future<void> getSectionType() async {
    loading = true;
    sectionTypeModel = await ApiService().sectionType();
    printLog("get_type status :==> ${sectionTypeModel.status}");
    printLog("get_type message :==> ${sectionTypeModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> getGenres() async {
    loading = true;
    genresModel = await ApiService().genres();
    printLog("get_category status :==> ${genresModel.status}");
    printLog("get_category message :==> ${genresModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> getLanguage() async {
    loading = true;
    langaugeModel = await ApiService().language();
    printLog("get_language status :==> ${langaugeModel.status}");
    printLog("get_language message :==> ${langaugeModel.message}");
    loading = false;
    notifyListeners();
  }

  void setLanguageListSize(int setNewSize) {
    setLanguageSize = setNewSize;
    notifyListeners();
  }

  void setGenresListSize(int setNewSize) {
    setGenresSize = setNewSize;
    notifyListeners();
  }

  void setLangSeeMore(bool isVisible) {
    isLangSeeMore = isVisible;
    notifyListeners();
  }

  void setGenSeeMore(bool isVisible) {
    isGenSeeMore = isVisible;
    notifyListeners();
  }

  clearProvider() {
    printLog("============ clearProvider ============");
    successModel = SuccessModel();
    sectionTypeModel = SectionTypeModel();
    langaugeModel = LangaugeModel();
    genresModel = GenresModel();

    isGenSeeMore = true;
    isLangSeeMore = true;
    setLanguageSize = 5;
    setGenresSize = 5;
  }
}
