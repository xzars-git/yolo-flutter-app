import 'package:hive/hive.dart';

part 'login_result.g.dart';

@HiveType(typeId: 0)
class LoginResult {
  @HiveField(0)
  int? code;
  @HiveField(2)
  DataLogin? data;
  @HiveField(3)
  String? message;
  @HiveField(4)
  String? status;

  LoginResult({this.code, this.data, this.message, this.status});

  LoginResult.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data'] != null ? DataLogin.fromJson(json['data']) : null;
    message = json['message'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    data['status'] = status;
    return data;
  }
}

@HiveType(typeId: 1)
class DataLogin {
  @HiveField(0)
  String? accessToken;
  @HiveField(1)
  DataUser? dataUser;

  DataLogin({this.accessToken, this.dataUser});

  DataLogin.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    dataUser = json['data_user'] != null ? DataUser.fromJson(json['data_user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['access_token'] = accessToken;
    if (dataUser != null) {
      data['data_user'] = dataUser!.toJson();
    }
    return data;
  }
}

@HiveType(typeId: 2)
class DataUser {
  @HiveField(0)
  String? id;
  @HiveField(1)
  String? username;
  @HiveField(2)
  String? password;
  @HiveField(3)
  String? fullName;
  @HiveField(4)
  String? address;
  @HiveField(5)
  String? email;
  @HiveField(6)
  String? phone;
  @HiveField(7)
  String? deviceId;
  @HiveField(8)
  String? kdWil;
  @HiveField(9)
  String? nmWil;
  @HiveField(10)
  String? createdDate;
  @HiveField(11)
  String? updatedDate;
  @HiveField(12)
  String? lastLogin;
  @HiveField(13)
  String? active;
  @HiveField(14)
  String? roleId;
  @HiveField(15)
  String? roleName;
  @HiveField(16)
  String? ipAddress;
  @HiveField(17)
  String? subKdWil;
  @HiveField(18)
  String? kdKabKota;

  DataUser({
    this.id,
    this.username,
    this.password,
    this.fullName,
    this.address,
    this.email,
    this.phone,
    this.deviceId,
    this.kdWil,
    this.nmWil,
    this.createdDate,
    this.updatedDate,
    this.lastLogin,
    this.active,
    this.roleId,
    this.roleName,
    this.ipAddress,
    this.subKdWil,
    this.kdKabKota,
  });

  DataUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    password = json['password'];
    fullName = json['full_name'];
    address = json['address'];
    email = json['email'];
    phone = json['phone'];
    deviceId = json['device_id'];
    kdWil = json['kd_wil'];
    nmWil = json['nm_wil'];
    createdDate = json['created_date'];
    updatedDate = json['updated_date'];
    lastLogin = json['last_login'];
    active = json['active'];
    roleId = json['role_id'];
    roleName = json['role_name'];
    ipAddress = json['ip_address'];
    subKdWil = json['sub_kd_wil'];
    kdKabKota = json['kd_kabkota'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['password'] = password;
    data['full_name'] = fullName;
    data['address'] = address;
    data['email'] = email;
    data['phone'] = phone;
    data['device_id'] = deviceId;
    data['kd_wil'] = kdWil;
    data['nm_wil'] = nmWil;
    data['created_date'] = createdDate;
    data['updated_date'] = updatedDate;
    data['last_login'] = lastLogin;
    data['active'] = active;
    data['role_id'] = roleId;
    data['role_name'] = roleName;
    data['ip_address'] = ipAddress;
    data['sub_kd_wil'] = subKdWil;
    data['kd_kabkota'] = kdKabKota;
    return data;
  }
}
