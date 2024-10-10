import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizapp_flutter/models/ClasseModel.dart';
import '/../AppLocalizations.dart';
import '/../utils/colors.dart';
import '/../utils/constants.dart';

// Include generated file
part 'AppStore.g.dart';

// This is the class used by rest of your codebase
class AppStore = _AppStore with _$AppStore;

// The store-class
abstract class _AppStore with Store {
  @observable
  bool isLoading = false;

  @observable
  String? userName = '';

  @observable
  ClasseModel? currentClasse;

  @observable
  bool isLoggedIn = false;

  @observable
  String? userProfileImage = '';

  @observable
  String? userId = '';

  @observable
  String? userClasse;

  @observable
  String? userEmail = '';

  @observable
  String? userAge = '';

  @observable
  String selectedLanguage = defaultLanguage;

  @observable
  AppLocalizations? appLocale;

  @observable
  bool isDarkMode = false;

  @action
  void setAppLocalization(BuildContext context) {
    appLocale = AppLocalizations.of(context);
  }

  String translate(String key) {
    return appLocale!.translate(key);
  }

  @action
  void setLanguage(String val) {
    selectedLanguage = val;
  }

  @action
  void setCurrentClasse(ClasseModel? val) {
    currentClasse = val;
  }

  @action
  void setLoading(bool value) {
    isLoading = value;
  }

  @action
  void setLoggedIn(bool value) {
    isLoggedIn = value;
  }

  @action
  void setName(String? name) {
    userName = name;
  }

  @action
  void setUserId(String? value) {
    userId = value;
  }

  @action
  void setUserClasse(String? value) {
    userClasse = value;
  }

  @action
  void setUserEmail(String? value) {
    userEmail = value;
  }

  @action
  void setUserAge(String? value) {
    userAge = value;
  }

  @action
  void setProfileImage(String? image) {
    userProfileImage = image;
  }

  @action
  Future<void> setDarkMode(bool aIsDarkMode) async {
    isDarkMode = aIsDarkMode;

    if (isDarkMode) {
      textPrimaryColorGlobal = Colors.white;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = scaffoldSecondaryDark;
      appButtonBackgroundColorGlobal = appButtonColorDark;
      shadowColorGlobal = Colors.white12;
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = Colors.white;
      appButtonBackgroundColorGlobal = Colors.white;
      shadowColorGlobal = Colors.black12;
    }
  }
}
