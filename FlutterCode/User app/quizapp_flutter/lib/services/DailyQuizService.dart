import 'package:intl/intl.dart';
import '/../models/QuizModel.dart';
import '/../services/BaseService.dart';
import '/../utils/constants.dart';

import '../main.dart';

class DailyQuizService extends BaseService {
  DailyQuizService() {
    ref = db.collection('dailyQuiz');
  }

  Future<QuizModel> dailyQuiz() async {
    return await ref.doc(DateFormat(CurrentDateFormat).format(DateTime.now()) /*'06-05-2021'*/).get().then(
          (value) => QuizModel.fromJson(value.data() as Map<String, dynamic>),
        );
  }
}
