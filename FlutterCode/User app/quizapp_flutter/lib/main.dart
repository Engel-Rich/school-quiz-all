// import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:quizapp_flutter/services/PubliciteService.dart';
import 'package:quizapp_flutter/services/TypeCategorieServices.dart';
import 'package:quizapp_flutter/store/controllers/subscription_controller.dart';
// import 'package:quizapp_flutter/models/ClasseModel.dart';

import '/../AppLocalizations.dart';
import '/../screens/SplashScreen.dart';
import '/../services/AuthService.dart';
import '/../services/CategoryService.dart';
import '/../services/ContestService.dart';
import '/../services/DailyQuizService.dart';
import '/../services/OnlineQuizServices.dart';
import '/../services/QuestionService.dart';
import '/../services/QuizHistoryService.dart';
import '/../services/QuizService.dart';
import '/../services/SettingService.dart';
import '/../services/userDBService.dart';
import '/../store/AppStore.dart';
import '/../utils/AppTheme.dart';
import '/../utils/constants.dart';

AppStore appStore = AppStore();

FirebaseFirestore db = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

AuthService authService = AuthService();
UserDBService userDBService = UserDBService();
CategoryService categoryService = CategoryService();
QuestionService questionService = QuestionService();
ContestService contestService = ContestService();
QuizService quizService = QuizService();
QuizHistoryService quizHistoryService = QuizHistoryService();
DailyQuizService dailyQuizService = DailyQuizService();
AppSettingService appSettingService = AppSettingService();
OnlineQuizServices onlineQuizServices = OnlineQuizServices();
TypeCategorieServices typeCategorieServices = TypeCategorieServices();
PubliciteServices publiciteServices = PubliciteServices();

bool bannerReady = false;
bool interstitialReady = false;
bool rewarded = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp().then((value) async {
    MobileAds.instance.initialize();
  });

  await initialize(
    aLocaleLanguageList: [
      LanguageDataModel(
          id: 1,
          name: 'English',
          languageCode: 'en',
          flag: 'images/flag/ic_us.png'),
      LanguageDataModel(
          id: 2,
          name: 'Hindi',
          languageCode: 'hi',
          flag: 'images/flag/ic_india.png'),
      LanguageDataModel(
          id: 3,
          name: 'Arabic',
          languageCode: 'ar',
          flag: 'images/flag/ic_ar.png'),
      LanguageDataModel(
          id: 4,
          name: 'Spanish',
          languageCode: 'es',
          flag: 'images/flag/ic_spain.png'),
      LanguageDataModel(
          id: 5,
          name: 'Afrikaans',
          languageCode: 'af',
          flag: 'images/flag/ic_south_africa.png'),
      LanguageDataModel(
          id: 6,
          name: 'French',
          languageCode: 'fr',
          flag: 'images/flag/ic_france.png'),
      LanguageDataModel(
          id: 7,
          name: 'German',
          languageCode: 'de',
          flag: 'images/flag/ic_germany.png'),
      LanguageDataModel(
          id: 8,
          name: 'Indonesian',
          languageCode: 'id',
          flag: 'images/flag/ic_indonesia.png'),
      LanguageDataModel(
          id: 9,
          name: 'Portuguese',
          languageCode: 'pt',
          flag: 'images/flag/ic_portugal.png'),
      LanguageDataModel(
          id: 10,
          name: 'Turkish',
          languageCode: 'tr',
          flag: 'images/flag/ic_turkey.png'),
      LanguageDataModel(
          id: 11,
          name: 'vietnam',
          languageCode: 'vi',
          flag: 'images/flag/ic_vitnam.png'),
      LanguageDataModel(
          id: 12,
          name: 'Dutch',
          languageCode: 'nl',
          flag: 'images/flag/ic_dutch.png'),
    ],
  );

  selectedLanguageDataModel =
      getSelectedLanguageModel(defaultLanguage: defaultLanguage);
  if (selectedLanguageDataModel != null) {
    appStore.setLanguage(selectedLanguageDataModel!.languageCode.validate());
  } else {
    selectedLanguageDataModel = localeLanguageList.first;
    appStore.setLanguage(selectedLanguageDataModel!.languageCode.validate());
  }
  defaultRadius = 12.0;
  defaultAppButtonRadius = 12.0;
  setOrientationPortrait();

  appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));
  if (appStore.isLoggedIn) {
    appStore.setUserId(getStringAsync(USER_ID));
    appStore.setName(getStringAsync(USER_DISPLAY_NAME));
    appStore.setUserEmail(getStringAsync(USER_EMAIL));
    appStore.setProfileImage(getStringAsync(USER_PHOTO_URL));
    appStore.setUserAge(getStringAsync(USER_AGE));
    if (getStringAsync(USER_CLASSE).isNotEmpty)
      appStore.setUserClasse(getStringAsync(USER_CLASSE));
  }
  int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
  if (themeModeIndex == ThemeModeLight) {
    appStore.setDarkMode(false);
  } else if (themeModeIndex == ThemeModeDark) {
    appStore.setDarkMode(true);
  }
  //
  // await OneSignal.shared.setAppId(mOneSignalAppId);
  // OneSignal.shared.consentGranted(true);
  // OneSignal.shared.promptUserForPushNotificationPermission();
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.Debug.setAlertLevel(OSLogLevel.none);
  OneSignal.consentRequired(false);

  OneSignal.initialize(mOneSignalAppId);
  OneSignal.User.pushSubscription.optIn();
  OneSignal.Notifications.permission;

  Get.put(SubscriptionController());
  //

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => GetMaterialApp(
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: MyBehavior(),
            child: child!,
          );
        },
        title: mAppName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: SplashScreen(),
        locale: Locale(appStore.selectedLanguage),
        supportedLocales: LanguageDataModel.languageLocales(),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
      ),
    );
  }
}

class MyBehavior extends ScrollBehavior {
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
