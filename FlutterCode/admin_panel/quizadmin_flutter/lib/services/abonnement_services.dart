import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/abonnement_model.dart';
import 'package:quizeapp/services/BaseService.dart';

class AbonnementServices extends BaseService {
  AbonnementServices() {
    ref = db.collection('Abonnements');
  }

  Stream<List<AbonnementModel>> getAbonnement() {
    return ref.snapshots().map((event) => event.docs
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
