import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:quizeapp/models/UserModel.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Constants.dart';

import '../../main.dart';
import 'components/AppWidgets.dart';
import 'components/UserItemWidget.dart';

class UserListScreen extends StatefulWidget {
  static String tag = '/UserListScreen';

  @override
  UserListScreenState createState() => UserListScreenState();
}

class UserListScreenState extends State<UserListScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appBarWidget(appStore.translate("lbl_Users"),
          titleTextStyle: boldTextStyle(size: 22),
          showBack: false,
          elevation: 0.0),
      body: PaginateFirestore(
        scrollController: scrollController,
        isLive: true,
        itemBuilderType: PaginateBuilderType.listView,
        itemBuilder: (context, documentSnapshots, index) {
          UserModel data = UserModel.fromJson(
              documentSnapshots[index].data() as Map<String, dynamic>);

          return UserItemWidget(data);
        },
        shrinkWrap: true,
        padding: EdgeInsets.all(8),
        // orderBy is compulsory to enable pagination
        query: userService.getUserList()!,
        itemsPerPage: DocLimit,
        bottomLoader: Center(
            child: Loader(valueColor: AlwaysStoppedAnimation(colorPrimary))),
        initialLoader: Center(
            child: Loader(valueColor: AlwaysStoppedAnimation(colorPrimary))),
        onEmpty: noDataWidget(),
        onError: (e) => Text(e.toString(), style: primaryTextStyle()).center(),
      ),
    ).cornerRadiusWithClipRRect(16);
  }
}
