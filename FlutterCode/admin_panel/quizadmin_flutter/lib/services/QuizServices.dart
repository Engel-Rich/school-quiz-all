import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/QuizData.dart';
import 'package:quizeapp/services/BaseService.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

class QuizServices extends BaseService {
  QuizServices() {
    ref = db.collection('quiz');
  }

  Future<List<QuizData>> get quizList async {
    return await ref.get().then((value) => value.docs
        .map((e) => QuizData.fromJson(e.data() as Map<String, dynamic>))
        .toList());
  }

  Stream<List<QuizData>> streamQuizList(
      {String? classe, String? category, String? subCategory}) {
    if (subCategory != null) {
      return ref
          .where(QuizKeys.subcategoryId, isEqualTo: subCategory)
          .snapshots()
          .map((value) => value.docs
              .map((e) => QuizData.fromJson(e.data() as Map<String, dynamic>))
              .toList());
    } else if (category != null) {
      return ref
          .where(QuizKeys.categoryId, isEqualTo: category)
          .snapshots()
          .map((value) => value.docs
              .map((e) => QuizData.fromJson(e.data() as Map<String, dynamic>))
              .toList());
    }
    // TODO : Add classe filter
    // else if (classe != null) {
    //   return ref.where('classe', isEqualTo: classe).snapshots().map((value) =>
    //       value.docs
    //           .map((e) => QuizData.fromJson(e.data() as Map<String, dynamic>))
    //           .toList());
    // }
    return ref.snapshots().map((value) => value.docs
        .map((e) => QuizData.fromJson(e.data() as Map<String, dynamic>))
        .toList());
  }
}
