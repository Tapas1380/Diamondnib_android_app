import 'package:diamondnib/model/profilemodel.dart';
import 'package:diamondnib/model/successmodel.dart';
import 'package:diamondnib/model/threadslistmodel.dart' as podcast;
import 'package:diamondnib/model/threadslistmodel.dart';
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/utils.dart';
import 'package:diamondnib/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileModel profileModel = ProfileModel();
  ProfileModel otheruserprofilemodel = ProfileModel();
  SuccessModel uploadImgModel = SuccessModel();
  SuccessModel deleteThreadsModel = SuccessModel();
  SuccessModel successModel = SuccessModel();
  SuccessModel editsuccessmodel = SuccessModel();

  ThreadsListModel threadbyusermodel = ThreadsListModel();
  List<podcast.Result>? threadbyuserlist = [];
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  bool loadmore = false;

  bool loading = false, loadingUpdate = false, threadloading = false;

  setLoading(isLoading) {
    loading = isLoading;
    threadloading = isLoading;
  }

  Future<void> getProfile(BuildContext context) async {
    printLog("getProfile userID :==> ${Constant.userID}");

    loading = true;
    profileModel = await ApiService().profile();
    printLog("get_profile status :==> ${profileModel.status}");
    printLog("get_profile message :==> ${profileModel.message}");
    printLog("get_profile message :==> ${profileModel.toJson()}");
    // if (profileModel.status == 200 && profileModel.result != null) {
    //   if ((profileModel.result?.length ?? 0) > 0) {
    //     Utils.updatePremium(profileModel.result?[0].isBuy.toString() ?? "0");
    //     if (context.mounted) {
    //       printLog("========= get_profile loadAds =========");
    //       Utils.loadAds(context);
    //     }
    //   }
    // }
    loading = false;
    notifyListeners();
  }

  Future<void> getOtherProfile(userID) async {
    loading = true;
    otheruserprofilemodel = await ApiService().getUserProfile(userID);
    printLog(
        "otheruserprofilemodel status :==> ${otheruserprofilemodel.status}");
    printLog(
        "otheruserprofilemodel message :==> ${otheruserprofilemodel.message}");

    loading = false;
    notifyListeners();
  }

  Future<void> getDeleteThreads(threadsID) async {
    loading = true;
    deleteThreadsModel = await ApiService().deleteThreads(threadsID);
    printLog("deleteThreadsModel status :==> ${deleteThreadsModel.status}");
    printLog("deleteThreadsModel message :==> ${deleteThreadsModel.message}");

    loading = false;
    notifyListeners();
  }

  Future<void> getThreadsByUserList(userID, pageNo) async {
    threadloading = true;
    threadbyusermodel = await ApiService().threadbyuser(userID, pageNo);
    printLog("threadbyusermodel status :==> ${threadbyusermodel.status}");
    printLog("threadbyusermodel message :==> ${threadbyusermodel.message}");

    if (threadbyusermodel.status == 200) {
      setPodcastPaginationData(
          threadbyusermodel.totalRows,
          threadbyusermodel.totalPage,
          threadbyusermodel.currentPage,
          threadbyusermodel.morePage);
      if (threadbyusermodel.result != null &&
          (threadbyusermodel.result?.length ?? 0) > 0) {
        if (threadbyusermodel.result != null &&
            (threadbyusermodel.result?.length ?? 0) > 0) {
          for (var i = 0; i < (threadbyusermodel.result?.length ?? 0); i++) {
            threadbyuserlist
                ?.add(threadbyusermodel.result?[i] ?? podcast.Result());
          }
          final Map<int, podcast.Result> postMap = {};
          threadbyuserlist?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          threadbyuserlist = postMap.values.toList();

          setLoadMore(false);
        }
      }
    }

    threadloading = false;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  setPodcastPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? isMorePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.isMorePage = isMorePage;
    notifyListeners();
  }

  Future<void> getUpdateProfile(
    fullName,
    // userName,
    email,
    // password,
    mobileNumber,
    aboutMe,
    profileFrontImg,
  ) async {
    printLog("getUpdateProfile userID :==> ${Constant.userID}");

    loading = true;
    editsuccessmodel = await ApiService().updateProfile(
      fullName,
      // userName,
      email,
      // password,
      mobileNumber,
      aboutMe,
      profileFrontImg,
    );
    printLog("update_profile status :===> ${editsuccessmodel.status}");
    printLog("update_profile message :==> ${editsuccessmodel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> getImageUpload(profileImg) async {
    printLog("getImageUpload userID :==> ${Constant.userID}");
    printLog("getImageUpload profileImg :==> ${profileImg.toString()}");
    loading = true;
    uploadImgModel = await ApiService().imageUpload(profileImg);
    printLog("image_upload status :==> ${uploadImgModel.status}");
    printLog("image_upload message :==> ${uploadImgModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> getUpdateDataForPayment(fullName, email, mobileNumber) async {
    printLog("getUpdateDataForPayment fullname :==> $fullName");
    printLog("getUpdateDataForPayment email :=====> $email");
    printLog("getUpdateDataForPayment mobile :====> $mobileNumber");
    loadingUpdate = true;
    successModel =
        await ApiService().updateDataForPayment(fullName, email, mobileNumber);
    printLog("getUpdateDataForPayment status :==> ${successModel.status}");
    printLog("getUpdateDataForPayment message :==> ${successModel.message}");
    loadingUpdate = false;
    notifyListeners();
  }

  setUpdateLoading(bool isLoading) {
    loadingUpdate = isLoading;
    notifyListeners();
  }

  clearProvider() {
    profileModel = ProfileModel();
    successModel = SuccessModel();
    uploadImgModel = SuccessModel();
    threadbyuserlist = [];
    loading = false;
    currentPage = 0;
    totalPage = 0;
  }
}
