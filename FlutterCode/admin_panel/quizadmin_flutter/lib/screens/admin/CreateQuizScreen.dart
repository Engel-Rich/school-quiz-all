import 'dart:html';

import 'package:async/async.dart';
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
// import 'package:quizeapp/models/SubCategoryData.dart';
import 'package:quizeapp/services/Settingservice.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';

class CreateQuizScreen extends StatefulWidget {
  final QuizData? quizData;

  CreateQuizScreen({this.quizData});

  @override
  CreateQuizScreenState createState() => CreateQuizScreenState();
}

class CreateQuizScreenState extends State<CreateQuizScreen> {
  AsyncMemoizer categoryMemoizer = AsyncMemoizer<List<CategoryData>>();
  AsyncMemoizer questionListMemoizer = AsyncMemoizer<List<QuestionData>>();

  var formKey = GlobalKey<FormState>();

  TextEditingController dateController = TextEditingController();
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
      dateController.text =
          DateFormat(CurrentDateFormat).format(widget.quizData!.createdAt!);
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
        quizData.isSpin = false;
        await quizServices
            .updateDocument(quizData.toJson(), widget.quizData!.id)
            .then((value) {
          toast('Updated');
          setState(() => loadingSave = false);
          finish(context);
        }).catchError((e) {
          setState(() => loadingSave = false);
          toast(e.toString());
        });
      } else {
        ///Create quiz
        quizData.createdAt = DateTime.now();
        quizData.isSpin = false;

        await quizServices.addDocument(quizData.toJson()).then(
          (value) {
            toast('Quiz Added');
            setState(() => loadingSave = false);
            if (sendNotification!) {
              //Send push notification
              sendPushNotifications('New Quiz Added',
                  parseHtmlString(titleController.text.trim()),
                  id: value.id);
            }

            dateController.clear();
            pointController.clear();
            titleController.clear();
            imageUrlController.clear();
            descriptionController.clear();
            imageData = null;
            imagesPicket = null;
            setState(() => loadingSave = false);

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
    dateController.dispose();
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
      appBar: mIsUpdate
          ? appBarWidget(widget.quizData!.quizTitle.validate())
          : null,
      floatingActionButton: AppButton(
        padding: EdgeInsets.all(16),
        color: colorPrimary,
        child: loadingSave
            ? Padding(
                padding: const EdgeInsets.all(5.0),
                child: CircularProgressIndicator(color: white),
              )
            : Text(appStore.translate("lbl_save"),
                style: primaryTextStyle(color: white)),
        onTap: () {
          if (!loadingSave)
            save();
          else
            toast("Opération en cour");
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            8.height,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (categories.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appStore.translate("lbl_select_category"),
                          style: boldTextStyle()),
                      8.height,
                      Container(
                        width: context.width() * 0.45,
                        decoration: BoxDecoration(
                            borderRadius: radius(),
                            color: Colors.grey.shade200),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: DropdownButton(
                          underline: Offstage(),
                          items: categories.map(
                            (e) {
                              return DropdownMenuItem(
                                  child: Text(e.name.validate()), value: e);
                            },
                          ).toList(),
                          isExpanded: true,
                          value: selectedCategory,
                          onChanged: (dynamic c) {
                            selectedCategory = c;
                            loadSubCategories(selectedCategory!.id!);
                          },
                        ),
                      ),
                    ],
                  ).expand(),
                16.width,
                selectedSubCategory != null && subCategories.isNotEmpty
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Select Sub Category', style: boldTextStyle()),
                          8.height,
                          Container(
                            width: context.width() * 0.45,
                            margin: EdgeInsets.only(bottom: 23),
                            decoration: BoxDecoration(
                                borderRadius: radius(),
                                color: Colors.grey.shade200),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: DropdownButton<CategoryData>(
                              value: selectedSubCategory,
                              underline: Offstage(),
                              hint: Text('Select Sub Category',
                                  style: secondaryTextStyle()),
                              items: subCategories
                                  .map<DropdownMenuItem<CategoryData>>((e) {
                                return DropdownMenuItem(
                                  child: Text(e.name.validate()),
                                  value: e,
                                );
                              }).toList(),
                              isExpanded: true,
                              onChanged: (c) {
                                selectedSubCategory = c;
                                selectSubCategoryValue = true;
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ).expand()
                    : Text(
                        appStore.translate("lbl_not_subcategory"),
                        style: boldTextStyle(),
                        textAlign: TextAlign.start,
                      ).paddingOnly(top: 40, right: 30),
                8.width,
              ],
            ),
            16.height,
            Divider(thickness: 0.5),
            16.height,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appStore.translate("lbl_select_questions"),
                        style: boldTextStyle()),
                    6.height,
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
                    8.height,
                    Container(
                      width: context.width() * 0.55,
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
                              height: context.height() * 0.49,
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
                                    QuestionData data = (questionList
                                      ..sort(
                                        (a, b) => a.createdAt!
                                            .compareTo(b.createdAt!),
                                      ))[index];
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
                                            updateSelectedQuestion(
                                                data, newValue);
                                          },
                                        ),
                                        8.width,
                                        // Text(),
                                        Text.rich(
                                          style: secondaryTextStyle(),
                                          TextSpan(
                                            text: "${data.questionTitle}, \n",
                                            children: [
                                              TextSpan(
                                                text: DateFormat(
                                                        "EEE d MMM y H:m")
                                                    .format(data.createdAt!),
                                                style: TextStyle(
                                                  color: colorPrimary,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ).expand(),
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
                      Text("Enter Quiz Details", style: boldTextStyle()),
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
                      16.width,
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

  ///
  ///Images Add functions
  ///

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

  ///
  ///Fin de la gestion de l'Image
  ///
}
