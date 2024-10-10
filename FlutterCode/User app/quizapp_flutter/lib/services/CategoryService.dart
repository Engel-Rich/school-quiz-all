import 'dart:convert';

import 'package:quizapp_flutter/models/ClasseModel.dart';

import '/../main.dart';
import '/../models/CategoryModel.dart';
import '/../services/BaseService.dart';

class CategoryService extends BaseService {
  CategoryService() {
    ref = db.collection('categories');
  }

  Future<List<CategoryModel>> categories() async {
    // return await ref.get().then((event) => event.docs.map((e) => CategoryModel.fromJson(e.data() as Map<String, dynamic>)).toList());
    final classe = appStore.userClasse != null
        ? ClasseModel.fromMap(jsonDecode(appStore.userClasse!))
        : null;
    if (appStore.userClasse != null && classe?.id_classe != null)
      return await ref
          .where('parentCategoryId', isEqualTo: '')
          .where('classe', isEqualTo: classe?.id_classe)
          .orderBy('createdAt')
          .get()
          .then((x) => x.docs
              .map((y) =>
                  CategoryModel.fromJson(y.data() as Map<String, dynamic>))
              .toList());
    return await ref.where('parentCategoryId', isEqualTo: '').get().then((x) =>
        x
            .docs
            .map(
                (y) => CategoryModel.fromJson(y.data() as Map<String, dynamic>))
            .toList());
  }

  Stream<List<CategoryModel>> categoriesStream({bool hasLimite = false}) {
    // return await ref.get().then((event) => event.docs.map((e) => CategoryModel.fromJson(e.data() as Map<String, dynamic>)).toList());
    final ClasseModel? classe = appStore.userClasse != null
        ? ClasseModel.fromMap(jsonDecode(appStore.userClasse!))
        : null;
    if (appStore.userClasse != null && classe?.id_classe != null)
      return (!hasLimite ? ref : ref.limit(4))
          .where('parentCategoryId', isEqualTo: '')
          .where('classe', isEqualTo: classe!.id_classe)
          .orderBy('createdAt')
          .snapshots()
          .map((x) => x.docs
              .map((y) =>
                  CategoryModel.fromJson(y.data() as Map<String, dynamic>))
              .toList());
    return (!hasLimite ? ref : ref.limit(4))
        .where('parentCategoryId', isEqualTo: '')
        .orderBy('createdAt')
        .snapshots()
        .map((x) => x.docs
            .map(
                (y) => CategoryModel.fromJson(y.data() as Map<String, dynamic>))
            .toList());
  }

  Future<List<CategoryModel>> subCategories(String parentCategoryId) {
    return ref
        .where('parentCategoryId', isEqualTo: parentCategoryId)
        .orderBy('createdAt')
        .get()
        .then(
          (event) => event.docs
              .map((e) =>
                  CategoryModel.fromJson(e.data() as Map<String, dynamic>))
              .toList(),
        );
    // return ref.get().then((event) => event.docs.map((e) => CategoryModel.fromJson(e.data())).toList());
  }

  Future<List<CategoryModel>> categoriesByClasse(String classe) {
    return ref
        .where('classe', isEqualTo: classe)
        .orderBy('createdAt')
        .get()
        .then(
          (event) => event.docs
              .map((e) =>
                  CategoryModel.fromJson(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  Future<List<CategoryModel>> subCategoriesByClasse(
      {required String classe, required String parentCategoryId}) {
    return ref
        .where('classe', isEqualTo: classe)
        .where('parentCategoryId', isEqualTo: parentCategoryId)
        .orderBy('createdAt')
        .get()
        .then(
          (event) => event.docs
              .map((e) =>
                  CategoryModel.fromJson(e.data() as Map<String, dynamic>))
              .toList(),
        );
  }
}
