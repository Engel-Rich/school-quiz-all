import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../components/QuizComponent.dart';
import '/../main.dart';
import '/../models/CategoryModel.dart';
import '/../models/QuizModel.dart';
import '/../screens/QuizDescriptionScreen.dart';
import '/../services/QuizService.dart';
import '/../utils/colors.dart';
import '/../utils/constants.dart';
import '/../utils/widgets.dart';

import '../components/AppBarComponent.dart';

class QuizScreen extends StatefulWidget {
  static String tag = '/QuizScreen';

  final String? catName, catId;

  QuizScreen({this.catName, this.catId});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  int? subcategoryIndex;
  List<QuizModel> quizData = [];
  String? subCatId;
  bool hasSubCat = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    categoryService.subCategories(widget.catId!).then(
      (value) {
        if (value.isNotEmpty) {
          hasSubCat = true;
          setState(() {});
        }
      },
    ).catchError(
      (error) {
        log(error);
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(context: context, title: '${widget.catName}'),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            child: Container(
              height: context.height(),
              child: Column(
                children: [
                  hasSubCat
                      ? Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: boxDecorationWithRoundedCorners(
                            borderRadius: BorderRadius.circular(12),
                            backgroundColor: subCatId == null
                                ? colorPrimary
                                : context.cardColor,
                          ),
                          child: RotatedBox(
                              quarterTurns: 3,
                              child: Text('All',
                                  style: boldTextStyle(
                                    color: appStore.isDarkMode
                                        ? white
                                        : subCatId == null
                                            ? white
                                            : black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center)),
                        ).onTap(() {
                          subCatId = null;
                          subcategoryIndex = null;
                          setState(() {});
                        }, borderRadius: BorderRadius.circular(20))
                      : SizedBox(),
                  FutureBuilder<List<CategoryModel>>(
                    future: categoryService.subCategories(widget.catId!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.isNotEmpty) {
                          return SizedBox(
                            width: 50,
                            child: Column(
                              children:
                                  List.generate(snapshot.data!.length, (index) {
                                CategoryModel mData = snapshot.data![index];
                                return Container(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(top: 8),
                                  decoration: boxDecorationWithRoundedCorners(
                                    borderRadius: BorderRadius.circular(12),
                                    backgroundColor: subcategoryIndex == index
                                        ? colorPrimary
                                        : context.cardColor,
                                  ),
                                  child: RotatedBox(
                                    quarterTurns: 3,
                                    child: Text(
                                      mData.name!,
                                      style: boldTextStyle(
                                          color: appStore.isDarkMode
                                              ? white
                                              : subcategoryIndex == index
                                                  ? white
                                                  : Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ).onTap(
                                  () {
                                    subcategoryIndex = index;
                                    subCatId = mData.id;
                                    setState(() {});
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                );
                              }),
                            ),
                          );
                        }
                      }
                      return SizedBox();
                    },
                  ),
                ],
              ).paddingOnly(top: 16, right: 16, left: 16),
            ).visible(hasSubCat == true),
          ),
          FutureBuilder<List<QuizModel>>(
            future: subCatId == null
                ? QuizService().getQuizByCatId(widget.catId)
                : QuizService().getQuizBySubCatId(subCatId!),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!.isNotEmpty
                    ? SingleChildScrollView(
                        child: Container(
                          padding: EdgeInsets.only(
                              left: appStore.selectedLanguage == 'ar'
                                  ? 16
                                  : hasSubCat
                                      ? 0
                                      : 16,
                              top: 16,
                              bottom: 16,
                              right: appStore.selectedLanguage == 'ar'
                                  ? hasSubCat
                                      ? 0
                                      : 16
                                  : 16),
                          child: AnimationLimiter(
                            child: Column(
                                children:
                                    AnimationConfiguration.toStaggeredList(
                              duration: Duration(seconds: 1),
                              childAnimationBuilder: (widget) => SlideAnimation(
                                horizontalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: widget,
                                ),
                              ),
                              children: snapshot.data!.map(
                                (mData) {
                                  return QuizComponent(quiz: mData).onTap(
                                    () {
                                      if (mData.questionRef.validate().isEmpty)
                                        return toast('No question found');
                                      if (mData.minRequiredPoint! <=
                                          getIntAsync(USER_POINTS)) {
                                        QuizDescriptionScreen(quizModel: mData)
                                            .launch(context);
                                      } else {
                                        toast(
                                            '${appStore.translate('lbl_your_points')}:${getIntAsync(USER_POINTS)} \n ${appStore.translate('lbl_minimum_requied_points')} ${mData.minRequiredPoint}');
                                      }
                                    },
                                    borderRadius:
                                        BorderRadius.circular(defaultRadius),
                                  ).paddingOnly(bottom: 16);
                                },
                              ).toList(),
                            )),
                          ),
                        ),
                      )
                    : emptyWidget(text: appStore.translate('lbl_noDataFound'));
              }
              return snapWidgetHelper(snapshot,
                  defaultErrorMessage: errorSomethingWentWrong);
            },
          ).expand(),
        ],
      ),
    );
  }
}
