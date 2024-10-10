import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../main.dart';
import '/../models/QuizModel.dart';
import '/../utils/colors.dart';
import '/../utils/constants.dart';
import '/../utils/widgets.dart';

import 'QuizQuestionsScreen.dart';

class DailyQuizDescriptionScreen extends StatefulWidget {
  static String tag = '/DailyQuizDescriptionScreen';

  @override
  DailyQuizDescriptionScreenState createState() => DailyQuizDescriptionScreenState();
}

class DailyQuizDescriptionScreenState extends State<DailyQuizDescriptionScreen> {
  bool isShow = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
            future: dailyQuizService.dailyQuiz(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                QuizModel mData = snapshot.data as QuizModel;
                return FutureBuilder(
                  future: quizHistoryService.quizHistoryById(id: mData.id),
                  builder: (context, snap) {
                    if (snap.hasData) {
                      if (snap.data == true) {
                        return emptyWidget(text: appStore.translate('lbl_noDataFound')).center();
                      } else {
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                mData.imageUrl!,
                                width: context.width(),
                                height: context.height() * 0.40,
                                fit: BoxFit.cover,
                              ).cornerRadiusWithClipRRectOnly(bottomLeft: defaultRadius.toInt(), bottomRight: defaultRadius.toInt()),
                              30.height,
                              Text(appStore.translate('lbl_about_this_quiz'), style: boldTextStyle(size: 20)).paddingOnly(left: 16, right: 16),
                              Container(
                                margin: EdgeInsets.all(16),
                                padding: EdgeInsets.all(16),
                                width: context.width(),
                                decoration: boxDecorationWithRoundedCorners(
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                  border: Border.all(color: grey.withOpacity(0.3)),
                                  backgroundColor: Theme.of(context).cardColor,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(appStore.translate('lbl_quiz_title') + ':', style: boldTextStyle()),
                                    8.height,
                                    Text(mData.quizTitle!, style: primaryTextStyle()),
                                    8.height,
                                    Divider(color: grey.withOpacity(0.3), thickness: 1),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        8.height,
                                        Text(appStore.translate('lbl_no_of_questions') + ':', style: boldTextStyle()),
                                        8.height,
                                        Text(mData.description!, style: primaryTextStyle()),
                                        8.height,
                                        Divider(color: grey.withOpacity(0.3), thickness: 1),
                                      ],
                                    ).visible(mData.description.validate().isNotEmpty),
                                    8.height,
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(appStore.translate('lbl_no_of_questions') + ":", style: boldTextStyle()),
                                        4.width,
                                        Text(mData.questionRef!.length.toString(), softWrap: true, style: primaryTextStyle()).expand(),
                                      ],
                                    ),
                                    8.height,
                                    Divider(color: grey.withOpacity(0.3), thickness: 1),
                                    8.height,
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(appStore.translate('lbl_quiz_duration') + ':', style: boldTextStyle()),
                                        4.width,
                                        Text(mData.quizTime.toString() + " Minutes", softWrap: true, style: primaryTextStyle()).expand(),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              16.height,
                              Container(
                                padding: EdgeInsets.only(left: 30, right: 30),
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [colorPrimary, colorSecondary],
                                    begin: FractionalOffset.centerLeft,
                                    end: FractionalOffset.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(defaultRadius),
                                ),
                                child: TextButton(
                                  child: Text(
                                    appStore.translate('lbl_start'),
                                    style: primaryTextStyle(color: white),
                                  ),
                                  onPressed: () {
                                    if (mData.questionRef!.length != 0) {
                                      finish(context);
                                      QuizQuestionsScreen(quizData: mData, quizType: QuizTypeDaily).launch(context);
                                    } else {
                                      toast(appStore.translate('lbl_no_questions_found'));
                                    }
                                  },
                                ),
                              ).center(),
                              16.height,
                            ],
                          ),
                        );
                      }
                    }
                    return snapWidgetHelper(snapshot, errorWidget: emptyWidget(text:appStore.translate('lbl_playedQuiz')));
                  },
                );
              }
              return snapWidgetHelper(snapshot, errorWidget: emptyWidget(text:appStore.translate('lbl_noDailyQuiz')));
            },
          ),
          Positioned(
            right: 16,
            top:height+6,
            child: CircleAvatar(
              child: Icon(Icons.close, color: black),
              backgroundColor: white,
              radius: 15,
            ).onTap(
              () {
                finish(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
