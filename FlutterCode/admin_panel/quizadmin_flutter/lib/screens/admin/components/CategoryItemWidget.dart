import 'package:flutter/material.dart';
// import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/screens/admin/SubCategoryListScreen.dart';

import '../../../utils/Colors.dart';
import 'AppWidgets.dart';
import 'NewCategoryDialog.dart';

class CategoryItemWidget extends StatefulWidget {
  static String tag = '/CategoryItemWidget';
  final CategoryData? data;

  CategoryItemWidget({this.data});

  @override
  _CategoryItemWidgetState createState() => _CategoryItemWidgetState();
}

class _CategoryItemWidgetState extends State<CategoryItemWidget> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 250,
          height: 250,
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Image.network(
                    widget.data!.image.toString(),
                    width: 200,
                    height: 130,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return cachedImage('', height: 130, width: 200)
                          .cornerRadiusWithClipRRect(12);
                    },
                  ).cornerRadiusWithClipRRect(12),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: InkWell(
                      splashFactory: NoSplash.splashFactory,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        showInDialog(context,
                            builder: (BuildContext context) =>
                                NewCategoryDialog(
                                    categoryData: widget.data)).then(
                          (value) {
                            //
                          },
                        );
                      },
                      child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            gradient: LinearGradient(
                                colors: [colorPrimary, colorSecondary],
                                begin: FractionalOffset.centerLeft,
                                end: FractionalOffset.centerRight),
                          ),
                          child:
                              Icon(Icons.edit, color: Colors.white, size: 16)),
                    ),
                  ),
                ],
              ),
              16.height,
              Text(widget.data!.name.toString(),
                  style: boldTextStyle(),
                  maxLines: 2,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ],
    ).onTap(
      () {
        SubCategoryListScreen(
                showAppBar: true,
                categoryId: widget.data!.id,
                categoryName: widget.data!.name)
            .launch(context);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
    );
  }
}
