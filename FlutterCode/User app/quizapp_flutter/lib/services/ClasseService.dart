import 'package:quizapp_flutter/main.dart';
import 'package:quizapp_flutter/models/ClasseModel.dart';

class ClasseService {
  static List<ClasseModel> classeModelList = [];

  static Future getClasseList() async {
    return await db.collection('classes').get().then((value) {
      final data = value.docs;
      final liste =
          data.map((classe) => ClasseModel.fromMap(classe.data())).toList();
      classeModelList = liste;
    });
  }

  static Future<ClasseModel?> getClasseById(String idClasse) async =>
      db.collection('classes').doc(idClasse).get().then((value) {
        return ClasseModel.fromMap(value.data() as Map<String, dynamic>);
      });
}
