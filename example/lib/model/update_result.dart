class UpdateResult {
  int? code;
  DataUpdate? data;
  String? message;
  String? status;

  UpdateResult({this.code, this.data, this.message, this.status});

  UpdateResult.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    data = json['data'] != null ? DataUpdate.fromJson(json['data']) : null;
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

class DataUpdate {
  String? id;
  String? username;
  String? fullName;
  String? email;
  String? address;
  String? phone;
  String? kdWil;
  String? roleId;
  String? active;
  String? updatedDate;

  DataUpdate(
      {this.id,
      this.username,
      this.fullName,
      this.email,
      this.address,
      this.phone,
      this.kdWil,
      this.roleId,
      this.active,
      this.updatedDate});

  DataUpdate.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    fullName = json['full_name'];
    email = json['email'];
    address = json['address'];
    phone = json['phone'];
    kdWil = json['kd_wil'];
    roleId = json['role_id'];
    active = json['active'];
    updatedDate = json['updated_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['full_name'] = fullName;
    data['email'] = email;
    data['address'] = address;
    data['phone'] = phone;
    data['kd_wil'] = kdWil;
    data['role_id'] = roleId;
    data['active'] = active;
    data['updated_date'] = updatedDate;
    return data;
  }
}
