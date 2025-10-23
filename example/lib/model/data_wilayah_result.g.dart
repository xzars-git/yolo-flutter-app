// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_wilayah_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResultDataWilayahAdapter extends TypeAdapter<ResultDataWilayah> {
  @override
  final int typeId = 5;

  @override
  ResultDataWilayah read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResultDataWilayah(
      code: fields[0] as int?,
      data: (fields[1] as List?)?.cast<DataWilayah>(),
      message: fields[2] as String?,
      status: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ResultDataWilayah obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultDataWilayahAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DataWilayahAdapter extends TypeAdapter<DataWilayah> {
  @override
  final int typeId = 6;

  @override
  DataWilayah read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataWilayah(
      kdWil: fields[0] as String?,
      nmWil: fields[1] as String?,
      alUppd: fields[2] as String?,
      kabKota: fields[3] as String?,
      provinsi: fields[4] as String?,
      telp: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DataWilayah obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.kdWil)
      ..writeByte(1)
      ..write(obj.nmWil)
      ..writeByte(2)
      ..write(obj.alUppd)
      ..writeByte(3)
      ..write(obj.kabKota)
      ..writeByte(4)
      ..write(obj.provinsi)
      ..writeByte(5)
      ..write(obj.telp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataWilayahAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
