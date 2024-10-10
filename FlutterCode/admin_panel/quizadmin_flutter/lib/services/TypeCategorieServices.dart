import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/CategorieTypeModel.dart';
import 'package:quizeapp/services/BaseService.dart';

class TypeCategorieServices extends BaseService {
  TypeCategorieServices() {
    ref = db.collection('TypeDeCategorie');
  }

  Future<bool> createTypeCategorie(TypeCategorie typeCategorie) async {
    try {
      typeCategorie.createdAt = DateTime.now();
      typeCategorie.updatedAt = DateTime.now();
      final id = ref.doc().id;
      typeCategorie.id = id;
      await ref.doc(id).set(typeCategorie.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTypeCategorie(
      {required TypeCategorie typeCategorie,
      required String typeCategorieId}) async {
    try {
      typeCategorie.updatedAt = DateTime.now();
      await ref.doc(typeCategorieId).update(typeCategorie.toMap());
      return true;
    } catch (e) {
      return false;
    }
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
