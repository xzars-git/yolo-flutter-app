// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kriteria_telusur_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KriteriaTelusurResultAdapter extends TypeAdapter<KriteriaTelusurResult> {
  @override
  final int typeId = 7;

  @override
  KriteriaTelusurResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KriteriaTelusurResult(
      code: fields[0] as int?,
      data: (fields[1] as List?)?.cast<DataKriteriaTelusur>(),
      message: fields[2] as String?,
      status: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, KriteriaTelusurResult obj) {
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
      other is KriteriaTelusurResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DataKriteriaTelusurAdapter extends TypeAdapter<DataKriteriaTelusur> {
  @override
  final int typeId = 8;

  @override
  DataKriteriaTelusur read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataKriteriaTelusur(
      kdTelusur: fields[0] as String?,
      nmTelusur: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DataKriteriaTelusur obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.kdTelusur)
      ..writeByte(1)
      ..write(obj.nmTelusur);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataKriteriaTelusurAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
