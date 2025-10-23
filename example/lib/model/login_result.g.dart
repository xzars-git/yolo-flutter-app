// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoginResultAdapter extends TypeAdapter<LoginResult> {
  @override
  final int typeId = 0;

  @override
  LoginResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginResult(
      code: fields[0] as int?,
      data: fields[2] as DataLogin?,
      message: fields[3] as String?,
      status: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LoginResult obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.code)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.message)
      ..writeByte(4)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DataLoginAdapter extends TypeAdapter<DataLogin> {
  @override
  final int typeId = 1;

  @override
  DataLogin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataLogin(
      accessToken: fields[0] as String?,
      dataUser: fields[1] as DataUser?,
    );
  }

  @override
  void write(BinaryWriter writer, DataLogin obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(1)
      ..write(obj.dataUser);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataLoginAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DataUserAdapter extends TypeAdapter<DataUser> {
  @override
  final int typeId = 2;

  @override
  DataUser read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataUser(
      id: fields[0] as String?,
      username: fields[1] as String?,
      password: fields[2] as String?,
      fullName: fields[3] as String?,
      address: fields[4] as String?,
      email: fields[5] as String?,
      phone: fields[6] as String?,
      deviceId: fields[7] as String?,
      kdWil: fields[8] as String?,
      nmWil: fields[9] as String?,
      createdDate: fields[10] as String?,
      updatedDate: fields[11] as String?,
      lastLogin: fields[12] as String?,
      active: fields[13] as String?,
      roleId: fields[14] as String?,
      roleName: fields[15] as String?,
      ipAddress: fields[16] as String?,
      subKdWil: fields[17] as String?,
      kdKabKota: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DataUser obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.fullName)
      ..writeByte(4)
      ..write(obj.address)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.phone)
      ..writeByte(7)
      ..write(obj.deviceId)
      ..writeByte(8)
      ..write(obj.kdWil)
      ..writeByte(9)
      ..write(obj.nmWil)
      ..writeByte(10)
      ..write(obj.createdDate)
      ..writeByte(11)
      ..write(obj.updatedDate)
      ..writeByte(12)
      ..write(obj.lastLogin)
      ..writeByte(13)
      ..write(obj.active)
      ..writeByte(14)
      ..write(obj.roleId)
      ..writeByte(15)
      ..write(obj.roleName)
      ..writeByte(16)
      ..write(obj.ipAddress)
      ..writeByte(17)
      ..write(obj.subKdWil)
      ..writeByte(18)
      ..write(obj.kdKabKota);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataUserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
