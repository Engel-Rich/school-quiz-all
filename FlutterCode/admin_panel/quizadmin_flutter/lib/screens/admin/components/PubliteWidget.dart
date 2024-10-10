import 'package:flutter/material.dart';
// import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/Publicite.dart';
import 'package:quizeapp/screens/admin/components/newPublicite.dart';
// import 'package:quizeapp/screens/admin/SubCategoryListScreen.dart';

import '../../../utils/Colors.dart';
import 'AppWidgets.dart';
// import 'NewCategoryDialog.dart';

class PubliciteWidget extends StatefulWidget {
  static String tag = '/PubliciteWidget';
  final Publicite? data;

  PubliciteWidget({this.data});

  @override
  _PubliciteWidgetState createState() => _PubliciteWidgetState();
}

class _PubliciteWidgetState extends State<PubliciteWidget> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 230,
          height: 230,
          padding: EdgeInsets.all(16),
          decoration: boxDecorationWithRoundedCorners(
              borderRadius: BorderRadius.circular(16),
              backgroundColor: colorPrimary),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  widget.data!.imageUrl == null ||
                          widget.data!.imageUrl!.trim().isEmpty
                      ? Image.asset(
                          "assets/no_data.png",
                          width: 200,
                          height: 130,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return cachedImage('', height: 130, width: 200)
                                .cornerRadiusWithClipRRect(12);
                          },
                        ).cornerRadiusWithClipRRect(12)
                      : Image.network(
                          widget.data!.imageUrl.toString(),
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
                                NewPubliciteDialog(
                                    publiciteData: widget.data)).then(
                          (value) {
                            //
                          },
                        );
                      },
                      child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: widget.data?.isactive == true
                                ? greenColor
                                : null,
                            gradient: widget.data?.isactive == true
                                ? null
                                : LinearGradient(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.data!.libelle ?? "Publicité",
                    style: boldTextStyle(),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 15,
                    child: Switch(
                      value: widget.data!.isactive,
                      activeColor: greenColor,
                      inactiveThumbColor: colorPrimary,
                      onChanged: (value) {
                        publiciteServices.updateDocument({'isactive': value},
                            widget.data!.id).then((value) => setState(() {}));
                      },
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    ).onTap(
      () {},
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
    );
  }
}
