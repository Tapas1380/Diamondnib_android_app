import 'package:hive/hive.dart';

part 'download_item.g.dart';

@HiveType(typeId: 0)
class DownloadEpisodeItem extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int? contentId;

  @HiveField(2)
  int? contentType;

  @HiveField(3)
  int? categoryId;

  @HiveField(4)
  int? languageId;

  @HiveField(5)
  int? artistId;

  @HiveField(6)
  String? name;

  @HiveField(7)
  String? title;

  @HiveField(8)
  String? image;

  @HiveField(9)
  String? portraitImg;

  @HiveField(10)
  String? landscapeImg;

  @HiveField(11)
  String? description;

  @HiveField(12)
  int? audioType;

  @HiveField(13)
  String? audio;

  @HiveField(14)
  String? musicUploadType;

  @HiveField(15)
  String? music;

  @HiveField(16)
  int? musicDuration;

  @HiveField(17)
  int? audioDuration;

  @HiveField(18)
  int? isAudioPaid;

  @HiveField(19)
  int? isAudioCoin;

  @HiveField(20)
  int? totalAudioPlayed;

  @HiveField(21)
  int? videoType;

  @HiveField(22)
  String? video;

  @HiveField(23)
  int? videoDuration;

  @HiveField(24)
  int? totalEpisode;

  @HiveField(25)
  int? totalReviews;

  @HiveField(26)
  int? isVideoPaid;

  @HiveField(27)
  int? isVideoCoin;

  @HiveField(28)
  int? totalVideoPlayed;

  @HiveField(29)
  String? book;

  @HiveField(30)
  int? totalPlayed;

  @HiveField(31)
  int? isBookPaid;

  @HiveField(32)
  int? isBookCoin;

  @HiveField(33)
  int? totalBookPlayed;

  @HiveField(34)
  String? fullNovel;

  @HiveField(35)
  int? isPaidNovel;

  @HiveField(36)
  int? novelCoin;

  @HiveField(37)
  int? sortable;

  @HiveField(38)
  int? status;

  @HiveField(39)
  String? createdAt;

  @HiveField(40)
  String? updatedAt;

  @HiveField(41)
  int? stopTime;

  @HiveField(42)
  int? isBuy;

  @HiveField(43)
  String? avgRating;

  @HiveField(44)
  String? securityKey;

  @HiveField(45)
  String? savedDir;
  @HiveField(46)
  String? savedFile;
  @HiveField(47)
  int? isDownload;
  @HiveField(48)
  int? bookId;

  @HiveField(49)
  int downloadProgress = 0; // New field for download progress

  @HiveField(50)
  bool isDownloading = false; // New field to check if the item is downloading

  DownloadEpisodeItem(
      {this.id,
      this.securityKey,
      this.contentId,
      this.contentType,
      this.artistId,
      this.categoryId,
      this.novelCoin,
      this.savedDir,
      this.savedFile,
      this.isDownload,
      this.totalPlayed,
      this.totalReviews,
      this.languageId,
      this.fullNovel,
      this.isPaidNovel,
      this.name,
      this.title,
      this.musicUploadType,
      this.music,
      this.musicDuration,
      this.portraitImg,
      this.image,
      this.description,
      this.audioType,
      this.avgRating,
      this.audio,
      this.audioDuration,
      this.isAudioPaid,
      this.isAudioCoin,
      this.totalAudioPlayed,
      this.videoType,
      this.video,
      this.videoDuration,
      this.landscapeImg,
      this.isVideoPaid,
      this.isVideoCoin,
      this.totalVideoPlayed,
      this.book,
      this.isBookPaid,
      this.totalEpisode,
      this.isBookCoin,
      this.totalBookPlayed,
      this.sortable,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.stopTime,
      this.isBuy,
      this.bookId});

  factory DownloadEpisodeItem.fromJson(Map<String, dynamic> json) =>
      DownloadEpisodeItem(
        id: json["id"],
        securityKey: json["securityKey"],
        contentId: json["content_id"],
        contentType: json["content_type"],
        name: json["name"],
        artistId: json["artist_id"],
        title: json["title"],
        categoryId: json["category_id"],
        languageId: json["language_id"],
        totalPlayed: json["total_played"],
        fullNovel: json["full_novel"],
        isPaidNovel: json["is_paid_novel"],
        savedDir: json["savedDir"],
        savedFile: json["savedFile"],
        isDownload: json["isDownload"],
        landscapeImg: json["landscape_img"],
        novelCoin: json["novel_coin"],
        musicUploadType: json["music_upload_type"],
        music: json["music"],
        musicDuration: json["music_duration"],
        portraitImg: json["portrait_img"],
        image: json["image"],
        description: json["description"],
        totalEpisode: json["total_episode"],
        audioType: json["audio_type"],
        audio: json["audio"],
        totalReviews: json["total_reviews"],
        audioDuration: json["audio_duration"],
        isAudioPaid: json["is_audio_paid"],
        isAudioCoin: json["is_audio_coin"],
        totalAudioPlayed: json["total_audio_played"],
        videoType: json["video_type"],
        video: json["video"],
        videoDuration: json["video_duration"],
        isVideoPaid: json["is_video_paid"],
        isVideoCoin: json["is_video_coin"],
        totalVideoPlayed: json["total_video_played"],
        book: json["book"],
        isBookPaid: json["is_book_paid"],
        isBookCoin: json["is_book_coin"],
        totalBookPlayed: json["total_book_played"],
        sortable: json["sortable"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        stopTime: json["stop_time"],
        isBuy: json["is_buy"],
        avgRating: json["avg_rating"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "securityKey": securityKey,
        "content_id": contentId,
        "content_type": contentType,
        "artist_id": artistId,
        "isDownload": isDownload,
        "landscape_img": landscapeImg,
        "savedDir": savedDir,
        "savedFile": savedFile,
        "name": name,
        "image": image,
        "category_id": categoryId,
        "language_id": languageId,
        "title": title,
        "music_upload_type": musicUploadType,
        "music": music,
        "music_duration": musicDuration,
        'total_reviews': totalReviews,
        "portrait_img": portraitImg,
        "total_played": totalPlayed,
        "description": description,
        "audio_type": audioType,
        "audio": audio,
        "full_novel": fullNovel,
        "is_paid_novel": isPaidNovel,
        "avg_rating": avgRating,
        "novel_coin": novelCoin,
        "audio_duration": audioDuration,
        "is_audio_paid": isAudioPaid,
        "is_audio_coin": isAudioCoin,
        "total_audio_played": totalAudioPlayed,
        "total_episode": totalEpisode,
        "video_type": videoType,
        "video": video,
        "video_duration": videoDuration,
        "is_video_paid": isVideoPaid,
        "is_video_coin": isVideoCoin,
        "total_video_played": totalVideoPlayed,
        "book": book,
        "is_book_paid": isBookPaid,
        "is_book_coin": isBookCoin,
        "total_book_played": totalBookPlayed,
        "sortable": sortable,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "stop_time": stopTime,
        "is_buy": isBuy,
      };
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "securityKey": securityKey,
      "content_id": contentId,
      "content_type": contentType,
      "artist_id": artistId,
      "isDownload": isDownload,
      "landscape_img": landscapeImg,
      "savedDir": savedDir,
      "savedFile": savedFile,
      "name": name,
      "image": image,
      "category_id": categoryId,
      "language_id": languageId,
      "title": title,
      "music_upload_type": musicUploadType,
      "music": music,
      "music_duration": musicDuration,
      'total_reviews': totalReviews,
      "portrait_img": portraitImg,
      "total_played": totalPlayed,
      "description": description,
      "audio_type": audioType,
      "audio": audio,
      "full_novel": fullNovel,
      "is_paid_novel": isPaidNovel,
      "avg_rating": avgRating,
      "novel_coin": novelCoin,
      "audio_duration": audioDuration,
      "is_audio_paid": isAudioPaid,
      "is_audio_coin": isAudioCoin,
      "total_audio_played": totalAudioPlayed,
      "total_episode": totalEpisode,
      "video_type": videoType,
      "video": video,
      "video_duration": videoDuration,
      "is_video_paid": isVideoPaid,
      "is_video_coin": isVideoCoin,
      "total_video_played": totalVideoPlayed,
      "book": book,
      "is_book_paid": isBookPaid,
      "is_book_coin": isBookCoin,
      "total_book_played": totalBookPlayed,
      "sortable": sortable,
      "status": status,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "stop_time": stopTime,
      "is_buy": isBuy,
    };
  }
}
