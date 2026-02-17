import 'dart:convert';

import 'package:diamondnib/model/download_item.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class DownLoadProvider extends ChangeNotifier {
  // ========  Download ======== //
  int dProgress = 0;
  int? itemId;
  bool loading = false, videoloading = false;
  bool downLoadloading = false;
  bool decryptloading = false;
  late Box<DownloadEpisodeItem> episodeBox;
  List<DownloadEpisodeItem>? myEpisodeList;
  int downloadPercentage = 0;
  bool isLoading = false;
  bool downLoadLoading = false;
  Map<int, DownloadProgressInfo> downloadProgressMap = {};

  setDownloadProgress(int progress, int itemId) {
    this.itemId = itemId;
    loading = (progress != -1);
    dProgress = progress;

    printLog('setDownloadProgress dProgress ==============> $dProgress');
    updateDownloadProgress(itemId, progress);
    notifyListeners();
  }

  // Getter for download status
  bool isDownloading(int itemId) {
    return downloadProgressMap[itemId]?.isDownloading ?? false;
  }

  // Getter for download progress
  int getDownloadProgress(int itemId) {
    return downloadProgressMap[itemId]?.progress ?? 0;
  }

  // downLoadsetLoading(bool isLoading) {
  //   loading = isLoading;
  //   notifyListeners();
  // }

  setCurrentDownload(int? itemId) {
    printLog('setDownloadProgress itemId ==============> $itemId');
    this.itemId = itemId;
    notifyListeners();
  }

  downLoadclearProvider() {
    printLog("<================ clearProvider ================>");
    dProgress = 0;
    itemId = null;
    downLoadloading = false;
    loading = false;
  }

  notifyProvider() {
    notifyListeners();
  }

  setLoading(bool isLoading) {
    loading = isLoading;
    videoloading = isLoading;
  }

  // ========  Download ======== //

  int _selectedTab = 0;

  int get selectedTab => _selectedTab;
  setTabPosition(int newTabPosition) {
    _selectedTab = newTabPosition;
    notifyListeners();
  }

  setDecryptLoading(bool isLoading) {
    decryptloading = isLoading;
    notifyListeners();
  }

  makeDownloadPlayslits(int contentid) {
    downLoadloading = true;

    if (!kIsWeb) {
      if (Constant.userID != null) {
        episodeBox = Hive.box<DownloadEpisodeItem>(
            '${Constant.audioEpisodeDownloadBox}_${Constant.userID}');
      } else {
        episodeBox =
            Hive.box<DownloadEpisodeItem>(Constant.audioEpisodeDownloadBox);
      }
    }

    // ignore: unnecessary_null_comparison
    if (contentid == null) {
      printLog("Content ID is null");
      downLoadloading = false;
      notifyListeners();
      return;
    }

    myEpisodeList = [];

    // Debugging all values in the episodeBox
    printLog("All episodeBox values: ${episodeBox.values.toList()}");

    myEpisodeList = episodeBox.values.where((episodeItem) {
      printLog(
          "Comparing episodeItem.contentId: ${episodeItem.contentId} with contentid: $contentid");
      return episodeItem.contentId == contentid;
    }).toList();

    printLog("Filtered myEpisodeList count: ${myEpisodeList?.length}");
    printLog("Filtered myEpisodeList content: ${jsonEncode(myEpisodeList)}");

    downLoadloading = false;
    notifyListeners();
  }

  downalodClearProvider() {
    _selectedTab = 0;
  }

  // // State to keep track of downloads
  // Map<int, DownloadProgressInfo> downloadProgressMap = {};
  // void updateDownloadProgress(int itemId, int progress) {
  //   // Update the progress information for the specific itemId
  //   downloadProgressMap[itemId] =
  //       DownloadProgressInfo(progress: progress, isDownloading: progress != -1);

  //   // Set the current item's progress and loading state
  //   this.itemId = itemId;
  //   downloadPercentage = progress;
  //   isLoading = (progress != -1);

  //   notifyListeners();
  //   printLog(
  //       'Updated download progress for itemId $itemId: Progress = $downloadPercentage%');
  // }
  // Update the progress information for the specific itemId
  void updateDownloadProgress(int itemId, int progress) {
    // Update the progress information for the specific itemId
    downloadProgressMap[itemId] = DownloadProgressInfo(
      progress: progress,
      isDownloading:
          progress != 100, // Set `isDownloading` to false when progress is 100%
    );

    // Notify listeners about the state change
    notifyListeners();

    // Log the progress update
    printLog(
        'Updated download progress for itemId $itemId: Progress = $progress%');

    // If download completed (progress == 100), perform any final steps
    if (progress == 100) {
      markDownloadComplete(itemId);
    }
  }

// A method to handle actions when download completes
  void markDownloadComplete(int itemId) {
    // Mark the download as complete and stop the downloading state
    downloadProgressMap[itemId] =
        DownloadProgressInfo(progress: 100, isDownloading: false);

    // Notify listeners that the download has finished
    notifyListeners();
    printLog('Download complete for itemId $itemId');
  }

  // Call this method when entering the download page
  void loadDownloadStatus(int itemId) {
    printLog(
        'loadDownloadStatus download progress for itemId $itemId: Progress = $downloadPercentage%');
    // Assuming myEpisodeList is populated with DownloadEpisodeItem objects
    final episodeItem = myEpisodeList?.firstWhere(
      (item) => item.id == itemId,
      orElse: () => DownloadEpisodeItem(),
    );

    if (episodeItem != null) {
      // Assuming each DownloadEpisodeItem has properties: downloadProgress and isDownloading
      downloadPercentage = episodeItem
          .downloadProgress; // Replace with the actual progress property
      downLoadLoading =
          episodeItem.isDownloading; // Replace with the actual loading property
    } else {
      // Handle the case where the item is not found
      downloadPercentage = 0;
      downLoadLoading = false;
    }

    notifyListeners();
  }
}

class DownloadProgressInfo {
  final int progress;
  final bool isDownloading;

  DownloadProgressInfo({required this.progress, required this.isDownloading});
}
