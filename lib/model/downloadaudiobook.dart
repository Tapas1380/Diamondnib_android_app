import 'package:hive/hive.dart';

part 'downloadaudiobook.g.dart'; // Required for generating the adapter

@HiveType(typeId: 1) // Specify a unique typeId for the class
class AudioBookBox extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  int? contentType;

  @HiveField(2)
  int? artistId;

  @HiveField(3)
  int? categoryId;

  @HiveField(4)
  int? languageId;

  @HiveField(5)
  String? title;

  @HiveField(6)
  String? portraitImg;

  @HiveField(7)
  String? landscapeImg;

  @HiveField(8)
  String? description;

  @HiveField(9)
  String? fullNovel;

  @HiveField(10)
  int? isPaidNovel;

  @HiveField(11)
  int? novelCoin;

  @HiveField(12)
  int? totalPlayed;

  @HiveField(13)
  int? status;

  @HiveField(14)
  String? createdAt;

  @HiveField(15)
  String? updatedAt;

  @HiveField(16)
  String? categoryName;

  @HiveField(17)
  String? languageName;

  @HiveField(18)
  String? artistName;

  @HiveField(19)
  String? artistImage;

  @HiveField(20)
  int? isFollow;

  @HiveField(21)
  int? artistFollowers;

  @HiveField(22)
  String? avgRating;

  @HiveField(23)
  int? totalEpisode;

  @HiveField(24)
  int? totalReviews;

  @HiveField(25)
  String? book;

  @HiveField(26)
  int? isBookPaid;

  @HiveField(27)
  int? isBookCoin;

  @HiveField(28)
  int? totalBookPlayed;

  @HiveField(29)
  int? isBuy;

  @HiveField(30)
  int? totalUserPlay;

  @HiveField(31)
  int? isBookMark;

  @HiveField(32)
  final int? isDownload;

  @HiveField(33)
  final String? securityKey;

  @HiveField(34)
  final String? savedDir;
  @HiveField(35)
  final String? savedFile;

  AudioBookBox({
    this.id,
    this.contentType,
    this.artistId,
    this.categoryId,
    this.languageId,
    this.title,
    this.portraitImg,
    this.landscapeImg,
    this.description,
    this.fullNovel,
    this.isPaidNovel,
    this.novelCoin,
    this.totalPlayed,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.languageName,
    this.artistName,
    this.artistImage,
    this.isFollow,
    this.book,
    this.isBookPaid,
    this.isBookCoin,
    this.totalBookPlayed,
    this.artistFollowers,
    this.avgRating,
    this.totalEpisode,
    this.totalReviews,
    this.isBuy,
    this.totalUserPlay,
    this.isBookMark,
    this.isDownload,
    this.savedDir,
    this.savedFile,
    this.securityKey,
  });
}
