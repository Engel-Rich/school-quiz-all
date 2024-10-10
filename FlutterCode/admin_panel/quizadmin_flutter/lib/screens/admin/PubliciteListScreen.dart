import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/models/Publicite.dart';
import 'package:quizeapp/screens/admin/components/AppWidgets.dart';
// import 'package:quizeapp/screens/admin/components/CategoryItemWidget.dart';
import 'package:quizeapp/screens/admin/components/PubliteWidget.dart';
import 'package:quizeapp/screens/admin/components/newPublicite.dart';

import 'package:quizeapp/utils/Common.dart';

import '../../main.dart';
import '../../utils/Colors.dart';

class PubliciteListScreen extends StatefulWidget {
  static String tag = '/PubliciteListScreen';

  @override
  _PubliciteListScreenState createState() => _PubliciteListScreenState();
}

class _PubliciteListScreenState extends State<PubliciteListScreen> {
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: buildAdverticiteList()),
        // VerticalDivider(),
        // Expanded(child: buildAdverticiActivatedteList()),
      ],
    )).cornerRadiusWithClipRRect(16);
  }

  Widget buildAdverticiteList() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Publicités", style: boldTextStyle(size: 22)),
              commonAppButton(
                context,
                "Ajouter une publicite",
                onTap: () {
                  showInDialog(context,
                      builder: (BuildContext context) => NewPubliciteDialog());
                },
                isFull: false,
              ),
            ],
          ),
          16.height,
          StreamBuilder<List<Publicite>>(
            stream: publiciteServices.allPublicite(),
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
                      return PubliciteWidget(data: e);
                    },
                  ).toList(),
                );
              }
              return snapWidgetHelper(snap,
                      loadingWidget: Loader(
                              valueColor: AlwaysStoppedAnimation(colorPrimary))
                          .paddingOnly(top: 350))
                  .center();
            },
          ),
        ],
      ),
    );
  }

  Widget buildAdverticiActivatedteList() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Publicités Actives", style: boldTextStyle(size: 22)),
            ],
          ),
          16.height,
          StreamBuilder<List<Publicite>>(
            stream: publiciteServices.allPublicite(isACtive: true),
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
                      return PubliciteWidget(data: e);
                    },
                  ).toList(),
                );
              }
              return snapWidgetHelper(snap,
                      loadingWidget: Loader(
                              valueColor: AlwaysStoppedAnimation(colorPrimary))
                          .paddingOnly(top: 350))
                  .center();
            },
          ),
        ],
      ),
    );
  }
}
