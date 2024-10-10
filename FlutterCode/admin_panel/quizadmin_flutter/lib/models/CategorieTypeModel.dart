// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class TypeCategorie {
  String? id;
  String? nameTypeCategorie;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? images;
  TypeCategorie({
    this.id,
    this.nameTypeCategorie,
    this.images,
    this.createdAt,
    this.updatedAt,
  });

  TypeCategorie copyWith(
      {String? id,
      String? nameTypeCategorie,
      DateTime? createdAt,
      DateTime? updatedAt,
      String? images}) {
    return TypeCategorie(
      id: id ?? this.id,
      nameTypeCategorie: nameTypeCategorie ?? this.nameTypeCategorie,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      images: images ?? this.images,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name_type_categorie': nameTypeCategorie,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'images': images,
    };
  }

  factory TypeCategorie.fromMap(Map<String, dynamic> map) {
    return TypeCategorie(
      id: map['id'] as String,
      nameTypeCategorie: map['name_type_categorie'] as String,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
      images: map['images'],
    );
  }

  String toJson() => json.encode(toMap());

  factory TypeCategorie.fromJson(String source) =>
      TypeCategorie.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'TypeCategorie(id: $id, nameTypeCategorie: $nameTypeCategorie, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant TypeCategorie other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.nameTypeCategorie == nameTypeCategorie &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nameTypeCategorie.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
