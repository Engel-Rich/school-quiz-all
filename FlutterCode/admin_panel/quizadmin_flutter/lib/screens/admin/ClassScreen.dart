import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/ClasseModel.dart';
import 'package:quizeapp/screens/admin/components/AppWidgets.dart';
import 'package:quizeapp/screens/admin/components/ClasseComponent.dart';
// import 'package:quizeapp/screens/admin/components/NewCategoryDialog.dart';
import 'package:quizeapp/screens/admin/components/NewClasseDialog.dart';
import 'package:quizeapp/utils/Common.dart';

import '../../main.dart';
import '../../utils/Colors.dart';

class ClassesListScreen extends StatefulWidget {
  static String tag = '/ClassesListScreen';

  @override
  _ClassesListScreenState createState() => _ClassesListScreenState();
}

class _ClassesListScreenState extends State<ClassesListScreen> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appStore.translate("lbl_classe"),
                    style: boldTextStyle(size: 22)),
                commonAppButton(context, appStore.translate("lbl_add_classe"),
                    onTap: () {
                  showInDialog(context,
                      builder: (BuildContext context) => NewClassDialog());
                }, isFull: false),
              ],
            ),
            16.height,
            StreamBuilder<List<ClasseModel>>(
              stream: classeService.classes(),
              builder: (_, snap) {
                if (snap.hasData) {
                  if (snap.data!.isEmpty) return noDataWidget();
                  return Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.start,
                    spacing: 16,
                    runSpacing: 8,
                    children: snap.data.validate().map(
                      (e) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ClassesWidget(data: e),
                        );
                      },
                    ).toList(),
                  );
                }
                return snapWidgetHelper(snap,
                        loadingWidget: Loader(
                                valueColor:
                                    AlwaysStoppedAnimation(colorPrimary))
                            .paddingOnly(top: 350))
                    .center();
              },
            ),
          ],
        ),
      ),
    ).cornerRadiusWithClipRRect(16);
  }
}
