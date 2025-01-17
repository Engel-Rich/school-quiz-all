import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/AppLocalizations.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Constants.dart';

import '../models/QuestionData.dart';

part 'AppStore.g.dart';

class AppStore = _AppStore with _$AppStore;

abstract class _AppStore with Store {
  @observable
  bool isLoggedIn = false;

  @observable
  bool isAdmin = false;

  @observable
  bool isTester = false;

  @observable
  bool isSuperAdmin = false;

  @observable
  bool isNotificationOn = true;

  @observable
  bool isDarkMode = false;

  @observable
  bool isLoading = false;

  @observable
  String selectedLanguageCode = defaultLanguage;

  @observable
  String? userProfileImage = '';

  @observable
  String? userFullName = '';

  @observable
  String? userEmail = '';

  @observable
  String? classeModel;

  @observable
  String? userId = '';

  @observable
  String? oneSignalAppId = '';

  @observable
  String? oneSignalRestApi = '';

  @observable
  String? oneSignalChannelId = '';

  @observable
  AppLocalizations? appLocale;

  @observable
  List<QuestionData> selectedQuestionList = ObservableList<QuestionData>();

  @action
  void removeSelectedQuestion(QuestionData value) {
    selectedQuestionList.remove(value);
  }

  @action
  void addSelectedQuestion(QuestionData value) {
    selectedQuestionList.add(value);
  }

  @action
  void setAppLocalization(BuildContext context) {
    appLocale = AppLocalizations.of(context);
  }

  String translate(String key) {
    return appLocale!.translate(key);
  }

  @action
  void setClasseModel(String? model) {
    classeModel = model;
  }

  @action
  void setLanguage(String val) {
    selectedLanguageCode = val;
  }

  @action
  void setUserProfile(String? image) {
    userProfileImage = image;
  }

  @action
  void setUserId(String? val) {
    userId = val;
  }

  @action
  void setUserEmail(String? email) {
    userEmail = email;
  }

  @action
  void setFullName(String? name) {
    userFullName = name;
  }

  @action
  Future<void> setLoggedIn(bool val) async {
    isLoggedIn = val;
    await setValue(IS_LOGGED_IN, val);
  }

  @action
  void setLoading(bool val) {
    isLoading = val;
  }

  @action
  void setAdmin(bool val) {
    isAdmin = val;
  }

  @action
  void setSuperAdmin(bool val) {
    isSuperAdmin = val;
  }

  @action
  void setTester(bool val) {
    isTester = val;
    setValue(IS_TEST_USER, val);
  }

  @action
  void setNotification(bool val) {
    isNotificationOn = val;

    setValue(IS_NOTIFICATION_ON, val);

    if (isMobile) {
      //OneSignal.shared.setSubscription(val);
    }
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

      setStatusBarColor(scaffoldSecondaryDark);
    } else {
      textPrimaryColorGlobal = textPrimaryColor;
      textSecondaryColorGlobal = textSecondaryColor;

      defaultLoaderBgColorGlobal = Colors.white;
      appButtonBackgroundColorGlobal = Colors.white;
      shadowColorGlobal = Colors.black12;

      setStatusBarColor(Colors.white);
    }
  }

/* @action
  Future<void> setLanguage(String aSelectedLanguageCode) async {
    selectedLanguageCode = aSelectedLanguageCode;

    //language = languages.firstWhere((element) => element.languageCode == aSelectedLanguageCode);
    //await setValue(LANGUAGE, aSelectedLanguageCode);
  }*/
}
