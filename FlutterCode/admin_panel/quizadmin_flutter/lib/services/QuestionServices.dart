import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeapp/models/QuestionData.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

import '../main.dart';
import 'BaseService.dart';

class QuestionServices extends BaseService {
  QuestionServices() {
    ref = db.collection('question');
  }

  Stream<List<QuestionData>> listQuestion() {
    return ref.snapshots().map((x) => x.docs
        .map((y) => QuestionData.fromJson(y.data() as Map<String, dynamic>))
        .toList());
  }

  Query getQuestions({DocumentReference? categoryRef}) {
    if (categoryRef != null) {
      return ref.where('category', isEqualTo: categoryRef);
    } else {
      return ref;
    }
  }

  Query? getListOfQue() {
    return ref;
  }

  Future<QuestionData> questionById(String? id) async {
    return await ref.where('id', isEqualTo: id).limit(1).get().then(
      (x) {
        if (x.docs.isNotEmpty) {
          return QuestionData.fromJson(
              x.docs.first.data() as Map<String, dynamic>);
        } else {
          throw 'Not available';
        }
      },
    );
  }

  Future<List<QuestionData>> questionListFuture(
      {DocumentReference? categoryRef, String? subcategorie}) async {
    Query? query;

    if (subcategorie != null) {
      query = ref.where('subcategoryId', isEqualTo: subcategorie);
    } else if (categoryRef != null) {
      query = ref.where('category', isEqualTo: categoryRef);
    } else {
      query = ref;
    }
    query.orderBy(CommonKeys.createdAt);
    return await query.get().then((x) => x.docs
        .map((y) => QuestionData.fromJson(y.data() as Map<String, dynamic>))
        .toList());
  }

  Query questionListQuery(
      {DocumentReference? categoryRef, String? subcategorie}) {
    Query? query;

    if (subcategorie != null) {
      query = ref.where('subcategoryId', isEqualTo: subcategorie);
    } else if (categoryRef != null) {
      query = ref.where('category', isEqualTo: categoryRef);
    } else {
      query = ref;
    }
    return query;
  }
}
