import '../main.dart';
import '../models/QuizHistoryModel.dart';
import '../utils/ModelKeys.dart';
import 'BaseService.dart';

class QuizHistoryService extends BaseService {
  QuizHistoryService() {
    ref = db.collection('quizHistory');
  }

  Future<List<QuizHistoryModel>> quizHistoryByQuizID({String? userID}) async {
      return await ref.where(QuizHistoryKeys.userId, isEqualTo:userID).orderBy('createdAt', descending: true).get().then(
            (value) => value.docs.map((e) => QuizHistoryModel.fromJson(e.data() as Map<String, dynamic>)).toList(),
      );
  }

  Future<List<QuizHistoryModel>> quizHistoryByQuiz({String? quizId}) async {
    return await ref.where("quizId", isEqualTo:quizId).orderBy('rightQuestion',descending: true).get().then(
          (value) => value.docs.map((e) => QuizHistoryModel.fromJson(e.data() as Map<String, dynamic>)).toList(),
    );
  }
}
