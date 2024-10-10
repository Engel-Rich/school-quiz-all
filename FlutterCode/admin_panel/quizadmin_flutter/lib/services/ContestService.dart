import '../main.dart';
import '../models/QuizData.dart';
import 'BaseService.dart';

class ContestService extends BaseService {
  ContestService() {
    ref = db.collection('contest');
  }

  Stream<List<QuizData>> get getContest {
    return ref.snapshots().map((e) => e.docs.map((x) => QuizData.fromJson(x.data() as Map<String, dynamic>)).toList());
  }

  Future<List<QuizData>> getContestFuture() async {
    return await ref.get().then((value) => value.docs.map((e) => QuizData.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<QuizData>> upComingContest({DateTime? date}) {
    return ref.where("startAt", isGreaterThan: date).get().then((value) => value.docs.map((e) => QuizData.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<QuizData>> onGoingContest({DateTime? date}) {
    var data = ref.where("startAt", isLessThanOrEqualTo: date);
    return data.get().then((value) => value.docs.map((e) => QuizData.fromJson(e.data() as Map<String, dynamic>)).toList());
    // return ref.where("startAt", isLessThan: date)
    //           .where("endAt", isGreaterThan: date).get().then((value) => value.docs.map((e) => QuizData.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<QuizData>> endedContest({DateTime? date}) {
    return ref.where("endAt", isLessThan: date).get().then((value) => value.docs.map((e) => QuizData.fromJson(e.data() as Map<String, dynamic>)).toList());
  }
}
