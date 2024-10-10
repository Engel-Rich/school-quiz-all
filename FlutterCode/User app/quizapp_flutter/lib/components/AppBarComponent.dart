import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/colors.dart';

AppBar appBarComponent({required BuildContext context, String? title}) {
  return AppBar(
    title: Text(title!, style: TextStyle(color: scaffoldColor)),
    backgroundColor:Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
    flexibleSpace: Container(
        decoration: BoxDecoration(
      borderRadius: BorderRadius.only(bottomRight: Radius.circular(26), bottomLeft: Radius.circular(26)),
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.topRight, colors: [
        colorPrimary,
        colorSecondary,
      ]),
    )),
  );
}
