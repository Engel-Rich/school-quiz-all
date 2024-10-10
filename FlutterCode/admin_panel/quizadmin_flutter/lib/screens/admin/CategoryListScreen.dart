import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/screens/admin/components/AppWidgets.dart';
import 'package:quizeapp/screens/admin/components/CategoryItemWidget.dart';
import 'package:quizeapp/screens/admin/components/NewCategoryDialog.dart';
import 'package:quizeapp/utils/Common.dart';

import '../../main.dart';
import '../../utils/Colors.dart';

class CategoryListScreen extends StatefulWidget {
  static String tag = '/CategoryListScreen';

  @override
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
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
                Text(appStore.translate("lbl_categories"),
                    style: boldTextStyle(size: 22)),
                commonAppButton(context, appStore.translate("lbl_add_category"),
                    onTap: () {
                  showInDialog(context,
                      builder: (BuildContext context) => NewCategoryDialog());
                }, isFull: false),
              ],
            ),
            16.height,
            StreamBuilder<List<CategoryData>>(
              stream: categoryService.categories(classe: appStore.classeModel),
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
                        return CategoryItemWidget(data: e);
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
