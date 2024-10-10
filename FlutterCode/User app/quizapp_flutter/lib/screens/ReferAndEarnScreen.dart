import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../main.dart';
import 'package:share_plus/share_plus.dart';

import '../models/SettingModel.dart';
import '../utils/colors.dart';
import '../utils/images.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({Key? key}) : super(key: key);

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  final Shader linearGradient = LinearGradient(
    colors: <Color>[colorPrimary, colorSecondary],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
  String? referCode;
  bool isShow = true;
  AppSettingModel appSettingModel = AppSettingModel();

  @override
  initState() {
    super.initState();
    userDBService.getUserById(appStore.userId!).then((value) async {
      appSettingModel = await db.collection('settings').get().then((value) => AppSettingModel.fromJson(value.docs.first.data()));
      referCode = value.referCode;
      isShow = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      body: isShow == true
          ? Center(child: CircularProgressIndicator(color: colorPrimary))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: (context.height() / 2) - 60,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(26), bottomRight: Radius.circular(26)),
                            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.topRight, colors: [colorPrimary, colorSecondary])),
                        child: Image.asset(ReferImage),
                      ),
                      Positioned(
                        top: height,
                        left: appStore.selectedLanguage == 'ar' ? null : 0,
                        right: appStore.selectedLanguage == 'ar' ? 0 : null,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(padding: EdgeInsets.all(16), child: Icon(Icons.keyboard_backspace, color: Colors.white)),
                        ),
                      )
                    ],
                  ),
                  20.height,
                  Text(
                    appStore.translate('lbl_refer_earn'),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, foreground: Paint()..shader = linearGradient),
                  ),
                  14.height,
                  Text(
                    appStore.translate('lbl_invite_friend') + appSettingModel.referPoints.validate() + appStore.translate('lbl_points'),
                    style: primaryTextStyle(),
                    textAlign: TextAlign.center,
                  ).paddingSymmetric(horizontal: 16),
                  22.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      circularCard(image: 'images/ic_users.png', text: appStore.translate('lbl_refer_invite')),
                      circularCard(image: 'images/ic_downloading.png', text: appStore.translate('lbl_your_friend')),
                      circularCard(image: 'images/ic_presents.png', text: appStore.translate('lbl_youGet') + appSettingModel.referPoints.validate() + appStore.translate('lbl_points'))
                    ],
                  ).paddingOnly(left: 16, right: 16),
                  16.height,
                  Text(appStore.translate('lbl_your_refer_code'), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, foreground: Paint()..shader = linearGradient)),
                  14.height,
                  Container(
                    height: 50,
                    margin: EdgeInsets.only(left: 16, right: 16),
                    decoration: BoxDecoration(border: Border.all(color: colorSecondary, width: 1), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(referCode.validate(), style: primaryTextStyle(color: colorSecondary)).paddingAll(16),
                        InkWell(
                          onTap: () async {
                            await Clipboard.setData(ClipboardData(text: referCode.validate().toString()));
                            toast(appStore.translate('lbl_copied'));
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.topRight, colors: [colorPrimary, colorSecondary])),
                            child: Icon(Icons.copy, color: Colors.white, size: 20),
                          ),
                        )
                      ],
                    ),
                  ),
                  22.height,
                  InkWell(
                    onTap: () async {
                      await Share.share(referCode.validate());
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.topRight, colors: [colorPrimary, colorSecondary]),
                      ),
                      child: Text(appStore.translate('lbl_share_now'), style: boldTextStyle(color: Colors.white)),
                    ),
                  ),
                  22.height,
                ],
              ),
            ),
    );
  }

  Widget circularCard({String? image, String? text}) {
    return SizedBox(
      width: 100,
      height: 135,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [colorPrimary, colorSecondary],
              ),
            ),
            child: Container(
              height: 70,
              width: 70,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1)),
              child: Image.asset(image!),
            ),
          ),
          8.height,
          Text(text!, softWrap: true, textAlign: TextAlign.center, style: primaryTextStyle(size: 14))
        ],
      ),
    );
  }
}
