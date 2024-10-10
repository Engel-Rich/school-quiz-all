import 'package:cloud_firestore/cloud_firestore.dart';
import '/../models/UserModel.dart';
import '/../utils/ModelKeys.dart';

import '../main.dart';
import 'BaseService.dart';

class UserDBService extends BaseService {
  UserDBService() {
    ref = db.collection('users');
  }

  Future<UserModel> getUserById(String id) {
    return ref.where(CommonKeys.id, isEqualTo: id).limit(1).get().then(
      (res) {
        if (res.docs.isNotEmpty) {
          return UserModel.fromJson(
              res.docs.first.data() as Map<String, dynamic>);
        } else {
          throw 'User not found';
        }
      },
    );
  }

  Future<UserModel> getUserByEmail(String? email) {
    return ref.where(UserKeys.email, isEqualTo: email).limit(1).get().then(
      (res) {
        if (res.docs.isNotEmpty) {
          return UserModel.fromJson(
              res.docs.first.data() as Map<String, dynamic>);
        } else {
          throw 'User not found';
        }
      },
    );
  }

  Future<bool> isUserExist(String? email, String loginType) async {
    Query query = ref
        .limit(1)
        .where('loginType', isEqualTo: loginType)
        .where('email', isEqualTo: email);

    var res = await query.get();

    // ignore: unnecessary_null_comparison
    if (res.docs != null) {
      return res.docs.length == 1;
    } else {
      return false;
    }
  }

  Future<bool> isUserExists(String? id) async {
    return await getUserByEmail(id).then(
      (value) {
        return true;
      },
    ).catchError(
      (e) {
        return false;
      },
    );
  }

  Future<UserModel> loginUser(String email, String password) async {
    var data = await ref
        .where(UserKeys.email, isEqualTo: email)
        .where(UserKeys.password, isEqualTo: password)
        .limit(1)
        .get();

    if (data.docs.isNotEmpty) {
      return UserModel.fromJson(data.docs.first.data() as Map<String, dynamic>);
    } else {
      throw 'User not found';
    }
  }

  Future<List<UserModel>> userByPoints() async {
    return await ref.orderBy("points", descending: true).get().then((event) =>
        event.docs
            .map((e) => UserModel.fromJson(e.data() as Map<String, dynamic>))
            .toList());
  }

  Future<UserModel> getUserByReferCode(String referCode) {
    return ref
        .where(UserKeys.referCode, isEqualTo: referCode)
        .limit(1)
        .get()
        .then(
      (res) {
        if (res.docs.isNotEmpty) {
          return UserModel.fromJson(
              res.docs.first.data() as Map<String, dynamic>);
        } else {
          throw 'User not found';
        }
      },
    );
  }

  Future<UserModel> userByMobileNumber(String? phone) async {
    return await ref
        .where('mobile', isEqualTo: phone)
        .limit(1)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        return UserModel.fromJson(
            value.docs.first.data() as Map<String, dynamic>);
      } else {
        throw 'EXCEPTION_NO_USER_FOUND';
      }
    });
  }
}
