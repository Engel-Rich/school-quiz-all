import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/ClasseModel.dart';
import 'package:quizeapp/screens/admin/components/DrawerWidget.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Constants.dart';

import '../../utils/Common.dart';
import 'components/AdminStatisticsWidget.dart';
import 'components/AppWidgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  AdminDashboardScreenState createState() => AdminDashboardScreenState();
}

class AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Widget currentWidget = AdminStatisticsWidget();
  ClasseModel? selectedClasse;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    appStore.setAppLocalization(context);
    return Scaffold(
      backgroundColor: context.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorPrimary,
        elevation: 0.0,
        flexibleSpace: gradientContainer(),
        title: Row(
          children: [
            Image.asset('assets/splash_app_logo.png', height: 40),
            16.width,
            Text(mAppName, style: boldTextStyle(size: 24, color: Colors.white)),
            16.width,
            Column(
              children: [
                8.height,
                StreamBuilder<List<ClasseModel>>(
                  stream: classeService.classes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Container(
                        width: context.width() * 0.25,
                        decoration: BoxDecoration(
                            borderRadius: radius(),
                            color: Colors.grey.shade200),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: DropdownButton<ClasseModel>(
                          underline: Offstage(),
                          hint: Text("No class selected"),
                          items: snapshot.data!.map((e) {
                            return DropdownMenuItem<ClasseModel>(
                              child: Text(e.long_name.validate()),
                              value: e,
                            );
                          }).toList(),
                          isExpanded: true,
                          value: selectedClasse,
                          onChanged: (ClasseModel? c) {
                            appStore.setClasseModel(c?.id_classe);
                            print(appStore.classeModel);
                            selectedClasse = c;
                            setState(() {});
                          },
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Text(snapshot.error!.toString());
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            )
          ],
        ),
        actions: [
          16.width,
          Row(
            children: [
              appStore.userProfileImage!.isNotEmpty
                  ? cachedImage(appStore.userProfileImage,
                          width: 42, height: 42, fit: BoxFit.cover)
                      .cornerRadiusWithClipRRect(20)
                  : Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white38),
                      child: Text(appStore.userFullName!.split('').first,
                          style: boldTextStyle(size: 14, color: colorPrimary)),
                    ),
              16.width,
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(appStore.userFullName!,
                      style: primaryTextStyle(size: 16, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                  Text(appStore.userEmail!,
                      style: primaryTextStyle(size: 14, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                ],
              ),
            ],
          ),
          16.width,
        ],
      ),
      body: Container(
        height: context.height(),
        decoration: gradientDecoration(),
        child: Row(
          children: [
            Container(
              width: context.width() * 0.15,
              //   color: Colors.white,
              padding: EdgeInsets.only(left: 16),
              height: context.height(),
              child: DrawerWidget(
                onWidgetSelected: (w) {
                  currentWidget = w!;
                  setState(() {});
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 8, bottom: 16, right: 16),
              padding: EdgeInsets.all(16),
              decoration: boxDecorationWithRoundedCorners(
                borderRadius: BorderRadius.circular(16),
                backgroundColor: selectedDrawerViewColor,
                boxShadow: [
                  BoxShadow(
                      color: Colors.transparent, spreadRadius: 0, blurRadius: 0)
                ],
              ),
              width: context.width() * 0.84,
              height: context.height(),
              child: currentWidget,
            ).expand(),
          ],
        ),
      ),
    );
  }
}
