import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../main.dart';
import '/../utils/constants.dart';

class ThemeSelectionDialog extends StatefulWidget {
  @override
  ThemeSelectionDialogState createState() => ThemeSelectionDialogState();
}

class ThemeSelectionDialogState extends State<ThemeSelectionDialog> {
  List<String> themeModelList = ['Light', 'Dark', 'System Default'];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    currentIndex = getIntAsync(THEME_MODE_INDEX);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(

        padding: EdgeInsets.zero,
        itemCount: themeModelList.length,
        shrinkWrap: true,
        itemBuilder: (_, index) {
          return RadioListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 8,vertical: 0),
            value: index,
            dense: true,
            groupValue: currentIndex,
            title: Text(themeModelList[index], style: primaryTextStyle()),
            onChanged: (dynamic val) {
              setState(
                () {
                  currentIndex = val;
                  if (val == ThemeModeSystem) {
                    appStore.setDarkMode(context.platformBrightness() == Brightness.dark);
                  } else if (val == ThemeModeLight) {
                    appStore.setDarkMode(false);
                  } else if (val == ThemeModeDark) {
                    appStore.setDarkMode(true);
                  }

                  setValue(THEME_MODE_INDEX, val);
                },
              );
              finish(context);
            },
          );
        },
      ),
    );
  }
}
