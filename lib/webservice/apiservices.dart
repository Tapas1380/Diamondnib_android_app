// Dart core libraries
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

// Flutter packages
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

// Models
import 'package:diamondnib/model/artistprofilemodel.dart';
import 'package:diamondnib/model/audiosectionlistmodel.dart';
import 'package:diamondnib/model/avatarmodel.dart';
import 'package:diamondnib/model/commentmodel.dart';
import 'package:diamondnib/model/contentdetailmodel.dart';
import 'package:diamondnib/model/couponmodel.dart';
import 'package:diamondnib/model/download_item.dart';
import 'package:diamondnib/model/downloadaudiobook.dart';
import 'package:diamondnib/model/earncoinmodel.dart';
import 'package:diamondnib/model/earncointransactionlistmodel.dart';
import 'package:diamondnib/model/episodebycontentmodel.dart';
import 'package:diamondnib/model/getcontentbyartistmodel.dart';
import 'package:diamondnib/model/getnotificationmodel.dart';
import 'package:diamondnib/model/novelsectionlistmodel.dart';
import 'package:diamondnib/model/pagesmodel.dart';
import 'package:diamondnib/model/paymentoptionmodel.dart';
import 'package:diamondnib/model/paytmmodel.dart';
import 'package:diamondnib/model/searchlistmodel.dart';
import 'package:diamondnib/model/sectionbannermodel.dart';
import 'package:diamondnib/model/sectionlistmodel.dart';
import 'package:diamondnib/model/sectiontypemodel.dart';
import 'package:diamondnib/model/watchlistmodel.dart';
import 'package:diamondnib/model/getwishlistmodel.dart';
import 'package:diamondnib/model/successmodel.dart';
import 'package:diamondnib/model/videobyidmodel.dart';
import 'package:diamondnib/model/subscriptionmodel.dart';
import 'package:diamondnib/model/rentmodel.dart';
import 'package:diamondnib/model/threadslistmodel.dart';
import 'package:diamondnib/model/sectiondetailmodel.dart';
import 'package:diamondnib/model/transactionlistmodel.dart';
import 'package:diamondnib/model/genresmodel.dart';
import 'package:diamondnib/model/langaugemodel.dart';
import 'package:diamondnib/model/channelsectionmodel.dart';
import 'package:diamondnib/model/generalsettingmodel.dart';
import 'package:diamondnib/model/loginregistermodel.dart';
import 'package:diamondnib/model/profilemodel.dart';

// Providers
import 'package:diamondnib/provider/downloadprovider.dart';

// Utils
import 'package:diamondnib/utils/constant.dart';
import 'package:diamondnib/utils/utils.dart';

// Aliases for model imports to avoid conflicts
import 'package:diamondnib/model/episodebycontentmodel.dart' as audiobookepisode;
import 'package:diamondnib/model/contentdetailmodel.dart' as audiobookdetails;
import 'package:diamondnib/model/contentdetailmodel.dart' as noveldetails;
import 'package:diamondnib/model/episodebycontentmodel.dart' as novelchapters;



class ApiService {
  String baseUrl = Constant.baseurl;

  late Dio dio;

  Options optHeaders = Options(headers: <String, dynamic>{
    'Content-Type': 'application/json',
  });

  ApiService() {
    dio = Dio();
    // dio.interceptors.add(
    //   PrettyDioLogger(
    //     requestHeader: true,
    //     requestBody: true,
    //     responseBody: true,
    //     responseHeader: false,
    //     compact: false,
    //   ),
    // );
  }

  // general_setting API
  Future<GeneralSettingModel> genaralSetting() async {
    GeneralSettingModel generalSettingModel;
    String generalsetting = "general_setting";
    Response response = await dio.post(
      '$baseUrl$generalsetting',
      options: optHeaders,
    );
    generalSettingModel = GeneralSettingModel.fromJson(response.data);
    return generalSettingModel;
  }

  // get_pages API
  Future<PagesModel> getPages() async {
    PagesModel pagesModel;
    String getPagesAPI = "get_pages";
    Response response = await dio.post(
      '$baseUrl$getPagesAPI',
      options: optHeaders,
    );
    pagesModel = PagesModel.fromJson(response.data);
    return pagesModel;
  }

  /* type => 1-Facebook, 2-Google, 4-Google */
  // login API
  Future<LoginRegisterModel> loginWithSocial(
      email, String name, type, deviceType, File? profileImg) async {
    printLog("email :==> $email");
    printLog("name :==> $name");
    printLog("type :==> $type");
    printLog("profileImg :==> $profileImg");

    LoginRegisterModel loginModel;
    String gmailLogin = "login";
    Response response = await dio.post(
      '$baseUrl$gmailLogin',
      options: optHeaders,
      data: FormData.fromMap({
        'type': type,
        'email': email,
        'full_name': name,
        'device_type': deviceType,
        'image': (profileImg?.path ?? "").isNotEmpty
            ? await MultipartFile.fromFile(
                profileImg?.path ?? "",
                filename: (profileImg?.path ?? "").split('/').last,
              )
            : "",
      }),
    );

    loginModel = LoginRegisterModel.fromJson(response.data);
    return loginModel;
  }

  /* type => 3-OTP */
  // login API
  Future<LoginRegisterModel> loginWithOTP(mobile) async {
    printLog("mobile :==> $mobile");

    LoginRegisterModel loginModel;
    String doctorLogin = "login";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      options: optHeaders,
      data: {
        'type': '1',
        'mobile_number': mobile,
      },
    );

    loginModel = LoginRegisterModel.fromJson(response.data);
    return loginModel;
  }

  /* type => 4-Normal */
  // login/register API
  Future<LoginRegisterModel> loginWithEmailPassword(
    String email,
    String password,
    String? fullName,
    String? deviceType,
    String? deviceToken,
    bool isRegister,
  ) async {
    printLog("email :==> $email");

    LoginRegisterModel loginModel;
    String apiName = "login";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'type': '4',
        'email': email,
        'password': password,
        'full_name': fullName ?? "",
        'device_type': deviceType ?? "0",
        'device_token': deviceToken ?? "",
        'is_register': isRegister ? '1' : '0',
      },
    );

    loginModel = LoginRegisterModel.fromJson(response.data);
    return loginModel;
  }

  // forgot_password API
  Future<SuccessModel> forgotPassword(email) async {
    printLog("email :==> $email");

    SuccessModel successModel;
    String doctorLogin = "forgot_password";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      options: optHeaders,
      data: {
        'email': email,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      successModel = SuccessModel.fromJson(data);
    } else if (data is String) {
      successModel = successModelFromJson(data);
    } else {
      successModel = SuccessModel.fromJson(
        Map<String, dynamic>.from(data as dynamic),
      );
    }
    return successModel;
  }

  // get_profile API
  Future<ProfileModel> profile() async {
    printLog("profile userID :==> ${Constant.userID}");

    ProfileModel profileModel;
    String doctorLogin = "get_profile";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
      },
    );

    profileModel = ProfileModel.fromJson(response.data);
    return profileModel;
  }

  // get_profile API
  Future<ProfileModel> getUserProfile(userID) async {
    ProfileModel otheruserModel;
    String otherUser = "get_profile";
    Response response = await dio.post(
      '$baseUrl$otherUser',
      options: optHeaders,
      data: {
        'user_id': userID,
      },
    );

    otheruserModel = ProfileModel.fromJson(response.data);
    return otheruserModel;
  }

  // update_profile API
  Future<SuccessModel> updateProfile(
    fullName,
    email,
    mobileNumber,
    aboutMe,
    profileFrontImg,
  ) async {
    printLog("updateProfile userID :==> ${Constant.userID}");
    printLog("updateProfile fullName :==> $fullName");
    printLog("updateProfile email :==> $email");
    printLog("updateProfile aboutMe :==> $aboutMe");

    printLog("profileFrontImg  :==> $profileFrontImg");

    SuccessModel successModel;
    String doctorLogin = "update_profile";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      data: FormData.fromMap({
        'user_id': Constant.userID ?? 0,
        'full_name': fullName,
        'email': email,
        'mobile_number': mobileNumber,
        'bio': aboutMe ?? "",
        "image": profileFrontImg != null
            ? (MultipartFile.fromFileSync(
                profileFrontImg?.path ?? "",
                filename: path.basename(profileFrontImg?.path ?? ""),
              ))
            : "",
      }),
      options: optHeaders,
    );

    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // image_upload API
  Future<SuccessModel> imageUpload(File? profileImg) async {
    printLog("ProfileImg Filename :==> ${profileImg?.path.split('/').last}");
    printLog(
        "profileImg Extension :==> ${profileImg?.path.split('/').last.split(".").last}");
    SuccessModel uploadImgModel;
    String uploadImage = "image_upload";
    printLog("imageUpload API :==> $baseUrl$uploadImage");
    Response response = await dio.post(
      '$baseUrl$uploadImage',
      data: FormData.fromMap({
        'id': Constant.userID,
        'image': (profileImg?.path ?? "").isNotEmpty
            ? await MultipartFile.fromFile(
                profileImg?.path ?? "",
                filename: (profileImg?.path ?? "").split('/').last,
              )
            : "",
      }),
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    uploadImgModel = SuccessModel.fromJson(response.data);
    return uploadImgModel;
  }

  // update_profile API
  Future<SuccessModel> updateDataForPayment(
      fullName, email, mobileNumber) async {
    printLog("updateDataForPayment userID :====> ${Constant.userID}");
    printLog("updateDataForPayment fullName :==> $fullName");
    printLog("updateDataForPayment email :=====> $email");
    printLog("updateProfile mobileNumber :=====> $mobileNumber");

    SuccessModel responseModel;
    String apiName = "update_profile";
    Response response = await dio.post(
      '$baseUrl$apiName',
      data: FormData.fromMap({
        'user_id': Constant.userID,
        'full_name': fullName,
        'email': email,
        'mobile_number': mobileNumber,
      }),
      options: optHeaders,
    );

    responseModel = SuccessModel.fromJson(response.data);
    return responseModel;
  }

  // Upload Threads API
  Future<SuccessModel> uploadThreads(
    description,
    image,
  ) async {
    printLog("uploadThreads userID :====> ${Constant.userID}");
    printLog("uploadThreads description :==> $description");
    printLog("uploadThreads image :=====> $image");

    SuccessModel uploadThreadsModel;
    String apiName = "upload_threads";
    Response response = await dio.post(
      '$baseUrl$apiName',
      data: FormData.fromMap({
        'user_id': Constant.userID,
        'description': description,
        "image": image != null
            ? (MultipartFile.fromFileSync(
                image?.path ?? "",
                filename: path.basename(image?.path ?? ""),
              ))
            : "",
      }),
      options: optHeaders,
    );

    uploadThreadsModel = SuccessModel.fromJson(response.data);
    return uploadThreadsModel;
  }

  // delete_threads API
  Future<SuccessModel> deleteThreads(threadsID) async {
    SuccessModel deleteThreadsModel;
    String apiName = "delete_threads";
    Response response = await dio.post(
      '$baseUrl$apiName',
      data: FormData.fromMap({
        'threads_id': threadsID,
      }),
      options: optHeaders,
    );

    deleteThreadsModel = SuccessModel.fromJson(response.data);
    return deleteThreadsModel;
  }

  // get_avatar API
  Future<AvatarModel> getAvatar() async {
    AvatarModel avatarModel;
    String getAvatar = "get_avatar";
    Response response = await dio.post(
      '$baseUrl$getAvatar',
      options: optHeaders,
      data: {},
    );
    avatarModel = AvatarModel.fromJson(response.data);
    return avatarModel;
  }

  /* type => 1-movies, 2-news, 3-sport, 4-tv show */
  // get_type API
  Future<SectionTypeModel> sectionType() async {
    SectionTypeModel sectionTypeModel;
    String sectionType = "get_type";
    Response response = await dio.post(
      '$baseUrl$sectionType',
      options: optHeaders,
    );
    sectionTypeModel = SectionTypeModel.fromJson(response.data);
    return sectionTypeModel;
  }

  // get_banner API
  Future<SectionBannerModel> homesectionBanner(
      topcategoryID, isHomePage) async {
    printLog('sectionBanner typeId ==>>> $topcategoryID');
    printLog('sectionBanner isHomePage ==>>> $isHomePage');
    SectionBannerModel sectionBannerModel;
    String sectionBanner = "get_home_banner";
    Response response = await dio.post(
      '$baseUrl$sectionBanner',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'top_category_id': topcategoryID,
        'is_home_screen': isHomePage,
      },
    );
    sectionBannerModel = SectionBannerModel.fromJson(response.data);
    return sectionBannerModel;
  }

  // get_audiobook_banner API
  Future<SectionBannerModel> audiobooksectionBanner(
      topcategoryID, isHomePage) async {
    SectionBannerModel audiosectionBannerModel;
    String audiosectionBanner = "get_audiobook_banner";
    Response response = await dio.post(
      '$baseUrl$audiosectionBanner',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'top_category_id': topcategoryID,
        'is_home_screen': isHomePage,
      },
    );
    audiosectionBannerModel = SectionBannerModel.fromJson(response.data);
    return audiosectionBannerModel;
  }

  // get_novel_banner API
  Future<SectionBannerModel> novelsectionBanner(
      topcategoryID, isHomePage) async {
    SectionBannerModel novelsectionBannerModel;
    String novelsectionBanner = "get_novel_banner";
    Response response = await dio.post(
      '$baseUrl$novelsectionBanner',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'top_category_id': topcategoryID,
        'is_home_screen': isHomePage,
      },
    );
    novelsectionBannerModel = SectionBannerModel.fromJson(response.data);
    return novelsectionBannerModel;
  }

  Future<ContentDetailsModel> seeall(sectionId, pageno) async {
    printLog("sectionid == $sectionId");
    ContentDetailsModel seeallmodel;
    String seeall = "get_content_section_detail";
    Response response = await dio.post(
      '$baseUrl$seeall',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'section_id': sectionId,
        'page_no': pageno,
      },
    );
    seeallmodel = ContentDetailsModel.fromJson(response.data);
    return seeallmodel;
  }

  Future<SectionListModel> musicsectionList(
      ishomescreen, topCategoryId, pageNo) async {
    SectionListModel musicsectionListModel;
    String apiname = "get_music_section";
    Response response = await dio.post('$baseUrl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'is_home_screen': ishomescreen,
          'top_category_id': topCategoryId,
          'page_no': pageNo,
        }));
    musicsectionListModel = SectionListModel.fromJson(response.data);
    return musicsectionListModel;
  }

  // section_list API
  Future<SectionListModel> sectionList(typeId, isHomePage, pageno) async {
    printLog("get_home_section calling ");
    SectionListModel sectionListModel;
    String sectionList = "get_home_section";
    Response response = await dio.post(
      '$baseUrl$sectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'top_category_id': typeId,
        'page_no': pageno,
        'is_home_screen': isHomePage,
      },
    );
    sectionListModel = SectionListModel.fromJson(response.data);
    return sectionListModel;
  }

  // audiobook section_list API
  Future<AudioSectionListModel> audiosectionList(
      typeId, isHomePage, pageno) async {
    AudioSectionListModel audiosectionListModel;
    String audiosectionList = "get_audiobook_section";
    Response response = await dio.post(
      '$baseUrl$audiosectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'top_category_id': typeId,
        'page_no': pageno,
        'is_home_screen': isHomePage,
      },
    );
    audiosectionListModel = AudioSectionListModel.fromJson(response.data);
    return audiosectionListModel;
  }

  // novel section_list API
  Future<NovelSectionListModel> novelsectionList(
      typeId, isHomePage, pageno) async {
    NovelSectionListModel novelsectionListModel;
    String novelsectionList = "get_novel_section";
    Response response = await dio.post(
      '$baseUrl$novelsectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'top_category_id': typeId,
        'page_no': pageno,
        'is_home_screen': isHomePage,
      },
    );
    novelsectionListModel = NovelSectionListModel.fromJson(response.data);
    return novelsectionListModel;
  }

  // Threads section_list API
  Future<ThreadsListModel> threadssectionList(pageNo) async {
    printLog("Page nO == $pageNo");
    ThreadsListModel threadssectionListModel;
    String threadssectionList = "get_threads_list";
    Response response = await dio.post(
      '$baseUrl$threadssectionList',
      options: optHeaders,
      data: {'user_id': Constant.userID ?? 0, 'page_no': pageNo},
    );
    threadssectionListModel = ThreadsListModel.fromJson(response.data);
    return threadssectionListModel;
  }

  //  get_threads_by_user API
  Future<ThreadsListModel> threadbyuser(userID, pageno) async {
    ThreadsListModel threadbyuserModel;
    String threadbyuserList = "get_threads_by_user";
    Response response = await dio.post(
      '$baseUrl$threadbyuserList',
      options: optHeaders,
      data: {'user_id': userID, 'page_no': pageno},
    );
    threadbyuserModel = ThreadsListModel.fromJson(response.data);
    return threadbyuserModel;
  }

  //  get_threads_by_user API
  Future<ThreadsListModel> threadbyartist(artistID, pageno) async {
    ThreadsListModel threadbyartistModel;
    String threadbyartistList = "get_threads_by_artist";
    Response response = await dio.post(
      '$baseUrl$threadbyartistList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'artist_id': artistID,
        'page_no': pageno
      },
    );
    threadbyartistModel = ThreadsListModel.fromJson(response.data);
    return threadbyartistModel;
  }

  // contentDetails API
  Future<ContentDetailsModel> contentDetails(contentid, contenttype) async {
    printLog("contentid == $contentid");
    printLog("contenttype == $contenttype");
    ContentDetailsModel contentDetailsModel;
    String contentDetails = "get_content_detail";
    Response response = await dio.post(
      '$baseUrl$contentDetails',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'content_id': contentid,
        'content_type': contenttype,
      },
    );
    contentDetailsModel = ContentDetailsModel.fromJson(response.data);
    return contentDetailsModel;
  }

  // get_video_by_content API
  Future<EpisodeByContentModel> episodeVideoByContent(seasonId, pageno) async {
    EpisodeByContentModel episodeByContentModel;
    String episodeByContentList = "get_episode_video_by_content";
    Response response = await dio.post(
      '$baseUrl$episodeByContentList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'content_id': seasonId,
        'page_no': pageno
      },
    );
    episodeByContentModel = EpisodeByContentModel.fromJson(response.data);
    return episodeByContentModel;
  }

  // get_audio_by_content API
  Future<EpisodeByContentModel> episodeAudioByContent(seasonId, pageno) async {
    EpisodeByContentModel audioByContentModel;
    String audioByContentList = "get_episode_audio_by_content";
    Response response = await dio.post(
      '$baseUrl$audioByContentList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'content_id': seasonId,
        'page_no': pageno
      },
    );
    audioByContentModel = EpisodeByContentModel.fromJson(response.data);
    printLog("audioByContentModel == ${audioByContentModel.status}");
    return audioByContentModel;
  }

  // get_music_section_detail API
  Future<EpisodeByContentModel> episodeMusicBySection(sectionID, pageno) async {
    EpisodeByContentModel musicByContentModel;
    String musicByContentList = "get_music_section_detail";
    Response response = await dio.post(
      '$baseUrl$musicByContentList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'section_id': sectionID,
        'page_no': pageno
      },
    );
    musicByContentModel = EpisodeByContentModel.fromJson(response.data);
    printLog("audioByContentModel == ${musicByContentModel.status}");
    return musicByContentModel;
  }

  // get_episode_book_by_content API
  Future<EpisodeByContentModel> episodeByBook(seasonId, pageno) async {
    EpisodeByContentModel chapterByContentModel;
    String audioByContentList = "get_episode_book_by_content";
    Response response = await dio.post(
      '$baseUrl$audioByContentList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'content_id': seasonId,
        'page_no': pageno
      },
    );
    chapterByContentModel = EpisodeByContentModel.fromJson(response.data);
    return chapterByContentModel;
  }

  // section_detail API
  Future<SectionDetailModel> sectionDetails(
      typeId, videoType, videoId, upcomingType) async {
    SectionDetailModel sectionDetailModel;
    String sectionList = "section_detail";
    Response response = await dio.post(
      '$baseUrl$sectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'type_id': typeId,
        'video_type': videoType,
        'video_id': videoId,
        'upcoming_type': upcomingType,
      },
    );
    sectionDetailModel = SectionDetailModel.fromJson(response.data);
    return sectionDetailModel;
  }

  // get_earn_coin API
  Future<Earncoinmodel> getearncoins() async {
    Earncoinmodel earncoinModel;
    String earncoin = "get_earn_coin";
    Response response = await dio.post(
      '$baseUrl$earncoin',
      options: optHeaders,
      data: {},
    );
    earncoinModel = Earncoinmodel.fromJson(response.data);
    return earncoinModel;
  }

  // get_earn_coin_transaction API
  Future<SuccessModel> getearntransaction(coin, type) async {
    SuccessModel earncointransactionModel;
    String earncointransaction = "get_earn_coin_transaction";
    Response response = await dio.post(
      '$baseUrl$earncointransaction',
      options: optHeaders,
      data: {'user_id': Constant.userID, 'coin': coin, 'type': type},
    );
    earncointransactionModel = SuccessModel.fromJson(response.data);
    return earncointransactionModel;
  }

  Future<EarnCoindTransactionListModel> getearntransactionlist(pageNo) async {
    EarnCoindTransactionListModel earncointransactionlistModel;
    String earncointransactionlist = "get_earn_coin_transaction_list";
    Response response = await dio.post(
      '$baseUrl$earncointransactionlist',
      options: optHeaders,
      data: {'user_id': Constant.userID, 'page_no': pageNo},
    );
    earncointransactionlistModel =
        EarnCoindTransactionListModel.fromJson(response.data);
    return earncointransactionlistModel;
  }

  // get_wallet_transaction_list API
  Future<TransactionListModel> transactionList(pageNo) async {
    TransactionListModel transactionListModel;
    String transactionList = "get_wallet_transaction_list";
    Response response = await dio.post(
      '$baseUrl$transactionList',
      options: optHeaders,
      data: {'user_id': Constant.userID, 'page_no': pageNo},
    );
    transactionListModel = TransactionListModel.fromJson(response.data);
    return transactionListModel;
  }

  // get_transaction_list API
  Future<TransactionListModel> wallettransactionList(pageNo) async {
    TransactionListModel wallettransactionListModel;
    String wallettransactionList = "get_transaction_list";
    Response response = await dio.post(
      '$baseUrl$wallettransactionList',
      options: optHeaders,
      data: {'user_id': Constant.userID, 'page_no': pageNo},
    );
    wallettransactionListModel = TransactionListModel.fromJson(response.data);
    return wallettransactionListModel;
  }

  // get_reviews API
  Future<CommentModel> getreviews(conetentId, contentType, pageNo) async {
    CommentModel getReviewModel;
    String getReview = "get_reviews";
    Response response = await dio.post(
      '$baseUrl$getReview',
      options: optHeaders,
      data: {
        'content_id': conetentId,
        'content_type': contentType,
        'page_no': pageNo
      },
    );
    getReviewModel = CommentModel.fromJson(response.data);
    return getReviewModel;
  }

  // get_artist_detail API
  Future<ArtistProfileModel> getArtist(
    artistId,
  ) async {
    ArtistProfileModel getArtistModel;
    String getArtist = "get_artist_detail";
    Response response = await dio.post(
      '$baseUrl$getArtist',
      options: optHeaders,
      data: {
        'artist_id': artistId,
        'user_id': Constant.userID ?? 0,
      },
    );
    getArtistModel = ArtistProfileModel.fromJson(response.data);
    return getArtistModel;
  }

  // get_artist_detail API
  Future<ArtistProfileModel> getSugestedArtist() async {
    ArtistProfileModel getSuggestArtistModel;
    String getSuggestArtist = "get_artist_suggestion_list";
    Response response = await dio.post(
      '$baseUrl$getSuggestArtist',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
      },
    );
    getSuggestArtistModel = ArtistProfileModel.fromJson(response.data);
    return getSuggestArtistModel;
  }

  // video_view API
  Future<SuccessModel> videoView(videoId, videoType, otherId) async {
    printLog('videoView videoId ====>>> $videoId');
    printLog('videoView videoType ==>>> $videoType');
    printLog('videoView otherId ====>>> $otherId');
    SuccessModel successModel;
    String sectionList = "video_view";
    Response response = await dio.post(
      '$baseUrl$sectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'video_id': videoId,
        'video_type': videoType,
        'other_id': otherId,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // add_remove_bookmark API
  Future<SuccessModel> addRemoveBookmark(contentType, contentId) async {
    SuccessModel successModel;
    String sectionList = "add_remove_bookmark";
    Response response = await dio.post(
      '$baseUrl$sectionList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'content_type': contentType,
        'content_id': contentId,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // get_content_by_artist API
  Future<GetContentByArtistMdel> getContentByArtist(
      type, artistid, pageNo) async {
    GetContentByArtistMdel getContentByArtist;
    String getContentByArtistAPI = "get_content_by_artist";
    Response response = await dio.post(
      '$baseUrl$getContentByArtistAPI',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'type': type,
        'artist_id': artistid,
        'page_no': pageNo
      },
    );
    getContentByArtist = GetContentByArtistMdel.fromJson(response.data);
    return getContentByArtist;
  }

  // get_content_by_artist API
  Future<GetContentByArtistMdel> getNovelByArtist(
      type, artistid, pageNo) async {
    GetContentByArtistMdel getNovelByArtist;
    String getNovelByArtistAPI = "get_content_by_artist";
    Response response = await dio.post(
      '$baseUrl$getNovelByArtistAPI',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'type': type,
        'artist_id': artistid,
        'page_no': pageNo
      },
    );
    getNovelByArtist = GetContentByArtistMdel.fromJson(response.data);
    return getNovelByArtist;
  }

  // get_music_by_artist API
  Future<GetContentByArtistMdel> getMusicByArtist(artistid, pageNo) async {
    GetContentByArtistMdel getMusicByArtist;
    String getMusicByArtistAPI = "get_music_by_artist";
    Response response = await dio.post(
      '$baseUrl$getMusicByArtistAPI',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'artist_id': artistid,
        'page_no': pageNo
      },
    );
    getMusicByArtist = GetContentByArtistMdel.fromJson(response.data);
    return getMusicByArtist;
  }

  // get_music_by_artist API
  Future<EpisodeByContentModel> getMusicByArtistPlaylist(
      artistid, pageNo) async {
    EpisodeByContentModel getMusicByArtist;
    String getMusicByArtistAPI = "get_music_by_artist";
    Response response = await dio.post(
      '$baseUrl$getMusicByArtistAPI',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'artist_id': artistid,
        'page_no': pageNo
      },
    );
    getMusicByArtist = EpisodeByContentModel.fromJson(response.data);
    return getMusicByArtist;
  }

  // add_remove_like_dislike API
  Future<SuccessModel> addRemoveLike(threadID) async {
    SuccessModel addRemoveLikeModel;
    String addremoveLike = "add_remove_like_dislike";
    Response response = await dio.post(
      '$baseUrl$addremoveLike',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'threads_id': threadID,
      },
    );
    addRemoveLikeModel = SuccessModel.fromJson(response.data);
    return addRemoveLikeModel;
  }

  // add_continue_watching API
  Future<SuccessModel> addContinueWatching(
      contentId, contentType, stopTime, contentEpisodeId, audiobookType) async {
    SuccessModel successModel;
    String continueWatching = "add_content_to_history";
    Response response = await dio.post(
      '$baseUrl$continueWatching',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'content_id': contentId,
        'content_type': contentType,
        'stop_time': stopTime,
        'content_episode_id': contentEpisodeId,
        'audiobook_type': audiobookType
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> logout() async {
    SuccessModel logoutModel;
    String logout = "logout";
    Response response = await dio.post(
      '$baseUrl$logout',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
      },
    );
    logoutModel = SuccessModel.fromJson(response.data);
    return logoutModel;
  }

  // remove_continue_watching API
  /* user_id, video_id, video_type
     * Show :=> ("video_id" = Episode's ID)  AND  ("video_type" = "2")
     * Video :=> ("video_id" = Video's ID) */
  Future<SuccessModel> removeContinueWatching(
      contentId, contentType, contentEpisodeId, audiobookType) async {
    SuccessModel successModel;
    String removeContinueWatching = "remove_content_to_history";
    Response response = await dio.post(
      '$baseUrl$removeContinueWatching',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'content_id': contentId,
        'content_type': contentType,
        'content_episode_id': contentEpisodeId,
        'audiobook_type': audiobookType
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // get_category API
  Future<GenresModel> genres() async {
    GenresModel genresModel;
    String genres = "get_category";
    Response response = await dio.post(
      '$baseUrl$genres',
      options: optHeaders,
    );
    genresModel = GenresModel.fromJson(response.data);
    return genresModel;
  }

  // get_language API
  Future<LangaugeModel> language() async {
    LangaugeModel langaugeModel;
    String language = "get_language";
    Response response = await dio.post(
      '$baseUrl$language',
      options: optHeaders,
    );
    langaugeModel = LangaugeModel.fromJson(response.data);
    return langaugeModel;
  }

  // search_video API
  Future<SearchListModel> searchContent(searchText, type, pageNo) async {
    printLog('searchContent searchText ==>>> $searchText');
    SearchListModel searchModel;
    String search = "search_content";
    Response response = await dio.post(
      '$baseUrl$search',
      options: optHeaders,
      data: {
        'name': searchText,
        'user_id': Constant.userID ?? 0,
        'type': type,
        'page_no': pageNo
      },
    );
    searchModel = SearchListModel.fromJson(response.data);
    return searchModel;
  }

  // search_video Music API
  Future<EpisodeByContentModel> searchMusicContent(pageNo) async {
    EpisodeByContentModel searchMusicModel;
    String search = "search_content";
    Response response = await dio.post(
      '$baseUrl$search',
      options: optHeaders,
      data: {
        'name': Constant.searchtext,
        'user_id': Constant.userID ?? 0,
        'type': 3,
        'page_no': pageNo
      },
    );
    searchMusicModel = EpisodeByContentModel.fromJson(response.data);
    return searchMusicModel;
  }

  // channel_section_list API
  Future<ChannelSectionModel> channelSectionList() async {
    ChannelSectionModel channelSectionModel;
    String channelSection = "channel_section_list";
    Response response = await dio.post(
      '$baseUrl$channelSection',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
      },
    );
    channelSectionModel = ChannelSectionModel.fromJson(response.data);
    return channelSectionModel;
  }

  // rent_video_list API
  Future<RentModel> rentVideoList() async {
    RentModel rentModel;
    String rentList = "rent_video_list";
    Response response = await dio.post(
      '$baseUrl$rentList',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
      },
    );
    rentModel = RentModel.fromJson(response.data);
    return rentModel;
  }

  // add_remove_follow API
  Future<SuccessModel> addremovefollow(artistId) async {
    SuccessModel addRemoveFolloModel;
    String addremovefollow = "add_remove_follow";
    Response response = await dio.post(
      '$baseUrl$addremovefollow',
      options: optHeaders,
      data: {
        'artist_id': artistId,
        'user_id': Constant.userID,
      },
    );
    addRemoveFolloModel = SuccessModel.fromJson(response.data);
    return addRemoveFolloModel;
  }

  // add_reviews API
  Future<SuccessModel> addreviews(
      contentID, comment, contenttype, rating) async {
    SuccessModel addreviewsModel;
    String addreview = "add_reviews";
    Response response = await dio.post(
      '$baseUrl$addreview',
      options: optHeaders,
      data: {
        'content_id': contentID,
        'user_id': Constant.userID,
        'comment': comment,
        'content_type': contenttype,
        'rating': rating
      },
    );
    addreviewsModel = SuccessModel.fromJson(response.data);
    return addreviewsModel;
  }

  // add_comment API
  Future<SuccessModel> addComment(commentID, comment, threadID) async {
    SuccessModel addreviewsModel;
    String addreview = "add_comment";
    Response response = await dio.post(
      '$baseUrl$addreview',
      options: optHeaders,
      data: {
        'comment_id': commentID,
        'user_id': Constant.userID,
        'comment': comment,
        'threads_id': threadID
      },
    );
    addreviewsModel = SuccessModel.fromJson(response.data);
    return addreviewsModel;
  }

  // get_comment API
  Future<CommentModel> getComments(threadID, pageNo) async {
    CommentModel getCommentModel;
    String getComment = "get_comment";
    Response response = await dio.post(
      '$baseUrl$getComment',
      options: optHeaders,
      data: {'threads_id': threadID, 'page_no': pageNo},
    );
    getCommentModel = CommentModel.fromJson(response.data);
    return getCommentModel;
  }

  // get_reply_comment API
  Future<CommentModel> getReplyComments(commentID, pageNo) async {
    CommentModel getReplyCommentModel;
    String getReplyComment = "get_reply_comment";
    Response response = await dio.post(
      '$baseUrl$getReplyComment',
      options: optHeaders,
      data: {'comment_id': commentID, 'page_no': pageNo},
    );
    getReplyCommentModel = CommentModel.fromJson(response.data);
    return getReplyCommentModel;
  }

  Future<GetNotificationModel> notification(pageNo) async {
    GetNotificationModel getNotificationModel;
    String apiname = "get_notification";
    Response response = await dio.post('$baseUrl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'page_no': pageNo,
        }));
    getNotificationModel = GetNotificationModel.fromJson(response.data);
    return getNotificationModel;
  }

  Future<SuccessModel> readNotification(notificationId) async {
    SuccessModel successModel;
    String apiname = "read_notification";
    Response response = await dio.post('$baseUrl$apiname',
        data: FormData.fromMap({
          'user_id': Constant.userID == null ? "0" : (Constant.userID ?? ""),
          'notification_id': notificationId,
        }));
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // edit_reviews API
  Future<SuccessModel> editreviews(contentID, comment, rating) async {
    SuccessModel editreviewsModel;
    String editreview = "edit_reviews";
    Response response = await dio.post(
      '$baseUrl$editreview',
      options: optHeaders,
      data: {
        'review_id': contentID,
        'user_id': Constant.userID,
        'comment': comment,
        'rating': rating
      },
    );
    editreviewsModel = SuccessModel.fromJson(response.data);
    return editreviewsModel;
  }

  // edit_comment API
  Future<SuccessModel> editcomment(
    commentID,
    comment,
  ) async {
    SuccessModel editcommentModel;
    String editcomment = "edit_comment";
    Response response = await dio.post(
      '$baseUrl$editcomment',
      options: optHeaders,
      data: {
        'comment_id': commentID,
        'user_id': Constant.userID,
        'comment': comment,
      },
    );
    editcommentModel = SuccessModel.fromJson(response.data);
    return editcommentModel;
  }

  // buy_content_episode API
  Future<SuccessModel> buyEpisode(
    contentType,
    episodeID,
    audioBookType,
    contentID,
    coin,
  ) async {
    SuccessModel buyEpisodeModel;
    String buyepisode = "buy_content_episode";
    Response response = await dio.post(
      '$baseUrl$buyepisode',
      options: optHeaders,
      data: {
        'content_type': contentType,
        'user_id': Constant.userID,
        'content_episode_id': episodeID,
        'audiobook_type': audioBookType,
        'content_id': contentID,
        'coin': coin,
      },
    );
    buyEpisodeModel = SuccessModel.fromJson(response.data);
    return buyEpisodeModel;
  }

  // add_content_play API
  Future<SuccessModel> addToPlay(
    contentType,
    episodeID,
    audioBookType,
    contentID,
  ) async {
    SuccessModel addcontentplayModel;
    String addcontentplay = "add_content_play";
    Response response = await dio.post(
      '$baseUrl$addcontentplay',
      options: optHeaders,
      data: {
        'content_type': contentType,
        'user_id': Constant.userID,
        'content_episode_id': episodeID,
        'audiobook_type': audioBookType,
        'content_id': contentID,
      },
    );
    addcontentplayModel = SuccessModel.fromJson(response.data);
    return addcontentplayModel;
  }

  // delete_reviews API
  Future<SuccessModel> deletereviews(
    contentID,
  ) async {
    SuccessModel deletereviewsModel;
    String deletereview = "delete_reviews";
    Response response = await dio.post(
      '$baseUrl$deletereview',
      options: optHeaders,
      data: {
        'review_id': contentID,
      },
    );
    deletereviewsModel = SuccessModel.fromJson(response.data);
    return deletereviewsModel;
  }

  // delete_comment API
  Future<SuccessModel> deletecomment(
    commentId,
  ) async {
    SuccessModel deletecommentModel;
    String deletecomment = "delete_comment";
    Response response = await dio.post(
      '$baseUrl$deletecomment',
      options: optHeaders,
      data: {
        'comment_id': commentId,
      },
    );
    deletecommentModel = SuccessModel.fromJson(response.data);
    return deletecommentModel;
  }

  // video_by_category API
  Future<VideoByIdModel> videoByCategory(categoryID, typeId, pageNo) async {
    printLog('videoByCategory categoryID ==>>> $categoryID');
    printLog('videoByCategory typeId ====>>>>> $typeId');
    VideoByIdModel videoByIdModel;
    String byCategory = "get_content_by_category";
    Response response = await dio.post(
      '$baseUrl$byCategory',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'category_id': categoryID,
        'type': typeId,
        "page_no": pageNo
      },
    );
    videoByIdModel = VideoByIdModel.fromJson(response.data);
    return videoByIdModel;
  }

  // video_by_language API
  Future<VideoByIdModel> videoByLanguage(languageID, typeId, pageNo) async {
    printLog('videoByLanguage languageID ==>>> $languageID');
    printLog('videoByLanguage typeId ====>>>>> $typeId');
    VideoByIdModel videoByIdModel;
    String byLanguage = "get_content_by_language";
    Response response = await dio.post(
      '$baseUrl$byLanguage',
      options: optHeaders,
      data: {
        'user_id': Constant.userID ?? 0,
        'language_id': languageID,
        'type': typeId,
        "page_no": pageNo
      },
    );
    videoByIdModel = VideoByIdModel.fromJson(response.data);
    return videoByIdModel;
  }

  // get_package API
  Future<SubscriptionModel> subscriptionPackage() async {
    printLog('subscriptionPackage userID ==>>> ${Constant.userID}');
    SubscriptionModel subscriptionModel;
    String getPackage = "get_package";
    Response response = await dio.post(
      '$baseUrl$getPackage',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
      },
    );
    subscriptionModel = SubscriptionModel.fromJson(response.data);
    return subscriptionModel;
  }

  // get_bookmark_video API
  Future<GetWishListModel> watchlist(contentType, pageNo) async {
    printLog("watchlist userID :==> ${Constant.userID}");

    GetWishListModel watchlistModel;
    String getBookmarkVideo = "get_bookmark_list";
    printLog("getBookmarkVideo API :==> $baseUrl$getBookmarkVideo");
    Response response = await dio.post(
      '$baseUrl$getBookmarkVideo',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'content_type': contentType,
        'page_no': pageNo
      },
    );

    watchlistModel = GetWishListModel.fromJson(response.data);
    return watchlistModel;
  }

  // get_payment_option API
  Future<PaymentOptionModel> getPaymentOption() async {
    PaymentOptionModel paymentOptionModel;
    String paymentOption = "get_payment_option";
    printLog("paymentOption API :==> $baseUrl$paymentOption");
    Response response = await dio.post(
      '$baseUrl$paymentOption',
      options: optHeaders,
    );

    paymentOptionModel = PaymentOptionModel.fromJson(response.data);
    return paymentOptionModel;
  }

  // apply_coupon API
  Future<CouponModel> applyPackageCoupon(couponCode, packageId) async {
    CouponModel couponModel;
    String applyCoupon = "apply_coupon";
    printLog("applyPackageCoupon API :==> $baseUrl$applyCoupon");
    Response response = await dio.post(
      '$baseUrl$applyCoupon',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'apply_coupon_type': "1",
        'unique_id': couponCode,
        'package_id': packageId,
      },
    );

    couponModel = CouponModel.fromJson(response.data);
    return couponModel;
  }

  // apply_coupon API
  Future<CouponModel> applyRentCoupon(
      couponCode, videoId, typeId, videoType, price) async {
    CouponModel couponModel;
    String applyCoupon = "apply_coupon";
    printLog("applyRentCoupon API :==> $baseUrl$applyCoupon");
    Response response = await dio.post(
      '$baseUrl$applyCoupon',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'apply_coupon_type': "2",
        'unique_id': couponCode,
        'video_id': videoId,
        'type_id': typeId,
        'video_type': videoType,
        'price': price,
      },
    );

    couponModel = CouponModel.fromJson(response.data);
    return couponModel;
  }

  // get_payment_token API
  Future<PayTmModel> getPaytmToken(merchantID, orderId, custmoreID, channelID,
      txnAmount, website, callbackURL, industryTypeID) async {
    PayTmModel payTmModel;
    String paytmToken = "get_payment_token";
    printLog("paytmToken API :==> $baseUrl$paytmToken");
    Response response = await dio.post(
      '$baseUrl$paytmToken',
      options: optHeaders,
      data: {
        'MID': merchantID,
        'order_id': orderId,
        'CUST_ID': custmoreID,
        'CHANNEL_ID': channelID,
        'TXN_AMOUNT': txnAmount,
        'WEBSITE': website,
        'CALLBACK_URL': callbackURL,
        'INDUSTRY_TYPE_ID': industryTypeID,
      },
    );

    payTmModel = PayTmModel.fromJson(response.data);
    return payTmModel;
  }

  // add_transaction API
  Future<SuccessModel> addTransaction(
    packageId,
    description,
    amount,
    transactionId,
    coin,
  ) async {
    printLog('addTransaction userID ==>>> ${Constant.userID}');
    printLog('addTransaction packageId ==>>> $packageId');
    printLog('addTransaction description ==>>> $description');
    printLog('addTransaction amount ==>>> $amount');
    SuccessModel successModel;
    String transaction = "add_transaction";
    Response response = await dio.post(
      '$baseUrl$transaction',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'package_id': packageId,
        'description': description,
        'price': amount,
        'coin': coin,
        // 'payment_id': paymentId,
        // 'currency_code': currencyCode,
        // 'unique_id': couponCode,
        'transaction_id': transactionId
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // add_rent_transaction API
  Future<SuccessModel> addRentTransaction(
      videoId, price, typeId, videoType, couponCode) async {
    printLog('addRentTransaction userID ==>>> ${Constant.userID}');
    printLog('addRentTransaction video_id ==>>> $videoId');
    printLog('addRentTransaction price ==>>> $price');
    printLog('addRentTransaction typeId ==>>> $typeId');
    printLog('addRentTransaction videoType ==>>> $videoType');
    printLog('addTransaction couponCode ==>>> $couponCode');
    SuccessModel successModel;
    String rentTransaction = "add_rent_transaction";
    Response response = await dio.post(
      '$baseUrl$rentTransaction',
      options: optHeaders,
      data: {
        'user_id': Constant.userID,
        'video_id': videoId,
        'price': price,
        'type_id': typeId,
        'video_type': videoType,
        'unique_id': couponCode,
      },
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  Future<SuccessModel> verifyResetCode(
    String email,
    String code,
    String newPassword,
    String confirmPassword,
  ) async {
    SuccessModel successModel;
    String apiName = "verify_reset_code";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: optHeaders,
      data: {
        'email': email,
        'code': code,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      successModel = SuccessModel.fromJson(data);
    } else if (data is String) {
      successModel = successModelFromJson(data);
    } else {
      successModel = SuccessModel.fromJson(
        Map<String, dynamic>.from(data as dynamic),
      );
    }
    return successModel;
  }
}

// /* ========================== Download Videos ========================== */
// Future<void> prepareAudioDownload(BuildContext context, int index,
//     contentdetails.Result? contentDetails) async {
//   // final receivePort = ReceivePort();
//   contentdetails.Result? sectionDetails = contentDetails;

//   final downloadProvider = Provider.of<EpisodeProvider>(context, listen: false);
//   await downloadProvider.setCurrentDownload(sectionDetails?.id ?? 0);

//   Dio dio = Dio();

//   /* Hive */
//   Box<DownloadEpisodeItem> dowonloadBox;

//   dowonloadBox = Hive.box<DownloadEpisodeItem>(
//       '${Constant.hiveDownloadBox}_${Constant.userID}');

//   DateTime now = DateTime.now();
//   String timeStamp = now.millisecondsSinceEpoch.abs().toString();

//   /* Prepare Target Video File START ************* */
//   File? mTargetFile;
//   String? localPath;
//   String? mFileName = ('${(sectionDetails?.title ?? "").replaceAll(" ", "")}'
//       '${(sectionDetails?.id ?? 0)}${(Constant.userID)}');
//   try {
//     localPath = await Utils.prepareSaveDir();
//     printLog("localPath ====> $localPath");
//     mTargetFile = File(path.join(localPath, '$mFileName.mp3'));
//     // This is a sync operation on a real
//     // app you'd probably prefer to use writeAsByte and handle its Future
//   } catch (e) {
//     printLog("saveVideoStorage Exception ===> $e");
//   }
//   printLog("mFileName ========> $mFileName");
//   printLog("mTargetFile ========> ${mTargetFile?.absolute.path ?? ""}");
//   /* *************** Prepare Target Video File END */

//   /* Prepare Target Image Files START ************* */
//   File? mTargetPortImageFile, mTargetLandImageFile;
//   String? mPortImageFileName = 'port_$timeStamp';
//   String? mLandImageFileName = 'land_$timeStamp';
//   if (localPath != null) {
//     try {
//       mTargetPortImageFile =
//           File(path.join(localPath, '$mPortImageFileName.png'));
//       mTargetLandImageFile =
//           File(path.join(localPath, '$mLandImageFileName.png'));
//     } catch (e) {
//       printLog("saveVideoStorage Exception ===> $e");
//     }
//   } else {
//     return;
//   }
//   printLog("mPortImageFileName ========> $mPortImageFileName");
//   printLog(
//       "mTargetPortImageFile ======> ${mTargetPortImageFile?.absolute.path ?? ""}");
//   printLog("mLandImageFileName ========> $mLandImageFileName");
//   printLog(
//       "mTargetLandImageFile ======> ${mTargetLandImageFile?.absolute.path ?? ""}");
//   /* *************** Prepare Target Image Files END */

//   try {
//     Utils.showToast("Download started");

//     /* Potrait Image Download */
//     dio.download(sectionDetails?.portraitImg ?? "",
//         path.join(localPath, '$mPortImageFileName.png'),
//         onReceiveProgress: (received, total) {});

//     /* Landscape Image Download */
//     dio.download(sectionDetails?.portraitImg ?? "",
//         path.join(localPath, '$mLandImageFileName.png'),
//         onReceiveProgress: (received, total) {});

//     /* Audio Download */
//     await dio.download(sectionDetails?.title ?? "", mTargetFile?.path,
//         onReceiveProgress: (received, total) async {
//       if (total != -1) {
//         await await downloadProvider.setDownloadProgress(
//             (received / total * 100).round(), 0);
//       }
//     });

//     // /* Encrypt Video File START ************** */
//     // String generateKey = Utils.generateRandomKey(32);
//     // printLog("generateKey =======> $generateKey");
//     // var rootToken = RootIsolateToken.instance!;
//     // final isolate = await Isolate.spawn(Utils.encryptFile,
//     //     [mTargetFile, generateKey, receivePort.sendPort, rootToken]);
//     // receivePort.listen((message) {
//     //   printLog("message =======> $message");
//     //   if (message != null) {
//     //     receivePort.close();
//     //     isolate.kill(priority: Isolate.immediate);
//     //   }
//     // });
//     // /* ***************** Encrypt Video File END */
//     /* Encrypt Video File START ************** */
//     String generateKey = Utils.convertToHex(
//         Utils.generateRandomKey(32).padRight(16, '0').substring(0, 16));
//     String generateIVKey = Utils.convertToHex(
//         Utils.generateRandomKey(16).padRight(16, '0').substring(0, 16));
//     printLog("generateKey =======> $generateKey");
//     printLog("generateIVKey =====> $generateIVKey");
//     dynamic encryptedFile = await Utils.encryptUsingFFMPEG([
//       mTargetFile,
//       generateKey,
//       generateIVKey,
//     ]);
//     printLog("encryptedFile =====> $encryptedFile");
//     /* ***************** Encrypt Video File END */

//     DownloadEpisodeItem downloadedItem = DownloadEpisodeItem(
//       id: sectionDetails?.id,
//       securityKey: generateKey,
//       contentType: sectionDetails?.contentType ?? 0,
//       artistId: sectionDetails?.artistId,
//       categoryId: sectionDetails?.categoryId,
//       languageId: sectionDetails?.languageId,
//       title: sectionDetails?.title,
//       name: sectionDetails?.name,
//       description: sectionDetails?.description,
//       audio: sectionDetails?.audio,
//       image: sectionDetails?.image,
//       savedDir: localPath,
//       savedFile: mTargetFile?.path ?? "",
//       audioType: sectionDetails?.audioType,
//       isAudioPaid: sectionDetails?.isAudioPaid,
//       isAudioCoin: sectionDetails?.isAudioCoin,
//       isBuy: sectionDetails?.isBuy,
//       isDownload: 1,
//       videoDuration: sectionDetails?.videoDuration,
//       stopTime: sectionDetails?.stopTime ?? 0,
//       portraitImg: mTargetPortImageFile?.path,
//       landscapeImg: mTargetLandImageFile?.path,
//     );

//     /* Insert in Hive */
//     dowonloadBox.add(downloadedItem);

//     await await downloadProvider.setDownloadProgress(-1, 0);
//     await downloadProvider.setCurrentDownload(null);
//     await downloadProvider.setLoading(false);
//     Utils.showToast("Download completed");
//   } catch (e) {
//     Utils.showToast("Download failed");
//   }
// }
/* ========================== Download Videos ========================== */

/* ========================== Download AudioBooks ========================== */
// Future<void> prepareAudioDownload(
//   BuildContext context, {
//   required audiobookdetails.Result? contentDetails,
//   required int? episodePos,
//   required audiobookepisode.Result? episodeDetails,
// }) async {
//   audiobookdetails.Result? sectionDetails = contentDetails;

//   int epiPos = episodePos ?? 0;
//   audiobookepisode.Result? epiDetails = episodeDetails;

//   final downloadProvider =
//       Provider.of<DownLoadProvider>(context, listen: false);
//   await downloadProvider.setCurrentDownload(epiDetails?.id ?? 0);

//   Dio dio = Dio();

//   /* Hive */
//   Box<DownloadEpisodeItem> dowonloadBox;
//   Box<AudioBookBox> dowonloadSeasonBox;

//   dowonloadBox = Hive.box<DownloadEpisodeItem>(
//       '${Constant.audioEpisodeDownloadBox}_${Constant.userID}');
//   dowonloadSeasonBox = Hive.box<AudioBookBox>(
//       '${Constant.hiveAudioBookDetailsDownloadBox}_${Constant.userID}');

//   if (!dowonloadBox.isOpen) {
//     return;
//   }

//   DateTime now = DateTime.now();
//   String timeStamp = now.millisecondsSinceEpoch.abs().toString();

//   /* Prepare Target Video File START ************* */
//   File? mTargetFile;
//   String? localPath;
//   try {
//     localPath = await Utils.prepareShowSaveDir(
//       (sectionDetails?.title ?? "").replaceAll(RegExp('\\W+'), ''),
//     );
//     printLog("localPath ====> $localPath");
//     String? mFileName;

//     // mFileName = '_Ep${(epiPos + 1)}_${episodeDetails?.id}${(Constant.userID)}';

//     mFileName =
//         (('_Ep${(epiPos + 1)}_${episodeDetails?.id}${(Constant.userID)}'));
//     printLog("mFileName ======> $mFileName");

//    mTargetFile = File(path.join(localPath, '$mFileName.mp3'));
//   } catch (e) {
//     printLog("saveShowStorage Exception ===> $e");
//   }
//   printLog("mTargetFile ====> ${mTargetFile?.absolute.path ?? ""}");
//   /* *************** Prepare Target Video File END */

//   /* Prepare Target Image Files START ************* */
//   File? mShowPortImageFile,
//       mShowLandImageFile,
//       mEpiPortImageFile,
//       mEpiLandImageFile;
//   String? mShowPortImgFileName = 'port_$timeStamp';
//   String? mShowLandImgFileName = 'land_$timeStamp';
//   String? mEpiPortImgFileName = 'port_epi_$timeStamp';
//   String? mEpiLandImgFileName = 'land_epi_$timeStamp';
//   if (localPath != null) {
//     try {
//       mShowPortImageFile =
//           File(path.join(localPath, '$mShowPortImgFileName.png'));
//       mShowLandImageFile =
//           File(path.join(localPath, '$mShowLandImgFileName.png'));
//       mEpiPortImageFile =
//           File(path.join(localPath, '$mEpiPortImgFileName.png'));
//       mEpiLandImageFile =
//           File(path.join(localPath, '$mEpiLandImgFileName.png'));
//     } catch (e) {
//       printLog("saveShowStorage Exception ===> $e");
//     }
//   } else {
//     return;
//   }
//   printLog("mPortImageFileName ========> $mShowPortImgFileName");
//   printLog(
//       "mTargetPortImageFile ======> ${mShowPortImageFile?.absolute.path ?? ""}");
//   printLog("mLandImageFileName ========> $mShowLandImgFileName");
//   printLog(
//       "mTargetLandImageFile ======> ${mShowLandImageFile?.absolute.path ?? ""}");
//   printLog("mEpiPortImgFileName =====> $mEpiPortImgFileName");
//   printLog(
//       "mEpiPortImageFile =======> ${mEpiPortImageFile?.absolute.path ?? ""}");
//   printLog("mEpiLandImgFileName =====> $mEpiLandImgFileName");
//   printLog(
//       "mEpiLandImageFile =======> ${mEpiLandImageFile?.absolute.path ?? ""}");
//   /* *************** Prepare Target Image Files END */

//   try {
//     Utils.showToast("Download started");

//     /* Save Video/Show */
//     List<AudioBookBox> myDownloadList = [];
//     AudioBookBox downloadedItem = AudioBookBox(
//       id: sectionDetails?.id,
//       securityKey: "",
//       title: sectionDetails?.title,
//       description: sectionDetails?.description,
//       savedDir: localPath,
//       contentType: sectionDetails?.contentType,
//       savedFile: "",
//       isBuy: sectionDetails?.isBuy,
//       isDownload: 1,
//       portraitImg: mShowPortImageFile?.path,
//       landscapeImg: mShowLandImageFile?.path,
//     );
//     /* Check in Download Box */
//     myDownloadList = dowonloadSeasonBox.values.where((myDowonloadItem) {
//       return (myDowonloadItem.id == sectionDetails?.id);
//     }).toList();

//     if (myDownloadList.isEmpty) {
//       /* Potrait Image Download */
//       dio.download(sectionDetails?.portraitImg ?? "",
//           path.join(localPath, '$mShowPortImgFileName.png'),
//           onReceiveProgress: (received, total) {});

//       /* Landscape Image Download */
//       dio.download(sectionDetails?.landscapeImg ?? "",
//           path.join(localPath, '$mShowLandImgFileName.png'),
//           onReceiveProgress: (received, total) {});
//     }

//     /* Potrait Episode Image Download */
//     dio.download(epiDetails?.image ?? "",
//         path.join(localPath, '$mEpiPortImgFileName.png'),
//         onReceiveProgress: (received, total) {});

//     /* Landscape Episode Image Download */
//     dio.download(epiDetails?.image ?? "",
//         path.join(localPath, '$mEpiLandImgFileName.png'),
//         onReceiveProgress: (received, total) {});

//     /* Video Download */
//     await dio.download(epiDetails?.audio ?? "", mTargetFile?.path,
//         onReceiveProgress: (received, total) async {
//       if (total != -1) {
//         await downloadProvider.setDownloadProgress(
//             (received / total * 100).round(), epiDetails?.id ?? 0);
//       }
//     });

//     /* Encrypt Episode File START ************** */
//     String generateKey = Utils.convertToHex(
//         Utils.generateRandomKey(32).padRight(16, '0').substring(0, 16));
//     String generateIVKey = Utils.convertToHex(
//         Utils.generateRandomKey(16).padRight(16, '0').substring(0, 16));
//     printLog("generateKey =======> $generateKey");
//     printLog("generateIVKey =====> $generateIVKey");

//     dynamic encryptedFile = await Utils.encryptUsingFFMPEG([
//       mTargetFile,
//       generateKey,
//       generateIVKey,
//     ]);
//     printLog("encryptedFile =======> $encryptedFile");
//     /* ***************** Encrypt Episode File END */

//     /* Check In Downloaded Items START **************** */

//     List<DownloadEpisodeItem> mySavedEpiList = [];

//     /* Save Episode */
//     DownloadEpisodeItem episodeItem = DownloadEpisodeItem(
//         id: epiDetails?.id,
//         securityKey: generateKey,
//         contentId: epiDetails?.contentId,
//         image: mEpiLandImageFile?.path,
//         // portraitImg: mEpiPortImageFile?.path,
//         // landscapeImg: mEpiLandImageFile?.path,
//         description: epiDetails?.description,
//         status: epiDetails?.status,
//         contentType: sectionDetails?.contentType,
//         audio: epiDetails?.audio,
//         artistId: epiDetails?.artistId,
//         categoryId: epiDetails?.categoryId,
//         languageId: epiDetails?.languageId,
//         title: epiDetails?.name,
//         name: epiDetails?.name,
//         savedDir: localPath,
//         savedFile: mTargetFile?.path ?? "",
//         audioType: epiDetails?.audioType,
//         isBookCoin: epiDetails?.isBookCoin,
//         isBookPaid: epiDetails?.isBookPaid,
//         totalBookPlayed: epiDetails?.totalBookPlayed,
//         isAudioPaid: epiDetails?.isAudioPaid,
//         isAudioCoin: epiDetails?.isAudioCoin,
//         isBuy: epiDetails?.isBuy,
//         isDownload: 1,
//         videoDuration: epiDetails?.videoDuration,
//         stopTime: epiDetails?.stopTime ?? 0,
//         bookId: sectionDetails?.id);

//     /* Check in Episode Box */
//     mySavedEpiList = dowonloadBox.values.where((myEpiItem) {
//       return (myEpiItem.id == sectionDetails?.id &&
//           myEpiItem.id == episodeDetails?.id);
//     }).toList();
//     printLog("myDownloadList =======> ${myDownloadList.length}");
//     printLog("mySavedEpiList =======> ${mySavedEpiList.length}");
//     /* ****************** Check In Downloaded Items END */

//     /* Insert in Hive */
//     if (mySavedEpiList.isEmpty) {
//       dowonloadBox.add(episodeItem);
//     }

//     if (myDownloadList.isEmpty) {
//       dowonloadSeasonBox.add(downloadedItem);
//     }

//     await await downloadProvider.setDownloadProgress(-1, 0);
//     await downloadProvider.setCurrentDownload(null);
//     await downloadProvider.setLoading(false);
//     Utils.showToast("Download completed");
//   } catch (e) {
//     if (!context.mounted) return;
//     Utils.showToast("Download failed");
//   }
// }

Future<void> prepareAudioDownload(
  BuildContext context, {
  required audiobookdetails.Result? contentDetails, // Audiobook details
  required int? episodePos, // Episode position
  required audiobookepisode.Result? episodeDetails, // Episode details
}) async {
  audiobookdetails.Result? sectionDetails = contentDetails;
  int epiPos = episodePos ?? 0;
  audiobookepisode.Result? epiDetails = episodeDetails;

  final downloadProvider =
      Provider.of<DownLoadProvider>(context, listen: false);
  await downloadProvider
      .setCurrentDownload(epiDetails?.id ?? 0); // Set current download

  Dio dio = Dio();

  /* Hive */
  Box<DownloadEpisodeItem> downloadEpisodeBox;
  Box<AudioBookBox> downloadAudioBox;

  downloadEpisodeBox = Hive.box<DownloadEpisodeItem>(
      '${Constant.audioEpisodeDownloadBox}_${Constant.userID}');
  downloadAudioBox = Hive.box<AudioBookBox>(
      '${Constant.hiveAudioBookDetailsDownloadBox}_${Constant.userID}');

  if (!downloadEpisodeBox.isOpen || !downloadAudioBox.isOpen) {
    return;
  }

  DateTime now = DateTime.now();
  String timeStamp = now.millisecondsSinceEpoch.abs().toString();

  /* Prepare Target File path for the Audio and Images */
  File? mTargetFile;
  String? localPath;
  try {
    localPath = await Utils.prepareShowSaveDir(
      (sectionDetails?.title ?? "").replaceAll(RegExp('\\W+'), ''),
    );
    String mFileName =
        '_Ep${(epiPos + 1)}_${episodeDetails?.id}${(Constant.userID)}';
    mTargetFile = File(path.join(localPath, '$mFileName.mp3'));
  } catch (e) {
    printLog("saveShowStorage Exception ===> $e");
  }

  if (mTargetFile == null || localPath == null) return;

  /* Prepare Image File Paths */
  String mShowPortImgFileName = 'port_$timeStamp';
  String mShowLandImgFileName = 'land_$timeStamp';
  String mEpiPortImgFileName = 'port_epi_$timeStamp';
  String mEpiLandImgFileName = 'land_epi_$timeStamp';

  File mShowPortImageFile =
      File(path.join(localPath, '$mShowPortImgFileName.png'));
  File mShowLandImageFile =
      File(path.join(localPath, '$mShowLandImgFileName.png'));
  File mEpiPortImageFile =
      File(path.join(localPath, '$mEpiPortImgFileName.png'));
  File mEpiLandImageFile =
      File(path.join(localPath, '$mEpiLandImgFileName.png'));

  /* Step 1: Add Audio (Main Audiobook) Details if Not Already Added */
  List<AudioBookBox> existingAudioList =
      downloadAudioBox.values.where((audioItem) {
    return audioItem.id == sectionDetails?.id;
  }).toList();

  if (existingAudioList.isEmpty) {
    AudioBookBox audioBookItem = AudioBookBox(
      id: sectionDetails?.id,
      securityKey: "",
      title: sectionDetails?.title,
      description: sectionDetails?.description,
      savedDir: localPath,
      contentType: sectionDetails?.contentType,
      savedFile: "",
      isBuy: sectionDetails?.isBuy,
      isDownload: 1,
      portraitImg: mShowPortImageFile.path,
      landscapeImg: mShowLandImageFile.path,
    );

    /* Add Audiobook details to Hive */
    downloadAudioBox.add(audioBookItem);

    /* Download Images for Audiobook */
    await dio.download(
        sectionDetails?.portraitImg ?? "", mShowPortImageFile.path);
    await dio.download(
        sectionDetails?.landscapeImg ?? "", mShowLandImageFile.path);
  }

  /* Step 2: Add Episode Details if Not Already Added */
  List<DownloadEpisodeItem> existingEpisodeList =
      downloadEpisodeBox.values.where((episodeItem) {
    return episodeItem.id == epiDetails?.id;
  }).toList();

  if (existingEpisodeList.isEmpty) {
    DownloadEpisodeItem episodeItem = DownloadEpisodeItem(
      id: epiDetails?.id,
      securityKey: "",
      contentId: epiDetails?.contentId,
      image: mEpiLandImageFile.path,
      description: epiDetails?.description,
      status: epiDetails?.status,
      contentType: sectionDetails?.contentType,
      audio: epiDetails?.audio,
      artistId: epiDetails?.artistId,
      categoryId: epiDetails?.categoryId,
      languageId: epiDetails?.languageId,
      title: epiDetails?.name,
      name: epiDetails?.name,
      savedDir: localPath,
      savedFile: mTargetFile.path,
      audioType: epiDetails?.audioType,
      isAudioPaid: epiDetails?.isAudioPaid,
      isAudioCoin: epiDetails?.isAudioCoin,
      isBuy: epiDetails?.isBuy,
      isDownload: 1,
      videoDuration: epiDetails?.videoDuration,
      stopTime: epiDetails?.stopTime ?? 0,
      bookId: sectionDetails?.id,
    );

    /* Add Episode details to Hive */
    downloadEpisodeBox.add(episodeItem);

    /* Download Images for Episode */
    await dio.download(epiDetails?.image ?? "", mEpiPortImageFile.path);
    await dio.download(epiDetails?.image ?? "", mEpiLandImageFile.path);
  }

  /* Step 3: Start Download of Episode Audio */
  try {
    Utils.showToast("Download started");

    await dio.download(epiDetails?.audio ?? "", mTargetFile.path,
        onReceiveProgress: (received, total) async {
     
      if (total != -1) {
        // Update progress using the provider
        await downloadProvider.setDownloadProgress(
            (received / total * 100).round(), epiDetails?.id ?? 0);
      }
    });

    /* Encrypt the Audio File */
    String encryptionKey = Utils.generateRandomKey(32).substring(0, 16);
    String encryptionIV = Utils.generateRandomKey(16).substring(0, 16);
    await Utils.encryptUsingFFMPEG([mTargetFile, encryptionKey, encryptionIV]);

    Utils.showToast("Download completed");
    await downloadProvider.setDownloadProgress(
        -1, 0); // Reset progress on completion
    await downloadProvider.setCurrentDownload(null); // Clear current download
    await downloadProvider.setLoading(false); // Hide loading state
  } catch (e) {
    Utils.showToast("Download failed");
    await downloadProvider.setDownloadProgress(
        -1, 0); // Reset progress on failure
    await downloadProvider.setCurrentDownload(null); // Clear current download
    await downloadProvider.setLoading(false); // Hide loading state
  }
}

/* ========================== Download AudioBooks ========================== */

/* ========================== Download Novels ========================== */

Future<void> prepareNovelDownload(
  BuildContext context, {
  required noveldetails.Result? contentDetails,
  required int? episodePos,
  required novelchapters.Result? episodeDetails,
}) async {
  noveldetails.Result? sectionDetails = contentDetails;

  int epiPos = episodePos ?? 0;
  novelchapters.Result? epiDetails = episodeDetails;

  final downloadProvider =
      Provider.of<DownLoadProvider>(context, listen: false);
  await downloadProvider.setCurrentDownload(epiDetails?.id ?? 0);

  Dio dio = Dio();
  final receivePort = ReceivePort();

  /* Hive */
  Box<DownloadEpisodeItem> dowonloadBox;
  Box<AudioBookBox> dowonloadChapterBox;

  dowonloadBox = Hive.box<DownloadEpisodeItem>(
      '${Constant.novelChapterDownloadBox}_${Constant.userID}');
  dowonloadChapterBox = Hive.box<AudioBookBox>(
      '${Constant.hiveNovelDownloadBox}_${Constant.userID}');

  if (!dowonloadBox.isOpen) {
    return;
  }

  DateTime now = DateTime.now();
  String timeStamp = now.millisecondsSinceEpoch.abs().toString();

  /* Prepare Target Video File START ************* */
  File? mTargetFile;
  String? localPath;
  try {
    localPath = await Utils.prepareShowSaveDir(
      (sectionDetails?.title ?? "").replaceAll(RegExp('\\W+'), ''),
    );
    printLog("localPath ====> $localPath");
    String? mFileName;

    // mFileName = '_Ep${(epiPos + 1)}_${episodeDetails?.id}${(Constant.userID)}';

    mFileName =
        (('_chapter${(epiPos + 1)}_${episodeDetails?.id}${(Constant.userID)}'));
    printLog("mFileName ======> $mFileName");

    mTargetFile = File(path.join(localPath, '$mFileName.pdf'));
  } catch (e) {
    printLog("saveShowStorage Exception ===> $e");
  }
  printLog("mTargetFile ====> ${mTargetFile?.absolute.path ?? ""}");
  /* *************** Prepare Target Video File END */

  /* Prepare Target Image Files START ************* */
  File? mShowPortImageFile,
      mShowLandImageFile,
      mEpiPortImageFile,
      mEpiLandImageFile;
  String? mShowPortImgFileName = 'port_$timeStamp';
  String? mShowLandImgFileName = 'land_$timeStamp';
  String? mEpiPortImgFileName = 'port_ch_$timeStamp';
  String? mEpiLandImgFileName = 'land_ch_$timeStamp';
  if (localPath != null) {
    try {
      mShowPortImageFile =
          File(path.join(localPath, '$mShowPortImgFileName.png'));
      mShowLandImageFile =
          File(path.join(localPath, '$mShowLandImgFileName.png'));
      mEpiPortImageFile =
          File(path.join(localPath, '$mEpiPortImgFileName.png'));
      mEpiLandImageFile =
          File(path.join(localPath, '$mEpiLandImgFileName.png'));
    } catch (e) {
      printLog("saveShowStorage Exception ===> $e");
    }
  } else {
    return;
  }
  printLog("mPortImageFileName ========> $mShowPortImgFileName");
  printLog(
      "mTargetPortImageFile ======> ${mShowPortImageFile?.absolute.path ?? ""}");
  printLog("mLandImageFileName ========> $mShowLandImgFileName");
  printLog(
      "mTargetLandImageFile ======> ${mShowLandImageFile?.absolute.path ?? ""}");
  printLog("mEpiPortImgFileName =====> $mEpiPortImgFileName");
  printLog(
      "mEpiPortImageFile =======> ${mEpiPortImageFile?.absolute.path ?? ""}");
  printLog("mEpiLandImgFileName =====> $mEpiLandImgFileName");
  printLog(
      "mEpiLandImageFile =======> ${mEpiLandImageFile?.absolute.path ?? ""}");
  /* *************** Prepare Target Image Files END */

  try {
    if (!context.mounted) return;
    Utils.showToast("Download started");

    /* Save Video/Show */
    List<AudioBookBox> myDownloadList = [];
    AudioBookBox downloadedItem = AudioBookBox(
      id: sectionDetails?.id,
      securityKey: "",
      contentType: sectionDetails?.contentType,
      title: sectionDetails?.title,
      description: sectionDetails?.description,
      savedDir: localPath,
      savedFile: "",
      isBuy: sectionDetails?.isBuy,
      isDownload: 1,
      portraitImg: mShowPortImageFile?.path,
      landscapeImg: mShowLandImageFile?.path,
    );
    /* Check in Download Box */
    myDownloadList = dowonloadChapterBox.values.where((myDowonloadItem) {
      return (myDowonloadItem.id == sectionDetails?.id);
    }).toList();

    if (myDownloadList.isEmpty) {
      /* Potrait Image Download */
      dio.download(sectionDetails?.portraitImg ?? "",
          path.join(localPath, '$mShowPortImgFileName.png'),
          onReceiveProgress: (received, total) {});

      /* Landscape Image Download */
      dio.download(sectionDetails?.landscapeImg ?? "",
          path.join(localPath, '$mShowLandImgFileName.png'),
          onReceiveProgress: (received, total) {});
    }

    /* Potrait Episode Image Download */
    dio.download(epiDetails?.image ?? "",
        path.join(localPath, '$mEpiPortImgFileName.png'),
        onReceiveProgress: (received, total) {});

    /* Landscape Episode Image Download */
    dio.download(epiDetails?.image ?? "",
        path.join(localPath, '$mEpiLandImgFileName.png'),
        onReceiveProgress: (received, total) {});

    /* Video Download */
    await dio.download(epiDetails?.book ?? "", mTargetFile?.path,
        onReceiveProgress: (received, total) async {
      if (total != -1) {
        await downloadProvider.setDownloadProgress(
            (received / total * 100).round(), epiDetails?.id ?? 0);
      }
    });

    // /* Encrypt Episode File START ************** */
    // String generateKey = Utils.convertToHex(
    //     Utils.generateRandomKey(32).padRight(16, '0').substring(0, 16));
    // String generateIVKey = Utils.convertToHex(
    //     Utils.generateRandomKey(16).padRight(16, '0').substring(0, 16));
    // printLog("generateKey =======> $generateKey");
    // printLog("generateIVKey =====> $generateIVKey");

    // dynamic encryptedFile = await Utils.encryptUsingFFMPEG([
    //   mTargetFile,
    //   generateKey,
    //   generateIVKey,
    // ]);
    // printLog("encryptedFile =======> $encryptedFile");
    // /* ***************** Encrypt Episode File END */

    /* Encrypt Video File START ************** */
    String generateKey = Utils.generateRandomKey(32);
    printLog("generateKey =======> $generateKey");
    var rootToken = RootIsolateToken.instance!;
    final isolate = await Isolate.spawn(Utils.encryptFile,
        [mTargetFile, generateKey, receivePort.sendPort, rootToken]);
    receivePort.listen((message) {
      printLog("message =======> $message");
      if (message != null) {
        receivePort.close();
        isolate.kill(priority: Isolate.immediate);
      }
    });
    /* ***************** Encrypt Video File END */

    /* Check In Downloaded Items START **************** */

    List<DownloadEpisodeItem> mySavedEpiList = [];

    /* Save Episode */
    DownloadEpisodeItem episodeItem = DownloadEpisodeItem(
        id: epiDetails?.id,
        securityKey: generateKey,
        image: mEpiLandImageFile?.path,
        // portraitImg: mEpiPortImageFile?.path,
        // landscapeImg: mEpiLandImageFile?.path,
        description: epiDetails?.description,
        status: epiDetails?.status,
        audio: epiDetails?.audio,
        contentType: sectionDetails?.contentType,
        contentId: epiDetails?.contentId,
        artistId: epiDetails?.artistId,
        categoryId: epiDetails?.categoryId,
        languageId: epiDetails?.languageId,
        title: epiDetails?.name,
        name: epiDetails?.name,
        savedDir: localPath,
        savedFile: mTargetFile?.path ?? "",
        audioType: epiDetails?.audioType,
        book: epiDetails?.book,
        isBookCoin: epiDetails?.isBookCoin,
        isBookPaid: epiDetails?.isBookPaid,
        totalBookPlayed: epiDetails?.totalBookPlayed,
        isAudioPaid: epiDetails?.isAudioPaid,
        isAudioCoin: epiDetails?.isAudioCoin,
        isBuy: epiDetails?.isBuy,
        isDownload: 1,
        videoDuration: epiDetails?.videoDuration,
        stopTime: epiDetails?.stopTime ?? 0,
        bookId: sectionDetails?.id);

    /* Check in Episode Box */
    mySavedEpiList = dowonloadBox.values.where((myEpiItem) {
      return (myEpiItem.id == sectionDetails?.id &&
          myEpiItem.id == episodeDetails?.id);
    }).toList();
    printLog("myDownloadList =======> ${myDownloadList.length}");
    printLog("mySavedEpiList =======> ${mySavedEpiList.length}");
    /* ****************** Check In Downloaded Items END */

    /* Insert in Hive */
    if (mySavedEpiList.isEmpty) {
      dowonloadBox.add(episodeItem);
    }

    if (myDownloadList.isEmpty) {
      dowonloadChapterBox.add(downloadedItem);
    }

    await downloadProvider.setDownloadProgress(-1, 0);
    await downloadProvider.setCurrentDownload(null);
    await downloadProvider.setLoading(false);
    Utils.showToast("Download completed");
  } catch (e) {
    printLog("Download eroor $e");
    if (!context.mounted) return;
    Utils.showToast("Download failed");
  }
}
/* ========================== Download Novels ========================== */
