// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Publicite {
  String? id;
  String? libelle;
  String? sitUrl;
  String? playUrl;
  String? iosUrl;
  String? videoUrl;
  String? imageUrl;
  List userSeeingList = [];
  List userTapedList = [];
  DateTime? createdAt;
  DateTime? updatedAt;
  bool isactive;
  Publicite({
    this.id,
    this.libelle,
    this.sitUrl,
    this.playUrl,
    this.iosUrl,
    this.videoUrl,
    this.imageUrl,
    required this.userSeeingList,
    required this.userTapedList,
    this.createdAt,
    this.updatedAt,
    this.isactive = false,
  });

  Publicite copyWith({
    String? id,
    String? libelle,
    String? sitUrl,
    String? playUrl,
    String? iosUrl,
    String? videoUrl,
    String? imageUrl,
    List? userSeeingList,
    List? userTapedList,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isactive,
  }) {
    return Publicite(
      id: id ?? this.id,
      libelle: libelle ?? this.libelle,
      sitUrl: sitUrl ?? this.sitUrl,
      playUrl: playUrl ?? this.playUrl,
      iosUrl: iosUrl ?? this.iosUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      userSeeingList: userSeeingList ?? this.userSeeingList,
      userTapedList: userTapedList ?? this.userTapedList,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isactive: isactive ?? this.isactive,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'libelle': libelle,
      'sitUrl': sitUrl,
      'playUrl': playUrl,
      'iosUrl': iosUrl,
      'videoUrl': videoUrl,
      'imageUrl': imageUrl,
      'isactive': isactive,
      'userSeeingList': userSeeingList,
      'userTapedList': userTapedList,
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  factory Publicite.fromMap(Map<String, dynamic> map) {
    return Publicite(
      id: map['id'] != null ? map['id'] as String : null,
      libelle: map['libelle'] != null ? map['libelle'] as String : null,
      sitUrl: map['sitUrl'] != null ? map['sitUrl'] as String : null,
      playUrl: map['playUrl'] != null ? map['playUrl'] as String : null,
      iosUrl: map['iosUrl'] != null ? map['iosUrl'] as String : null,
      videoUrl: map['videoUrl'] != null ? map['videoUrl'] as String : null,
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
      isactive: map["isactive"] ?? false,
      userSeeingList: map['userSeeingList'],
      userTapedList: map['userTapedList'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Publicite.fromJson(String source) =>
      Publicite.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Publicite(id: $id, libelle: $libelle, sitUrl: $sitUrl, playUrl: $playUrl, iosUrl: $iosUrl, videoUrl: $videoUrl, imageUrl: $imageUrl, userSeeingList: $userSeeingList, userTapedList: $userTapedList, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant Publicite other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.libelle == libelle &&
        other.sitUrl == sitUrl &&
        other.playUrl == playUrl &&
        other.iosUrl == iosUrl &&
        other.videoUrl == videoUrl &&
        other.imageUrl == imageUrl &&
        listEquals(other.userSeeingList, userSeeingList) &&
        listEquals(other.userTapedList, userTapedList) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.isactive == isactive;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        libelle.hashCode ^
        sitUrl.hashCode ^
        playUrl.hashCode ^
        iosUrl.hashCode ^
        videoUrl.hashCode ^
        imageUrl.hashCode ^
        userSeeingList.hashCode ^
        userTapedList.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        isactive.hashCode;
  }
}
