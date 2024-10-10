import 'package:cloud_firestore/cloud_firestore.dart';
import '/../utils/ModelKeys.dart';

class UserModel {
  String? id;
  String? email;
  String? password;
  String? name;
  String? age;
  String? loginType;
  DateTime? updatedAt;
  DateTime? createdAt;
  int? points;
  String? photoUrl;
  bool? isAdmin = false;
  bool? isTestUser;
  String? referCode;
  String? mobileNumber;
  String? classe;

  UserModel(
      {this.email,
      this.password,
      this.name,
      this.age,
      this.id,
      this.loginType,
      this.updatedAt,
      this.createdAt,
      this.points = 50,
      this.photoUrl,
      this.isAdmin,
      this.isTestUser,
      this.classe,
      this.referCode,
      this.mobileNumber});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json[UserKeys.email],
      password: json[UserKeys.password],
      name: json[UserKeys.name],
      age: json[UserKeys.age],
      id: json[CommonKeys.id],
      points: json[UserKeys.points],
      loginType: json[UserKeys.loginType],
      photoUrl: json[UserKeys.photoUrl],
      isAdmin: json[UserKeys.isAdmin],
      mobileNumber: json[UserKeys.mobile],
      isTestUser: json[UserKeys.isTestUser],
      createdAt: json[CommonKeys.createdAt] != null
          ? (json[CommonKeys.createdAt] as Timestamp).toDate()
          : null,
      updatedAt: json[CommonKeys.updatedAt] != null
          ? (json[CommonKeys.updatedAt] as Timestamp).toDate()
          : null,
      referCode: json[UserKeys.referCode],
      classe: json[UserKeys.classe],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[UserKeys.email] = this.email;
    data[UserKeys.password] = this.password;
    data[UserKeys.name] = this.name;
    data[UserKeys.age] = this.age;
    data[CommonKeys.id] = this.id;
    data[UserKeys.points] = this.points;
    data[UserKeys.photoUrl] = this.photoUrl;
    data[UserKeys.loginType] = this.loginType;
    data[CommonKeys.createdAt] = this.createdAt;
    data[CommonKeys.updatedAt] = this.updatedAt;
    data[UserKeys.isTestUser] = this.isTestUser;
    data[UserKeys.isAdmin] = this.isAdmin;
    data[UserKeys.referCode] = this.referCode;
    data[UserKeys.mobile] = this.mobileNumber;
    data[UserKeys.classe] = this.classe;
    return data;
  }
}
