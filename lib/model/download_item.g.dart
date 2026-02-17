// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadEpisodeItemAdapter extends TypeAdapter<DownloadEpisodeItem> {
  @override
  final int typeId = 0;

  @override
  DownloadEpisodeItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadEpisodeItem(
      id: fields[0] as int?,
      securityKey: fields[44] as String?,
      contentId: fields[1] as int?,
      contentType: fields[2] as int?,
      artistId: fields[5] as int?,
      categoryId: fields[3] as int?,
      novelCoin: fields[36] as int?,
      savedDir: fields[45] as String?,
      savedFile: fields[46] as String?,
      isDownload: fields[47] as int?,
      totalPlayed: fields[30] as int?,
      totalReviews: fields[25] as int?,
      languageId: fields[4] as int?,
      fullNovel: fields[34] as String?,
      isPaidNovel: fields[35] as int?,
      name: fields[6] as String?,
      title: fields[7] as String?,
      musicUploadType: fields[14] as String?,
      music: fields[15] as String?,
      musicDuration: fields[16] as int?,
      portraitImg: fields[9] as String?,
      image: fields[8] as String?,
      description: fields[11] as String?,
      audioType: fields[12] as int?,
      avgRating: fields[43] as String?,
      audio: fields[13] as String?,
      audioDuration: fields[17] as int?,
      isAudioPaid: fields[18] as int?,
      isAudioCoin: fields[19] as int?,
      totalAudioPlayed: fields[20] as int?,
      videoType: fields[21] as int?,
      video: fields[22] as String?,
      videoDuration: fields[23] as int?,
      landscapeImg: fields[10] as String?,
      isVideoPaid: fields[26] as int?,
      isVideoCoin: fields[27] as int?,
      totalVideoPlayed: fields[28] as int?,
      book: fields[29] as String?,
      isBookPaid: fields[31] as int?,
      totalEpisode: fields[24] as int?,
      isBookCoin: fields[32] as int?,
      totalBookPlayed: fields[33] as int?,
      sortable: fields[37] as int?,
      status: fields[38] as int?,
      createdAt: fields[39] as String?,
      updatedAt: fields[40] as String?,
      stopTime: fields[41] as int?,
      isBuy: fields[42] as int?,
      bookId: fields[48] as int?,
    )
      ..downloadProgress = fields[49] as int
      ..isDownloading = fields[50] as bool;
  }

  @override
  void write(BinaryWriter writer, DownloadEpisodeItem obj) {
    writer
      ..writeByte(51)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.contentId)
      ..writeByte(2)
      ..write(obj.contentType)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.languageId)
      ..writeByte(5)
      ..write(obj.artistId)
      ..writeByte(6)
      ..write(obj.name)
      ..writeByte(7)
      ..write(obj.title)
      ..writeByte(8)
      ..write(obj.image)
      ..writeByte(9)
      ..write(obj.portraitImg)
      ..writeByte(10)
      ..write(obj.landscapeImg)
      ..writeByte(11)
      ..write(obj.description)
      ..writeByte(12)
      ..write(obj.audioType)
      ..writeByte(13)
      ..write(obj.audio)
      ..writeByte(14)
      ..write(obj.musicUploadType)
      ..writeByte(15)
      ..write(obj.music)
      ..writeByte(16)
      ..write(obj.musicDuration)
      ..writeByte(17)
      ..write(obj.audioDuration)
      ..writeByte(18)
      ..write(obj.isAudioPaid)
      ..writeByte(19)
      ..write(obj.isAudioCoin)
      ..writeByte(20)
      ..write(obj.totalAudioPlayed)
      ..writeByte(21)
      ..write(obj.videoType)
      ..writeByte(22)
      ..write(obj.video)
      ..writeByte(23)
      ..write(obj.videoDuration)
      ..writeByte(24)
      ..write(obj.totalEpisode)
      ..writeByte(25)
      ..write(obj.totalReviews)
      ..writeByte(26)
      ..write(obj.isVideoPaid)
      ..writeByte(27)
      ..write(obj.isVideoCoin)
      ..writeByte(28)
      ..write(obj.totalVideoPlayed)
      ..writeByte(29)
      ..write(obj.book)
      ..writeByte(30)
      ..write(obj.totalPlayed)
      ..writeByte(31)
      ..write(obj.isBookPaid)
      ..writeByte(32)
      ..write(obj.isBookCoin)
      ..writeByte(33)
      ..write(obj.totalBookPlayed)
      ..writeByte(34)
      ..write(obj.fullNovel)
      ..writeByte(35)
      ..write(obj.isPaidNovel)
      ..writeByte(36)
      ..write(obj.novelCoin)
      ..writeByte(37)
      ..write(obj.sortable)
      ..writeByte(38)
      ..write(obj.status)
      ..writeByte(39)
      ..write(obj.createdAt)
      ..writeByte(40)
      ..write(obj.updatedAt)
      ..writeByte(41)
      ..write(obj.stopTime)
      ..writeByte(42)
      ..write(obj.isBuy)
      ..writeByte(43)
      ..write(obj.avgRating)
      ..writeByte(44)
      ..write(obj.securityKey)
      ..writeByte(45)
      ..write(obj.savedDir)
      ..writeByte(46)
      ..write(obj.savedFile)
      ..writeByte(47)
      ..write(obj.isDownload)
      ..writeByte(48)
      ..write(obj.bookId)
      ..writeByte(49)
      ..write(obj.downloadProgress)
      ..writeByte(50)
      ..write(obj.isDownloading);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadEpisodeItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
