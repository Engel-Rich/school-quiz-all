import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/AppSettingModel.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';

import '../../utils/Colors.dart';

class AdminSettingScreen extends StatefulWidget {
  static String tag = '/AdminSettingScreen';

  @override
  _AdminSettingScreenState createState() => _AdminSettingScreenState();
}

class _AdminSettingScreenState extends State<AdminSettingScreen> {
  var formKey = GlobalKey<FormState>();

  TextEditingController termConditionCont = TextEditingController();
  TextEditingController privacyPolicyCont = TextEditingController();
  TextEditingController contactInfoCont = TextEditingController();
  TextEditingController referPointCont = TextEditingController();

  bool? disableAd = false;

  String termCondition = '';
  String privacyPolicy = '';
  String contactInfo = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setLoading(true);

    await appSettingService.getAppSettings().then(
      (value) async {
        disableAd = value.disableAd;
        termConditionCont.text = value.termCondition!;
        privacyPolicyCont.text = value.privacyPolicy!;
        contactInfoCont.text = value.contactInfo!;
        referPointCont.text = value.referPoints!;
        setState(() {});
      },
    ).catchError(
      (e) {
        toast(errorSomethingWentWrong);
      },
    );

    appStore.setLoading(false);
  }

  Future<void> save() async {
    if (formKey.currentState!.validate()) {
      if (appStore.isTester) return toast(mTesterNotAllowedMsg);

      appStore.setLoading(true);

      AppSettingModel appSettingModel = AppSettingModel();

      appSettingModel.disableAd = disableAd;
      appSettingModel.termCondition = termConditionCont.text.trim();
      appSettingModel.privacyPolicy = privacyPolicyCont.text.trim();
      appSettingModel.contactInfo = contactInfoCont.text.trim();
      appSettingModel.referPoints = referPointCont.text;

      await appSettingService
          .updateDocument(appSettingModel.toJson(), "setting")
          .then(
        (value) async {
          await appSettingService.saveAppSettings(appSettingModel);

          toast('Successfully Saved');
        },
      ).catchError(
        (e) {
          e.toString().toastString();
        },
      );

      appStore.setLoading(false);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    appStore.setAppLocalization(context);
    return Scaffold(
      body: Stack(
        children: [
          Form(
            key: formKey,
            child: SingleChildScrollView(
              child: SizedBox(
                width: !context.isDesktop() ? 420 : 500,
                child: Column(
                  children: [
                    Container(
                      decoration: boxDecorationWithRoundedCorners(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 0.5,
                              spreadRadius: 0.5,
                              color: gray.withOpacity(0.1)),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(appStore.translate("lbl_language"),
                              style: boldTextStyle()),
                          LanguageListWidget(
                            widgetType: WidgetType.DROPDOWN,
                            onLanguageChange: (val) async {
                              appStore.setLanguage(val.languageCode.validate());
                              await setValue(
                                  SELECTED_LANGUAGE_CODE, val.languageCode);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    16.height,
                    AppTextField(
                      controller: termConditionCont,
                      textFieldType: TextFieldType.URL,
                      decoration: inputDecoration(
                          labelText: appStore.translate("lbl_term_condition")),
                      validator: (s) {
                        if (s!.isEmpty) return errorThisFieldRequired;
                        return null;
                      },
                    ),
                    16.height,
                    AppTextField(
                      controller: privacyPolicyCont,
                      textFieldType: TextFieldType.URL,
                      decoration: inputDecoration(
                          labelText: appStore.translate("lbl_privacy_policy")),
                      validator: (s) {
                        if (s!.isEmpty) return errorThisFieldRequired;
                        return null;
                      },
                    ),
                    16.height,
                    AppTextField(
                      controller: contactInfoCont,
                      textFieldType: TextFieldType.OTHER,
                      decoration: inputDecoration(
                          labelText: appStore.translate("lbl_contact_info")),
                    ),
                    16.height,
                    AppTextField(
                      controller: referPointCont,
                      textFieldType: TextFieldType.NUMBER,
                      decoration: inputDecoration(
                          labelText: appStore.translate('lbl_refer_points')),
                      validator: (s) {
                        if (s!.isEmpty) return errorThisFieldRequired;
                        return null;
                      },
                    ),
                    16.height,
                    SettingItemWidget(
                      padding: EdgeInsets.zero,
                      title: appStore.translate("lbl_disable_adMob"),
                      leading: Checkbox(
                        value: disableAd,
                        activeColor: colorPrimary,
                        onChanged: (v) {
                          disableAd = v;

                          setState(() {});
                        },
                      ),
                      onTap: () {
                        disableAd = !disableAd!;

                        setState(() {});
                      },
                      hoverColor: Colors.white,
                      splashColor: Colors.white,
                    ),
                    16.height,
                    commonAppButton(context, appStore.translate("lbl_save"),
                        onTap: () {
                      save();
                    })
                  ],
                ).paddingAll(16),
              ),
            ),
          ),
          Observer(
              builder: (_) =>
                  Loader(valueColor: AlwaysStoppedAnimation(colorPrimary))
                      .visible(appStore.isLoading)),
        ],
      ),
    ).cornerRadiusWithClipRRect(16);
  }
}
