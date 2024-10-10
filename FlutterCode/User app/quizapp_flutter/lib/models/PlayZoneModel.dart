// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

import 'package:quizapp_flutter/models/CategorieTypeModel.dart';

class PlayZoneModel {
  String? name;
  String? image;
  VoidCallback callback;
  TypeCategorie? typeCategorie;
  String? typeCategorieimage;
  PlayZoneModel({
    this.image,
    this.name,
    required this.callback,
    this.typeCategorie,
    this.typeCategorieimage,
  });

  PlayZoneModel copyWith({
    String? name,
    String? image,
    VoidCallback? callback,
    TypeCategorie? typeCategorie,
    String? typeCategorieimage,
  }) {
    return PlayZoneModel(
      name: name ?? this.name,
      image: image ?? this.image,
      callback: callback ?? this.callback,
      typeCategorie: typeCategorie ?? this.typeCategorie,
      typeCategorieimage: typeCategorieimage ?? this.typeCategorieimage,
    );
  }
}
