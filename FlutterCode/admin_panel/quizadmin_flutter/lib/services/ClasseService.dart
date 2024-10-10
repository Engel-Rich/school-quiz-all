import 'dart:async';

import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/ClasseModel.dart';
import 'package:quizeapp/services/BaseService.dart';

class ClassesServices extends BaseService {
  ClassesServices() {
    ref = db.collection('classes');
  }

  Stream<List<ClasseModel>> classes() {
    return ref.snapshots().map(
          (x) => x.docs
              .map((y) => ClasseModel.fromMap(y.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  Future<List<ClasseModel>> classesList() async {
    return ref.get().then(
          (x) => x.docs
              .map((y) => ClasseModel.fromMap(y.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  Stream<ClasseModel?> classeById(String? idclasse) =>
      ref.doc(idclasse).snapshots().map(
            (event) =>
                ClasseModel.fromMap(event.data() as Map<String, dynamic>),
          );

  Future saveClasse(ClasseModel model) async {
    await ref.doc().set(model.toMap());
  }

  //
}
