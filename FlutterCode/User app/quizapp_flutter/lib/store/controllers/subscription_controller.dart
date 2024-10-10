import 'dart:developer';

import 'package:get/get.dart';
import 'package:quizapp_flutter/models/subscription_model.dart';
import 'package:quizapp_flutter/services/subscriptionn_service.dart';

class SubscriptionController extends GetxController {
  Rx<SubscriptionModel?> currentSubscription = Rx(null);

  final SubscriptionnService subscriptionnService = SubscriptionnService();

  static SubscriptionController get to => Get.find();

  initSubcription() {
    subscriptionnService.getActiveSubcription().listen((data) {
      log("Listen Subscription: $data");
      currentSubscription.value = data;
      update();
    });
  }
}
