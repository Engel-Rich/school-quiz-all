import 'package:cloud_firestore/cloud_firestore.dart';

class AppSettingModel {
  String? contactInfo;
  bool? disableAd;
  String? privacyPolicy;
  String? termCondition;
  String? referPoints;

  AppSettingModel({
    this.contactInfo,
    this.disableAd,
    this.privacyPolicy,
    this.termCondition,
    this.referPoints,
  });

  factory AppSettingModel.fromJson(Map<String, dynamic> json) {
    return AppSettingModel(
      contactInfo: json['contactInfo'],
      disableAd: json['disableAd'],
      privacyPolicy: json['privacyPolicy'],
      termCondition: json['termCondition'],
      referPoints: json['referPoints']
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['contactInfo'] = this.contactInfo;
    data['disableAd'] = this.disableAd;
    data['privacyPolicy'] = this.privacyPolicy;
    data['termCondition'] = this.termCondition;
    data['referPoints'] =this.referPoints;
    return data;
  }
}

class OneSignalModel {
  String? appId;
  String? channelId;
  String? restApiKey;
  DateTime? createdAt;
  DateTime? updatedAt;

  OneSignalModel(
      {this.appId,
        this.channelId,
        this.restApiKey,
        this.createdAt,
        this.updatedAt});

  factory OneSignalModel.fromJson(Map<String, dynamic> json) {
    return OneSignalModel(
      appId: json['appId'],
      channelId: json['channelId'],
      restApiKey: json['restApiKey'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appId'] = this.appId;
    data['channelId'] = this.channelId;
    data['restApiKey'] = this.restApiKey;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}