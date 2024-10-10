import '/../utils/ModelKeys.dart';

class CategoryModel {
  String? id;
  String? image;
  String? name;
  String? classe;
  String? parentCategoryId;

  CategoryModel({
    this.id,
    this.image,
    this.name,
    this.classe,
    this.parentCategoryId,
  });

  factory CategoryModel.fromJson(json) {
    return CategoryModel(
      id: json[CommonKeys.id],
      image: json[CategoryKeys.image],
      name: json[CategoryKeys.name],
      classe: json[CategoryKeys.classe],
      parentCategoryId: json[CategoryKeys.parentCategoryId],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[CommonKeys.id] = this.id;
    data[CategoryKeys.image] = this.image;
    data[CategoryKeys.name] = this.name;
    data[CategoryKeys.classe] = classe;
    data[CategoryKeys.parentCategoryId] = parentCategoryId;
    return data;
  }
}
