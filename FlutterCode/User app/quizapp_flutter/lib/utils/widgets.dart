// ignore_for_file: body_might_complete_normally_catch_error

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../utils/colors.dart';
import '/../utils/constants.dart';
import '/../utils/images.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

InputDecoration inputDecoration({String? hintText}) {
  return InputDecoration(
    filled: true,
    hintText: hintText != null ? hintText : '',
    hintStyle: secondaryTextStyle(),
    fillColor: appStore.isDarkMode
        ? scaffoldSecondaryDark
        : Colors.grey.withOpacity(0.15),
    counterText: '',
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(color: Colors.transparent)),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(color: Colors.red)),
    disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(color: Colors.transparent)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(color: Colors.transparent)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(color: Colors.transparent)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(color: Colors.red)),
    alignLabelWithHint: true,
    isDense: true,
    // enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(defaultRadius)),
    // focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.transparent), borderRadius: BorderRadius.circular(defaultRadius)),
    // errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red), borderRadius: BorderRadius.circular(defaultRadius)),
  );
}

Widget gradientButton(
    {required String text,
    Function? onTap,
    bool isFullWidth = false,
    required BuildContext context,
    Color? color}) {
  return Container(
    width: isFullWidth ? context.width() : null,
    padding: EdgeInsets.only(left: 30, right: 30),
    height: 50,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [colorPrimary, colorSecondary],
        begin: FractionalOffset.centerLeft,
        end: FractionalOffset.centerRight,
      ),
      borderRadius: BorderRadius.circular(defaultRadius),
      //color: color
    ),
    child: TextButton(
      style: TextButton.styleFrom(backgroundColor: color),
      child: Text(
        text,
        style: boldTextStyle(color: white),
      ),
      onPressed: onTap as void Function()?,
    ),
  );
}

Widget cachedImage(String url,
    {double? height,
    double? width,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    bool usePlaceholderIfUrlEmpty = true,
    double? radius}) {
  if (url.validate().isEmpty) {
    return placeHolderWidget(
        height: height,
        width: width,
        fit: fit,
        alignment: alignment,
        radius: radius);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: fit,
      alignment: alignment as Alignment? ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            radius: radius);
      },
      placeholder: (_, s) {
        if (!usePlaceholderIfUrlEmpty) return SizedBox();
        return placeHolderWidget(
            height: height,
            width: width,
            fit: fit,
            alignment: alignment,
            radius: radius);
      },
    );
  } else {
    return Image.asset(
      url,
      height: height,
      width: width,
      fit: fit,
      alignment: alignment ?? Alignment.center,
    ).cornerRadiusWithClipRRect(radius ?? defaultRadius);
  }
}

Widget placeHolderWidget(
    {double? height,
    double? width,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    double? radius}) {
  return Image.asset(
    PlaceholderImage,
    height: height,
    width: width,
    fit: fit ?? BoxFit.cover,
    alignment: alignment ?? Alignment.center,
  ).cornerRadiusWithClipRRect(radius ?? defaultRadius);
}

Future<void> appLaunchUrl(String url, {bool forceWebView = false}) async {
  log(url);
  await launchUrl(Uri.parse(url)).catchError((e) {
    log(e);
    toast(" ${appStore.translate('lbl_invalid_url')}:$url");
  });
}

bool isLoggedInWithGoogle() {
  return appStore.isLoggedIn && getStringAsync(LOGIN_TYPE) == LoginTypeGoogle;
}

String getLevel({required int points}) {
  if (points < 100) {
    return Level0;
  } else if (points >= 100 && points < 200) {
    return Level1;
  } else if (points >= 200 && points < 300) {
    return Level2;
  } else if (points >= 300 && points < 400) {
    return Level3;
  } else if (points >= 400 && points < 500) {
    return Level4;
  } else if (points >= 500 && points < 600) {
    return Level5;
  } else if (points >= 600 && points < 700) {
    return Level6;
  } else if (points >= 700 && points < 800) {
    return Level7;
  } else if (points >= 800 && points < 900) {
    return Level8;
  } else if (points >= 900 && points < 1000) {
    return Level9;
  } else if (points >= 1000) {
    return Level10;
  } else {
    return '';
  }
}

Widget emptyWidget({required String text}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(EmptyImage, height: 150, fit: BoxFit.cover),
      4.height,
      Text(text, style: boldTextStyle(size: 20)),
    ],
  ).center();
}

Widget customCenterDialog({IconData? icon}) {
  return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: colorPrimary.withOpacity(0.5)),
      child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: colorPrimary.withOpacity(0.7), shape: BoxShape.circle),
          child: Icon(icon, size: 60, color: Colors.white)));
}

Widget customCenterDialogImage({String? image}) {
  return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: colorPrimary.withOpacity(0.5)),
      child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: colorPrimary.withOpacity(0.7), shape: BoxShape.circle),
          child: Image.asset(image!, height: 80, width: 80)));
}

InputDecoration addAnswerInputDecoration({String? hintText, Color? fillColor}) {
  return InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16.0),
    //fillColor: fillColor,
    filled: true,

    hintText: hintText != null ? hintText : '',
    hintStyle: secondaryTextStyle(),
    enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
            style: appStore.isDarkMode ? BorderStyle.solid : BorderStyle.none,
            color: Colors.white60),
        borderRadius: BorderRadius.circular(defaultRadius)),
    focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(defaultRadius)),
    errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(style: BorderStyle.none),
        borderRadius: BorderRadius.circular(defaultRadius)),
  );
}

/*class CorrectAnswerSwitch extends StatefulWidget {
  @override
  CorrectAnswerSwitchState createState() => CorrectAnswerSwitchState();
}

class CorrectAnswerSwitchState extends State<CorrectAnswerSwitch> {
  bool correctAnswer = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationWithRoundedCorners(backgroundColor: white),
      child: SwitchListTile(
        value: correctAnswer,
        title: Text('Correct answer', style: secondaryTextStyle()),
        onChanged: (bool val) {
          setState(
            () {
              correctAnswer = val;
            },
          );
        },
      ),
    );
  }
}*/

gradientContainer() {
  return Container(
      decoration: BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.topRight,
        colors: [
          colorPrimary,
          colorSecondary,
        ]),
  ));
}

Future<void> mLaunchUrl(String url, {bool forceWebView = false}) async {
  if (url.isNotEmpty) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)
        .catchError((e) {
      log(e);
      log('Invalid URL: $url');
    });
  } else {
    toast('URL is Empty');
  }
}
