import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizapp_flutter/services/ClasseService.dart';
import '/../main.dart';
import '/../screens/LoginScreen.dart';
import '/../screens/WalkThroughScreen.dart';
import '/../utils/colors.dart';
import '/../utils/constants.dart';
import '/../utils/images.dart';
import '/../utils/strings.dart';

import 'HomeScreen.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(scaffoldColor);
    await ClasseService.getClasseList();
    setState(() {});
    Future.delayed(
      Duration(seconds: 2),
      () {
        if (appStore.isLoggedIn) {
          HomeScreen().launch(context, isNewTask: true);
        } else {
          if (getBoolAsync(IS_FIRST_TIME, defaultValue: true)) {
            WalkThroughScreen().launch(context, isNewTask: true);
          } else {
            LoginScreen().launch(context, isNewTask: true);
          }
        }
      },
    );
    int themeModeIndex = getIntAsync(THEME_MODE_INDEX);
    if (themeModeIndex == ThemeModeSystem) {
      appStore.setDarkMode(
          MediaQuery.of(context).platformBrightness == Brightness.dark);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    setStatusBarColor(Theme.of(context).scaffoldBackgroundColor);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(appLogoImage, height: 150, width: 150),
            16.height,
            Text(lbl_online_quiz, style: boldTextStyle(size: 24)),
          ],
        ),
      ),
    );
  }
}
