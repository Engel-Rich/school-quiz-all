import 'package:cloud_firestore/cloud_firestore.dart';
import '/../main.dart';
import '/../models/QuizHistoryModel.dart';
import '/../services/BaseService.dart';
import '/../utils/ModelKeys.dart';
import '/../utils/constants.dart';

class QuizHistoryService extends BaseService {
  QuizHistoryService() {
    ref = db.collection('quizHistory');
  }

  Future<List<QuizHistoryModel>> quizHistoryByQuizType({String? quizType}) async {
    if (quizType == All) {
      return await ref.where(QuizHistoryKeys.userId, isEqualTo: appStore.userId).orderBy('createdAt', descending: true).get().then(
            (value) => value.docs.map((e) => QuizHistoryModel.fromJson(e.data() as Map<String, dynamic>)).toList(),
          );
    }
    return await ref
        .where(QuizHistoryKeys.userId, isEqualTo: appStore.userId)
        .where(QuizHistoryKeys.quizType, isEqualTo: quizType)
        .orderBy(CommonKeys.createdAt, descending: true)
        .get()
        .then((value) => value.docs.map((e) => QuizHistoryModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<bool> quizHistoryById({String? id}) async {
    Query query = ref.limit(1).where(QuizHistoryKeys.userId, isEqualTo: appStore.userId).where("quizId", isEqualTo: id);
    var res = await query.get();
    return res.docs.length == 1;
  }

  Future<List<QuizHistoryModel>> quizHistoryByQuiz({String? quizId}) async {
    return await ref.where("quizId", isEqualTo:quizId).orderBy('rightQuestion',descending: true).get().then(
          (value) => value.docs.map((e) => QuizHistoryModel.fromJson(e.data() as Map<String, dynamic>)).toList(),
    );
  }
}
