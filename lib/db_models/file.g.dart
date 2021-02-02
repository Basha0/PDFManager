// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomFileAdapter extends TypeAdapter<CustomFile> {
  @override
  final int typeId = 1;

  @override
  CustomFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomFile(
      timeStamp: fields[0] as String,
      fileName: fields[1] as String,
      fileUrl: fields[2] as String,
      completed: fields[3] as bool,
      currentPage: fields[4] as int,
      filePath: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CustomFile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.timeStamp)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.fileUrl)
      ..writeByte(3)
      ..write(obj.completed)
      ..writeByte(4)
      ..write(obj.currentPage)
      ..writeByte(5)
      ..write(obj.filePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
