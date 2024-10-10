import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:quizeapp/AppLocalizations.dart';
import 'package:quizeapp/firebase_options.dart';
import 'package:quizeapp/screens/SplashScreen.dart';
import 'package:quizeapp/services/AppSettingService.dart';
import 'package:quizeapp/services/CategoryService.dart';
import 'package:quizeapp/services/ClasseService.dart';
import 'package:quizeapp/services/ContestService.dart';
import 'package:quizeapp/services/DailyQuizServices.dart';
import 'package:quizeapp/services/PubliciteService.dart';
import 'package:quizeapp/services/QuestionServices.dart';
import 'package:quizeapp/services/QuizHistoryService.dart';
import 'package:quizeapp/services/QuizServices.dart';
import 'package:quizeapp/services/Settingservice.dart';
import 'package:quizeapp/services/TypeCategorieServices.dart';
import 'package:quizeapp/services/UserService.dart';
import 'package:quizeapp/services/abonnement_services.dart';
import 'package:quizeapp/store/AppStore.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';
import 'package:url_strategy/url_strategy.dart';

AppStore appStore = AppStore();

FirebaseFirestore db = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

UserService userService = UserService();
QuizHistoryService quizHistoryService = QuizHistoryService();
QuestionServices questionServices = QuestionServices();
CategoryService categoryService = CategoryService();
PubliciteServices publiciteServices = PubliciteServices();
ClassesServices classeService = ClassesServices();
TypeCategorieServices typeCategorieServices = TypeCategorieServices();
QuizServices quizServices = QuizServices();
ContestService contestService = ContestService();
DailyQuizServices dailyQuizServices = DailyQuizServices();
AppSettingService appSettingService = AppSettingService();
SettingsService settingsService = SettingsService();
AbonnementServices abonnementServices = AbonnementServices();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setPathUrlStrategy();

  defaultRadius = 6;
  defaultAppButtonRadius = 4;
  defaultAppBarElevation = 2.0;

  defaultAppButtonTextColorGlobal = colorPrimary;
  appButtonBackgroundColorGlobal = Colors.white;

  desktopBreakpointGlobal = 700.0;

  await initialize(
    aLocaleLanguageList: [
      LanguageDataModel(
          id: 1,
          name: 'English',
          languageCode: 'en',
          flag: 'assets/flags/ic_us.png'),
      LanguageDataModel(
          id: 2,
          name: 'Hindi',
          languageCode: 'hi',
          flag: 'assets/flags/ic_india.png'),
      LanguageDataModel(
          id: 3,
          name: 'Arabic',
          languageCode: 'ar',
          flag: 'assets/flags/ic_ar.png'),
      LanguageDataModel(
          id: 4,
          name: 'Spanish',
          languageCode: 'es',
          flag: 'assets/flags/ic_spain.png'),
      LanguageDataModel(
          id: 5,
          name: 'Afrikaans',
          languageCode: 'af',
          flag: 'assets/flags/ic_south_africa.png'),
      LanguageDataModel(
          id: 6,
          name: 'French',
          languageCode: 'fr',
          flag: 'assets/flags/ic_france.png'),
      LanguageDataModel(
          id: 7,
          name: 'German',
          languageCode: 'de',
          flag: 'assets/flags/ic_germany.png'),
      LanguageDataModel(
          id: 8,
          name: 'Indonesian',
          languageCode: 'id',
          flag: 'assets/flags/ic_indonesia.png'),
      LanguageDataModel(
          id: 9,
          name: 'Portuguese',
          languageCode: 'pt',
          flag: 'assets/flags/ic_portugal.png'),
      LanguageDataModel(
          id: 10,
          name: 'Turkish',
          languageCode: 'tr',
          flag: 'assets/flags/ic_turkey.png'),
      LanguageDataModel(
          id: 11,
          name: 'vietnam',
          languageCode: 'vi',
          flag: 'assets/flags/ic_vitnam.png'),
      LanguageDataModel(
          id: 12,
          name: 'Dutch',
          languageCode: 'nl',
          flag: 'assets/flags/ic_dutch.png'),
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

  defaultAppButtonShapeBorder =
      OutlineInputBorder(borderSide: BorderSide(color: colorPrimary));

  appStore.setLanguage(getStringAsync(LANGUAGE, defaultValue: defaultLanguage));
  appStore.setLoggedIn(getBoolAsync(IS_LOGGED_IN));

  if (appStore.isLoggedIn) {
    appStore.setUserId(getStringAsync(USER_ID));
    appStore.setAdmin(getBoolAsync(IS_ADMIN));
    appStore.setSuperAdmin(getBoolAsync(IS_SUPER_ADMIN));
    appStore.setFullName(getStringAsync(FULL_NAME));
    appStore.setUserEmail(getStringAsync(USER_EMAIL));
    appStore.setUserProfile(getStringAsync(PROFILE_IMAGE));
    appStore.setTester(getBoolAsync(IS_TEST_USER));
  }

  if (isWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.web,
    );
  }

  if (isMobile) {
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    MobileAds.instance.initialize();

    oneSignalData();
  }

  /*  if (isMobile) {
            await OneSignal.shared.init(
              mOneSignalAppId,
              iOSSettings: {OSiOSSettings.autoPrompt: false, OSiOSSettings.promptBeforeOpeningPushUrl: true, OSiOSSettings.inAppAlerts: false},
            );

            OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.notification);

            OneSignal.shared.getPermissionSubscriptionState().then((value) {
              log(value.jsonRepresentation());

              setValue(PLAYER_ID, value.subscriptionStatus.userId.validate());
            });
          }*/
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        title: mAppName,
        themeMode: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
        supportedLocales: LanguageDataModel.languageLocales(),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate
        ],
        localeResolutionCallback: (locale, supportedLocales) => locale,
        locale: Locale(appStore.selectedLanguageCode),
      ),
    );
  }
}
