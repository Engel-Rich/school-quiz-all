import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

class CategoryData {
  String? id;
  String? name;
  String? image;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? classe;
  String? type;

  //Add Line
  String? parentCategoryId;

  CategoryData({
    this.id,
    this.name,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.parentCategoryId,
    this.classe,
    this.type,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
        id: json[CommonKeys.id],
        name: json[CategoryKeys.name],
        image: json[CategoryKeys.image],
        createdAt: json[CommonKeys.createdAt] != null
            ? (json[CommonKeys.createdAt] as Timestamp).toDate()
            : null,
        updatedAt: json[CommonKeys.updatedAt] != null
            ? (json[CommonKeys.updatedAt] as Timestamp).toDate()
            : null,
        parentCategoryId: json[CategoryKeys.parentCategoryId],
        classe: json[CategoryKeys.classe],
        type: json[CategoryKeys.type]);
  }

  Map<String, dynamic> toJson({bool toStore = true}) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[CommonKeys.id] = this.id;
    data[CategoryKeys.name] = this.name;
    data[CategoryKeys.image] = this.image;
    data[CommonKeys.createdAt] = this.createdAt;
    data[CommonKeys.updatedAt] = this.updatedAt;
    data[CategoryKeys.parentCategoryId] = this.parentCategoryId;
    data[CategoryKeys.classe] = classe;
    data[CategoryKeys.type] = type;
    return data;
  }
}
