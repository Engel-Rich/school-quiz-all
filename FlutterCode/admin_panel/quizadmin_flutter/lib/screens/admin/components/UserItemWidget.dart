import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/UserModel.dart';
import 'package:quizeapp/screens/admin/components/AppWidgets.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Constants.dart';
import 'package:quizeapp/utils/ModelKeys.dart';

import '../../../main.dart';

class UserItemWidget extends StatefulWidget {
  static String tag = '/UserItemWidget';
  final UserModel data;

  UserItemWidget(this.data);

  @override
  _UserItemWidgetState createState() => _UserItemWidgetState();
}

class _UserItemWidgetState extends State<UserItemWidget> {

  Future<void> makeAdmin(bool value) async {
    if (getBoolAsync(IS_TEST_USER)) return toast(mTestUserMsg);

    widget.data.isAdmin = !widget.data.isAdmin.validate();
    setState(() {});

    await userService.updateDocument({UserKeys.isAdmin: value}, widget.data.id).then(
      (res) {
        //
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: white,
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          widget.data.image.validate().isNotEmpty
              ? cachedImage(
                  widget.data.image,
                  height: 60,
                  width: 60,
                  fit: BoxFit.cover,
                ).cornerRadiusWithClipRRect(30)
              : Image.asset('assets/ic_user.png',width: 60,height:60),
          16.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.data.name.validate(), style: boldTextStyle()),
              4.height,
              Text(widget.data.email.validate(), style: secondaryTextStyle()).visible(!appStore.isTester),
              4.height,
              Text(getLevel(points:widget.data.points!), style: secondaryTextStyle()),
            ],
          ).expand(),
          InkWell(
            onTap: () {
              showConfirmDialogCustom(
                context,
                title: appStore.translate("lbl_delete_user"),
                positiveText: appStore.translate("lbl_yes"),
                negativeText: appStore.translate("lbl_no"),
                primaryColor: colorPrimary,
                onAccept: (p0) {
                  if (getBoolAsync(IS_TEST_USER)) return toast(mTestUserMsg);
                  quizHistoryService.quizHistoryByQuizID(userID:widget.data.id).then((value) {
                    value.forEach((element) {
                      quizHistoryService.removeDocument(element.id);
                    });
                  });
                  userService.removeDocument(widget.data.id).then(
                        (value) {
                      toast('Deleted');
                    },
                  ).catchError(
                        (e) {
                      toast(e.toString());
                    },
                  );
                },
              );
            },
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(colors: [colorPrimary, colorSecondary], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight),
              ),
              child: Icon(Icons.delete, color: Colors.white,size: 18),
            ),
          ).paddingAll(16)
        ],
      ),
    );
  }
}

String getLevel({required int points}) {
  if (points < 100) {
    return "Level 0";
  } else if (points >= 100 && points < 200) {
    return "Level 1";
  } else if (points >= 200 && points < 300) {
    return "Level 2";
  } else if (points >= 300 && points < 400) {
    return "Level 3";
  } else if (points >= 400 && points < 500) {
    return "Level 4";
  } else if (points >= 500 && points < 600) {
    return "Level 5";
  } else if (points >= 600 && points < 700) {
    return "Level 6";
  } else if (points >= 700 && points < 800) {
    return "Level 7";
  } else if (points >= 800 && points < 900) {
    return "Level 8";
  } else if (points >= 900 && points < 1000) {
    return "Level 9";
  } else if (points >= 1000) {
    return "Level 10";
  } else {
    return '';
  }
}

