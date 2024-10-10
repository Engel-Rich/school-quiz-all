import 'package:quizapp_flutter/main.dart';
import 'package:quizapp_flutter/models/abonnement_model.dart';
import 'package:quizapp_flutter/services/BaseService.dart';

class AbonnementServices extends BaseService {
  AbonnementServices() {
    ref = db.collection('Abonnements');
  }

  Future<List<AbonnementModel>> getAbonnement() async {
    return await ref.get().then((event) => event.docs
        .map((e) => AbonnementModel.fromJson(e.data() as Map<String, dynamic>))
        .toList());
  }

  Future<AbonnementModel> abonnementById(String id) async {
    return await ref.doc(id).get().then((value) {
      final data = value.data();
      return AbonnementModel.fromJson(data as Map<String, dynamic>);
    });
  }

  //
}
