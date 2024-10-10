import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:nb_utils/nb_utils.dart';
import '../components/AppBarComponent.dart';
import '../main.dart';
import '../models/QuizModel.dart';
import '../models/UserModel.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/images.dart';
import '../utils/widgets.dart';
import 'LeaderBoardScreen.dart';
import 'QuizQuestionsScreen.dart';

class ContestScreen extends StatefulWidget {
  static String tag = "/ContestScreen";

  const ContestScreen({Key? key}) : super(key: key);

  @override
  State<ContestScreen> createState() => _ContestScreenState();
}

class _ContestScreenState extends State<ContestScreen> {
  List<QuizModel> live = [];
  int _selectedIndex = 0;
  List<String> tabName = [
    appStore.translate('lbl_all'),
    appStore.translate('lbl_ended'),
    appStore.translate('lbl_live'),
    appStore.translate('lbl_upcoming')
  ];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    contestService.onGoingContest(date: DateTime.now()).then((value) {
      value.forEach((element) {
        if (element.endAt!.isAfter(DateTime.now()) ||
            element.endAt! == DateTime.now() ||
            element.startAt == DateTime.now()) {
          live.add(element);
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: appBarComponent(
          context: context, title: appStore.translate('lbl_contest')),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 50,
              child: Column(
                children: List.generate(tabName.length, (index) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: boxDecorationWithRoundedCorners(
                      borderRadius: BorderRadius.circular(12),
                      backgroundColor: _selectedIndex == index
                          ? colorPrimary
                          : context.cardColor,
                    ),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        tabName[index],
                        style: boldTextStyle(
                            color: appStore.isDarkMode
                                ? white
                                : _selectedIndex == index
                                    ? white
                                    : Colors.black),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ).onTap(
                    () {
                      _selectedIndex = index;
                      setState(() {});
                    },
                    borderRadius: BorderRadius.circular(20),
                  );
                }),
              )).paddingOnly(top: 16, left: 16, right: 16),
          Container(
            width: screenWidth - 82,
            // padding: EdgeInsets.only(top: 16, bottom: 16),
            child: _selectedIndex == 0
                ? all()
                : _selectedIndex == 2
                    ? liveWidget(live)
                    : ended(index: _selectedIndex),
          )
        ],
      ),
    );
  }

  Widget all() {
    return StreamBuilder<List<QuizModel>>(
      stream: contestService.getContest,
      builder: (_, snap) {
        if (snap.hasData) {
          if (snap.data!.isEmpty) return emptyWidget(text: "No Contest");
          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: snap.data!.map((e) {
                return InkWell(
                    onTap: () {
                      if (e.startAt!.isAfter(DateTime.now())) {
                        MotionToast(
                          icon: Icons.done_all,
                          title: Text(appStore.translate('lbl_not_started'),
                              style: boldTextStyle(color: colorSecondary)),
                          description: SizedBox(),
                          height: 60,
                          width: context.width() - 100,
                          primaryColor: colorSecondary,
                        ).show(context);
                      } else if (e.endAt!.isBefore(DateTime.now())) {
                        MotionToast(
                          icon: Icons.done_all,
                          title: Text(appStore.translate('lbl_ended_message'),
                              style: boldTextStyle(color: colorSecondary)),
                          description: SizedBox(),
                          height: 60,
                          width: context.width() - 100,
                          primaryColor: colorSecondary,
                        ).show(context);
                      } else {
                        quizHistoryService
                            .quizHistoryById(id: e.id)
                            .then((value) {
                          if (value == false) {
                            // QuizQuestionsScreen(quizData: live[index], quizType: QuizTypeContest).launch(context);
                            showConfirmDialogCustom(
                              context,
                              title: appStore.translate('lbl_do_play_quiz'),
                              primaryColor: colorPrimary,
                              customCenterWidget: Container(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                      color: colorPrimary.withOpacity(0.5)),
                                  child: Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                          color: colorPrimary.withOpacity(0.7),
                                          shape: BoxShape.circle),
                                      child: Image.asset(Quiz_icon,
                                          height: 80, width: 80))),
                              positiveText: appStore.translate('lbl_yes'),
                              negativeText: appStore.translate('lbl_no'),
                              onAccept: (p0) {},
                            ).then((value) {
                              if (value ?? false) {
                                QuizQuestionsScreen(
                                        quizData: e, quizType: QuizTypeContest)
                                    .launch(context);
                              }
                            });
                          } else {
                            MotionToast(
                              icon: Icons.done_all,
                              title: Text(appStore.translate('lbl_played'),
                                  style: boldTextStyle(color: colorSecondary)),
                              description: SizedBox(),
                              height: 60,
                              width: context.width() - 100,
                              primaryColor: colorSecondary,
                            ).show(context);
                            // toast("Your Have Played this contest");
                          }
                        });
                      }
                    },
                    child: SingleChildScrollView(child: card(e)));
              }).toList(),
            ),
          );
        } else {
          return snapWidgetHelper(snap);
        }
      },
    );
  }

  Widget liveWidget(List<QuizModel> live) {
    // bool isShow;
    List<UserModel> userList = [];
    return live.length == 0
        ? Center(child: emptyWidget(text: "No Live Contest"))
        : SingleChildScrollView(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: List.generate(live.length, (index) {
                return InkWell(
                    onTap: () {
                      quizHistoryService
                          .quizHistoryById(id: live[index].id)
                          .then((value) {
                        if (value == false) {
                          // QuizQuestionsScreen(quizData: live[index], quizType: QuizTypeContest).launch(context);
                          showConfirmDialogCustom(
                            context,
                            title: appStore.translate('lbl_do_play_quiz'),
                            primaryColor: colorPrimary,
                            customCenterWidget: Container(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                    color: colorPrimary.withOpacity(0.5)),
                                child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                        color: colorPrimary.withOpacity(0.7),
                                        shape: BoxShape.circle),
                                    child: Image.asset(Quiz_icon,
                                        height: 80, width: 80))),
                            positiveText: appStore.translate('lbl_yes'),
                            negativeText: appStore.translate('lbl_no'),
                            onAccept: (p0) {},
                          ).then((value) {
                            if (value ?? false) {
                              QuizQuestionsScreen(
                                      quizData: live[index],
                                      quizType: QuizTypeContest)
                                  .launch(context);
                            }
                          });
                        } else {
                          MotionToast(
                            icon: Icons.done_all,
                            title: Text(appStore.translate('lbl_played'),
                                style: boldTextStyle(color: colorSecondary)),
                            description: SizedBox(),
                            height: 60,
                            width: context.width() - 100,
                            primaryColor: colorSecondary,
                          ).show(context);
                          // toast("Your Have Played this contest");
                        }
                      });
                    },
                    child: Stack(
                      children: [
                        card(live[index]),
                        Positioned(
                          right: 30,
                          top: 16,
                          child: InkWell(
                              onTap: () {
                                quizHistoryService
                                    .quizHistoryByQuiz(quizId: live[index].id)
                                    .then((value) {
                                  value.forEach((element) {
                                    userDBService
                                        .getUserById(element.userId!)
                                        .then((value) {
                                      userList.add(value);
                                      setState(() {});
                                    });
                                  });
                                  if (value.length == 0) {
                                    print("No Record");
                                  }
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              LeadingBoardScreen(
                                                  isContest: true,
                                                  contestId: live[index].id)));
                                });
                              },
                              child: Image.asset(leaderBoard,
                                  width: 30, height: 30)),
                        ),
                      ],
                    ));
              }),
            ),
          );
  }

  Widget ended({int? index}) {
    List<UserModel> userList = [];
    return FutureBuilder<List<QuizModel>>(
      future: index == 1
          ? contestService.endedContest(date: DateTime.now())
          : index == 3
              ? contestService.upComingContest(date: DateTime.now())
              : contestService.upComingContest(date: DateTime.now()),
      builder: (_, snap) {
        if (snap.hasData) {
          if (snap.data!.isEmpty) return emptyWidget(text: 'No Contest');
          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 16, bottom: 16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: snap.data!.map((e) {
                return InkWell(
                  onTap: () {
                    if (index == 1) {
                      MotionToast(
                        icon: Icons.done_all,
                        title: Text(appStore.translate('lbl_ended_message'),
                            style: boldTextStyle(color: colorSecondary)),
                        description: SizedBox(),
                        height: 60,
                        width: context.width() - 100,
                        primaryColor: colorSecondary,
                      ).show(context);
                    } else {
                      MotionToast(
                        icon: Icons.done_all,
                        title: Text(appStore.translate('lbl_not_started'),
                            style: boldTextStyle(color: colorSecondary)),
                        description: SizedBox(),
                        height: 60,
                        width: context.width() - 100,
                        primaryColor: colorSecondary,
                      ).show(context);
                    }
                  },
                  child: Stack(
                    children: [
                      card(e),
                      Positioned(
                        right: 30,
                        top: 16,
                        child: InkWell(
                            onTap: () {
                              quizHistoryService
                                  .quizHistoryByQuiz(quizId: e.id)
                                  .then((value) {
                                value.forEach((element) {
                                  userDBService
                                      .getUserById(element.userId!)
                                      .then((value) {
                                    userList.add(value);
                                    setState(() {});
                                  });
                                });
                                if (value.length == 0) {
                                  print("No Record");
                                }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            LeadingBoardScreen(
                                                isContest: true,
                                                contestId: e.id)));
                              });
                            },
                            child: Image.asset(leaderBoard,
                                width: 30, height: 30)),
                      )
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        } else {
          return snapWidgetHelper(snap);
        }
      },
    );
  }

  Widget card(QuizModel? quiz) {
    return Stack(
      children: [
        Container(
          width: (context.width() - 82),
          margin: EdgeInsets.only(
              right: appStore.selectedLanguage == 'ar' ? 0 : 16,
              left: appStore.selectedLanguage == 'ar' ? 16 : 0),
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            backgroundColor: quiz!.minRequiredPoint! > getIntAsync(USER_POINTS)
                ? Colors.grey.withOpacity(0.3)
                : Theme.of(context).cardColor,
            boxShadow: appStore.isDarkMode ? null : defaultBoxShadow(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 136,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      quiz.imageUrl!,
                      fit: BoxFit.fill,
                      height: 120,
                      width: (context.width() * 0.5) - 25,
                    ).cornerRadiusWithClipRRectOnly(topLeft: 12, topRight: 12),
                  ],
                ),
              ),
              10.height,
              Row(
                children: [
                  Text(
                    '${quiz.quizTitle}',
                    style: boldTextStyle(
                        color:
                            appStore.isDarkMode ? Colors.white : Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ).paddingOnly(left: 16).expand(),
                  4.width,
                  Text(
                    '${quiz.questionRef!.length} Qs',
                    style: primaryTextStyle(
                        size: 12,
                        color:
                            appStore.isDarkMode ? Colors.white : Colors.black),
                    maxLines: 1,
                  ).paddingOnly(right: 16)
                ],
              ),
              10.height,
            ],
          ),
        ),
        quiz.minRequiredPoint! > getIntAsync(USER_POINTS)
            ? Container(
                width: (context.width() - (3 * 16)) * 0.5,
                color: grey.withOpacity(0.3),
                height: 120,
              ).cornerRadiusWithClipRRectOnly(topLeft: 12, topRight: 12)
            : SizedBox(),
      ],
    );
  }
}
