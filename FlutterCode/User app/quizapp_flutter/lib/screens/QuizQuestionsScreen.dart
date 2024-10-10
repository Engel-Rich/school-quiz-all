import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../components/QuizQuestionComponent.dart';
import '/../main.dart';
import '/../models/QuestionModel.dart';
import '/../models/QuizHistoryModel.dart';
import '/../models/QuizModel.dart';
import '/../screens/QuizResultScreen.dart';
import '/../utils/ModelKeys.dart';
import '/../utils/colors.dart';
import '/../utils/constants.dart';
import '/../utils/widgets.dart';

import '../utils/images.dart';

class QuizQuestionsScreen extends StatefulWidget {
  static String tag = '/QuizQuestionsScreen';

  final QuizModel? quizData;
  final String? quizType;
  final List<QuestionModel>? queList;
  final int? time;

  QuizQuestionsScreen({this.quizData, this.quizType, this.queList, this.time});

  @override
  QuizQuestionsScreenState createState() => QuizQuestionsScreenState();
}

class QuizQuestionsScreenState extends State<QuizQuestionsScreen> {
  DateTime? currentBackPressTime;
  CountdownTimerController? countdownController;
  PageController? pageController;
  int? endTime;
  int? endTimeNew;
  int rightAnswers = 0;
  int falseAnswers = 0;
  int selectedPageIndex = 0;
  bool isSelfChallenge = false;
  QuestionModel? replaceQuestion;
  bool isShow = true;
  bool? questionType;
  List<bool> lifeLine = [false, false, false];
  int? second;
  int? min;

  List<QuestionModel> quizQuestionsList = [];
  List<QuestionModel> questions = [];
  List<QuizAnswer> quizAnswer = [];

  String? oldLevel, newLevel;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isSelfChallenge = widget.quizType == QuizTypeSelfChallenge;
    (widget.quizType == QuizTypeSelfChallenge ||
            widget.quizType == QuizTypeGuessWord ||
            widget.quizType == QuizTypeTrueFalse ||
            widget.quizType == QuizTypeRandom)
        ? isSelfChallenge = true
        : isSelfChallenge = false;

    endTime = DateTime.now().millisecondsSinceEpoch +
        Duration(
                minutes:
                    isSelfChallenge ? widget.time! : widget.quizData!.quizTime!)
            .inMilliseconds;

    countdownController =
        CountdownTimerController(endTime: endTime!, onEnd: onEnd);

    pageController = PageController(initialPage: selectedPageIndex);

    LiveStream().on(
      answerQuestionStream,
      (s) {
        if (questions.contains(s)) {
          questions.remove(s);
        }
        questions.add(s as QuestionModel);
      },
    );

    if (isSelfChallenge) {
      quizQuestionsList = widget.queList!;
    } else {
      widget.quizData!.questionRef!.forEach(
        (e) async {
          debugPrint(e);
          await questionService.questionById(e).then(
            (value) {
              if (value != null) quizQuestionsList.add(value);
              setState(() {});
            },
          ).catchError(
            (e) {
              throw e.toString();
            },
          );
        },
      );
      quizQuestionsList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
      setState(() {});
    }
  }

  Widget nextButton() {
    return AppButton(
      text: appStore.translate('lbl_next'),
      color: colorPrimary,
      onTap: () {
        hideKeyboard(context);
        setState(() {
          isShow = true;
        });
        pageController!.animateToPage(++selectedPageIndex,
            duration: Duration(milliseconds: 350), curve: Curves.bounceIn);
      },
      textColor: scaffoldColor,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
    );
  }

  Widget previousButton() {
    return AppButton(
        text: appStore.translate('lbl_previous'),
        color: colorPrimary,
        onTap: () {
          hideKeyboard(context);
          setState(() {
            isShow = true;
          });
          pageController!.animateToPage(--selectedPageIndex,
              duration: Duration(milliseconds: 350), curve: Curves.bounceOut);
        },
        textColor: scaffoldColor,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10));
  }

  Widget submitButton() {
    return AppButton(
      text: appStore.translate('lbl_submit'),
      color: colorPrimary,
      onTap: onSubmit,
      textColor: scaffoldColor,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() async {
    super.dispose();
    countdownController!.dispose();
    pageController!.dispose();
    LiveStream().dispose(answerQuestionStream);
  }

  void onEnd() {
    showInDialog(
      context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () => Future.value(false),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(appStore.translate('lbl_time_over_message'),
                  style: primaryTextStyle()),
              16.height,
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(
                    text: appStore.translate('lbl_submit'),
                    onTap: submitQuiz,
                    elevation: 0,
                    color: greenColor,
                    textColor: white),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> submitQuiz() async {
    countdownController!.disposeTimer();
    appStore.setLoading(true);
    questions.forEach(
      (element) {
        if (element.answer == element.correctAnswer) {
          rightAnswers++;
        } else {
          falseAnswers++;
        }
      },
    );

    questions.forEach(
      (element) {
        print("question List ${element.addQuestion}");
        if (element != replaceQuestion) {
          quizAnswer.add(
            QuizAnswer(
              question: element.addQuestion.validate(),
              answers: element.answer.validate(value: 'Not Answered'),
              correctAnswer: element.correctAnswer.validate(),
            ),
          );
        }
      },
    );

    QuizHistoryModel quizHistory = QuizHistoryModel();

    quizHistory.userId = appStore.userId;
    quizHistory.createdAt = DateTime.now();
    quizHistory.quizType = widget.quizType;
    quizHistory.quizTitle = isSelfChallenge
        ? widget.quizType == QuizTypeTrueFalse
            ? 'True False Quiz'
            : widget.quizType == QuizTypeGuessWord
                ? "Guess The Word"
                : widget.quizType == QuizTypeRandom
                    ? 'Random Quiz'
                    : 'Self Challenge Quiz'
        : widget.quizData!.quizTitle.validate();
    if (isSelfChallenge == true ||
        widget.quizType == QuizTypeTrueFalse ||
        widget.quizType == QuizTypeGuessWord ||
        widget.quizType == QuizTypeRandom) {
      quizHistory.image = null;
    } else {
      quizHistory.image = widget.quizData!.imageUrl.validate();
    }
    quizHistory.quizAnswers = quizAnswer.validate();
    quizHistory.totalQuestion = quizAnswer.length.validate();
    quizHistory.rightQuestion = rightAnswers.validate();
    if (isSelfChallenge == true ||
        widget.quizType == QuizTypeTrueFalse ||
        widget.quizType == QuizTypeGuessWord ||
        widget.quizType == QuizTypeRandom) {
      quizHistory.quizId = null;
    } else {
      quizHistory.quizId = widget.quizData!.id;
    }
    await quizHistoryService.addDocument(quizHistory.toJson()).then(
      (v) async {
        int points = getIntAsync(USER_POINTS);
        if (widget.quizType == QuizTypeContest) {
          points += (rightAnswers * POINT_PER_QUESTION);
          points -= (falseAnswers * POINT_PER_QUESTION);
        } else {
          points -= (falseAnswers * POINT_PER_QUESTION);
        }
        if (points <= 0) {
          points = 0;
        }
        await userDBService.updateDocument(
          {UserKeys.points: points},
          appStore.userId,
        ).then(
          (value) {
            oldLevel = getLevel(points: getIntAsync(USER_POINTS));

            // setValue(USER_POINTS,
            //     getIntAsync(USER_POINTS) + POINT_PER_QUESTION * rightAnswers);

            setValue(USER_POINTS, points);
            newLevel = getLevel(points: getIntAsync(USER_POINTS));

            appStore.setLoading(false);
            finish(context);
            QuizResultScreen(
                    quizHistoryData: quizHistory,
                    oldLevel: oldLevel,
                    newLevel: newLevel)
                .launch(context);
          },
        ).catchError(
          (e) {
            toast(e.toString());
          },
        );
      },
    ).catchError(
      (e) {
        toast(e.toString());
      },
    );
  }

  void onSubmit() {
    hideKeyboard(context);
    showConfirmDialogCustom(
      context,
      title: appStore.translate('lbl_want_to_submit'),
      positiveText: appStore.translate('lbl_yes'),
      negativeText: appStore.translate('lbl_no'),
      primaryColor: colorPrimary,
      barrierDismissible: false,
      customCenterWidget: customCenterDialog(icon: Icons.done_all),
      onAccept: (p0) {},
    ).then(
      (value) {
        if (value ?? false) {
          submitQuiz.call();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: [
            Container(
              width: context.width(),
              height: context.height() * 0.30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [colorPrimary, colorSecondary],
                    begin: AlignmentDirectional.centerStart,
                    end: AlignmentDirectional.centerEnd),
              ),
            ),
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${appStore.translate('lbl_questions')} ${selectedPageIndex + 1}/${widget.quizType == QuizTypeContest ? quizQuestionsList.length - 1 : quizQuestionsList.length}',
                        style: boldTextStyle(
                          color: white,
                          size: 20,
                        ),
                      ),
                      CountdownTimer(
                        controller: countdownController,
                        onEnd: onEnd,
                        endTime: endTime,
                        textStyle: primaryTextStyle(color: white),
                        widgetBuilder: (context, time) {
                          min = time?.min;
                          second = time?.sec;
                          if (time?.sec != null && time?.min != null) {
                            return Text('${time?.min}:${time?.sec}',
                                style: boldTextStyle(
                                    color: Colors.white, size: 22));
                          } else if (time?.min == null && time?.sec != null) {
                            return Text('00:${time?.sec}',
                                style: boldTextStyle(
                                    color: Colors.white, size: 22));
                          } else if (time?.sec == null &&
                              time?.min == null &&
                              time == null) {
                            return Text('Game over',
                                style: boldTextStyle(
                                    color: Colors.white, size: 22));
                          }
                          return Text('Game over',
                              style:
                                  boldTextStyle(color: Colors.white, size: 22));
                        },
                      ),
                    ],
                  ),
                  AppButton(
                      text: appStore.translate('lbl_end_quiz'),
                      color: white,
                      onTap: onSubmit,
                      textColor: colorPrimary,
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 10))
                ],
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              top: context.height() * 0.20,
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: boxDecorationWithRoundedCorners(
                  borderRadius: BorderRadius.circular(defaultRadius),
                  backgroundColor: Theme.of(context).cardColor,
                ),
                child: PageView(
                  physics: new NeverScrollableScrollPhysics(),
                  controller: pageController,
                  children: List.generate(
                    quizQuestionsList.length,
                    (index) {
                      LiveStream()
                          .emit(answerQuestionStream, quizQuestionsList[index]);
                      setState(() {
                        questionType =
                            quizQuestionsList[selectedPageIndex].questionType ==
                                    'GuessWord'
                                ? true
                                : false;
                      });
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            QuizQuestionComponent(
                                question: quizQuestionsList[index],
                                isShow: isShow),
                            16.height,
                            if (index == 0 && quizQuestionsList.length != 1)
                              Row(
                                children: [
                                  nextButton().expand(),
                                ],
                              )
                            else if (index > 0 &&
                                    widget.quizType == QuizTypeContest
                                ? index < quizQuestionsList.length - 2
                                : index < quizQuestionsList.length - 1)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (quizQuestionsList[index].audio == null ||
                                      quizQuestionsList[index].audio!.isEmpty)
                                    previousButton().expand(),
                                  if (quizQuestionsList[index].audio == null ||
                                      quizQuestionsList[index].audio!.isEmpty)
                                    16.width,
                                  nextButton().expand(),
                                ],
                              )
                            else if (widget.quizType == QuizTypeContest
                                ? index == quizQuestionsList.length - 2
                                : index == quizQuestionsList.length - 1 &&
                                    quizQuestionsList.length != 1)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (quizQuestionsList[index].audio == null ||
                                      quizQuestionsList[index].audio!.isEmpty)
                                    previousButton().expand(),
                                  if (quizQuestionsList[index].audio == null ||
                                      quizQuestionsList[index].audio!.isEmpty)
                                    16.width,
                                  submitButton().expand(),
                                ],
                              )
                            else if (quizQuestionsList.length == 1)
                              Row(
                                children: [
                                  submitButton().expand(),
                                ],
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  onPageChanged: (value) {
                    selectedPageIndex = value;
                    setState(() {});
                  },
                ),
              ),
            ),
            Observer(
                builder: (context) => Loader().visible(appStore.isLoading)),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 26),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        if (lifeLine[0] == false) {
                          endTimeNew = DateTime.now().millisecondsSinceEpoch +
                              Duration(minutes: min! + 1, seconds: second!)
                                  .inMilliseconds;
                          countdownController = CountdownTimerController(
                              endTime: endTimeNew!, onEnd: onEnd);
                          countdownController!.start();
                          lifeLine[0] = true;
                          setState(() {});
                        }
                      },
                      child: Container(
                        padding: lifeLine[0] == true
                            ? EdgeInsets.all(8)
                            : EdgeInsets.all(16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withOpacity(0.3)),
                        child: lifeLine[0] == true
                            ? Stack(
                                children: [
                                  Icon(Icons.not_interested,
                                      color: Colors.black, size: 44),
                                  Positioned.fill(
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Icon(Icons.plus_one,
                                              color:
                                                  Colors.black.withOpacity(0.8),
                                              size: 30)))
                                ],
                              )
                            : Icon(Icons.plus_one,
                                color: Colors.black, size: 30),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          replaceQuestion =
                              quizQuestionsList[selectedPageIndex];
                          quizQuestionsList[selectedPageIndex] =
                              quizQuestionsList.last;
                          isShow = true;
                          lifeLine[1] = true;
                        });
                      },
                      child: Container(
                        padding: lifeLine[1] == true
                            ? EdgeInsets.all(8)
                            : EdgeInsets.all(16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withOpacity(0.3)),
                        child: lifeLine[1] == true
                            ? Stack(
                                children: [
                                  Icon(Icons.not_interested,
                                      color: Colors.black, size: 44),
                                  Positioned.fill(
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Icon(Icons.skip_next,
                                              color:
                                                  Colors.black.withOpacity(0.8),
                                              size: 30)))
                                ],
                              )
                            : Icon(Icons.skip_next,
                                color: Colors.black, size: 30),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (questionType == false) {
                          if (lifeLine[2] == false) {
                            setState(() {
                              isShow = false;
                              lifeLine[2] = true;
                            });
                          }
                        } else {
                          toast(
                              "50/50 Not available on guess the word question");
                        }
                      },
                      child: Container(
                        padding: lifeLine[2] == true
                            ? EdgeInsets.all(8)
                            : EdgeInsets.all(16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.withOpacity(0.3)),
                        child: lifeLine[2] == true
                            ? Stack(
                                children: [
                                  Icon(Icons.not_interested,
                                      color: Colors.black, size: 44),
                                  Positioned.fill(
                                      child: Align(
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            lifeLineImage,
                                            color:
                                                Colors.black.withOpacity(0.8),
                                            height: 26,
                                            width: 26,
                                          )))
                                ],
                              )
                            : Image.asset(lifeLineImage,
                                color: Colors.black, height: 30, width: 30),
                      ),
                    ),
                  ],
                ),
              ),
            ).visible(widget.quizType == QuizTypeContest)
          ],
        ).withHeight(context.height()),
      ),
    );
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "You can not go back. End Quiz");
      return Future.value(false);
    }
    return Future.value(false);
  }
}
