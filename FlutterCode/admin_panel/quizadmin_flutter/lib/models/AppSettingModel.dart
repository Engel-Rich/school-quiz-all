import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

class AppSettingModel {
  bool? disableAd;
  String? termCondition;
  String? privacyPolicy;
  String? contactInfo;
  String? referPoints;

  AppSettingModel({
    this.disableAd,
    this.termCondition,
    this.privacyPolicy,
    this.contactInfo,
    this.referPoints
  });

  factory AppSettingModel.fromJson(Map<String, dynamic> json) {
    return AppSettingModel(
      disableAd: json[AppSettingKeys.disableAd],
      termCondition: json[AppSettingKeys.termCondition],
      privacyPolicy: json[AppSettingKeys.privacyPolicy],
      contactInfo: json[AppSettingKeys.contactInfo],
      referPoints: json[AppSettingKeys.referPoints]
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data[AppSettingKeys.disableAd] = this.disableAd;
    data[AppSettingKeys.termCondition] = this.termCondition;
    data[AppSettingKeys.privacyPolicy] = this.privacyPolicy;
    data[AppSettingKeys.contactInfo] = this.contactInfo;
    data[AppSettingKeys.referPoints]=this.referPoints;
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