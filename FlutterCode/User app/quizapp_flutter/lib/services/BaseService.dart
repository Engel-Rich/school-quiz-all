import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '/../utils/ModelKeys.dart';

abstract class BaseService {
  late CollectionReference ref;

  Future<DocumentReference> addDocument(Map<String, dynamic> data) async {
    var doc = await ref.add(data);
    doc.update({CommonKeys.id: doc.id});
    return doc;
  }

  Future<DocumentReference> addDocumentWithCustomId(String id, Map data) async {
    var doc = ref.doc(id);

    return await doc.set(data).then((value) {
      log('Added: $data');

      return doc;
    }).catchError((e) {
      log(e);
      throw e;
    });
  }

  Future<void> updateDocument(Map<String, dynamic> data, String? id) => ref.doc(id).update(data);

  Future removeDocument(String uid) => ref.doc(uid).delete();
}
