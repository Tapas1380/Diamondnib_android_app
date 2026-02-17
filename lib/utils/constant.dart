import 'package:diamondnib/model/qualitymodel.dart';
import 'package:diamondnib/model/subtitlemodel.dart';

class Constant {
  static const String baseurl = 'https://app.diamondnib.com/public/api/';

  static String appName = "Diamondnib";
  static String appPackageName = "com.diamondnib.app";
  static String? appleAppId = "6751876844";
  static String dynamicLinkPrefix = "https://diamondnibapp.page.link";

  /* Constant for TV check */
  static bool isTV = false;

  /* Download config */
  static String bgEncryptDecryptTask = 'encrypt_decrypt_task';
  static String audioEpisodeDownloadBox = 'DOWNLOADS';
  static String hiveAudioBookDetailsDownloadBox = 'AUDIOBOOKDOWNLOADS';

  static String novelChapterDownloadBox = 'CHAPTERDOWNLOADS';
  static String hiveNovelDownloadBox = 'NOVELDOWNLOADS';

  static String? userID;
  static String? musicsectionId;
  static String currencySymbol = "";
  static String currency = "";

  static String androidAppShareUrlDesc =
      "Let me recommend you this application\n\n$androidAppUrl";
  static String iosAppShareUrlDesc =
      "Let me recommend you this application\n\n$iosAppUrl";

  static String androidAppUrl =
      "https://play.google.com/store/apps/details?id=${Constant.appPackageName}";
  static String iosAppUrl =
      "https://apps.apple.com/in/app/${Constant.appName.toLowerCase()}/id6751876844";

  static List<QualityModel> resolutionsUrls = [];
  static List<SubTitleModel> subtitleUrls = [];

  /* Download config */
  static String videoDownloadPort = 'video_downloader_send_port';
  static String showDownloadPort = 'show_downloader_send_port';
  static String hawkVIDEOList = "myVideoList_";
  static String hawkKIDSVIDEOList = "myKidsVideoList_";
  static String hawkSHOWList = "myShowList_";
  static String hawkSEASONList = "mySeasonList_";
  static String hawkEPISODEList = "myEpisodeList_";
  /* Download config */

  static int fixFourDigit = 1317;
  static int fixSixDigit = 161613;

  static int bannerDuration = 10000; // in milliseconds
  static int animationDuration = 800; // in milliseconds

  /* Show Ad By Type */
  static String rewardAdType = "rewardAd";
  static String interstialAdType = "interstialAd";

  static String musicType = "1";
  static String podcastType = "2";
  static String radioType = "3";
  static String? searchtext;

  // ===== Deep Link Configuration =====
  /// Deep link content ID from shared link
  static int? deepLinkContentId;

  /// Deep link content type from shared link
  static int? deepLinkContentType;

  /// Flag to navigate to audio details on app launch
  static bool shouldOpenAudioDetails = false;

  /// Initial deep link from platform
  static String? initialLink;
}
