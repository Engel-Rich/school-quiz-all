import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/screens/admin/components/AppWidgets.dart';
import 'package:quizeapp/screens/admin/components/NewSubCategoryDialog.dart';
import 'package:quizeapp/screens/admin/components/SubCategoryItemWidget.dart';

import '../../utils/Common.dart';

class SubCategoryListScreen extends StatefulWidget {
  static String tag = '/NewsListWidget';

  final bool? showAppBar;

  final String? categoryId;
  final String? categoryName;

  SubCategoryListScreen({this.showAppBar, this.categoryId, this.categoryName});

  @override
  _NewsListWidgetState createState() => _NewsListWidgetState();
}

class _NewsListWidgetState extends State<SubCategoryListScreen> {
  List<CategoryData> data = [];

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar.validate() ? appBarWidget(widget.categoryName!) : null,
      body: Container(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('', style: boldTextStyle()),
                  commonAppButton(context,appStore.translate("lbl_add_sub_category"),onTap: (){
                    showInDialog(context, builder: (BuildContext context)=>NewSubCategoryDialog(categoryId: widget.categoryId!));
                  },isFull: false),
                ],
              ),
              8.height,
              StreamBuilder<List<CategoryData>>(
                stream: categoryService.categories(parentCategoryId: widget.categoryId!),
                builder: (_, snap) {
                  if (snap.hasData) {
                    if (snap.data!.isEmpty) return noDataWidget();

                    return Wrap(
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      spacing: 16,
                      runSpacing: 8,
                      children: snap.data.validate().map((e) {
                        return SubCategoryItemWidget(data: e);
                      }).toList(),
                    );
                  } else {
                    return snapWidgetHelper(snap);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
