import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/models/QuestionData.dart';
import 'package:quizeapp/models/QuizData.dart';
import 'package:quizeapp/models/UserModel.dart';
import 'package:quizeapp/screens/admin/components/AppWidgets.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';

class AdminStatisticsWidget extends StatefulWidget {
  static String tag = '/AdminStatisticsWidget';

  @override
  _AdminStatisticsWidgetState createState() => _AdminStatisticsWidgetState();
}

class _AdminStatisticsWidgetState extends State<AdminStatisticsWidget> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await 2.microseconds.delay;
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    appStore.setAppLocalization(context);
    Widget itemWidget(Color bgColor, Color textColor, String title, int totalCount, IconData icon, {Function? onTap}) {
      return Container(
        width: 285,
        height: 147,
        decoration: BoxDecoration(
          border: Border.all(color: context.dividerColor),
          borderRadius: radius(12),
          color: bgColor,
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.topRight, colors: [
            colorPrimary,
            colorSecondary,
          ]),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: secondaryTextStyle(color: textColor, size: 28)),
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(totalCount.toString(), style: primaryTextStyle(size: 24, color: textColor)),
                Icon(icon, color: textColor, size: 30),
              ],
            ),
          ],
        ),
      ).onTap(
        onTap,
        borderRadius: radius(16),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                StreamBuilder<List<CategoryData>>(
                  stream: categoryService.categories(),
                  builder: (_, snap) {
                    if (snap.hasData) {
                      return itemWidget(
                        colorPrimary,
                        white,
                        appStore.translate("lbl_total_category"),
                        snap.data!.length,
                        MaterialCommunityIcons.view_dashboard_outline,
                        onTap: () {
                          LiveStream().emit('selectItem', TotalCategories);
                        },
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                ),
                StreamBuilder<List<QuestionData>>(
                  stream: questionServices.listQuestion(),
                  builder: (_, snap) {
                    if (snap.hasData) {
                      return itemWidget(
                        colorPrimary,
                        white,
                        appStore.translate("lbl_total_questions"),
                        snap.data!.length,
                        AntDesign.questioncircleo,
                        onTap: () {
                          LiveStream().emit('selectItem', TotalQuestions);
                        },
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                ),
                StreamBuilder<List<UserModel>>(
                  stream: userService.users(),
                  builder: (_, snap) {
                    if (snap.hasData) {
                      return itemWidget(
                        colorPrimary,
                        white,
                        appStore.translate("lbl_total_users"),
                        snap.data!.length,
                        Icons.person_outline,
                        onTap: () {
                          LiveStream().emit('selectItem', TotalUsers);
                        },
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                ),
              ],
            ),
            16.height,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(appStore.translate("lbl_today_quiz"), style: boldTextStyle(size: 22)),
                    16.width,
                    Text(getTodayQuizDate1, style: secondaryTextStyle()),
                  ],
                ),
                16.height,
                FutureBuilder<QuizData>(
                  future: dailyQuizServices.dailyQuestionListFuture(getTodayQuizDate),
                  builder: (_, snap) {
                    if (snap.hasData) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: snap.data!.questionRef!.map(
                          (e) {
                            return Container(
                              padding: EdgeInsets.all(16),
                              margin: EdgeInsets.only(top: 8, bottom: 8),
                              decoration: boxDecorationWithRoundedCorners(
                                border: Border.all(color: gray.withOpacity(0.4), width: 0.1),
                              ),
                              child: FutureBuilder<QuestionData>(
                                future: questionServices.questionById(e),
                                builder: (_, question) {
                                  if (question.hasData) {
                                    return Text('${snap.data!.questionRef!.indexOf(e) + 1}. ${question.data!.questionTitle.validate()}', style: boldTextStyle());
                                  } else {
                                    return SizedBox();
                                  }
                                },
                              ),
                            );
                          },
                        ).toList(),
                      );
                    } else {
                      return noDataWidget();
                    }
                  },
                ),
              ],
            ).paddingSymmetric(vertical: 16),
          ],
        ),
      ),
    ).cornerRadiusWithClipRRect(16);
  }
}
