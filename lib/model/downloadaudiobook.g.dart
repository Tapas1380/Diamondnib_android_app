// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'downloadaudiobook.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AudioBookBoxAdapter extends TypeAdapter<AudioBookBox> {
  @override
  final int typeId = 1;

  @override
  AudioBookBox read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AudioBookBox(
      id: fields[0] as int?,
      contentType: fields[1] as int?,
      artistId: fields[2] as int?,
      categoryId: fields[3] as int?,
      languageId: fields[4] as int?,
      title: fields[5] as String?,
      portraitImg: fields[6] as String?,
      landscapeImg: fields[7] as String?,
      description: fields[8] as String?,
      fullNovel: fields[9] as String?,
      isPaidNovel: fields[10] as int?,
      novelCoin: fields[11] as int?,
      totalPlayed: fields[12] as int?,
      status: fields[13] as int?,
      createdAt: fields[14] as String?,
      updatedAt: fields[15] as String?,
      categoryName: fields[16] as String?,
      languageName: fields[17] as String?,
      artistName: fields[18] as String?,
      artistImage: fields[19] as String?,
      isFollow: fields[20] as int?,
      book: fields[25] as String?,
      isBookPaid: fields[26] as int?,
      isBookCoin: fields[27] as int?,
      totalBookPlayed: fields[28] as int?,
      artistFollowers: fields[21] as int?,
      avgRating: fields[22] as String?,
      totalEpisode: fields[23] as int?,
      totalReviews: fields[24] as int?,
      isBuy: fields[29] as int?,
      totalUserPlay: fields[30] as int?,
      isBookMark: fields[31] as int?,
      isDownload: fields[32] as int?,
      savedDir: fields[34] as String?,
      savedFile: fields[35] as String?,
      securityKey: fields[33] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AudioBookBox obj) {
    writer
      ..writeByte(36)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.contentType)
      ..writeByte(2)
      ..write(obj.artistId)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.languageId)
      ..writeByte(5)
      ..write(obj.title)
      ..writeByte(6)
      ..write(obj.portraitImg)
      ..writeByte(7)
      ..write(obj.landscapeImg)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.fullNovel)
      ..writeByte(10)
      ..write(obj.isPaidNovel)
      ..writeByte(11)
      ..write(obj.novelCoin)
      ..writeByte(12)
      ..write(obj.totalPlayed)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.categoryName)
      ..writeByte(17)
      ..write(obj.languageName)
      ..writeByte(18)
      ..write(obj.artistName)
      ..writeByte(19)
      ..write(obj.artistImage)
      ..writeByte(20)
      ..write(obj.isFollow)
      ..writeByte(21)
      ..write(obj.artistFollowers)
      ..writeByte(22)
      ..write(obj.avgRating)
      ..writeByte(23)
      ..write(obj.totalEpisode)
      ..writeByte(24)
      ..write(obj.totalReviews)
      ..writeByte(25)
      ..write(obj.book)
      ..writeByte(26)
      ..write(obj.isBookPaid)
      ..writeByte(27)
      ..write(obj.isBookCoin)
      ..writeByte(28)
      ..write(obj.totalBookPlayed)
      ..writeByte(29)
      ..write(obj.isBuy)
      ..writeByte(30)
      ..write(obj.totalUserPlay)
      ..writeByte(31)
      ..write(obj.isBookMark)
      ..writeByte(32)
      ..write(obj.isDownload)
      ..writeByte(33)
      ..write(obj.securityKey)
      ..writeByte(34)
      ..write(obj.savedDir)
      ..writeByte(35)
      ..write(obj.savedFile);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioBookBoxAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
