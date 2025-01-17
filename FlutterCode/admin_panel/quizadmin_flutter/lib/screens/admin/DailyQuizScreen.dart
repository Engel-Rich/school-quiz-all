import 'dart:html';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/models/QuestionData.dart';
import 'package:quizeapp/models/QuizData.dart';
import 'package:quizeapp/models/QuizQuestionListData.dart';
import 'package:quizeapp/services/Settingservice.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';

class DailyQuizScreen extends StatefulWidget {
  final QuizData? quizData;

  DailyQuizScreen({this.quizData});

  @override
  DailyQuizScreenState createState() => DailyQuizScreenState();
}

class DailyQuizScreenState extends State<DailyQuizScreen> {
  AsyncMemoizer categoryMemoizer = AsyncMemoizer<List<CategoryData>>();
  AsyncMemoizer questionListMemoizer = AsyncMemoizer<List<QuestionData>>();
  var formKey = GlobalKey<FormState>();

  final dateController = TextEditingController();
  final pointController = TextEditingController();
  final titleController = TextEditingController();
  final imageUrlController = TextEditingController();
  final descriptionController = TextEditingController();

  FocusNode pointFocus = FocusNode();
  FocusNode dateFocus = FocusNode();
  FocusNode imageUrlFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();

  ScrollController controller = ScrollController();

  bool? _isChecked = false;
  int? selectedTime;

  DateTime? selectedDateQuiz;

  QuizQuestionListData mQuestion = QuizQuestionListData();

  List<QuestionData> questionList = [];
  List<QuestionData> selectedQuestionList = [];
  List<CategoryData> categoriesFilter = [];
  List<CategoryData> categories = [];

  List<CategoryData> subCategoriesFilters = [];

  late CategoryData selectedCategory;

  CategoryData? selectedCategoryForFilter;
  CategoryData? selectedSubCategoryForFilter;

  bool isLoading = true;
  bool mIsUpdate = false;
  bool isShow = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    loadQuestion();

    categoryService
        .categoriesFuture(classe: appStore.classeModel)
        .then((value) async {
      categoriesFilter.add(CategoryData(name: 'All Categories'));

      categories.addAll(value);
      categoriesFilter.addAll(value);

      selectedCategoryForFilter = categoriesFilter.first;

      setState(() {});

      /// Load categories
      categories =
          await categoryService.categoriesFuture(classe: appStore.classeModel);

      if (categories.isNotEmpty) {
        if (mIsUpdate) {
          try {
            selectedCategory = await categoryService
                .getCategoryById(widget.quizData!.categoryId);

            log(selectedCategory.name);
          } catch (e) {
            print(e);
          }
        } else {
          selectedCategory = categories.first;
        }
      }

      setState(() {});
    }).catchError((e) {
      //
    });
    await Duration(seconds: 3).delay;
    setState(() {
      isShow = false;
    });
  }

  Future<void> save() async {
    if (getBoolAsync(IS_TEST_USER)) return toast(mTestUserMsg);

    if (dateController.text.isEmpty) {
      return toast('Please Select Quiz Date');
    }
    if (selectedTime == null) {
      return toast('Please Select Quiz time');
    }
    if (formKey.currentState!.validate()) {
      QuizData quizData = QuizData();

      quizData.questionRef = selectedQuestionList.map((e) => e.id).toList();
      quizData.quizTitle = titleController.text.trim();
      quizData.imageUrl = imageUrlController.text.trim();
      quizData.description = descriptionController.text.trim();
      quizData.quizTime = selectedTime;

      String dateId = dateController.text;
      quizData.updatedAt = DateTime.now();
      setState(() => loadingSave = true);

      if (imagesPicket != null) {
        await saveFile("Question/Images", imagesPicket!).then((value) {
          if (value != null) {
            quizData.imageUrl = value;
          } else {
            toast("Impossible d'enrégistrer l'image ");
            setState(() => loadingSave = false);
            return;
          }
        }).onError((error, stackTrace) {
          toast(error.toString());
          setState(() => loadingSave = false);
          return;
        });
      }
      await dailyQuizServices.dailyQuestionListFuture(dateId).then(
        (value) async {
          log(value.createdAt);

          /// Update
          ///
          quizData.createdAt = value.createdAt;
          quizData.id = dateId;

          await dailyQuizServices
              .updateDocument(quizData.toJson(), dateId)
              .then(
            (value) {
              setState(() => loadingSave = false);

              imageData = null;
              imagesPicket = null;
              //
            },
          ).catchError(
            (e) {
              setState(() => loadingSave = false);
              toast(e.toString());
            },
          );
        },
      ).catchError(
        (e) async {
          log(e);
          setState(() => loadingSave = false);

          ///
          /// Create
          ///
          quizData.createdAt = DateTime.now();
          quizData.id = dateId;
          await dailyQuizServices
              .addDocumentWithCustomId(dateId, quizData.toJson())
              .then(
            (value) {
              toast(appStore.translate('lbl_added_daily_quiz'));
              setState(() => loadingSave = false);
              imageData = null;
              imagesPicket = null;
              dateController.clear();
              pointController.clear();
              titleController.clear();
              imageUrlController.clear();
              descriptionController.clear();
              selectedQuestionList.clear();
              _isChecked = false;
              questionList.forEach(
                (element) {
                  element.isChecked = false;
                },
              );
              setState(() {});
            },
          ).catchError(
            (e) {
              setState(() => loadingSave = false);
              log(e);
            },
          );
        },
      );
    }
  }

  Future<void> loadQuestion(
      {DocumentReference? categoryRef, String? subcat}) async {
    questionServices
        .questionListFuture(categoryRef: categoryRef, subcategorie: subcat)
        .then(
      (value) {
        isLoading = false;
        questionList.clear();
        questionList.addAll(value);

        setState(() {});
      },
    ).catchError(
      (e) {
        isLoading = false;
        setState(() {});
        toast(e.toString());
      },
    );
  }

  Future<void> loadSubCategoriesFilter({required String catID}) async {
    subCategoriesFilters =
        await categoryService.subCategoriesFuture(parentCategoryId: catID);

    setState(() {});
  }

  Future<void> updateSelectedQuestion(QuestionData data, bool? value) async {
    data.isChecked = value;

    if (selectedQuestionList.contains(data)) {
      selectedQuestionList.remove(data);
    } else {
      selectedQuestionList.add(data);
    }

    setState(() {});
  }

  @override
  void dispose() {
    dateController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: FutureBuilder<QuizData>(
          future: dailyQuizServices.dailyQuestionListFuture(getTodayQuizDate),
          builder: (_, snap) {
            if (snap.hasData) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(appStore.translate("lbl_today_quiz"),
                          style: boldTextStyle(size: 22)),
                      16.width,
                      Text(getTodayQuizDate, style: secondaryTextStyle()),
                    ],
                  ),
                  16.height,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: snap.data!.questionRef!.map(
                      (e) {
                        return Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(top: 8, bottom: 8),
                          decoration: boxDecorationWithRoundedCorners(
                            border: Border.all(
                                color: gray.withOpacity(0.4), width: 0.1),
                          ),
                          child: FutureBuilder<QuestionData>(
                            future: questionServices.questionById(e),
                            builder: (_, question) {
                              if (question.hasData) {
                                return Text(
                                  '${snap.data!.questionRef!.indexOf(e) + 1}. ${question.data!.questionTitle.validate()}',
                                  style: boldTextStyle(),
                                );
                              } else {
                                return SizedBox();
                              }
                            },
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ).paddingAll(16);
            } else {
              return isShow
                  ? Center(
                      child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(colorPrimary))
                          .paddingOnly(top: 350))
                  :
                  // isShow?Center(child: CircularProgressIndicator(strokeWidth:3,valueColor: AlwaysStoppedAnimation(colorPrimary)).paddingOnly(top: 30)):
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            commonAppButton(
                                context, appStore.translate("lbl_save"),
                                child: loadingSave
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CircularProgressIndicator(
                                            color: white),
                                      )
                                    : null, onTap: () {
                              if (!loadingSave)
                                save();
                              else
                                toast("Opération en cour");
                            }, isFull: false),
                          ],
                        ),
                        Divider(thickness: 0.5),
                        16.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    appStore.translate(
                                        "lbl_select_questions_daily_quiz"),
                                    style: boldTextStyle()),
                                16.height,
                                if (categories.isNotEmpty)
                                  Row(
                                    children: [
                                      Container(
                                        width: context.width() * 0.55,
                                        padding: EdgeInsets.only(left: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: radius(),
                                          color: Colors.grey.shade200,
                                        ),
                                        child: DropdownButton(
                                          underline: Offstage(),
                                          icon: Icon(Icons.filter_list_alt)
                                              .paddingOnly(right: 6),
                                          hint: Text(
                                              'Please choose a subcategorie'),
                                          items: categoriesFilter.map(
                                            (e) {
                                              return DropdownMenuItem(
                                                child: Text(e.name.validate()),
                                                value: e,
                                              );
                                            },
                                          ).toList(),
                                          isExpanded: true,
                                          value: selectedCategoryForFilter,
                                          onChanged: (dynamic c) {
                                            selectedCategoryForFilter = c;
                                            selectedSubCategoryForFilter = null;
                                            setState(() {});

                                            if (selectedCategoryForFilter!.id ==
                                                null) {
                                              loadQuestion();
                                            } else {
                                              loadSubCategoriesFilter(
                                                  catID:
                                                      selectedCategoryForFilter!
                                                          .id!);
                                              loadQuestion(
                                                categoryRef: categoryService.ref
                                                    .doc(
                                                        selectedCategoryForFilter!
                                                            .id),
                                              );
                                            }
                                          },
                                        ),
                                      ).expand(),

                                      ///
                                      ///Ajout des sous catégories
                                      ///
                                      if (subCategoriesFilters.isNotEmpty)
                                        8.width,
                                      if (subCategoriesFilters.isNotEmpty)
                                        Container(
                                          width: context.width() * 0.55,
                                          padding: EdgeInsets.only(left: 8),
                                          decoration: BoxDecoration(
                                            borderRadius: radius(),
                                            color: Colors.grey.shade200,
                                          ),
                                          child: DropdownButton(
                                            underline: Offstage(),
                                            icon: Icon(Icons.filter_list_alt)
                                                .paddingOnly(right: 6),
                                            hint: Text(
                                                'Please choose a category'),
                                            items: subCategoriesFilters.map(
                                              (e) {
                                                return DropdownMenuItem(
                                                  child:
                                                      Text(e.name.validate()),
                                                  value: e,
                                                );
                                              },
                                            ).toList(),
                                            isExpanded: true,
                                            value: selectedSubCategoryForFilter,
                                            onChanged: (CategoryData? c) {
                                              selectedSubCategoryForFilter = c;
                                              setState(() {});

                                              if (selectedSubCategoryForFilter!
                                                      .id ==
                                                  null) {
                                                loadQuestion(
                                                  categoryRef:
                                                      categoryService.ref.doc(
                                                          selectedCategoryForFilter!
                                                              .id),
                                                );
                                              } else {
                                                loadQuestion(
                                                  subcat:
                                                      selectedSubCategoryForFilter!
                                                          .id,
                                                );
                                              }
                                            },
                                          ),
                                        ).expand(),

                                      ///
                                      /// Fin de l'ajout des sous  catégories
                                      ///
                                    ],
                                  ),
                                16.height,
                                Container(
                                  width: context.width() * 0.55,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: gray.withOpacity(0.5),
                                        width: 0.3),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: _isChecked,
                                            activeColor: orange,
                                            onChanged: (bool? newValue) {
                                              questionList.forEach((element) {
                                                element.isChecked =
                                                    !_isChecked!;
                                              });

                                              if (_isChecked!) {
                                                selectedQuestionList.clear();
                                              } else {
                                                selectedQuestionList.clear();
                                                selectedQuestionList
                                                    .addAll(questionList);
                                              }

                                              _isChecked = newValue;

                                              setState(() {});
                                            },
                                          ),
                                          8.width,
                                          Text(
                                              appStore
                                                  .translate("lbl_Question"),
                                              style: boldTextStyle()),
                                        ],
                                      ).paddingAll(8),
                                      Divider(thickness: 0.5, height: 0),
                                      SingleChildScrollView(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: gray.withOpacity(0.1)),
                                          height: context.height() * 0.5,
                                          child: Scrollbar(
                                            thickness: 5.0,
                                            thumbVisibility: false,
                                            controller: controller,
                                            radius: Radius.circular(16),
                                            child: ListView.separated(
                                              controller: controller,
                                              shrinkWrap: true,
                                              itemCount: questionList.length,
                                              separatorBuilder: (_, i) =>
                                                  Divider(height: 0),
                                              itemBuilder: (_, index) {
                                                QuestionData data =
                                                    questionList[index];
                                                return Row(
                                                  children: [
                                                    Checkbox(
                                                      activeColor: orange,
                                                      value: data.isChecked
                                                          .validate(),
                                                      onChanged: (newValue) {
                                                        updateSelectedQuestion(
                                                            data, newValue);
                                                      },
                                                    ),
                                                    8.width,
                                                    Text(
                                                            data.questionTitle
                                                                .toString(),
                                                            style:
                                                                secondaryTextStyle())
                                                        .expand(),
                                                  ],
                                                ).paddingAll(8).onTap(
                                                  () {
                                                    print(data.isChecked);
                                                    updateSelectedQuestion(
                                                        data, !data.isChecked!);
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ).expand(flex: 4),
                            16.width,
                            Form(
                              key: formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      appStore.translate(
                                          "lbl_selected_question_list"),
                                      style: boldTextStyle()),
                                  16.height,
                                  AppTextField(
                                    controller: titleController,
                                    textFieldType: TextFieldType.NAME,
                                    decoration: inputDecoration(
                                        labelText:
                                            appStore.translate("lbl_title")),
                                    nextFocus: dateFocus,
                                    validator: (s) {
                                      if (s!.trim().isEmpty)
                                        return errorThisFieldRequired;
                                      return null;
                                    },
                                  ),
                                  16.height,
                                  Row(
                                    children: [
                                      AppTextField(
                                        readOnly: true,
                                        controller: dateController,
                                        textFieldType: TextFieldType.OTHER,
                                        nextFocus: pointFocus,
                                        focus: dateFocus,
                                        decoration: inputDecoration(
                                            labelText: appStore.translate(
                                                "lbl_pick_your_date")),
                                        onTap: () {
                                          showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2025),
                                            currentDate: selectedDateQuiz,
                                          ).then((date) {
                                            if (date != null) {
                                              selectedDateQuiz = date;

                                              dateController.text =
                                                  DateFormat(CurrentDateFormat)
                                                      .format(date);
                                            }
                                          }).catchError((e) {
                                            log(e);
                                          });
                                        },
                                        validator: (s) {
                                          if (s!.trim().isEmpty)
                                            return errorThisFieldRequired;
                                          return null;
                                        },
                                      ).expand(),
                                      16.width,
                                      SizedBox(
                                        width:
                                            ((context.width() * 0.55) - 25) / 2,
                                        child: DropdownButtonFormField(
                                          hint: SizedBox(
                                              width: ((context.width() * 0.55) -
                                                      130) /
                                                  2,
                                              child: Text(
                                                  appStore.translate(
                                                      "lbl_Quiz_Time"),
                                                  style: secondaryTextStyle(),
                                                  overflow:
                                                      TextOverflow.ellipsis)),
                                          value: selectedTime,
                                          items: List.generate(
                                            12,
                                            (index) {
                                              return DropdownMenuItem(
                                                value: (index + 1) * 5,
                                                child: SizedBox(
                                                    width: ((context.width() *
                                                                0.55) -
                                                            130) /
                                                        2,
                                                    child: Text(
                                                        '${(index + 1) * 5} Minutes',
                                                        style:
                                                            primaryTextStyle(),
                                                        overflow: TextOverflow
                                                            .ellipsis)),
                                              );
                                            },
                                          ),
                                          onChanged: (dynamic value) {
                                            selectedTime = value;
                                          },
                                          decoration: inputDecoration(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  16.height,
                                  AppTextField(
                                    controller: imageUrlController,
                                    textFieldType: TextFieldType.NAME,
                                    decoration: inputDecoration(
                                        labelText: appStore
                                            .translate("lbl_image_uRL")),
                                    focus: imageUrlFocus,
                                    nextFocus: descriptionFocus,
                                    validator: (s) {
                                      // if (s!.isEmpty) return errorThisFieldRequired;
                                      // if (!s.validateURL()) return 'URL is invalid';
                                      // return null;
                                      if (s!.trim().isEmpty &&
                                          imagesPicket == null) {
                                        return errorThisFieldRequired;
                                      } else if (s.trim().isNotEmpty &&
                                          !s.validateURL()) {
                                        return 'URL is invalid';
                                      }
                                      return null;
                                    },
                                  ),
                                  16.height,
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: context.width() * 0.15,
                                        child: commonAppButton(
                                          context,
                                          '',
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Choisir l\'image'),
                                              8.width,
                                              Icon(Icons.file_copy_outlined)
                                            ],
                                          ),
                                          onTap: () async {
                                            await pickImage();
                                          },
                                        ),
                                      ),
                                      16.width,
                                      Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border:
                                              Border.all(color: colorSecondary),
                                          image: imageData != null
                                              ? null
                                              : widget.quizData?.imageUrl ==
                                                      null
                                                  ? null
                                                  : DecorationImage(
                                                      image: NetworkImage(widget
                                                              .quizData
                                                              ?.imageUrl ??
                                                          ""),
                                                      fit: BoxFit.cover,
                                                    ),
                                        ),
                                        child: imageData != null
                                            ? Center(
                                                child: imageData != null
                                                    ? Image.memory(imageData!)
                                                    : CircularProgressIndicator(),
                                              )
                                            : widget.quizData?.imageUrl ==
                                                        null &&
                                                    imagesPicket == null
                                                ? Center(
                                                    child: Icon(
                                                        Icons.image_rounded),
                                                  )
                                                : null,
                                      ),
                                    ],
                                  ),
                                  16.width,
                                  16.width,
                                  AppTextField(
                                    controller: descriptionController,
                                    textFieldType: TextFieldType.NAME,
                                    maxLines: 3,
                                    minLines: 3,
                                    decoration: inputDecoration(
                                        labelText: appStore
                                            .translate("lbl_description")),
                                    focus: descriptionFocus,
                                    isValidationRequired: false,
                                  ),
                                  8.height,
                                  Container(
                                    width: context.width() * 0.5,
                                    child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: selectedQuestionList.length,
                                      itemBuilder: (_, index) {
                                        QuestionData data =
                                            selectedQuestionList[index];

                                        return Stack(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(16),
                                              margin: EdgeInsets.symmetric(
                                                  vertical: 2),
                                              decoration: BoxDecoration(
                                                  color: gray.withOpacity(0.1)),
                                              child: Row(
                                                children: [
                                                  8.width,
                                                  Text('${index + 1}',
                                                      style:
                                                          secondaryTextStyle()),
                                                  16.width,
                                                  Text(data.questionTitle!,
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              secondaryTextStyle())
                                                      .expand(),
                                                  8.width,
                                                  Container(
                                                    height: 30,
                                                    width: 30,
                                                    decoration:
                                                        boxDecorationWithRoundedCorners(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                            backgroundColor:
                                                                appButtonColor),
                                                    child: IconButton(
                                                      icon: Icon(Icons.clear,
                                                          size: 16,
                                                          color: white),
                                                      onPressed: () {
                                                        updateSelectedQuestion(
                                                            data,
                                                            !data.isChecked!);
                                                        if (selectedQuestionList
                                                            .contains(data)) {
                                                          selectedQuestionList
                                                              .remove(data);
                                                        }
                                                        setState(() {});
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ).expand(flex: 6),
                            )
                          ],
                        ),
                        16.height,
                      ],
                    ).paddingAll(16);
            }
          },
        ),
      ),
    ).cornerRadiusWithClipRRect(16);
  }

  bool loadingSave = false;
  File? imagesPicket;
  Uint8List? imageData;
  Uint8List? audioData;
  void _loadImage() {
    final reader = FileReader();
    reader.onLoadEnd.listen((event) {
      setState(() {
        imageData = reader.result as Uint8List?;
      });
    });
    reader.readAsArrayBuffer(imagesPicket!);
  }

  Future pickImage() async {
    File? imageFile = (await ImagePickerWeb.getMultiImagesAsFile())?[0];
    if (imageFile != null) {
      imagesPicket = imageFile;
      _loadImage();
      setState(() {});
    }
  }
}
