import 'package:firebase_auth/firebase_auth.dart';
import 'package:quizapp_flutter/main.dart';
import 'package:quizapp_flutter/models/subscription_model.dart';
import 'package:quizapp_flutter/services/BaseService.dart';
import 'package:collection/collection.dart';

class SubscriptionnService extends BaseService {
  SubscriptionnService() {
    ref = db.collection("Subscriptions");
  }

  Stream<SubscriptionModel?> getActiveSubcription() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return ref.where("userId", isEqualTo: userId).snapshots().map((data) {
      final subcriptionList =
          data.docs.map((e) => SubscriptionModel.fromMap(e.data())).toList();

      return subcriptionList
          .firstWhereOrNull((sub) => sub.datefin.isBefore(DateTime.now()));
    });
    //
  }
}
