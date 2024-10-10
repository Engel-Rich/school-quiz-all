import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:html/parser.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../main.dart';
import 'Colors.dart';
import 'Constants.dart';
import 'GradientText.dart';

InputDecoration inputDecoration({String? labelText, String? hintText}) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: secondaryTextStyle(),
    hintText: hintText,
    hintStyle: secondaryTextStyle(),
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: gray.withOpacity(0.4), width: 0.3)),
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: gray.withOpacity(0.4), width: 0.3)),
    focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.withOpacity(0.3), width: 0.3)),
    errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red.withOpacity(0.3), width: 0.3)),
    alignLabelWithHint: true,
  );
}

String get getTodayQuizDate =>
    DateFormat(CurrentDateFormat).format(DateTime.now());
String get getTodayQuizDate1 =>
    DateFormat(CurrentDateFormat1).format(DateTime.now());

Widget itemWidget(Color bgColor, Color textColor, String title, String desc) {
  return Container(
    width: 300,
    height: 130,
    decoration: BoxDecoration(
        border: Border.all(color: gray),
        borderRadius: radius(8),
        color: bgColor),
    padding: EdgeInsets.all(24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: primaryTextStyle(color: textColor, size: 25)),
        16.height,
        Text(desc, style: primaryTextStyle(size: 24, color: textColor)),
      ],
    ),
  );
}

// Send Notification Code

Future<bool> sendPushNotifications(String title, String content,
    {String? id, String? image}) async {
  Map req = {
    'headings': {
      'en': title,
    },
    'contents': {
      'en': content,
    },
    'data': {
      'id': id,
    },
    'app_id': mOneSignalAppId,
    'included_segments': ['All'],
  };
  var header = {
    HttpHeaders.authorizationHeader: 'Basic $mOneSignalRestKey',
    HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
  };

  Response res = await post(
    Uri.parse('https://onesignal.com/api/v1/notifications'),
    body: jsonEncode(req),
    headers: header,
  );

  log(res.statusCode);
  log(res.body);

  if (res.statusCode.isSuccessful()) {
    return true;
  } else {
    throw errorSomethingWentWrong;
  }
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

/*// ignore: non_constant_identifier_names
BorderRadiusGeometry(int index){
  return BoxDecoration(
   index-1 ?BorderRadius.only()
  }

  );
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

gradientDecoration({double boxRadius = 0.0}) {
  return BoxDecoration(
    borderRadius: radius(boxRadius),
    boxShadow: [
      BoxShadow(color: Colors.transparent, spreadRadius: 0, blurRadius: 0)
    ],
    gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.topRight,
        colors: [
          colorPrimary,
          colorSecondary,
        ]),
  );
}

gradientDecoration2() {
  return BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.topRight,
        colors: [
          colorSecondary.withOpacity(0.2),
          colorSecondary,
        ]),
  );
}

Widget gradientText(String text, {TextStyle? style}) {
  return GradientText(
    text,
    style: style == null ? primaryTextStyle() : style,
    gradient: LinearGradient(colors: [
      colorPrimary,
      colorSecondary,
    ]),
  );
}

gradientButton(String? bText,
    {double? width, EdgeInsetsGeometry? bPadding, Function()? onTap}) {
  return AppButton(
    width: width != null ? width : null,
    padding: EdgeInsets.zero,
    child: Container(
      decoration: gradientDecoration(boxRadius: defaultRadius),
      child: Text(bText!, style: primaryTextStyle(color: white)),
    ),
    color: colorPrimary,
    onTap: onTap,
  );
}

Widget commonAppButton(BuildContext context, String? title,
    {Function()? onTap, bool isFull = true, Widget? child}) {
  return AppButton(
    elevation: 0,
    child: Container(
      padding: isFull
          ? EdgeInsets.all(8)
          : EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      decoration: BoxDecoration(
          borderRadius: radius(defaultRadius),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [
                colorPrimary,
                colorSecondary,
              ]),
          boxShadow: [
            BoxShadow(color: shadowColorGlobal, spreadRadius: 1, blurRadius: 1)
          ]),
      width: isFull ? context.width() : null,
      child: child ??
          Text(
            title.validate(),
            style: primaryTextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
    ),
    padding: EdgeInsets.zero,
    onTap: onTap,
    color: Colors.transparent,
  );
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

void oneSignalData() {
  settingsService.getOneSignalSettings().then((value) {
    appStore.oneSignalAppId = value.appId.validate();
    appStore.oneSignalRestApi = value.restApiKey.validate();
    appStore.oneSignalChannelId = value.channelId.validate();

    // OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.Debug.setAlertLevel(OSLogLevel.none);
    OneSignal.consentRequired(false);
    OneSignal.Notifications.requestPermission(true);
    OneSignal.User.pushSubscription.optIn();
    OneSignal.Notifications.permission;

    OneSignal.initialize(value.appId.validate());

    // OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    // print("Accepted permission: $accepted");
    // });
    // OneSignal.shared.setNotificationWillShowInForegroundHandler((OSNotificationReceivedEvent? event) {
    // chatMessageService.fetchForMessageCount(loginStore.mId);
    //
    // return event?.complete(event.notification);
    // });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      print(
          'NOTIFICATION WILL DISPLAY LISTENER CALLED WITH: ${event.notification.jsonRepresentation()}');
      event.preventDefault();
      event.notification.display();
      // chatMessageService.fetchForMessageCount(loginStore.mId);
    });

    // OneSignal.shared.getDeviceState().then((value) async {
    // await setValue(playerId.validate(), value!.userId.validate());
    // });
    // OneSignal.shared.disablePush(false);
    // OneSignal.shared.consentGranted(true);
    // OneSignal.shared.requiresUserPrivacyConsent();

    // OneSignal.shared.setSubscriptionObserver((changes) async {
    // if (getBoolAsync(IS_LOGGED_IN)) {
    // userService.updateDocument({
    // 'oneSignalPlayerId': changes.to.userId,
    // 'updatedAt': Timestamp.now(),
    // }, getStringAsync(userId)).then((value) {
    // log("Updated");
    // }).catchError((e) {
    // log(e.toString());
    // });
    // }
    // if (!changes.to.userId.isEmptyOrNull) await setValue(playerId.validate(), changes.to.userId);
    // });
    print("step11111111111");

    OneSignal.User.pushSubscription.addObserver((state) async {
      print("step");
      print(OneSignal.User.pushSubscription.optedIn);
      print(OneSignal.User.pushSubscription.id);
      print(OneSignal.User.pushSubscription.token);
      print("------------------" + state.current.id.toString());
      print(
          "------------------" + OneSignal.User.pushSubscription.id.toString());
      await setValue(PLAYER_ID.validate(), OneSignal.User.pushSubscription.id);

      if (getBoolAsync(IS_LOGGED_IN)) {
        userService.updateDocument({
          'oneSignalPlayerId': OneSignal.User.pushSubscription.id,
          'updatedAt': Timestamp.now(),
        }, getStringAsync(appStore.userId!)).then((value) {
          log("Updated");
        }).catchError((e) {
          log(e.toString());
        });
      }
      if (!OneSignal.User.pushSubscription.id.isEmptyOrNull)
        await setValue(
            PLAYER_ID.validate(), OneSignal.User.pushSubscription.id);
    });
    appStore.setLoading(false);
  });
  print("Valuee->" + appStore.oneSignalAppId.validate());
}
