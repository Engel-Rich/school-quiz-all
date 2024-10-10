import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../main.dart';
import '/../models/CategoryModel.dart';
import '/../models/QuestionModel.dart';
import '/../screens/QuizQuestionsScreen.dart';
import '/../utils/constants.dart';
import '/../utils/widgets.dart';

import '../components/AppBarComponent.dart';

class SelfChallengeFormScreen extends StatefulWidget {
  static String tag = '/SelfChallengeFormScreen';

  @override
  SelfChallengeFormScreenState createState() => SelfChallengeFormScreenState();
}

class SelfChallengeFormScreenState extends State<SelfChallengeFormScreen> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController noOfQueController = TextEditingController();

  FocusNode noOfQueFocus = FocusNode();

  List<CategoryModel> categoryItems = [];
  int? selectedTime;
  String? categoryId;
  int? totalNoQuestion;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setLoading(true);
    await categoryService.categories().then(
      (value) {
        categoryItems.add(CategoryModel(name: 'All'));
        categoryItems.addAll(value);
        setState(() {});
      },
    );
    await questionService.questionList().then((value) {
      totalNoQuestion = value.length;
      setState(() {});
    });
    appStore.setLoading(false);
  }

  createQuiz(String? catId) {
    if (formKey.currentState!.validate()) {
      hideKeyboard(context);
      log(catId);
      appStore.setLoading(true);
      questionService.questionByCatId(catId).then(
        (value) async {
          appStore.setLoading(false);
          if (value.isNotEmpty) {
            List<QuestionModel> queList = [];
            int queCount;
            if (int.tryParse(noOfQueController.text.validate())! > value.length) {
              queCount = value.length;
              queList = value;
            } else {
              queCount = int.tryParse(noOfQueController.text.validate())!;
              QuestionModel getRandomElement<QuestionModel>(List<QuestionModel> value) {
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
            await QuizQuestionsScreen(quizType: QuizTypeSelfChallenge, queList: queList, time: selectedTime).launch(context);
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
      appBar: appBarComponent(context: context, title: appStore.translate('lbl_self_challenge')),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  Text(appStore.translate('lbl_enter_detail_sc_quiz'), style: secondaryTextStyle(), textAlign: TextAlign.center).center(),
                  30.height,
                  Text(appStore.translate('lbl_select_category'), style: primaryTextStyle()),
                  8.height,
                  SizedBox(
                    height: 50,
                    child: DropdownButtonFormField(
                      hint: Text(appStore.translate('lbl_select_category'), style: secondaryTextStyle()),
                      value: categoryId,
                      dropdownColor: Theme.of(context).cardColor,
                      isExpanded: true,
                      decoration: inputDecoration(),
                      items: List.generate(
                        categoryItems.length,
                        (index) {
                          return DropdownMenuItem(
                            value: categoryItems[index].id,
                            child: Text('${categoryItems[index].name}', style: primaryTextStyle()),
                          );
                        },
                      ),
                      onChanged: (dynamic value) {
                        categoryId = value;
                      },
                    ),
                  ),
                  16.height,
                  Text(appStore.translate('lbl_no_of_questions'), style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: noOfQueController,
                    textFieldType: TextFieldType.PHONE,
                    focus: noOfQueFocus,
                    decoration: inputDecoration(hintText: appStore.translate('lbl_hint_no_ques')),
                    onChanged: (p0) {
                      if (p0.toInt() > totalNoQuestion!) {
                        noOfQueController.text = totalNoQuestion.toString();
                        toast("Total no question are $totalNoQuestion");
                      }
                    },
                  ),
                  16.height,
                  Text(appStore.translate('lbl_time'), style: primaryTextStyle()),
                  8.height,
                  SizedBox(
                    height: 50,
                    child: DropdownButtonFormField(
                      hint: Text(appStore.translate('lbl_select_time'), style: secondaryTextStyle()),
                      value: selectedTime,
                      dropdownColor: Theme.of(context).cardColor,
                      decoration: inputDecoration(),
                      items: List.generate(
                        12,
                        (index) {
                          return DropdownMenuItem(value: (index + 1) * 5, child: Text('${(index + 1) * 5} Minutes', style: primaryTextStyle()));
                        },
                      ),
                      onChanged: (dynamic value) {
                        selectedTime = value;
                      },
                      validator: (dynamic value) {
                        return value == null ? 'This field is required' : null;
                      },
                    ),
                  ),
                  30.height,
                  gradientButton(
                      text: appStore.translate('lbl_continue'),
                      onTap: () {
                        createQuiz(categoryId);
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
