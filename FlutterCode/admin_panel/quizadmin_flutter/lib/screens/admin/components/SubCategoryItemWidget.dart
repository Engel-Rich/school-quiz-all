import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/screens/admin/components/NewSubCategoryDialog.dart';

class SubCategoryItemWidget extends StatefulWidget {
  final CategoryData? data;

  SubCategoryItemWidget({this.data});

  @override
  SubCategoryItemWidgetState createState() => SubCategoryItemWidgetState();
}

class SubCategoryItemWidgetState extends State<SubCategoryItemWidget> {
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 200,
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(8),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(blurRadius: 5, spreadRadius: 1, color: gray.withOpacity(0.2)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.network(widget.data!.image.toString(), height: 180, fit: BoxFit.cover).cornerRadiusWithClipRRect(16),
              8.height,
              Text(widget.data!.name.toString(), style: boldTextStyle(color: Colors.black45), maxLines: 2),
            ],
          ),
        ),
        Positioned(
          right: 24,
          top: 24,
          child: IconButton(
            icon: Icon(AntDesign.edit,color: Colors.white),
            onPressed: () {
              showInDialog(context, builder:(BuildContext context)=> NewSubCategoryDialog(subCategoryData: widget.data,categoryId: widget.data!.parentCategoryId)).then(
                (value) {
                  //
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
