import 'package:flutter/material.dart';
// import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/CategorieTypeModel.dart';

// import 'package:quizeapp/screens/admin/SubCategoryListScreen.dart';
import 'package:quizeapp/screens/admin/components/NewTypeCategorieDialog.dart';

import '../../../utils/Colors.dart';
import 'AppWidgets.dart';
// import 'NewCategoryDialog.dart';

class TypeCategoryItemWidget extends StatefulWidget {
  static String tag = '/TypeCategoryItemWidget';
  final TypeCategorie? data;

  TypeCategoryItemWidget({this.data});

  @override
  _TypeCategoryItemWidgetState createState() => _TypeCategoryItemWidgetState();
}

class _TypeCategoryItemWidgetState extends State<TypeCategoryItemWidget> {
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
                    widget.data!.images.toString(),
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
                                NewTypeCategorieDialog(
                                    typeCategorie: widget.data)).then(
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
              Text(widget.data!.nameTypeCategorie.toString(),
                  style: boldTextStyle(),
                  maxLines: 2,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ],
    ).onTap(
      () {
        // SubCategoryListScreen(
        //         showAppBar: true,
        //         categoryId: widget.data!.id,
        //         categoryName: widget.data!.name)
        //     .launch(context);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
    );
  }
}
