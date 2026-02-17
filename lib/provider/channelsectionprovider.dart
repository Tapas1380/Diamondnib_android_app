import 'package:diamondnib/model/channelsectionmodel.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class ChannelSectionProvider extends ChangeNotifier {
  ChannelSectionModel channelSectionModel = ChannelSectionModel();

  bool loading = false;
  int? cBannerIndex = 0;

  Future<void> getChannelSection() async {
    loading = true;
    channelSectionModel = await ApiService().channelSectionList();
    printLog("getChannelSection status :==> ${channelSectionModel.status}");
    printLog("getChannelSection message :==> ${channelSectionModel.message}");
    loading = false;
    notifyListeners();
  }

  setLoading(isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  setCurrentBanner(index) {
    cBannerIndex = index;
    notifyListeners();
  }

  updatePrimiumPurchase() {
    if (channelSectionModel.result != null) {
      for (var i = 0; i < (channelSectionModel.liveUrl?.length ?? 0); i++) {
        channelSectionModel.liveUrl?[i].isBuy = 1;
      }
    }
  }

  clearProvider() {
    printLog("<================ clearProvider ================>");
    channelSectionModel = ChannelSectionModel();
  }
}
