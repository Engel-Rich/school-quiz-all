import 'package:cloud_firestore/cloud_firestore.dart';
import '/../utils/ModelKeys.dart';

class QuizModel {
  String? categoryId;
  String? id;
  String? imageUrl;
  String? description;
  int? quizTime;
  int? minRequiredPoint;
  List<String>? questionRef;
  String? quizTitle;
  bool? isPremium;
  // String? onlineQuizCode;
  DateTime? startAt;
  DateTime? endAt;
  bool? isSpin;
  String? classe;

  QuizModel({
    this.categoryId,
    this.id,
    this.imageUrl,
    this.minRequiredPoint,
    this.questionRef,
    this.quizTitle,
    this.description,
    this.quizTime,
    this.isPremium,
    //  this.onlineQuizCode,
    this.endAt,
    this.startAt,
    this.classe,
    this.isSpin,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json[CommonKeys.id],
      categoryId: json[QuizKeys.categoryId],
      imageUrl: json[QuizKeys.imageUrl],
      minRequiredPoint: json[QuizKeys.minRequiredPoint],
      questionRef: json[QuizKeys.questionRef] != null
          ? new List<String>.from(json[QuizKeys.questionRef])
          : null,
      quizTitle: json[QuizKeys.quizTitle],
      description: json[QuizKeys.description],
      quizTime: json[QuizKeys.quizTime],
      isPremium: json[QuizKeys.isPremium],
      // onlineQuizCode: json[QuizKeys.onlineQuizCode],
      startAt: json[QuizKeys.startAt] != null
          ? (json[QuizKeys.startAt] as Timestamp).toDate()
          : null,
      endAt: json[QuizKeys.endAt] != null
          ? (json[QuizKeys.endAt] as Timestamp).toDate()
          : null,
      isSpin: json[QuizKeys.isSpin],
      classe: json['classe'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[CommonKeys.id] = this.id;
    data[QuizKeys.categoryId] = this.categoryId;
    data[QuizKeys.imageUrl] = this.imageUrl;
    data[QuizKeys.minRequiredPoint] = this.minRequiredPoint;
    data[QuizKeys.quizTitle] = this.quizTitle;
    data[QuizKeys.description] = this.description;
    data[QuizKeys.quizTime] = this.quizTime;
    data[QuizKeys.isPremium] = this.isPremium;
    // data[QuizKeys.onlineQuizCode] = this.onlineQuizCode;
    if (this.questionRef != null) {
      data[QuizKeys.questionRef] = this.questionRef;
    }
    data[QuizKeys.startAt] = this.startAt;
    data[QuizKeys.endAt] = this.endAt;
    data[QuizKeys.isSpin] = this.isSpin;
    data['classe'] = classe;
    return data;
  }
}
