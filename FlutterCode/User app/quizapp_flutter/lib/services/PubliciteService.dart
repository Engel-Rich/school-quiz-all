import 'package:quizapp_flutter/models/Publicite.dart';

import '../main.dart';
import 'BaseService.dart';

class PubliciteServices extends BaseService {
  PubliciteServices() {
    ref = db.collection('publicite');
  }

  Stream<List<Publicite>> allPublicite({bool? isACtive}) {
    return (isACtive != true
            ? ref.snapshots()
            : ref.where("isactive", isEqualTo: true).snapshots())
        .map((event) {
      return event.docs.map((publiciteData) {
        final publicite = publiciteData.data();
        return Publicite.fromMap(publicite as Map<String, dynamic>);
      }).toList();
    });
  }

  Future<List<Publicite>> allPubliciteActive() async {
    return await ref.where("isactive", isEqualTo: true).get().then((event) {
      return event.docs.map((publiciteData) {
        final publicite = publiciteData.data();
        return Publicite.fromMap(publicite as Map<String, dynamic>);
      }).toList();
    });
  }
}
