import 'package:quizapp_flutter/models/CategorieTypeModel.dart';
import 'package:quizapp_flutter/services/BaseService.dart';

import '../main.dart';

class TypeCategorieServices extends BaseService {
  TypeCategorieServices() {
    ref = db.collection('TypeDeCategorie');
  }

  Future<List<TypeCategorie>> getTypeCategorieList() async {
    return await ref.get().then((value) {
      return value.docs.map((e) {
        return TypeCategorie.fromMap(e.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Stream<List<TypeCategorie>> getTypeCategorieListStream() {
    return ref.snapshots().map((value) {
      return value.docs.map((e) {
        return TypeCategorie.fromMap(e.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<TypeCategorie?> getTypecategorieById(
      {required String typeCategorieId}) async {
    try {
      return await ref.doc(typeCategorieId).get().then(
            (value) =>
                TypeCategorie.fromMap(value.data() as Map<String, dynamic>),
          );
    } catch (e) {
      return null;
    }
  }
}
