import 'package:flutter/material.dart';

class DrawerItemModel {
  String? name;
  String? image;
  IconData? icon;
  Widget? widget;

  DrawerItemModel({this.name, this.image, this.icon, this.widget});
}

class WalkThroughItemModel {
  String? image;
  String? title;
  String? subTitle;

  WalkThroughItemModel({this.image, this.title, this.subTitle});
}

class AddAnswerModel {
  IconData? icon;
  String? name;
  Color? color;

  AddAnswerModel({this.icon, this.name, this.color});
}
