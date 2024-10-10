// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeapp/utils/Constants.dart';
import 'package:collection/collection.dart';

class ClasseModel {
  String? filiere;
  String? id_classe;
  bool? isSecondary;
  String? long_name;
  String? shurt_name;
  String? type_enseignement;
  String? type_section;
  DateTime? updatedAt;
  DateTime? createdAt;
  String? image;
  ClasseType classeType;
  ClasseModel({
    this.filiere,
    this.id_classe,
    this.isSecondary = true,
    this.long_name,
    this.shurt_name,
    this.type_enseignement,
    this.type_section,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.classeType = ClasseType.academic,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'filiere': filiere,
      'id_classe': id_classe,
      'isSecondary': isSecondary,
      'long_name': long_name,
      'shurt_name': shurt_name,
      'type_enseignement': type_enseignement,
      'type_section': type_section,
      'image': image,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'classe_type': this.classeType.toString().split('.').last,
    };
  }

  factory ClasseModel.fromMap(Map<String, dynamic> map) {
    return ClasseModel(
      filiere: map['filiere'] != null ? map['filiere'] as String? : null,
      id_classe: map['id_classe'] != null ? map['id_classe'] as String? : null,
      isSecondary:
          map['isSecondary'] != null ? map['isSecondary'] as bool? : null,
      long_name: map['long_name'] != null ? map['long_name'] as String? : null,
      shurt_name:
          map['shurt_name'] != null ? map['shurt_name'] as String? : null,
      type_enseignement: map['type_enseignement'] != null
          ? map['type_enseignement'] as String?
          : null,
      type_section:
          map['type_section'] != null ? map['type_section'] as String? : null,
      image: map['image'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      classeType: ClasseType.values.firstWhereOrNull((element) =>
              element.toString().split('.').last == map['classe_type']) ??
          ClasseType.academic,
    );
  }

  // String toJson() => json.encode(toMap());

  factory ClasseModel.fromJson(String source) =>
      ClasseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ClasseModel(filiere: $filiere, id_classe: $id_classe, isSecondary: $isSecondary, long_name: $long_name, shurt_name: $shurt_name, type_enseignement: $type_enseignement, type_section: $type_section)';
  }

  @override
  bool operator ==(covariant ClasseModel other) {
    if (identical(this, other)) return true;

    return other.id_classe == id_classe;
  }

  @override
  int get hashCode {
    return id_classe.hashCode;
  }
}
