// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizapp_flutter/models/CategorieTypeModel.dart';
import 'package:quizapp_flutter/models/CategoryModel.dart';
// import 'package:quizapp_flutter/services/CategoryService.dart';

import '/../main.dart';
import '/../models/QuestionModel.dart';
import '/../services/BaseService.dart';
import '/../utils/ModelKeys.dart';

class QuestionService extends BaseService {
  QuestionService() {
    ref = db.collection('question');
  }

  Future<QuestionModel?> questionById(String id) async {
    //return await ref.where('id', isEqualTo: id).limit(1).get().then((value) => QuestionModel.fromJson(value.docs.first.data()));
    return ref.doc(id).get().then((res) {
      if (res.data() != null) {
        return QuestionModel.fromJson(res.data() as Map<String, dynamic>);
      } else {
        // throw 'Not available';
        return null;
      }
    });
  }

  Future<List<QuestionModel>> questionByCatId(String? catId) async {
    if (catId != null) {
      return await ref
          .where(QuestionKeys.category,
              isEqualTo: categoryService.ref.doc(catId))
          .get()
          .then(
        (event) {
          return event.docs
              .map((e) =>
                  QuestionModel.fromJson(e.data() as Map<String, dynamic>))
              .toList();
        },
      );
    } else {
      return await ref.get().then((value) {
        return value.docs
            .map(
                (e) => QuestionModel.fromJson(e.data() as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<List<QuestionModel>> questionByType(String? type) async {
    return ref
        .where("questionType", isEqualTo: type)
        .where('classeId', isEqualTo: appStore.userClasse)
        .get()
        .then((res) {
      if (res.docs.isNotEmpty) {
        return res.docs
            .map(
                (e) => QuestionModel.fromJson(e.data() as Map<String, dynamic>))
            .toList();
      } else {
        throw 'Not available';
      }
    });
  }

  Future<List<QuestionModel>> questionList({bool byClasse = true}) async {
    return (appStore.userClasse == null || !byClasse
            ? ref.get()
            : ref.where('classeId', isEqualTo: appStore.userClasse).get())
        .then((value) {
      return value.docs
          .map((e) => QuestionModel.fromJson(e.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<QuestionModel>> questionListByTypeCategorie(
      TypeCategorie typeCategorie) async {
    print(typeCategorie);
    List<CategoryModel> catList = await categoryService.ref
        .where('type', isEqualTo: typeCategorie.id!)
        .get()
        .then(
          (value) =>
              value.docs.map((e) => CategoryModel.fromJson(e.data())).toList(),
        );
    print(catList);
    return ref
        .where(
          "subcategoryId",
          whereIn: catList.map((e) => e.id!).toList(),
        )
        .get()
        .then((value) {
      return value.docs
          .map((e) => QuestionModel.fromJson(e.data() as Map<String, dynamic>))
          .toList()
        ..shuffle();
    });
  }
}
