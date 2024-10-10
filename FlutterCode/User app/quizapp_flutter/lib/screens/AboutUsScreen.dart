import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '/../main.dart';
import '/../utils/colors.dart';
import '/../utils/constants.dart';
import '/../utils/widgets.dart';

import '../components/AppBarComponent.dart';
// import '../utils/images.dart';

class AboutUsScreen extends StatefulWidget {
  static String tag = '/AboutUsScreen';

  @override
  AboutUsScreenState createState() => AboutUsScreenState();
}

class AboutUsScreenState extends State<AboutUsScreen> {
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
    return Scaffold(
      appBar: appBarComponent(
          context: context, title: appStore.translate('lbl_about_us')),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(mAppName, style: primaryTextStyle(size: 30)),
            16.height,
            Container(
              decoration:
                  BoxDecoration(color: colorPrimary, borderRadius: radius(4)),
              height: 4,
              width: 100,
            ),
            16.height,
            Text(appStore.translate('lbl_version'),
                style: secondaryTextStyle()),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (_, snap) {
                if (snap.hasData) {
                  return Text('${snap.data!.version.validate()}',
                      style: primaryTextStyle());
                }
                return SizedBox();
              },
            ),
            16.height,
            Text(
              mAboutApp,
              style: primaryTextStyle(size: 14),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AppButton(
              color: colorPrimary,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.contact_support_outlined, color: Colors.white),
                  8.width,
                  Text(
                    appStore.translate('lbl_contactUs'),
                    style: boldTextStyle(color: white),
                  ),
                ],
              ),
              onTap: () {
                // appLaunchUrl('mailto:${getStringAsync(CONTACT_PREF)}');
                appLaunchUrl('https://t.me/+WuDTPbBqkM44MzA0');
              },
            ),
            // 16.height,
            // AppButton(
            //   color: colorPrimary,
            //   child: Row(
            //     mainAxisSize: MainAxisSize.min,
            //     children: [
            //       Image.asset(Purchase_icon, height: 24, color: white),
            //       8.width,
            //       Text(appStore.translate('lbl_purchase'), style: boldTextStyle(color: white)),
            //     ],
            //   ),
            //   onTap: () {
            //     appLaunchUrl(codeCanyonURL);
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
