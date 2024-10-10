import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../components/ThemeSelectionDialog.dart';
import '/../main.dart';
import '../components/AppBarComponent.dart';
import '../utils/constants.dart';
import '../utils/images.dart';
import 'LoginScreen.dart';

class SettingScreen extends StatefulWidget {
  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
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
    Widget _buildImageWidget(String imagePath) {
      if (imagePath.startsWith('http')) {
        return Image.network(imagePath, width: 24);
      } else {
        return Image.asset(imagePath, width: 24);
      }
    }

    return Scaffold(
      appBar: appBarComponent(context: context, title: appStore.translate('lbl_setting')),
      body: Theme(
        data: ThemeData(highlightColor: Colors.transparent, splashFactory: NoSplash.splashFactory),
        child: Column(
          children: [
            SettingItemWidget(
                padding: EdgeInsets.all(0),
                leading: Image.asset(language, height: 30, width: 30),
                title: appStore.translate('lbl_language'),
                trailing: DropdownButton<LanguageDataModel>(
                  value: selectedLanguageDataModel,
                  underline: SizedBox(),
                  dropdownColor: appStore.isDarkMode ? Colors.black : Colors.white,
                  elevation: defaultElevation,
                  onChanged: (LanguageDataModel? data) async {
                    selectedLanguageDataModel = data;

                    await setValue(SELECTED_LANGUAGE_CODE, data!.languageCode.validate());

                    setState(() {});
                    appStore.setLanguage(data.languageCode.validate());
                    await setValue(SELECTED_LANGUAGE_CODE, data.languageCode);
                    LiveStream().emit(HideDrawerStream, true);
                    setState(() {});
                  },
                  items: localeLanguageList.map((data) {
                    return DropdownMenuItem<LanguageDataModel>(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (data.flag != null) _buildImageWidget(data.flag!),
                          4.width,
                          Text(data.name.validate(), style: primaryTextStyle()),
                        ],
                      ),
                      value: data,
                    );
                  }).toList(),
                )),
            Divider(color: lightGray),
            8.height,
            SettingItemWidget(
              padding: EdgeInsets.all(0),
              leading: Image.asset(theme, width: 30, height: 30),
              title: appStore.translate('lbl_select_theme'),
              trailing: Text(
                  getIntAsync(THEME_MODE_INDEX) == 0
                      ? "Light"
                      : getIntAsync(THEME_MODE_INDEX) == 1
                          ? "Dark"
                          : "System Default",
                  style: secondaryTextStyle()),
              onTap: () async {
                setState(() {});
                await showInDialog(
                  context,
                  contentPadding: EdgeInsets.zero,
                  title: Text(appStore.translate('lbl_select_theme'), style: boldTextStyle(size: 20)),
                  builder: (_) {
                    // return SizedBox();
                    return ThemeSelectionDialog();
                  },
                );
              },
            ),
          ],
        ).paddingAll(16),
      ),
    );
  }
}
