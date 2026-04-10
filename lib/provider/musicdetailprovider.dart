import 'dart:convert';

import 'package:diamondnib/model/episodebycontentmodel.dart';
import 'package:diamondnib/model/successmodel.dart';
import 'package:diamondnib/utils/dimens.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/webservice/apiservices.dart';
// import 'package:diamondnib/model/addcontenttohistorymodel.dart';
// import 'package:diamondnib/model/addremovelikedislikemodel.dart';
// import 'package:diamondnib/model/addviewmodel.dart';
// import 'package:diamondnib/model/episodebyplaylistmodel.dart' as playlist;
// import 'package:diamondnib/model/episodebyplaylistmodel.dart';
import 'package:diamondnib/model/episodebycontentmodel.dart' as podcast;
// import 'package:diamondnib/model/searchlistmodel.dart' as search;
// import 'package:diamondnib/model/episodebypodcastmodel.dart';
// import 'package:diamondnib/model/episodebyradio.dart' as radio;
// import 'package:diamondnib/model/episodebyradio.dart';
// import 'package:diamondnib/model/removecontenttohistorymodel.dart';
// import 'package:diamondnib/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class MusicDetailProvider extends ChangeNotifier {
  EpisodeByContentModel epidoseByPodcastModel = EpisodeByContentModel();
  SuccessModel successModel = SuccessModel();
  SuccessModel addcontenttoplayModel = SuccessModel();
  SuccessModel episodeBuyModel = SuccessModel();
  // EpidoseByRadioModel epidoseByRadioModel = EpidoseByRadioModel();
  // EpisodebyplaylistModel episodebyplaylistModel = EpisodebyplaylistModel();
  // AddViewModel addViewModel = AddViewModel();
  // AddcontenttoHistoryModel addcontenttoHistoryModel =
  //     AddcontenttoHistoryModel();
  // RemoveContentHistoryModel removeContentHistoryModel =
  //     RemoveContentHistoryModel();
  // AddRemoveLikeDislikeModel addRemoveLikeDislikeModel =
  //     AddRemoveLikeDislikeModel();
  bool loading = false;
  int tabindex = 0;
  bool isexpend = false;
  String istype = "episode";
  double isheight = Dimens.musicdetailAnimateContainerheightNormal;

  List<podcast.Result>? podcastEpisodeList = [];
  int? podcasttotalRows, podcasttotalPage, podcastcurrentPage;
  bool? podcastisMorePage;

  // List<playlist.Result>? playlistEpisodeList = [];
  int? playlisttotalRows, playlisttotalPage, playlistcurrentPage;
  bool? playlistisMorePage;
  // SearchListModel searchModel = SearchListModel();
  // List<search.Result>? searchcontentlist = [];
  // List<radio.Result>? radioEpisodeList = [];
  int? radiototalRows, radiototalPage, radiocurrentPage;
  bool? radioisMorePage;

  bool loadmore = false;

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
    printLog("episodeBuyModel successfulls  = ${episodeBuyModel.status}");
    printLog("episodeBuyModel successfulls  = ${episodeBuyModel.message}");

    loading = false;
    notifyListeners();
  }

/* Podcast Episode */
  Future<void> getEpisodeByPodcast(podcastId, pageNo) async {
    printLog("Api Calling");
    printLog("Api Calling  podcastId = $podcastId");
    printLog("Api Calling  pageNo = $pageNo");
    loading = true;
    epidoseByPodcastModel =
        await ApiService().episodeAudioByContent(podcastId, pageNo);
    printLog("epidoseByPodcastModel = ${jsonEncode(epidoseByPodcastModel)}");

    printLog("epidoseByPodcastModel = ${epidoseByPodcastModel.status}");
    printLog("epidoseByPodcastModel = ${jsonEncode(epidoseByPodcastModel)}");
    if (epidoseByPodcastModel.status == 200) {
      setPodcastPaginationData(
          epidoseByPodcastModel.totalRows,
          epidoseByPodcastModel.totalPage,
          epidoseByPodcastModel.currentPage,
          epidoseByPodcastModel.morePage);
      if (epidoseByPodcastModel.result != null &&
          (epidoseByPodcastModel.result?.length ?? 0) > 0) {
        printLog(
            "followingModel length :==> ${(epidoseByPodcastModel.result?.length ?? 0)}");
        printLog('Now on page ==========> $playlistcurrentPage');
        if (epidoseByPodcastModel.result != null &&
            (epidoseByPodcastModel.result?.length ?? 0) > 0) {
          printLog(
              "followingModel length :==> ${(epidoseByPodcastModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (epidoseByPodcastModel.result?.length ?? 0);
              i++) {
            podcastEpisodeList
                ?.add(epidoseByPodcastModel.result?[i] ?? podcast.Result());
          }
          final Map<int, podcast.Result> postMap = {};
          podcastEpisodeList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          podcastEpisodeList = postMap.values.toList();
          printLog(
              "Podcast EpisodeList length :==> ${(podcastEpisodeList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  Future<void> getSearchVideo(pageNo) async {
    loading = true;

    epidoseByPodcastModel = await ApiService().searchMusicContent(pageNo);
    printLog("search_video status :==> ${epidoseByPodcastModel.status}");
    printLog("search_video message :==> ${epidoseByPodcastModel.message}");
    if (epidoseByPodcastModel.status == 200) {
      setPodcastPaginationData(
          epidoseByPodcastModel.totalRows,
          epidoseByPodcastModel.totalPage,
          epidoseByPodcastModel.currentPage,
          epidoseByPodcastModel.morePage);
      if (epidoseByPodcastModel.result != null &&
          (epidoseByPodcastModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (epidoseByPodcastModel.result?.length ?? 0); i++) {
          podcastEpisodeList
              ?.add(epidoseByPodcastModel.result?[i] ?? podcast.Result());
        }
        final Map<int, podcast.Result> postMap = {};
        podcastEpisodeList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        podcastEpisodeList = postMap.values.toList();
        printLog(
            "contentList length :==> ${(podcastEpisodeList?.length ?? 0)}");
        setLoadMore(false);
      }
    }
    loading = false;
    notifyListeners();
  }

/* Podcast Episode */
  Future<void> getEpisodeByMusic(podcastId, pageNo) async {
    printLog("Api Calling  podcastId = $podcastId");
    loading = true;
    epidoseByPodcastModel =
        await ApiService().episodeMusicBySection(podcastId, pageNo);
    printLog("epidoseByPodcastModel = ${jsonEncode(epidoseByPodcastModel)}");
    printLog("epidoseByPodcastModel = ${epidoseByPodcastModel.result?[0].id}");
    printLog("epidoseByPodcastModel = ${epidoseByPodcastModel.status}");
    printLog("epidoseByPodcastModel = ${jsonEncode(epidoseByPodcastModel)}");
    if (epidoseByPodcastModel.status == 200) {
      setPodcastPaginationData(
          epidoseByPodcastModel.totalRows,
          epidoseByPodcastModel.totalPage,
          epidoseByPodcastModel.currentPage,
          epidoseByPodcastModel.morePage);
      if (epidoseByPodcastModel.result != null &&
          (epidoseByPodcastModel.result?.length ?? 0) > 0) {
        printLog(
            "followingModel length :==> ${(epidoseByPodcastModel.result?.length ?? 0)}");
        printLog('Now on page ==========> $playlistcurrentPage');
        if (epidoseByPodcastModel.result != null &&
            (epidoseByPodcastModel.result?.length ?? 0) > 0) {
          printLog(
              "followingModel length :==> ${(epidoseByPodcastModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (epidoseByPodcastModel.result?.length ?? 0);
              i++) {
            podcastEpisodeList
                ?.add(epidoseByPodcastModel.result?[i] ?? podcast.Result());
          }
          final Map<int, podcast.Result> postMap = {};
          podcastEpisodeList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          podcastEpisodeList = postMap.values.toList();
          printLog(
              "Podcast EpisodeList length :==> ${(podcastEpisodeList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  /* Podcast Episode */
  Future<void> getEpisodeByAuthorMusic(podcastId, pageNo) async {
    printLog("Api Calling  podcastId = $podcastId");
    loading = true;
    epidoseByPodcastModel =
        await ApiService().getMusicByArtistPlaylist(podcastId, pageNo);
    printLog("epidoseByPodcastModel = ${jsonEncode(epidoseByPodcastModel)}");
    printLog("epidoseByPodcastModel = ${epidoseByPodcastModel.result?[0].id}");
    printLog("epidoseByPodcastModel = ${epidoseByPodcastModel.status}");
    printLog("epidoseByPodcastModel = ${jsonEncode(epidoseByPodcastModel)}");
    if (epidoseByPodcastModel.status == 200) {
      setPodcastPaginationData(
          epidoseByPodcastModel.totalRows,
          epidoseByPodcastModel.totalPage,
          epidoseByPodcastModel.currentPage,
          epidoseByPodcastModel.morePage);
      if (epidoseByPodcastModel.result != null &&
          (epidoseByPodcastModel.result?.length ?? 0) > 0) {
        printLog(
            "followingModel length :==> ${(epidoseByPodcastModel.result?.length ?? 0)}");
        printLog('Now on page ==========> $playlistcurrentPage');
        if (epidoseByPodcastModel.result != null &&
            (epidoseByPodcastModel.result?.length ?? 0) > 0) {
          printLog(
              "followingModel length :==> ${(epidoseByPodcastModel.result?.length ?? 0)}");
          for (var i = 0;
              i < (epidoseByPodcastModel.result?.length ?? 0);
              i++) {
            podcastEpisodeList
                ?.add(epidoseByPodcastModel.result?[i] ?? podcast.Result());
          }
          final Map<int, podcast.Result> postMap = {};
          podcastEpisodeList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          podcastEpisodeList = postMap.values.toList();
          printLog(
              "Podcast EpisodeList length :==> ${(podcastEpisodeList?.length ?? 0)}");
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setPodcastPaginationData(int? podcasttotalRows, int? podcasttotalPage,
      int? podcastcurrentPage, bool? podcastisMorePage) {
    this.podcastcurrentPage = podcastcurrentPage;
    this.podcasttotalRows = podcasttotalRows;
    this.podcasttotalPage = podcasttotalPage;
    podcastisMorePage = podcastisMorePage;
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
    printLog(
        " addcontenttoplayModel result == ${addcontenttoplayModel.result}");
    printLog(
        " addcontenttoplayModel status == ${addcontenttoplayModel.status}");
    printLog(
        " addcontenttoplayModel message == ${addcontenttoplayModel.message}");

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

// /* Radio Episode */
//   Future<void> getEpisodeByRadio(radioId, pageNo) async {
//     loading = true;
//     epidoseByRadioModel = await ApiService().episodeByRadio(radioId, pageNo);
//     if (epidoseByRadioModel.status == 200) {
//       setRadioPaginationData(
//           epidoseByRadioModel.totalRows,
//           epidoseByRadioModel.totalPage,
//           epidoseByRadioModel.currentPage,
//           epidoseByRadioModel.morePage);
//       if (epidoseByRadioModel.result != null &&
//           (epidoseByRadioModel.result?.length ?? 0) > 0) {
//         printLog(
//             "followingModel length :==> ${(epidoseByRadioModel.result?.length ?? 0)}");
//         printLog('Now on page ==========> $playlistcurrentPage');
//         if (epidoseByRadioModel.result != null &&
//             (epidoseByRadioModel.result?.length ?? 0) > 0) {
//           printLog(
//               "followingModel length :==> ${(epidoseByRadioModel.result?.length ?? 0)}");
//           for (var i = 0; i < (epidoseByRadioModel.result?.length ?? 0); i++) {
//             radioEpisodeList
//                 ?.add(epidoseByRadioModel.result?[i] ?? radio.Result());
//           }
//           final Map<int, radio.Result> postMap = {};
//           radioEpisodeList?.forEach((item) {
//             postMap[item.id ?? 0] = item;
//           });
//           radioEpisodeList = postMap.values.toList();
//           printLog(
//               "RadioList length :==> ${(radioEpisodeList?.length ?? 0)}");
//           setLoadMore(false);
//         }
//       }
//     }
//     loading = false;
//     notifyListeners();
//   }

//   setRadioPaginationData(int? radiototalRows, int? radiototalPage,
//       int? radiocurrentPage, bool? radioisMorePage) {
//     this.radiocurrentPage = radiocurrentPage;
//     this.radiototalRows = radiototalRows;
//     this.radiototalPage = radiototalPage;
//     radioisMorePage = radioisMorePage;
//     notifyListeners();
//   }

// /* PlayList Episode */
//   Future<void> getEpisodeByPlaylist(playlistId, contentType, pageNo) async {
//     loading = true;
//     episodebyplaylistModel =
//         await ApiService().episodeByPlaylist(playlistId, contentType, pageNo);
//     if (episodebyplaylistModel.status == 200) {
//       setPlaylistPaginationData(
//           episodebyplaylistModel.totalRows,
//           episodebyplaylistModel.totalPage,
//           episodebyplaylistModel.currentPage,
//           episodebyplaylistModel.morePage);
//       if (episodebyplaylistModel.result != null &&
//           (episodebyplaylistModel.result?.length ?? 0) > 0) {
//         printLog(
//             "followingModel length :==> ${(episodebyplaylistModel.result?.length ?? 0)}");
//         printLog('Now on page ==========> $playlistcurrentPage');
//         if (episodebyplaylistModel.result != null &&
//             (episodebyplaylistModel.result?.length ?? 0) > 0) {
//           printLog(
//               "followingModel length :==> ${(episodebyplaylistModel.result?.length ?? 0)}");
//           for (var i = 0;
//               i < (episodebyplaylistModel.result?.length ?? 0);
//               i++) {
//             playlistEpisodeList
//                 ?.add(episodebyplaylistModel.result?[i] ?? playlist.Result());
//           }
//           final Map<int, playlist.Result> postMap = {};
//           playlistEpisodeList?.forEach((item) {
//             postMap[item.id ?? 0] = item;
//           });
//           playlistEpisodeList = postMap.values.toList();
//           printLog(
//               "followFollowingList length :==> ${(playlistEpisodeList?.length ?? 0)}");
//           setLoadMore(false);
//         }
//       }
//     }
//     loading = false;
//     notifyListeners();
//   }

//   setPlaylistPaginationData(int? playlisttotalRows, int? playlisttotalPage,
//       int? playlistcurrentPage, bool? playlistisMorePage) {
//     this.playlistcurrentPage = playlistcurrentPage;
//     this.playlisttotalRows = playlisttotalRows;
//     this.playlisttotalPage = playlisttotalPage;
//     playlistisMorePage = playlistisMorePage;
//     notifyListeners();
//   }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  // Future<void> addContentHistory(
  //     contenttype, contentid, stoptime, episodeid) async {
  //   loading = true;
  //   addcontenttoHistoryModel = await ApiService()
  //       .addContentToHistory(contenttype, contentid, stoptime, episodeid);
  //   loading = false;
  // }

  // Future<void> removeContentHistory(contenttype, contentid, episodeid) async {
  //   loading = true;
  //   removeContentHistoryModel = await ApiService()
  //       .removeContentToHistory(contenttype, contentid, episodeid);
  //   loading = false;
  // }

  // Future<void> addLikeDislike(contenttype, contentid, status, episodeId) async {
  //   printLog("addLikeDislike postId :==> $contentid");
  //   addRemoveLikeDislikeModel = await ApiService()
  //       .addRemoveLikeDislike(contenttype, contentid, status, episodeId);
  //   printLog(
  //       "addLikeDislike status :==> ${addRemoveLikeDislikeModel.status}");
  //   printLog(
  //       "addLikeDislike message :==> ${addRemoveLikeDislikeModel.message}");
  // }

  // animateSheet(bool expend, double height) {
  //   isexpend = expend;
  //   isheight = height;
  //   notifyListeners();
  // }

  changeMusicTab(type) {
    istype = type;
    notifyListeners();
  }

  // Future<void> addView(contenttype, contentid) async {
  //   printLog("addPostView postId :==> $contentid");
  //   loading = true;
  //   addViewModel = await ApiService().addView(contenttype, contentid);
  //   printLog("addPostView status :==> ${addViewModel.status}");
  //   printLog("addPostView message :==> ${addViewModel.message}");
  //   loading = false;
  // }

  clearProvider() {
    // epidoseByPodcastModel = EpidoseByPodcastModel();
    // epidoseByRadioModel = EpidoseByRadioModel();
    // episodebyplaylistModel = EpisodebyplaylistModel();
    // addViewModel = AddViewModel();
    // addcontenttoHistoryModel = AddcontenttoHistoryModel();
    // removeContentHistoryModel = RemoveContentHistoryModel();
    // addRemoveLikeDislikeModel = AddRemoveLikeDislikeModel();
    epidoseByPodcastModel = EpisodeByContentModel();
    loading = false;
    tabindex = 0;
    isexpend = false;
    istype = "episode";
    isheight = Dimens.musicdetailAnimateContainerheightNormal;

    podcastEpisodeList = [];
    // podcastEpisodeList?.clear();

    // playlistEpisodeList = [];
    // playlistEpisodeList?.clear();
    playlisttotalRows;
    playlisttotalPage;
    playlistcurrentPage;
    playlistisMorePage;

    // radioEpisodeList = [];
    // radioEpisodeList?.clear();
    radiototalRows;
    radiototalPage;
    radiocurrentPage;
    radioisMorePage;

    loadmore = false;
    podcasttotalRows = 0;
    podcasttotalPage = 0;
    podcastcurrentPage = 0;
    podcastisMorePage = false;
  }

  // Method to update isBuy status for audio episode and notify listeners
  void updateAudioEpisodeBuyStatus(dynamic episodeId) {
    debugPrint("=== updateAudioEpisodeBuyStatus called in MusicDetailProvider ===");
    debugPrint("Looking for episode ID: $episodeId");
    
    if (podcastEpisodeList != null) {
      for (int i = 0; i < podcastEpisodeList!.length; i++) {
        var item = podcastEpisodeList![i];
        if (item.id.toString() == episodeId.toString()) {
          debugPrint("=== FOUND MATCHING EPISODE in podcastEpisodeList ===");
          debugPrint("Before update - isBuy: ${item.isBuy}");
          item.isBuy = 1;
          debugPrint("After update - isBuy: ${item.isBuy}");
        }
      }
    }
    
    if (epidoseByPodcastModel.result != null) {
      for (int i = 0; i < epidoseByPodcastModel.result!.length; i++) {
        var item = epidoseByPodcastModel.result![i];
        if (item.id.toString() == episodeId.toString()) {
          debugPrint("=== FOUND MATCHING EPISODE in epidoseByPodcastModel ===");
          debugPrint("Before update - isBuy: ${item.isBuy}");
          item.isBuy = 1;
          debugPrint("After update - isBuy: ${item.isBuy}");
        }
      }
    }
    notifyListeners();
    debugPrint("=== notifyListeners called ===");
  }
}