import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/widgets.dart';
import '/../main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../components/AppBarComponent.dart';
// import '../utils/constants.dart';
import '../utils/images.dart';
// import 'AboutUsScreen.dart';
import 'LoginScreen.dart';

class HelpDeskScreen extends StatefulWidget {
  @override
  HelpDeskScreenState createState() => HelpDeskScreenState();
}

class HelpDeskScreenState extends State<HelpDeskScreen> {
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

  void logout() {
    authService.logout().then((value) {
      LoginScreen().launch(context, isNewTask: true);
    }).catchError((e) {
      toast(e.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    appStore.setAppLocalization(context);

    return Scaffold(
      appBar: appBarComponent(context: context, title: "Help Desk"),
      body: Theme(
        data: ThemeData(
            highlightColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory),
        child: Column(
          children: [
            SettingItemWidget(
              padding: EdgeInsets.all(0),
              leading: Image.asset(AboutUsImage, height: 30, width: 30),
              title: appStore.translate('lbl_about_us'),
              onTap: () {
                appLaunchUrl(
                    "https://mundi237.github.io/school-quiz.com/about.html");
                // Navigator.push(context,
                //     MaterialPageRoute(builder: (context) => AboutUsScreen()));
              },
            ),
            Divider(color: lightGray),
            8.height,
            SettingItemWidget(
              padding: EdgeInsets.all(0),
              leading: Image.asset(RateUsImage, height: 30, width: 30),
              title: appStore.translate('lbl_rate_us'),
              onTap: () {
                PackageInfo.fromPlatform().then(
                  (value) async {
                    launchUrl(
                        Uri.parse('$playStoreBaseURL${value.packageName}'),
                        mode: LaunchMode.externalApplication);
                  },
                );
              },
            ),
            Divider(color: lightGray),
            8.height,
            SettingItemWidget(
              padding: EdgeInsets.all(0),
              leading: Image.asset(PrivacyPolicyImage, height: 30, width: 30),
              title: appStore.translate('lbl_privacy_policy'),
              onTap: () {
                // mLaunchUrl(getStringAsync(PRIVACY_POLICY_PREF));
                appLaunchUrl(
                    "https://mundi237.github.io/school-quiz.com/privacy-policy.html");
                // launchUrl(Uri.parse('${getStringAsync(PRIVACY_POLICY_PREF)}'),mode: LaunchMode.externalApplication);
              },
            ),
            Divider(color: lightGray),
            8.height,
            SettingItemWidget(
              padding: EdgeInsets.all(0),
              leading:
                  Image.asset(TermsAndConditionsImage, height: 30, width: 30),
              title: appStore.translate('lbl_terms_and_conditions'),
              onTap: () {
                appLaunchUrl(
                    "https://mundi237.github.io/school-quiz.com/terme%20d'utilisation.html");
                // mLaunchUrl(getStringAsync(TERMS_AND_CONDITION_PREF));
                // launchUrl(Uri.parse('$getStringAsync(TERMS_AND_CONDITION_PREF)'),mode: LaunchMode.externalApplication);
              },
            ),
          ],
        ).paddingAll(16),
      ),
    );
  }
}
