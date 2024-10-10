import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/models/QuestionData.dart';
import 'package:quizeapp/models/QuizData.dart';
import 'package:quizeapp/services/Settingservice.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';

class AddContestScreen extends StatefulWidget {
  final QuizData? quizData;

  AddContestScreen({this.quizData});

  @override
  AddContestScreenState createState() => AddContestScreenState();
}

class AddContestScreenState extends State<AddContestScreen> {
  var formKey = GlobalKey<FormState>();

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController pointController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController imageUrlController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  FocusNode pointFocus = FocusNode();
  FocusNode dateFocus = FocusNode();
  FocusNode imageUrlFocus = FocusNode();
  FocusNode descriptionFocus = FocusNode();

  ScrollController _controller = ScrollController();

  int? selectedTime;
  DateTime? startDateQuiz;
  DateTime? endDateQuiz;
  DateTime? startDateTime;
  DateTime? endDateTime;

  CategoryData? selectedCategoryForFilter;
  CategoryData? selectedSubCategoryForFilter;

  CategoryData? selectedCategory;
  CategoryData? selectedSubCategory;
  List<String?> selectedQuestionID = [];
  List<QuestionData> questionList = [];
  List<QuestionData> selectedQuestionList = [];
  List<CategoryData> categoriesFilter = [];
  List<CategoryData> categories = [];

  //Add Line
  List<CategoryData> subCategories = [];
  List<CategoryData> subCategoriesFilters = [];

  bool mIsUpdate = false;
  bool selectSubCategoryValue = false;
  bool? sendNotification = true;
  bool isUpdate = false;
  bool? _isChecked = false;
  bool isLoading = true;

  ///
  var toRemove = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    mIsUpdate = widget.quizData != null;

    // Don't send push notifications when updating by default.
    sendNotification = !mIsUpdate;

    if (mIsUpdate) {
      startDateController.text =
          DateFormat("dd-MM-yyyy HH:mm").format(widget.quizData!.startAt!);
      endDateController.text = DateFormat("dd-MM-yyyy HH:mm")
          .format(widget.quizData!.endAt!)
          .toString();
      pointController.text = widget.quizData!.minRequiredPoint.toString();
      titleController.text = widget.quizData!.quizTitle.validate();
      imageUrlController.text = widget.quizData!.imageUrl.validate();
      descriptionController.text = widget.quizData!.description.validate();

      selectedTime = widget.quizData!.quizTime.validate(value: 5);
      widget.quizData!.questionRef!.forEach((element) {
        selectedQuestionID.add(element);
        setState(() {});
      });
      widget.quizData!.questionRef!.forEach(
        (e) async {
          await questionServices.questionById(e).then(
            (value) {
              selectedQuestionList.add(value);
              setState(() {});
            },
          ).catchError(
            (e) {
              throw e.toString();
            },
          );
        },
      );
    }

    loadQuestion();

    categoryService.categoriesFuture(classe: appStore.classeModel).then(
      (value) async {
        categoriesFilter.add(CategoryData(name: 'All Categories'));

        categories.addAll(value);
        categoriesFilter.addAll(value);

        selectedCategoryForFilter = categoriesFilter.first;

        setState(() {});

        /// Load categories
        categories = await categoryService.categoriesFuture(
            classe: appStore.classeModel);

        if (categories.isNotEmpty) {
          if (isUpdate) {
            try {
              selectedCategory = await categoryService
                  .getCategoryById(widget.quizData!.categoryId);

              log(selectedCategory!.name);
            } catch (e) {
              print(e);
            }
          } else {
            selectedCategory = categories.first;
          }
        }

        setState(() {});
      },
    ).catchError(
      (e) {
        //
      },
    );
  }

  Future<void> loadSubCategories(String catId) async {
    subCategories =
        await categoryService.subCategoriesFuture(parentCategoryId: catId);

    if (subCategories.isNotEmpty) {
      selectedSubCategory = subCategories.first;
    } else {
      selectedSubCategory = null;
    }
    setState(() {});
  }

  Future<void> loadSubCategoriesFilter({required String catID}) async {
    subCategoriesFilters =
        await categoryService.subCategoriesFuture(parentCategoryId: catID);

    // if (subCategories.isNotEmpty) {
    //   selectedSubCategoryForFilter = subCategories.first;
    // } else {
    //   selectedSubCategory = null;
    // }
    setState(() {});
  }

  Future<void> save() async {
    if (getBoolAsync(IS_TEST_USER)) return toast(mTestUserMsg);

    if (selectedTime == null) {
      return toast('Please Select Quiz time');
    }
    if (formKey.currentState!.validate()) {
      QuizData quizData = QuizData();

      quizData.questionRef = selectedQuestionList.map((e) => e.id).toList();
      quizData.minRequiredPoint = pointController.text.toInt();
      quizData.quizTitle = titleController.text.trim();
      quizData.imageUrl = imageUrlController.text.trim();
      quizData.quizTime = selectedTime;
      quizData.description = descriptionController.text.trim();
      quizData.updatedAt = DateTime.now();

      if (selectedCategory != null) {
        quizData.categoryId = selectedCategory!.id;
      }

      if (selectSubCategoryValue == true) {
        if (selectedSubCategory != null) {
          quizData.subCategoryId = selectedSubCategory!.id;
        }
      } else {
        if (selectedSubCategory != null) {
          quizData.subCategoryId = '';
        }
      }
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
      if (mIsUpdate) {
        /// Update
        quizData.id = widget.quizData!.id;
        quizData.createdAt = widget.quizData!.createdAt;
        quizData.startAt = startDateQuiz ?? widget.quizData!.startAt;
        quizData.endAt = endDateTime ?? widget.quizData!.endAt;
        print('start date quiz ====>$startDateQuiz');
        print("widget data ------------> ${widget.quizData!.startAt}");
        print("================> ${quizData.startAt}");
        print('end date quiz ====>$endDateQuiz');
        print("widget data ------------> ${widget.quizData!.endAt}");
        print("================> ${quizData.endAt}");
        await contestService
            .updateDocument(quizData.toJson(), widget.quizData!.id)
            .then((value) {
          toast('Updated');
          setState(() => loadingSave = false);
          finish(context);
        }).catchError((e) {
          toast(e.toString());
        });
      } else {
        ///Create quiz
        quizData.createdAt = DateTime.now();
        quizData.startAt = startDateQuiz;
        quizData.endAt = endDateTime;

        await contestService.addDocument(quizData.toJson()).then(
          (value) {
            toast('Quiz Added');
            setState(() => loadingSave = false);
            imageData = null;
            imagesPicket = null;
            startDateController.clear();
            endDateController.clear();
            pointController.clear();
            titleController.clear();
            imageUrlController.clear();
            descriptionController.clear();
            selectedQuestionList.clear();
            selectedTime = null;
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
            log(e);
          },
        );
      }
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

  Future<void> updateSelectedQuestion(QuestionData data, bool? value) async {
    if (value == false) {
      setState(() {
        data.isChecked = false;
      });
      selectedQuestionList.forEach((element) {
        if (data.id == element.id) {
          toRemove.add(element);
        }
      });
      setState(() {
        selectedQuestionList.removeWhere((e) => toRemove.contains(e));
      });
    } else {
      data.isChecked = value;
      selectedQuestionList.add(data);
    }
    // if (selectedQuestionList.contains(data)) {
    //   selectedQuestionList.remove(data);
    // } else {
    //   selectedQuestionList.add(data);
    // }

    setState(() {});
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("Contest"),
      floatingActionButton: commonAppButton(
        context,
        appStore.translate("lbl_save"),
        child: loadingSave
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircularProgressIndicator(color: white),
              )
            : null,
        onTap: () {
          if (!loadingSave)
            save();
          else
            toast("Opération en cour");
        },
        isFull: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(appStore.translate("lbl_filter_question_by_category"), style: boldTextStyle(size: 22)),
            // 16.height,
            // Row(
            //   children: [
            //     if (categories.isNotEmpty)
            //       Container(
            //         padding: EdgeInsets.only(left: 8, right: 8),
            //         decoration: BoxDecoration(
            //           borderRadius: radius(),
            //           color: Colors.grey.shade200,
            //         ),
            //         child: DropdownButton(
            //           underline: Offstage(),
            //           hint: Text('Please choose a category'),
            //           items: categoriesFilter.map(
            //             (e) {
            //               return DropdownMenuItem(
            //                 child: Text(e.name.validate()),
            //                 value: e,
            //               );
            //             },
            //           ).toList(),
            //           isExpanded: true,
            //           value: selectedCategoryForFilter,
            //           onChanged: (dynamic c) {
            //             selectedCategoryForFilter = c;
            //             setState(() {});
            //
            //             if (selectedCategoryForFilter!.id == null) {
            //               loadQuestion();
            //             } else {
            //               loadQuestion(categoryRef: categoryService.ref.doc(selectedCategoryForFilter!.id));
            //             }
            //           },
            //         ),
            //       ).expand(),
            //     16.width,
            //     commonAppButton(context, appStore.translate("lbl_Clear"), onTap: () {
            //       _isChecked = false;
            //       selectedCategoryForFilter = categoriesFilter.first;
            //       selectedQuestionList.clear();
            //       loadQuestion();
            //     }, isFull: false),
            //   ],
            // ),
            // 16.height,
            // Divider(thickness: 0.5),
            16.height,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appStore.translate("lbl_select_questions"),
                        style: boldTextStyle()),
                    16.height,
                    // if (categories.isNotEmpty)
                    //   Container(
                    //     padding: EdgeInsets.only(left: 8, right: 8),
                    //     decoration: BoxDecoration(
                    //       borderRadius: radius(),
                    //       color: Colors.grey.shade200,
                    //     ),
                    //     child: DropdownButton(
                    //       underline: Offstage(),
                    //       icon: Icon(Icons.filter_list_alt),
                    //       hint: Text('Please choose a category'),
                    //       items: categoriesFilter.map(
                    //         (e) {
                    //           return DropdownMenuItem(
                    //             child: Text(e.name.validate()),
                    //             value: e,
                    //           );
                    //         },
                    //       ).toList(),
                    //       isExpanded: true,
                    //       value: selectedCategoryForFilter,
                    //       onChanged: (dynamic c) {
                    //         selectedCategoryForFilter = c;
                    //         setState(() {});

                    //         if (selectedCategoryForFilter!.id == null) {
                    //           loadQuestion();
                    //         } else {
                    //           loadQuestion(
                    //               categoryRef: categoryService.ref
                    //                   .doc(selectedCategoryForFilter!.id));
                    //         }
                    //       },
                    //     ),
                    //   ),

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
                            hint: Text('Please choose a subcategorie'),
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

                              if (selectedCategoryForFilter!.id == null) {
                                loadQuestion();
                              } else {
                                loadSubCategoriesFilter(
                                    catID: selectedCategoryForFilter!.id!);
                                loadQuestion(
                                  categoryRef: categoryService.ref
                                      .doc(selectedCategoryForFilter!.id),
                                );
                              }
                            },
                          ),
                        ).expand(),

                        ///
                        ///Ajout des sous catégories
                        ///
                        if (subCategoriesFilters.isNotEmpty) 8.width,
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
                              hint: Text('Please choose a category'),
                              items: subCategoriesFilters.map(
                                (e) {
                                  return DropdownMenuItem(
                                    child: Text(e.name.validate()),
                                    value: e,
                                  );
                                },
                              ).toList(),
                              isExpanded: true,
                              value: selectedSubCategoryForFilter,
                              onChanged: (CategoryData? c) {
                                selectedSubCategoryForFilter = c;
                                setState(() {});

                                if (selectedSubCategoryForFilter!.id == null) {
                                  loadQuestion(
                                    categoryRef: categoryService.ref
                                        .doc(selectedCategoryForFilter!.id),
                                  );
                                } else {
                                  loadQuestion(
                                    subcat: selectedSubCategoryForFilter!.id,
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
                      width: context.width() * 0.65,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: gray.withOpacity(0.5), width: 0.3),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: _isChecked,
                                activeColor: orange,
                                onChanged: (bool? newValue) {
                                  questionList.forEach(
                                    (element) {
                                      element.isChecked = !_isChecked!;
                                    },
                                  );

                                  if (_isChecked!) {
                                    selectedQuestionList.clear();
                                  } else {
                                    selectedQuestionList.clear();
                                    selectedQuestionList.addAll(questionList);
                                  }
                                  _isChecked = newValue;
                                  setState(() {});
                                },
                              ),
                              8.width,
                              Text(appStore.translate("lbl_Question"),
                                  style: boldTextStyle()),
                            ],
                          ).paddingAll(8),
                          Divider(color: gray, thickness: 0.5, height: 0),
                          SingleChildScrollView(
                            child: Container(
                              decoration:
                                  BoxDecoration(color: gray.withOpacity(0.1)),
                              height: context.height() * 0.68,
                              child: Scrollbar(
                                thickness: 5.0,
                                thumbVisibility: false,
                                controller: _controller,
                                radius: Radius.circular(16),
                                child: ListView.separated(
                                  controller: _controller,
                                  shrinkWrap: true,
                                  itemCount: questionList.length,
                                  separatorBuilder: (_, i) =>
                                      Divider(height: 0),
                                  itemBuilder: (_, index) {
                                    QuestionData data = questionList[index];
                                    selectedQuestionList.forEach((element) {
                                      if (element.id == data.id) {
                                        data.isChecked = true;
                                      }
                                    });
                                    return Row(
                                      children: [
                                        Checkbox(
                                          activeColor: orange,
                                          value: data.isChecked.validate(),
                                          onChanged: (newValue) {
                                            print(
                                                "==========================> $newValue");
                                            updateSelectedQuestion(
                                                data, newValue);
                                          },
                                        ),
                                        8.width,
                                        Text(data.questionTitle.toString(),
                                                style: secondaryTextStyle())
                                            .expand(),
                                      ],
                                    ).paddingAll(8).onTap(
                                      () {
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
                      Text(appStore.translate("lbl_selected_question_list"),
                          style: boldTextStyle()),
                      16.height,
                      AppTextField(
                        controller: titleController,
                        textFieldType: TextFieldType.NAME,
                        decoration: inputDecoration(
                            labelText: appStore.translate("lbl_title")),
                        nextFocus: dateFocus,
                        validator: (s) {
                          if (s!.trim().isEmpty) return errorThisFieldRequired;
                          return null;
                        },
                      ),
                      16.height,
                      Row(
                        children: [
                          AppTextField(
                            controller: pointController,
                            textFieldType: TextFieldType.PHONE,
                            decoration: inputDecoration(
                                labelText:
                                    appStore.translate("lbl_Required_point")),
                            focus: pointFocus,
                            nextFocus: imageUrlFocus,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: (s) {
                              if (s!.trim().isEmpty)
                                return errorThisFieldRequired;
                              return null;
                            },
                          ).expand(),
                          16.width,
                          SizedBox(
                            width: ((context.width() * 0.55) - 25) / 2,
                            child: DropdownButtonFormField(
                              hint: SizedBox(
                                  width: ((context.width() * 0.55) - 130) / 2,
                                  child: Text(
                                      appStore.translate("lbl_Quiz_Time"),
                                      style: secondaryTextStyle(),
                                      overflow: TextOverflow.ellipsis)),
                              value: selectedTime,
                              items: List.generate(
                                12,
                                (index) {
                                  return DropdownMenuItem(
                                    value: (index + 1) * 5,
                                    child: SizedBox(
                                        width:
                                            ((context.width() * 0.55) - 130) /
                                                2,
                                        child: Text(
                                            '${(index + 1) * 5} Minutes',
                                            style: primaryTextStyle(),
                                            overflow: TextOverflow.ellipsis)),
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
                      Row(
                        children: [
                          AppTextField(
                            readOnly: true,
                            controller: startDateController,
                            textFieldType: TextFieldType.OTHER,
                            nextFocus: pointFocus,
                            focus: dateFocus,
                            decoration: inputDecoration(
                                labelText:
                                    appStore.translate('lbl_start_date')),
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2025),
                                currentDate: startDateQuiz,
                              ).then((date) {
                                if (date != null) {
                                  startDateQuiz = date;
                                  startDateController.text =
                                      DateFormat(CurrentDateFormat)
                                          .format(date);
                                }
                              }).catchError((e) {
                                log(e);
                              }).whenComplete(() {
                                showTimePicker(
                                        context: context,
                                        initialTime:
                                            TimeOfDay(hour: 24, minute: 60))
                                    .then((value) {
                                  if (value != null) {
                                    startDateTime = DateTime(
                                        startDateQuiz!.year,
                                        startDateQuiz!.month,
                                        startDateQuiz!.day,
                                        value.hour,
                                        value.minute);
                                    startDateController.text =
                                        DateFormat("dd-MM-yyyy HH:mm")
                                            .format(startDateQuiz!)
                                            .toString();
                                  }
                                });
                              });
                            },
                            validator: (s) {
                              if (s!.trim().isEmpty)
                                return errorThisFieldRequired;
                              return null;
                            },
                          ).expand(),
                          16.width,
                          AppTextField(
                            readOnly: true,
                            controller: endDateController,
                            textFieldType: TextFieldType.OTHER,
                            nextFocus: pointFocus,
                            focus: dateFocus,
                            decoration: inputDecoration(
                                labelText: appStore.translate('lbl_end_date')),
                            onTap: () {
                              showDatePicker(
                                context: context,
                                initialDate: startDateQuiz!,
                                firstDate: startDateQuiz!,
                                lastDate: DateTime(2025),
                                currentDate: endDateQuiz,
                              ).then((date) {
                                if (date != null) {
                                  endDateQuiz = date;

                                  endDateController.text =
                                      DateFormat(CurrentDateFormat)
                                          .format(date);
                                }
                              }).catchError((e) {
                                log(e);
                              }).whenComplete(() {
                                showTimePicker(
                                        context: context,
                                        initialTime:
                                            TimeOfDay(hour: 24, minute: 60))
                                    .then((value) {
                                  if (value != null) {
                                    endDateTime = DateTime(
                                        endDateQuiz!.year,
                                        endDateQuiz!.month,
                                        endDateQuiz!.day,
                                        value.hour,
                                        value.minute);
                                    endDateController.text =
                                        DateFormat("dd-MM-yyyy HH:mm")
                                            .format(endDateTime!)
                                            .toString();
                                  }
                                });
                              });
                            },
                            validator: (s) {
                              if (s!.trim().isEmpty)
                                return errorThisFieldRequired;
                              return null;
                            },
                          ).expand(),
                        ],
                      ),
                      16.height,
                      AppTextField(
                        controller: imageUrlController,
                        textFieldType: TextFieldType.NAME,
                        decoration: inputDecoration(
                            labelText: appStore.translate("lbl_image_uRL")),
                        focus: imageUrlFocus,
                        nextFocus: descriptionFocus,
                        validator: (s) {
                          // if (s!.isEmpty) return errorThisFieldRequired;
                          // if (!s.validateURL()) return 'URL is invalid';
                          // return null;
                          if (s!.trim().isEmpty && imagesPicket == null) {
                            return errorThisFieldRequired;
                          } else if (s.trim().isNotEmpty && !s.validateURL()) {
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
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colorSecondary),
                              image: imageData != null
                                  ? null
                                  : widget.quizData?.imageUrl == null
                                      ? null
                                      : DecorationImage(
                                          image: NetworkImage(
                                              widget.quizData?.imageUrl ?? ""),
                                          fit: BoxFit.cover,
                                        ),
                            ),
                            child: imageData != null
                                ? Center(
                                    child: imageData != null
                                        ? Image.memory(imageData!)
                                        : CircularProgressIndicator(),
                                  )
                                : widget.quizData?.imageUrl == null &&
                                        imagesPicket == null
                                    ? Center(
                                        child: Icon(Icons.image_rounded),
                                      )
                                    : null,
                          ),
                        ],
                      ),
                      16.width,
                      16.height,
                      AppTextField(
                        controller: descriptionController,
                        textFieldType: TextFieldType.NAME,
                        maxLines: 3,
                        minLines: 3,
                        decoration: inputDecoration(
                            labelText: appStore.translate("lbl_description")),
                        focus: descriptionFocus,
                        isValidationRequired: false,
                      ),
                      16.height,
                      Container(
                        width: context.width() * 0.5,
                        child: ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: selectedQuestionList.length,
                          itemBuilder: (_, index) {
                            QuestionData data = selectedQuestionList[index];
                            return Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  margin: EdgeInsets.symmetric(vertical: 2),
                                  decoration: BoxDecoration(
                                      color: gray.withOpacity(0.1)),
                                  child: Row(
                                    children: [
                                      8.width,
                                      Text('${index + 1}',
                                          style: secondaryTextStyle()),
                                      16.width,
                                      Text(
                                        data.questionTitle!,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: secondaryTextStyle(),
                                      ).expand(),
                                    ],
                                  ),
                                ),
                                Align(
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    margin: EdgeInsets.only(right: 16, top: 4),
                                    decoration: boxDecorationWithRoundedCorners(
                                      borderRadius: BorderRadius.circular(8),
                                      backgroundColor: appButtonColor,
                                    ),
                                    child: IconButton(
                                      icon: Icon(Icons.clear,
                                          size: 16, color: white),
                                      onPressed: () {
                                        updateSelectedQuestion(data, false);
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                  alignment: Alignment.centerRight,
                                ).paddingOnly(top: 8),
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
        ).paddingAll(16),
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
