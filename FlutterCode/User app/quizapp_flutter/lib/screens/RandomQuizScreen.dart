// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:quizapp_flutter/models/CategorieTypeModel.dart';

import '../components/AppBarComponent.dart';
import '/../main.dart';
import '/../models/QuestionModel.dart';
import '/../screens/QuizQuestionsScreen.dart';
import '/../utils/constants.dart';
import '/../utils/widgets.dart';

class RandomQuizScreen extends StatefulWidget {
  static String tag = '/RandomQuizScreen';
  final TypeCategorie? typeCategorie;
  const RandomQuizScreen({
    Key? key,
    this.typeCategorie,
  }) : super(key: key);

  @override
  RandomQuizScreenState createState() => RandomQuizScreenState();
}

class RandomQuizScreenState extends State<RandomQuizScreen> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController noOfQueController = TextEditingController();

  FocusNode noOfQueFocus = FocusNode();

  int? selectedTime;
  int? totalNoQuestion;
  // String? categoryId;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    print(widget.typeCategorie?.id);
    if (widget.typeCategorie?.id != null) {
      questionService
          .questionListByTypeCategorie(
        widget.typeCategorie!,
      )
          .then((value) {
        print(value.length);
        totalNoQuestion = value.length;
        setState(() {});
      }).onError((error, stackTrace) {
        totalNoQuestion = 0;
        print(error);
      });
    } else {
      questionService.questionList(byClasse: false).then((value) {
        totalNoQuestion = value.length;
        setState(() {});
      });
    }
  }

  createQuiz() {
    if (formKey.currentState!.validate()) {
      hideKeyboard(context);
      appStore.setLoading(true);
      (widget.typeCategorie?.id != null
              ? questionService
                  .questionListByTypeCategorie(widget.typeCategorie!)
              : questionService.questionList(byClasse: false))
          .then(
        (value) async {
          print(value.length);
          print(value);
          appStore.setLoading(false);
          if (value.isNotEmpty) {
            List<QuestionModel> queList = [];
            int queCount;
            if (int.tryParse(noOfQueController.text.validate())! >
                value.length) {
              queCount = value.length;
              queList = value;
            } else {
              queCount = int.tryParse(noOfQueController.text.validate())!;
              QuestionModel getRandomElement<QuestionModel>(
                  List<QuestionModel> value) {
                final random = new Random();
                var i = random.nextInt(value.length);
                return value[i];
              }

              for (var i = 0; queList.length < queCount; i++) {
                var randomItem = getRandomElement(value);
                if (!queList.contains(randomItem)) {
                  queList.add(randomItem);
                }
              }
            }
            await QuizQuestionsScreen(
                    quizType: QuizTypeRandom,
                    queList: queList,
                    time: selectedTime)
                .launch(context);
          } else {
            toast(appStore.translate('lbl_no_questions_found_category'));
          }
        },
      ).catchError(
        (e) {
          appStore.setLoading(false);
          throw e;
        },
      );
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(context: context, title: "Random Quiz"),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  Text(appStore.translate('lbl_random_quiz'),
                          style: secondaryTextStyle(),
                          textAlign: TextAlign.center)
                      .center(),
                  30.height,
                  Text(appStore.translate('lbl_no_of_questions'),
                      style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: noOfQueController,
                    textFieldType: TextFieldType.PHONE,
                    focus: noOfQueFocus,
                    decoration: inputDecoration(
                        hintText: appStore.translate('lbl_hint_no_ques')),
                    maxLength: 3,
                    onChanged: (p0) {
                      if (p0.toInt() > totalNoQuestion!) {
                        noOfQueController.text = totalNoQuestion!.toString();
                        toast("Total No Of Question $totalNoQuestion");
                      }
                    },
                    validator: (value) {
                      if (value.toInt() > totalNoQuestion!) {
                        return "Total No Of Question $totalNoQuestion";
                      }
                      return null;
                    },
                  ),
                  16.height,
                  Text(appStore.translate('lbl_time'),
                      style: primaryTextStyle()),
                  8.height,
                  DropdownButtonFormField(
                    hint: Text(appStore.translate('lbl_select_time'),
                        style: secondaryTextStyle()),
                    value: selectedTime,
                    dropdownColor: Theme.of(context).cardColor,
                    decoration: inputDecoration(),
                    items: List.generate(12, (index) {
                      return DropdownMenuItem(
                        value: (index + 1) * 5,
                        child: Text('${(index + 1) * 5} Minutes',
                            style: primaryTextStyle()),
                      );
                    }),
                    onChanged: (dynamic value) {
                      selectedTime = value;
                    },
                    validator: (dynamic value) {
                      return value == null ? 'This field is required' : null;
                    },
                  ),
                  30.height,
                  gradientButton(
                      text: appStore.translate('lbl_ok'),
                      onTap: () {
                        createQuiz();
                      },
                      context: context,
                      isFullWidth: true),
                ],
              ).paddingOnly(left: 16, right: 16),
            ),
          ),
          Observer(builder: (context) => Loader().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
