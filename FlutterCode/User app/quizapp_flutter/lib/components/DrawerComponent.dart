import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '/../main.dart';
import '/../models/Model.dart';
import '/../screens/LoginScreen.dart';
import '/../screens/ProfileScreen.dart';
import '/../utils/colors.dart';
import '/../utils/constants.dart';
import '/../utils/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../utils/images.dart';

import '/../screens/DailyQuizDescriptionScreen.dart';
import '/../screens/EarnPointScreen.dart';
import '/../screens/MyQuizHistoryScreen.dart';
import '/../screens/QuizCategoryScreen.dart';
import '/../screens/SelfChallengeFormScreen.dart';
import '/../screens/SettingScreen.dart';
import '../screens/HelpDeskScreen.dart';
import '../screens/LeaderBoardScreen.dart';
import '../screens/ReferAndEarnScreen.dart';

class DrawerComponent extends StatefulWidget {
  static String tag = '/DrawerComponent';
  final Function? onCall;

  DrawerComponent({this.onCall});

  @override
  DrawerComponentState createState() => DrawerComponentState();
}

class DrawerComponentState extends State<DrawerComponent> {
  List<DrawerItemModel> drawerItems = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  void logout() {
    authService.logout().then((value) {
      LoginScreen().launch(context, isNewTask: true);
    }).catchError((e) {
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    drawerItems.clear();
    drawerItems.add(DrawerItemModel(
        name: appStore.translate('lbl_home'), image: HomeImage));
    drawerItems.add(DrawerItemModel(
        name: appStore.translate('lbl_leaderboard'),
        image: leaderBoard,
        widget: LeadingBoardScreen(isContest: false)));
    drawerItems.add(DrawerItemModel(
        name: appStore.translate('lbl_daily_quiz'),
        image: DailyQuizImage,
        widget: DailyQuizDescriptionScreen()));
    drawerItems.add(DrawerItemModel(
        name: appStore.translate('lbl_quiz_category'),
        image: QuizCategoryImage,
        widget: QuizCategoryScreen()));
    drawerItems.add(DrawerItemModel(
        name: appStore.translate('lbl_self_challenge'),
        image: SelfChallengeImage,
        widget: SelfChallengeFormScreen()));
    drawerItems.add(DrawerItemModel(
        name: appStore.translate('lbl_my_quiz_history'),
        image: QuizHistoryImage,
        widget: MyQuizHistoryScreen()));
    if (!getBoolAsync(DISABLE_AD))
      drawerItems.add(DrawerItemModel(
          name: appStore.translate('lbl_earn_points'),
          image: EarnPointsImage,
          widget: EarnPointScreen()));
    drawerItems.add(DrawerItemModel(
        name: appStore.translate('lbl_refer_earn'),
        widget: ReferAndEarnScreen(),
        image: referEarn));
    drawerItems.add(DrawerItemModel(
        name: appStore.translate('lbl_setting'),
        widget: SettingScreen(),
        image: SettingImage));
    drawerItems.add(DrawerItemModel(
        name: appStore.translate('lbl_help_desk'),
        widget: HelpDeskScreen(),
        image: helpDesk));
    drawerItems.add(DrawerItemModel(
        name: appStore.translate('lbl_delete_account'), image: delete));
    drawerItems.add(DrawerItemModel(
        name: appStore.translate('lbl_logout'), image: LogoutImage));
    return Drawer(
      backgroundColor: appStore.isDarkMode
          ? Colors.black.withOpacity(0.3)
          : Colors.white.withOpacity(0.5),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                8.height,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Observer(
                      builder: (context) =>
                          appStore.userProfileImage.validate().isEmpty
                              ? CircleAvatar(
                                  radius: 30, child: Image.asset(UserPic))
                              : CircleAvatar(
                                  radius: 30,
                                  child: cachedImage(
                                          appStore.userProfileImage.validate(),
                                          usePlaceholderIfUrlEmpty: true,
                                          height: 60,
                                          width: 60,
                                          fit: BoxFit.cover)
                                      .cornerRadiusWithClipRRect(35),
                                ),
                    ),
                    Icon(Icons.edit_outlined,
                            color: context.iconColor, size: 20)
                        .paddingAll(8)
                  ],
                ),
                8.height,
                Observer(
                  builder: (context) => Text.rich(TextSpan(children: [
                    TextSpan(
                        text: (appStore.userName ?? "") + " - ",
                        style: boldTextStyle()),
                    TextSpan(
                        text: getLevel(points: getIntAsync(USER_POINTS)),
                        style: boldTextStyle(color: colorPrimary)),
                  ])),
                ),
                8.height,
                Text(appStore.userEmail!, style: secondaryTextStyle()),
              ],
            ).paddingSymmetric(horizontal: 16, vertical: 8).onTap(() {
              finish(context);
              ProfileScreen().launch(context);
            },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent),
            Divider(height: 20),
            Column(
              children: List.generate(
                drawerItems.length,
                (index) {
                  DrawerItemModel mData = drawerItems[index];

                  return SettingItemWidget(
                    leading: Image.asset(mData.image!, height: 30, width: 30),
                    title: mData.name!,
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () async {
                      if (mData.widget != null) {
                        mData.widget.launch(context);
                      }
                      if (mData.name == appStore.translate('lbl_home')) {
                        log("drawer value---");
                        widget.onCall!();
                      } else if (mData.name ==
                          appStore.translate('lbl_delete_account')) {
                        showConfirmDialogCustom(
                          context,
                          title: appStore.translate('lbl_delete_message'),
                          positiveText: appStore.translate('lbl_yes'),
                          negativeText: appStore.translate('lbl_no'),
                          primaryColor: colorPrimary,
                          customCenterWidget: customCenterDialog(
                              icon: Icons.delete_outline_outlined),
                          onAccept: (p0) {
                            appStore.setLoading(true);
                            quizHistoryService
                                .quizHistoryByQuizType(quizType: "All")
                                .then((value) {
                              value.forEach((element) {
                                quizHistoryService.removeDocument(element.id!);
                              });
                            });
                            authService
                                .deleteUserPermanent(uid: appStore.userId)
                                .then((value) {
                              logout();
                              appStore.setLoading(false);
                            }).catchError((e) {
                              appStore.setLoading(false);
                              log(e);
                            });
                          },
                        );
                      } else if (mData.name ==
                          appStore.translate('lbl_logout')) {
                        showConfirmDialogCustom(context,
                            primaryColor: colorPrimary,
                            title: appStore.translate('lbl_want_to_logout'),
                            positiveText: appStore.translate('lbl_yes'),
                            negativeText: appStore.translate('lbl_no'),
                            customCenterWidget:
                                customCenterDialog(icon: Icons.login),
                            onAccept: (value) {
                          logout();
                        });
                      } else if (mData.name ==
                          appStore.translate('lbl_rate_us')) {
                        PackageInfo.fromPlatform().then(
                          (value) async {
                            launchUrl(Uri.parse(
                                '$playStoreBaseURL${value.packageName}'));
                          },
                        );
                      } else if (mData.name ==
                          appStore.translate('lbl_privacy_policy')) {
                        launchUrlString(
                            '${getStringAsync(PRIVACY_POLICY_PREF)}');
                      } else if (mData.name ==
                          appStore.translate('lbl_terms_and_conditions')) {
                        launchUrlString(
                            '${getStringAsync(TERMS_AND_CONDITION_PREF)}');
                      }
                    },
                  );
                },
              ),
            ),
            16.height,
          ],
        ),
      ),
    );
  }
}
