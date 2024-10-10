import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizapp_flutter/models/ClasseModel.dart';
import 'package:quizapp_flutter/services/ClasseService.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '/../models/UserModel.dart';
import '/../utils/ModelKeys.dart';
import '/../utils/constants.dart';

import '../components/OTPLoginComponent.dart';
import '../main.dart';

class AuthService {
  static FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleSignIn? buildGoogleSignInScope() {
    return GoogleSignIn(
      scopes: [
        'https://www.googleapis.com/auth/plus.me',
        'https://www.googleapis.com/auth/userinfo.email',
        'https://www.googleapis.com/auth/userinfo.profile',
      ],
    );
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future signInWithApple() async {
    try {
      String clientID = 'com.mundi.schoolquiz';
      // String redirectURL =
      //     "https://curly-ballistic-fine.glitch.me/callbacks/sign_in_with_apple";
      // final rawNonce = generateNonce();
      // final nonce = sha256ofString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        // nonce: Platform.isIOS ? nonce : null,
        webAuthenticationOptions: Platform.isIOS
            ? null
            : WebAuthenticationOptions(
                clientId: clientID,
                redirectUri: Uri.parse(
                  'https://bd-quiz-7c615.firebaseapp.com/__/auth/handler',
                ),
              ),
      );

      final AuthCredential appleAuthCredential =
          OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        // rawNonce: Platform.isIOS ? rawNonce : null,
        accessToken: Platform.isIOS ? null : appleCredential.authorizationCode,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(appleAuthCredential);

      final User user = userCredential.user!;
      print(user.displayName);
      print(user.email);

      await _auth.signOut();

      return await loginFromFirebaseUser(user, LoginTypeGoogle,
          fullName: user.displayName);
    } catch (e) {
      print("Error->" + e.toString());
      throw errorSomethingWentWrong;
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      AuthCredential credential = await getGoogleAuthCredential();
      UserCredential authResult = await _auth.signInWithCredential(credential);

      final User user = authResult.user!;

      await _auth.signOut();

      await buildGoogleSignInScope()?.signOut();

      return await loginFromFirebaseUser(user, LoginTypeGoogle);
    } catch (e) {
      print("Error->" + e.toString());
      throw errorSomethingWentWrong;
    }
  }

  Future<AuthCredential> getGoogleAuthCredential() async {
    GoogleSignInAccount? googleAccount =
        await (buildGoogleSignInScope()?.signIn());
    GoogleSignInAuthentication? googleAuthentication =
        await googleAccount!.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuthentication.idToken,
      accessToken: googleAuthentication.accessToken,
    );
    return credential;
  }

  Future<void> signUpWithEmailPassword({
    String? name,
    String? email,
    String? password,
    String? age,
    String? classe,
  }) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email!, password: password!);

    if (userCredential.user != null) {
      User currentUser = userCredential.user!;
      UserModel userModel = UserModel();

      /// Create user

      userModel.email = currentUser.email;
      userModel.classe = classe;
      userModel.id = currentUser.uid;
      userModel.name = name.validate();
      userModel.age = age.validate();
      userModel.password = password.validate();
      userModel.createdAt = DateTime.now();
      userModel.updatedAt = DateTime.now();
      userModel.photoUrl = currentUser.photoURL.validate();
      userModel.loginType = LoginTypeEmail;
      userModel.isAdmin = false;
      userModel.isTestUser = false;
      userModel.referCode = currentUser.uid.substring(0, 8).toUpperCase();
      //userModel.masterPwd = '';

      await userDBService
          .addDocumentWithCustomId(currentUser.uid, userModel.toJson())
          .then((value) async {
        log('Signed up');
        await signInWithEmailPassword(email: email, password: password)
            .then((value) {
//
        });
      }).catchError((e) {
        throw e;
      });
    } else {
      throw errorSomethingWentWrong;
    }
  }

  Future<void> signInWithEmailPassword(
      {required String email,
      required String password,
      String? displayName,
      String? age}) async {
    await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then(
      (value) async {
        return userDBService.getUserByEmail(email).then(
          (user) async {
            await setValue(USER_ID, user.id);
            await setValue(USER_DISPLAY_NAME, user.name);
            await setValue(USER_EMAIL, user.email);
            await setValue(PASSWORD, password);
            await setValue(USER_AGE, user.age.validate());
            await setValue(USER_POINTS, user.points.validate());
            await setValue(USER_PHOTO_URL, user.photoUrl.validate());
            // await setValue(USER_MASTER_PWD, user.masterPwd.validate());
            await setValue(LOGIN_TYPE, user.loginType.validate());
            await setValue(IS_LOGGED_IN, true);
            // await setValue(USER_CLASSE, user.classe);
            ClasseModel? classe = user.classe != null
                ? await ClasseService.getClasseById(user.classe!)
                : null;
            await setValue(USER_CLASSE, classe?.toJson());
            appStore.setUserClasse(classe?.toJson());

            appStore.setLoggedIn(true);
            appStore.setUserId(user.id);
            appStore.setName(user.name);
            appStore.setProfileImage(user.photoUrl);
            appStore.setUserEmail(user.email);
            appStore.setUserAge(user.age);
            // appStore.setUserClasse(user.classe);

            await userDBService.updateDocument(
                {CommonKeys.updatedAt: DateTime.now()}, user.id);
          },
        ).catchError(
          (e) {
            throw e;
          },
        );
      },
    ).catchError(
      (error) async {
        if (!await isNetworkAvailable()) {
          throw 'Please check network connection';
        }
        log(error.toString());
        throw 'Enter valid email and password';
      },
    );
  }

  Future<void> logout() async {
    await removeKey(USER_DISPLAY_NAME);
    if (getBoolAsync(IS_REMEMBERED) == false) {
      await removeKey(USER_EMAIL);
      await removeKey(PASSWORD);
    }
    await removeKey(USER_PHOTO_URL);
    await removeKey(IS_LOGGED_IN);
    await removeKey(LOGIN_TYPE);
    await removeKey(USER_AGE);
    await removeKey(USER_CLASSE);
    await removeKey(USER_POINTS);

    appStore.setLoggedIn(false);
    appStore.setUserId('');
    appStore.setName('');
    appStore.setUserEmail('');
    appStore.setProfileImage('');
    appStore.setUserClasse(null);
  }

  Future<void> setUserDetailPreference(UserModel user) async {
    await setValue(USER_ID, user.id);
    await setValue(USER_DISPLAY_NAME, user.name);
    await setValue(USER_EMAIL, user.email);
    await setValue(USER_POINTS, user.points);
    await setValue(USER_AGE, user.age.validate());
    await setValue(USER_PHOTO_URL, user.photoUrl.validate());
    await setValue(IS_TESTER, user.isTestUser);
    ClasseModel? classe = user.classe != null
        ? await ClasseService.getClasseById(user.classe!)
        : null;
    await setValue(USER_CLASSE, classe?.toJson());
    appStore.setUserClasse(classe?.toJson());
    appStore.setLoggedIn(true);
    appStore.setUserId(user.id);
    appStore.setName(user.name);
    appStore.setProfileImage(user.photoUrl);
    appStore.setUserEmail(user.email);
    appStore.setUserAge(user.age);
    await setValue(IS_LOGGED_IN, true);
  }

  Future<UserModel> loginFromFirebaseUser(User currentUser, String loginType,
      {String? fullName}) async {
    UserModel userModel = UserModel();

    if (await userDBService.isUserExist(currentUser.email, loginType)) {
      await userDBService.getUserByEmail(currentUser.email).then(
        (user) async {
          log('value');
          userModel = user;
        },
      ).catchError(
        (e) {
          throw e;
        },
      );
    } else {
      userModel.id = currentUser.uid;
      userModel.email = currentUser.email;
      userModel.photoUrl = currentUser.photoURL;
      userModel.name = (currentUser.displayName) ?? fullName;
      userModel.loginType = loginType;
      userModel.updatedAt = DateTime.now();
      userModel.createdAt = DateTime.now();

      await userDBService
          .addDocumentWithCustomId(currentUser.uid, userModel.toJson())
          .then(
        (value) {
          //
        },
      ).catchError(
        (e) {
          throw e;
        },
      );
    }

    await setValue(LOGIN_TYPE, loginType);

    appStore.setLoggedIn(true);
    appStore.setUserId(currentUser.uid);
    appStore.setName(currentUser.displayName);
    appStore.setProfileImage(currentUser.photoURL);
    appStore.setUserEmail(currentUser.email);

    await setUserDetailPreference(userModel);

    return userModel;
  }

  Future<void> forgotPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email).then(
      (value) {
        //
      },
    ).catchError(
      (error) {
        throw error.toString();
      },
    );
  }

  Future<void> resetPassword({required String newPassword}) async {
    await _auth.currentUser!.updatePassword(newPassword).then(
      (value) {
        //
      },
    ).catchError(
      (error) {
        throw error.toString();
      },
    );
  }

  Future deleteUserPermanent({String? uid}) async {
    FirebaseAuth.instance.currentUser!.delete();
    await removeKey(USER_DISPLAY_NAME);
    await removeKey(USER_EMAIL);
    await removeKey(PASSWORD);
    await removeKey(USER_PHOTO_URL);
    await removeKey(IS_LOGGED_IN);
    await removeKey(LOGIN_TYPE);
    await removeKey(USER_AGE);
    await removeKey(USER_CLASSE);
    await removeKey(USER_POINTS);

    appStore.setLoggedIn(false);
    appStore.setUserId('');
    appStore.setName('');
    appStore.setUserEmail('');
    appStore.setProfileImage('');
    await userDBService.removeDocument(uid!).then((value) async {
      _auth.currentUser!.delete();
      await _auth.signOut();
    }).catchError((e) {
      log(e);
    });
  }

  Future<void> loginWithOTP(BuildContext context, String phoneNumber) async {
    return await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {},
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          toast('The provided phone number is not valid.');
          throw 'The provided phone number is not valid.';
        } else {
          toast(e.toString());
          throw e.toString();
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        finish(context);
        await showDialog(
            context: context,
            builder: (context) => OTPDialog(
                verificationId: verificationId,
                isCodeSent: true,
                phoneNumber: phoneNumber),
            barrierDismissible: false);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        //
      },
    );
  }
}
