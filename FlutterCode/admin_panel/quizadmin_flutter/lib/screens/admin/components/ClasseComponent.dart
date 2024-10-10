import 'package:flutter/material.dart';
// import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/ClasseModel.dart';
import 'package:quizeapp/screens/admin/components/NewClasseDialog.dart';

import '../../../utils/Colors.dart';

class ClassesWidget extends StatefulWidget {
  static String tag = '/ClassesWidget';
  final ClasseModel? data;

  ClassesWidget({this.data});

  @override
  _ClassesWidgetState createState() => _ClassesWidgetState();
}

class _ClassesWidgetState extends State<ClassesWidget> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          elevation: 1.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: 200,
            height: 230,
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
                        return Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                (widget.data?.shurt_name ?? ''),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  // color: white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ).cornerRadiusWithClipRRect(12);
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
                                      NewClassDialog(classeModel: widget.data))
                              .then(
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
                            child: Icon(Icons.edit,
                                color: Colors.white, size: 16)),
                      ),
                    ),
                  ],
                ),
                16.height,
                Text(widget.data!.long_name.toString(),
                    style: boldTextStyle(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
