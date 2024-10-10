import '/../models/QuizModel.dart';
import '/../services/BaseService.dart';
import '/../utils/ModelKeys.dart';

import '../main.dart';

class QuizService extends BaseService {
  QuizService() {
    ref = db.collection('quiz');
  }

  Future<List<QuizModel>> getQuizByCatId(String? id) async {
    return await ref.where(QuizKeys.categoryId, isEqualTo: id).get().then((event) => event.docs.map((e) => QuizModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<QuizModel>> getQuizBySubCatId(String id) async {
    return await ref.where('subcategoryId', isEqualTo: id).get().then((event) => event.docs.map((e) => QuizModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<QuizModel>> getQuizByQuizId(String? id) async {
    return await ref.where(CommonKeys.id, isEqualTo: id).get().then((event) => event.docs.map((e) => QuizModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<QuizModel>> getQuiz() async {
    return await ref.get().then((event) => event.docs.map((e) => QuizModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future <QuizModel> quizByQuizID(String? id) async {
    var data = await ref.where(CommonKeys.id,isEqualTo: id).get();
    return QuizModel.fromJson(data.docs.first.data() as Map<String, dynamic>);
  }

  Future<List<QuizModel>> get quizList async {
    return await ref.get().then((value) => value.docs.map((e) => QuizModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }
}
