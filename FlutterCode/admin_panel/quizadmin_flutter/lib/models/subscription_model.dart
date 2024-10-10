// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SubscriptionModel {
  final String? id;
  final String userId;
  final String abonnementId;
  final DateTime datefin;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  SubscriptionModel({
    this.id,
    required this.userId,
    required this.abonnementId,
    required this.datefin,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  String toJson() => json.encode(toMap());

  factory SubscriptionModel.fromJson(String source) =>
      SubscriptionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'abonnementId': abonnementId,
      'datefin': datefin.millisecondsSinceEpoch,
      'createdAt': createdAt?.millisecondsSinceEpoch,
      'updatedAt': updatedAt?.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  factory SubscriptionModel.fromMap(map) {
    return SubscriptionModel(
      id: map['id'] != null ? map['id'] as String : null,
      userId: map['userId'] as String,
      abonnementId: map['abonnementId'] as String,
      datefin: DateTime.fromMillisecondsSinceEpoch(map['datefin'] as int),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int)
          : null,
      isActive: map['isActive'] ?? true,
    );
  }
}
