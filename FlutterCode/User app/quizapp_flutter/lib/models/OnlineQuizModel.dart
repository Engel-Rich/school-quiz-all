import 'package:cloud_firestore/cloud_firestore.dart';
import '/../models/QuestionModel.dart';
import '/../utils/ModelKeys.dart';

class OnlineQuizModel {
  List<QuestionModel>? questions;
  String? id;

  // String? imageUrl;
  String? quizTitle;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? description;
  int? onlineQuizCode;
  bool? expireQuizStatus;

  OnlineQuizModel({
    this.id,
    this.questions,
    this.quizTitle,
    this.updatedAt,
    this.createdAt,
    this.description,
    this.onlineQuizCode,
    this.expireQuizStatus,
  });

  factory OnlineQuizModel.fromJson(Map<String, dynamic> json) {
    return OnlineQuizModel(
      questions: json[QuizKeys.questions] != null ? (json['questions'] as List).map((i) => QuestionModel.fromJson(i)).toList() : null,
      id: json[CommonKeys.id],
      //  imageUrl: json['imageUrl'],
      quizTitle: json[QuizKeys.quizTitle],
      createdAt: json[CommonKeys.createdAt] != null ? (json[CommonKeys.createdAt] as Timestamp).toDate() : null,
      updatedAt: json[CommonKeys.updatedAt] != null ? (json[CommonKeys.updatedAt] as Timestamp).toDate() : null,
      description: json[QuizKeys.description],
      onlineQuizCode: json[QuizKeys.onlineQuizCode],
      expireQuizStatus: json[QuizKeys.expireQuizStatus],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[CommonKeys.id] = this.id;
    // data['imageUrl'] = this.imageUrl;
    data[QuizKeys.quizTitle] = this.quizTitle;
    data[CommonKeys.createdAt] = this.createdAt;
    data[CommonKeys.updatedAt] = this.updatedAt;
    data[QuizKeys.description] = this.description;
    data[QuizKeys.onlineQuizCode] = this.onlineQuizCode;
    data[QuizKeys.expireQuizStatus] = this.expireQuizStatus;
    if (this.questions != null) {
      data[QuizKeys.questions] = this.questions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
