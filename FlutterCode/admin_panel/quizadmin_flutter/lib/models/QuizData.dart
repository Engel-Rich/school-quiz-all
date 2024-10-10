import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

class QuizData {
  List<String?>? questionRef;
  int? minRequiredPoint;
  String? id;
  String? imageUrl;
  String? quizTitle;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? categoryId;
  int? quizTime;
  String? description;
  String? subCategoryId;
  DateTime? startAt;
  DateTime? endAt;
  bool? isSpin;

  QuizData({
    this.id,
    this.questionRef,
    this.minRequiredPoint,
    this.imageUrl,
    this.quizTitle,
    this.updatedAt,
    this.createdAt,
    this.categoryId,
    this.quizTime,
    this.description,
    this.subCategoryId,
    this.endAt,
    this.startAt,
    this.isSpin,
  });

  factory QuizData.fromJson(Map<String, dynamic> json) {
    return QuizData(
      questionRef: json[QuizKeys.questionRef].cast<String>(),
      minRequiredPoint: json[QuizKeys.minRequiredPoint],
      id: json[CommonKeys.id],
      imageUrl: json[QuizKeys.imageUrl],
      quizTitle: json[QuizKeys.quizTitle],
      createdAt: json[CommonKeys.createdAt] != null
          ? (json[CommonKeys.createdAt] as Timestamp).toDate()
          : null,
      updatedAt: json[CommonKeys.updatedAt] != null
          ? (json[CommonKeys.updatedAt] as Timestamp).toDate()
          : null,
      categoryId:
          json[QuizKeys.categoryId] != null ? json[QuizKeys.categoryId] : '',
      quizTime: json[QuizKeys.quizTime],
      description: json[QuizKeys.description],
      subCategoryId: json[QuizKeys.subcategoryId],
      startAt: json[QuizKeys.startAt] != null
          ? (json[QuizKeys.startAt] as Timestamp).toDate()
          : null,
      endAt: json[QuizKeys.endAt] != null
          ? (json[QuizKeys.endAt] as Timestamp).toDate()
          : null,
      isSpin: json[QuizKeys.isSpin],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[CommonKeys.id] = this.id;
    data[QuizKeys.questionRef] = this.questionRef;
    data[QuizKeys.minRequiredPoint] = this.minRequiredPoint;
    data[QuizKeys.imageUrl] = this.imageUrl;
    data[QuizKeys.quizTitle] = this.quizTitle;
    data[CommonKeys.createdAt] = this.createdAt;
    data[CommonKeys.updatedAt] = this.updatedAt;
    data[QuizKeys.categoryId] = this.categoryId;
    data[QuizKeys.quizTime] = this.quizTime;
    data[QuizKeys.description] = this.description;
    data[QuizKeys.subcategoryId] = this.subCategoryId;
    data[QuizKeys.startAt] = this.startAt;
    data[QuizKeys.endAt] = this.endAt;
    data[QuizKeys.isSpin] = this.isSpin;
    return data;
  }
}
