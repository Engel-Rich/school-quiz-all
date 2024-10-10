import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/ListModel.dart';
import 'package:quizeapp/screens/abonnement/abonnement_list_screen.dart';
import 'package:quizeapp/screens/abonnement/subscription_list_screen.dart';
import 'package:quizeapp/screens/admin/AddNewQuestionsScreen.dart';
import 'package:quizeapp/screens/admin/AdminSettingScreen.dart';
import 'package:quizeapp/screens/admin/CategoryListScreen.dart';
import 'package:quizeapp/screens/admin/ClassScreen.dart';
import 'package:quizeapp/screens/admin/CreateQuizScreen.dart';
import 'package:quizeapp/screens/admin/DailyQuizScreen.dart';
import 'package:quizeapp/screens/admin/PubliciteListScreen.dart';
import 'package:quizeapp/screens/admin/TypeCategorieListScreen.dart';
import 'package:quizeapp/screens/admin/UserListScreen.dart';
import 'package:quizeapp/screens/admin/CreateContestScreen.dart';
import 'package:quizeapp/screens/admin/SpinWheelScreen.dart';
import 'package:quizeapp/screens/admin/components/AdminStatisticsWidget.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';

import '../../../main.dart';
import '../../../services/AuthService.dart';
import '../AdminLoginScreen.dart';
import 'AllQuestionsListWidget.dart';
import 'QuizListScreen.dart';

class DrawerWidget extends StatefulWidget {
  static String tag = '/DrawerWidget';
  final Function(Widget?)? onWidgetSelected;

  DrawerWidget({this.onWidgetSelected});

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  List<ListModel> list = [];

  int index = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    LiveStream().on(
      'selectItem',
      (index) {
        this.index = index as int;

        widget.onWidgetSelected?.call(list[this.index].widget);

        setState(() {});
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    LiveStream().dispose('selectItem');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    list.clear();
    list.add(ListModel(
        name: appStore.translate('lbl_dashboard'),
        widget: AdminStatisticsWidget(),
        iconData: AntDesign.home));
    list.add(ListModel(
        name: appStore.translate('lbl_category_list'),
        widget: CategoryListScreen(),
        iconData: MaterialCommunityIcons.view_dashboard_outline));
    list.add(
      ListModel(
          name: "Type de catégorie",
          widget: TypeCategoryListScreen(),
          iconData: MaterialCommunityIcons.typewriter),
    );
    list.add(
      ListModel(
          name: "Publicités",
          widget: PubliciteListScreen(),
          iconData: MaterialCommunityIcons.basket),
    );
    list.add(ListModel(
        name: appStore.translate('lbl_classe'),
        widget: ClassesListScreen(),
        iconData: MaterialCommunityIcons.school));
    list.add(ListModel(
        name: appStore.translate("lbl_add_questions"),
        widget: AddNewQuestionsScreen(),
        iconData: MaterialIcons.add_circle_outline));
    list.add(ListModel(
        name: appStore.translate('lbl_question_list'),
        widget: AllQuestionsListWidget(),
        iconData: AntDesign.questioncircleo));
    list.add(ListModel(
        name: appStore.translate('lbl_daily_quiz'),
        widget: DailyQuizScreen(),
        iconData: Fontisto.date));
    list.add(ListModel(
        name: appStore.translate('lbl_quiz_list'),
        widget: QuizListScreen(),
        iconData: Ionicons.md_list_outline));
    list.add(ListModel(
        name: appStore.translate('lbl_create_quiz'),
        widget: CreateQuizScreen(),
        iconData: MaterialIcons.post_add));
    //
    list.add(ListModel(
        name: appStore.translate(''),
        widget: SubscriptionListScreen(),
        iconData: MaterialIcons.credit_card));
    //
    //
    list.add(ListModel(
        name: appStore.translate('abonnement_list'),
        widget: AbonnementListScreen(),
        iconData: MaterialIcons.credit_card));
    //
    list.add(ListModel(
        name: appStore.translate('lbl_contest'),
        widget: CreateContestScreen(),
        iconData: Icons.list_alt_rounded));
    list.add(ListModel(
        name: appStore.translate('lbl_spin_wheel_list'),
        widget: SpinWheelScreen(),
        iconData: Icons.add_circle_outline_sharp));
    list.add(ListModel(
        name: appStore.translate('lbl_manage_users'),
        widget: UserListScreen(),
        iconData: Icons.person_outline));
    list.add(ListModel(
        name: appStore.translate('lbl_settings'),
        widget: AdminSettingScreen(),
        iconData: Feather.settings));
    list.add(ListModel(
        name: appStore.translate('lbl_logout'), iconData: Feather.log_out));

    return Container(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Wrap(
          children: list.map(
            (e) {
              int cIndex = list.indexOf(e);
              return InkWell(
                onTap: () {
                  if (e.name == appStore.translate('lbl_logout')) {
                    showConfirmDialogCustom(
                      context,
                      title: appStore.translate("lbl_logout_dialog"),
                      positiveText: appStore.translate("lbl_yes"),
                      negativeText: appStore.translate("lbl_no"),
                      primaryColor: colorPrimary,
                      onAccept: (p0) {
                        logout(
                          context,
                          onLogout: () {
                            AdminLoginScreen().launch(context, isNewTask: true);
                          },
                        );
                      },
                    );
                  } else {
                    index = list.indexOf(e);
                    widget.onWidgetSelected?.call(e.widget);
                  }
                },
                child: Container(
                  padding:
                      EdgeInsets.only(left: 16, right: 0, top: 16, bottom: 16),
                  decoration: BoxDecoration(
                    color: cIndex == index ? selectedDrawerItemColor : null,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.transparent,
                          spreadRadius: 0,
                          blurRadius: 0)
                    ],
                    borderRadius: cIndex == index - 1
                        ? BorderRadius.only(
                            bottomRight: Radius.circular(24),
                            topLeft: Radius.circular(24),
                            bottomLeft: Radius.circular(24))
                        : cIndex == index + 1
                            ? BorderRadius.only(
                                topRight: Radius.circular(24),
                                topLeft: Radius.circular(24),
                                bottomLeft: Radius.circular(24))
                            : BorderRadius.only(
                                topLeft: Radius.circular(24),
                                bottomLeft: Radius.circular(24)),
                  ),
                  child:
                      // !context.isDesktop()
                      //     ? e.iconData != null
                      //         ? Icon(e.iconData, color: cIndex == index ? colorPrimary : Colors.white, size: 24)
                      //         : Image.asset(e.imageAsset!, color: cIndex == index ? colorPrimary : Colors.white, height: 24)
                      //     :
                      Row(
                    children: [
                      e.iconData != null
                          ? Icon(e.iconData,
                              color:
                                  cIndex == index ? colorPrimary : Colors.white,
                              size: 24)
                          : Image.asset(e.imageAsset!,
                              color:
                                  cIndex == index ? colorPrimary : Colors.white,
                              height: 24),
                      16.width,
                      context.isDesktop()
                          ? cIndex == index
                              ? SizedBox(
                                      child: gradientText(e.name!,
                                          style: boldTextStyle()))
                                  .expand()
                              : SizedBox(
                                  child: Text(e.name!,
                                      style:
                                          primaryTextStyle(color: Colors.white),
                                      overflow: TextOverflow.ellipsis),
                                ).expand()
                          : SizedBox(),
                    ],
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}
