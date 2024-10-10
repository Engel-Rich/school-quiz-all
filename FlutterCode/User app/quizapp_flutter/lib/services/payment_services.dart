import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizapp_flutter/models/abonnement_model.dart';

const String publicSandBoxKey =
    "pk_test.mjkH1lLs4iuDo9mb5xnJUtpPvtJfFSpSDhZmwdAkcQtGVvIZ9u5n20w7IV4RU0bUm9C8PwICMBgj6jbgLJRsdhRlb5LtNiik228W6kULu2RU0OroqGCbKNn9NlG29";

const String paymentUrl = " https://api.notchpay.co";
const String paymentStartUrl = "api.notchpay.co/payments";

class PaymentServices {
  static Dio _dio = Dio();

  static Future initPayment(AbonnementModel abonnement) async {
    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': publicSandBoxKey
      };

      final data = {
        "amount": abonnement.price,
        "currency": "XAF",
        "description": abonnement.name,
        "customer": {
          'email': "customer@email.com",
          'name': "${FirebaseAuth.instance.currentUser?.displayName}",
          "country": "CM",
        },
        "sandbox": true,
        "reference": "ref-${DateTime.now().millisecondsSinceEpoch}",
        "callback_url": "https://api.notchpay.co/callback",
      };
    } on DioException catch (e) {
      switch (e.response?.statusCode) {
        case 429:
          toast("Trop de tentative");
          break;
        default:
          toast("Erreur de paiement");
          break;
      }
    }
  }

  static Future<Response?> authentication(String reference) async {
    try {
      final response = await _dio.get(
        paymentUrl,
        options: Options(headers: {"Authorization": publicSandBoxKey}),
      );
      return response;
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        toast("Trop de tentative");
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
    return null;
  }

  //
}

class NotchPayPaymentInitResponse {
  final String? status;
  final String? message;
  final int? code;
  final Transaction? transaction;
  final String? authorizationUrl;

  NotchPayPaymentInitResponse({
    this.status,
    this.message,
    this.code,
    this.transaction,
    this.authorizationUrl,
  });

  factory NotchPayPaymentInitResponse.fromJson(Map<String, dynamic> json) {
    return NotchPayPaymentInitResponse(
      status: json['status'] as String?,
      message: json['message'] as String?,
      code: json['code'] as int?,
      transaction: json['transaction'] != null
          ? Transaction.fromJson(json['transaction'] as Map<String, dynamic>)
          : null,
      authorizationUrl: json['authorization_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'code': code,
      'transaction': transaction?.toJson(),
      'authorization_url': authorizationUrl,
    };
  }
}

class Transaction {
  final int? amount;
  final int? amountTotal;
  final bool? sandbox;
  final int? fee;
  final int? convertedAmount;
  final String? customer;
  final String? description;
  final String? reference;
  final String? status;
  final String? currency;
  final String? geo;
  final String? createdAt;
  final String? updatedAt;

  Transaction({
    this.amount,
    this.amountTotal,
    this.sandbox,
    this.fee,
    this.convertedAmount,
    this.customer,
    this.description,
    this.reference,
    this.status,
    this.currency,
    this.geo,
    this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      amount: json['amount'] as int?,
      amountTotal: json['amount_total'] as int?,
      sandbox: json['sandbox'] as bool?,
      fee: json['fee'] as int?,
      convertedAmount: json['converted_amount'] as int?,
      customer: json['customer'] as String?,
      description: json['description'] as String?,
      reference: json['reference'] as String?,
      status: json['status'] as String?,
      currency: json['currency'] as String?,
      geo: json['geo'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'amount_total': amountTotal,
      'sandbox': sandbox,
      'fee': fee,
      'converted_amount': convertedAmount,
      'customer': customer,
      'description': description,
      'reference': reference,
      'status': status,
      'currency': currency,
      'geo': geo,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
