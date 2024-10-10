import '../main.dart';
import '../models/QuizModel.dart';
import 'BaseService.dart';

class ContestService extends BaseService {
  ContestService() {
    ref = db.collection('contest');
  }

  Stream<List<QuizModel>> get getContest {
    return ref.snapshots().map((e) => e.docs.map((x) => QuizModel.fromJson(x.data() as Map<String, dynamic>)).toList());
  }

  Future<List<QuizModel>> getContestFuture() async {
    return await ref.get().then((value) => value.docs.map((e) => QuizModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<QuizModel>> upComingContest({DateTime? date}) {
    return ref.where("startAt", isGreaterThan: date).get().then((value) => value.docs.map((e) => QuizModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<QuizModel>> onGoingContest({DateTime? date}) {
    var data = ref.where("startAt", isLessThanOrEqualTo: date);
    return data.get().then((value) => value.docs.map((e) => QuizModel.fromJson(e.data() as Map<String, dynamic>)).toList());
    // return ref.where("startAt", isLessThan: date)
    //           .where("endAt", isGreaterThan: date).get().then((value) => value.docs.map((e) => QuizModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }

  Future<List<QuizModel>> endedContest({DateTime? date}) {
    return ref.where("endAt", isLessThan: date).get().then((value) => value.docs.map((e) => QuizModel.fromJson(e.data() as Map<String, dynamic>)).toList());
  }
}
