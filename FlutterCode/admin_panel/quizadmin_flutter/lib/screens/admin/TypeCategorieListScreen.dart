import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/CategorieTypeModel.dart';
import 'package:quizeapp/screens/admin/components/AppWidgets.dart';
import 'package:quizeapp/screens/admin/components/NewTypeCategorieDialog.dart';
import 'package:quizeapp/screens/admin/components/TypeCategorieItem.dart';
import 'package:quizeapp/utils/Common.dart';

import '../../main.dart';
import '../../utils/Colors.dart';

class TypeCategoryListScreen extends StatefulWidget {
  static String tag = '/TypeCategoryListScreen';

  @override
  _TypeCategoryListScreenState createState() => _TypeCategoryListScreenState();
}

class _TypeCategoryListScreenState extends State<TypeCategoryListScreen> {
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
                Text("Type de catégories", style: boldTextStyle(size: 22)),
                commonAppButton(context, "Ajouter un type", onTap: () {
                  showInDialog(context,
                      builder: (BuildContext context) =>
                          NewTypeCategorieDialog());
                }, isFull: false),
              ],
            ),
            16.height,
            StreamBuilder<List<TypeCategorie>>(
              stream: typeCategorieServices.getTypeCategorieListStream(),
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
                        return TypeCategoryItemWidget(data: e);
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
