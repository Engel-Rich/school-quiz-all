import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/models/QuestionData.dart';
import 'package:quizeapp/services/Settingservice.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';

import '../../utils/Colors.dart';

class AddNewQuestionsScreen extends StatefulWidget {
  final QuestionData? data;
  final bool isShowElevation;

  AddNewQuestionsScreen({this.data, this.isShowElevation = false});

  @override
  AddQuestionsScreenState createState() => AddQuestionsScreenState();
}

class AddQuestionsScreenState extends State<AddNewQuestionsScreen>
    with WidgetsBindingObserver {
  var formKey = GlobalKey<FormState>();
  AsyncMemoizer categoryMemoizer = AsyncMemoizer<List<CategoryData>>();

  TextEditingController questionImageCont = TextEditingController();
  FocusNode questionImageFocus = FocusNode();

  FocusNode questionFocus = FocusNode();

  List<String> options = [];

  String questionType = QuestionTypeOption;

  String? correctAnswer;

  String option1 = 'Answer 1 is empty';
  String option2 = 'Answer 2 is empty';
  String option3 = 'Answer 3 is empty';
  String option4 = 'Answer 4 is empty';
  String option5 = 'Answer 5 is empty';

  int? questionTypeGroupValue = 1;
  CategoryData? selectedCategory;

  //Add Line
  CategoryData? selectedSubCategory;

  List<CategoryData> categories = [];

  //Add Line
  List<CategoryData> subCategories = [];

  bool isUpdate = false;

  bool selectSubCategoryValue = false;

  TextEditingController questionCont = TextEditingController();
  TextEditingController ansCont = TextEditingController();
  TextEditingController option1Cont = TextEditingController();
  TextEditingController option2Cont = TextEditingController();
  TextEditingController option3Cont = TextEditingController();
  TextEditingController option4Cont = TextEditingController();
  TextEditingController option5Cont = TextEditingController();
  TextEditingController noteCont = TextEditingController();

  FocusNode option1Focus = FocusNode();
  FocusNode option2Focus = FocusNode();
  FocusNode option3Focus = FocusNode();
  FocusNode option4Focus = FocusNode();
  FocusNode option5Focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    init();
    initPalerStream();
  }

  Future<void> init() async {
    isUpdate = widget.data != null;

    if (isUpdate) {
      questionCont.text = widget.data!.questionTitle.validate();
      if (widget.data?.audio?.trim().isNotEmpty == true) {
        initAudioFromNetWork(widget.data!.audio!);
        log(widget.data!.audio);
      }
      if (widget.data!.questionType == QuestionTypeOption) {
        questionTypeGroupValue = 1;
      } else if (widget.data!.questionType == QuestionTypeTrueFalse) {
        questionTypeGroupValue = 2;
      } else if (widget.data!.questionType == QuestionTypeGuessWord) {
        questionTypeGroupValue = 3;
      } else if (widget.data!.questionType == QuestionTypePoll) {
        questionTypeGroupValue = 4;
      }

      if (widget.data!.optionList!.length > 0)
        option1Cont.text = widget.data!.optionList![0].validate();
      if (widget.data!.optionList!.length > 1)
        option2Cont.text = widget.data!.optionList![1].validate();
      if (widget.data!.optionList!.length > 2)
        option3Cont.text = widget.data!.optionList![2].validate();
      if (widget.data!.optionList!.length > 3)
        option4Cont.text = widget.data!.optionList![3].validate();
      if (widget.data!.optionList!.length > 4)
        option5Cont.text = widget.data!.optionList![4].validate();

      noteCont.text = widget.data!.note.validate();
      correctAnswer = widget.data!.correctAnswer.validate();
      questionImageCont.text = widget.data!.image.validate();
      ansCont.text = widget.data!.correctAnswer.validate();

      if (widget.data!.optionList!.length > 0)
        option1 = widget.data!.optionList![0].validate();
      if (widget.data!.optionList!.length > 1)
        option2 = widget.data!.optionList![1].validate();
      if (widget.data!.optionList!.length > 2)
        option3 = widget.data!.optionList![2].validate();
      if (widget.data!.optionList!.length > 3)
        option4 = widget.data!.optionList![3].validate();
      if (widget.data!.optionList!.length > 4)
        option5 = widget.data!.optionList![4].validate();

      /// Load subCategories
      subCategories = await categoryService.subCategoriesFuture(
          parentCategoryId: widget.data!.categoryRef!.id);

      if (subCategories.isNotEmpty) {
        if (isUpdate) {
          try {
            selectedSubCategory = subCategories.firstWhere(
                (element) => element.id == widget.data!.subcategoryId!);
          } catch (e) {
            print(e);
          }
        } else {
          selectedSubCategory = subCategories.first;
        }
      }
      setState(() {});
    }

    /// Load categories
    categories =
        await categoryService.categoriesFuture(classe: appStore.classeModel);

    if (categories.isNotEmpty) {
      if (isUpdate) {
        try {
          selectedCategory = categories.firstWhere(
              (element) => element.id == widget.data!.categoryRef!.id);
        } catch (e) {
          print(e);
        }
      } else {
        selectedCategory = categories.first;
      }
    }
    setState(() {});
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

    if (selectedCategory == null) {
      return toast('Please Select Category');
    }

    if (questionTypeGroupValue != 3) {
      if (correctAnswer == null) {
        return toast('Please Select Correct Answer');
      }
    }

    if (formKey.currentState!.validate()) {
      QuestionData questionData = QuestionData();

      options.clear();

      if (questionType == QuestionTypeOption) {
        if (option1Cont.text.trim().isNotEmpty &&
            !options.contains(option1Cont.text))
          options.add(option1Cont.text.trim());
        if (option2Cont.text.trim().isNotEmpty &&
            !options.contains(option2Cont.text))
          options.add(option2Cont.text.trim());
        if (option3Cont.text.trim().isNotEmpty &&
            !options.contains(option3Cont.text))
          options.add(option3Cont.text.trim());
        if (option4Cont.text.trim().isNotEmpty &&
            !options.contains(option4Cont.text))
          options.add(option4Cont.text.trim());
        if (option5Cont.text.trim().isNotEmpty &&
            !options.contains(option5Cont.text))
          options.add(option5Cont.text.trim());
      } else if (questionType == QuestionTypeTrueFalse) {
        if (option1Cont.text.trim().isNotEmpty)
          options.add(option1Cont.text.trim());
        if (option2Cont.text.trim().isNotEmpty)
          options.add(option2Cont.text.trim());
      }

      questionData.image = questionImageCont.text.trim();
      questionData.questionTitle = questionCont.text.trim();
      questionData.note = noteCont.text.trim();
      questionData.questionType = questionType;
      if (appStore.classeModel != null &&
          appStore.classeModel?.trim().isNotEmpty == true) {
        questionData.classe = appStore.classeModel;
      }

      if (questionTypeGroupValue == 3) {
        questionData.correctAnswer = ansCont.text.toUpperCase();
      } else {
        questionData.correctAnswer = correctAnswer;
      }
      questionData.updatedAt = DateTime.now();
      questionData.optionList = options;

      if (selectedCategory != null) {
        questionData.categoryRef =
            categoryService.ref.doc(selectedCategory!.id);
      }

      if (selectSubCategoryValue == true) {
        if (selectedSubCategory != null) {
          questionData.subcategoryId = selectedSubCategory!.id;
        }
      } else {
        if (selectedSubCategory != null) {
          questionData.subcategoryId = "";
        }
      }
      if (isUpdate) {
        questionData.audio = widget.data?.audio;
      }
      /*   if (selectedSubCategory != null) {
        questionData.subcategoryId = selectedSubCategory!.id;
      }*/
      setState(() => loadingSave = true);

      if (imagesPicket != null) {
        await saveFile("Question/Images", imagesPicket!).then((value) {
          if (value != null) {
            questionData.image = value;
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

      if (audioData != null) {
        await saveAudio("Question/Audio/${selectedCategory!.name}", audioData!)
            .then((value) {
          if (value != null) {
            questionData.audio = value;
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

      if (isUpdate) {
        questionData.id = widget.data!.id;
        questionData.createdAt = widget.data!.createdAt;

        await questionServices
            .updateDocument(questionData.toJson(), questionData.id)
            .then(
          (value) async {
            toast('Update Successfully');
            setState(() => loadingSave = false);
            await disposePalerStream();
            finish(context);
          },
        ).catchError(
          (e) {
            setState(() => loadingSave = false);
            log(e.toString());
          },
        );
      } else {
        questionData.createdAt = DateTime.now();

        questionServices.addDocument(questionData.toJson()).then(
          (value) async {
            toast('Added Question Successfully');
            setState(() => loadingSave = false);
            await disposePalerStream();
            options.clear();

            questionImageCont.clear();
            option1Cont.clear();
            option2Cont.clear();
            option3Cont.clear();
            option4Cont.clear();
            option5Cont.clear();
            questionCont.clear();
            noteCont.clear();
            ansCont.clear();

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

  @override
  void dispose() {
    disposePalerStream();
    super.dispose();
  }
  // QuestionMediaType? mediaType = QuestionMediaType.image;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    options.clear();
    if (questionType == QuestionTypeOption) {
      if (option1Cont.text.trim().isNotEmpty &&
          !options.contains(option1Cont.text))
        options.add(option1Cont.text.trim());
      if (option2Cont.text.trim().isNotEmpty &&
          !options.contains(option2Cont.text))
        options.add(option2Cont.text.trim());
      if (option3Cont.text.trim().isNotEmpty &&
          !options.contains(option3Cont.text))
        options.add(option3Cont.text.trim());
      if (option4Cont.text.trim().isNotEmpty &&
          !options.contains(option4Cont.text))
        options.add(option4Cont.text.trim());
      if (option5Cont.text.trim().isNotEmpty &&
          !options.contains(option5Cont.text))
        options.add(option5Cont.text.trim());
    } else {
      if (option1Cont.text.trim().isNotEmpty)
        options.add(option1Cont.text.trim());
      if (option2Cont.text.trim().isNotEmpty)
        options.add(option2Cont.text.trim());
    }

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        elevation: widget.isShowElevation ? 1 : 0,
        leading: isUpdate
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: black),
                onPressed: () {
                  finish(context);
                },
              )
            : null,
        title: Text(
            !isUpdate
                ? appStore.translate("lbl_create_new_question")
                : appStore.translate("lbl_update_question"),
            style: boldTextStyle(size: 22)),
        actions: [
          isUpdate
              ? IconButton(
                  icon: Icon(Icons.delete_outline, color: black),
                  onPressed: () {
                    showConfirmDialogCustom(
                      context,
                      title: appStore.translate("lbl_delete_questions"),
                      positiveText: appStore.translate("lbl_yes"),
                      negativeText: appStore.translate("lbl_no"),
                      primaryColor: colorPrimary,
                      onAccept: (p0) {
                        if (getBoolAsync(IS_TEST_USER))
                          return toast(mTestUserMsg);

                        questionServices.removeDocument(widget.data!.id).then(
                          (value) {
                            toast('Delete Successfully');
                            finish(context);
                            finish(context, true);
                          },
                        ).catchError(
                          (e) {
                            log("toast" + e.toString());
                          },
                        );
                      },
                    );
                  },
                ).paddingOnly(right: 8)
              : SizedBox(),
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: isUpdate ? const EdgeInsets.all(15) : null,
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: DropdownButton(
                                  underline: Offstage(),
                                  items: categories.map((e) {
                                    return DropdownMenuItem(
                                        child: Text(e.name.validate()),
                                        value: e);
                                  }).toList(),
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
                                  Text(
                                      appStore
                                          .translate("lbl_select_sub_category"),
                                      style: boldTextStyle()),
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
                                          .map<DropdownMenuItem<CategoryData>>(
                                        (e) {
                                          return DropdownMenuItem(
                                            child: Text(e.name.validate()),
                                            value: e,
                                          );
                                        },
                                      ).toList(),
                                      isExpanded: true,
                                      onChanged: (c) {
                                        log(c);
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
                      ],
                    ),
                    16.height,
                    Row(
                      children: [
                        AppTextField(
                          controller: questionCont,
                          textFieldType: TextFieldType.NAME,
                          focus: questionFocus,
                          nextFocus: questionImageFocus,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 2,
                          minLines: 1,
                          decoration: inputDecoration(
                              labelText: appStore.translate("lbl_question")),
                          validator: (s) {
                            if (s!.trim().isEmpty)
                              return errorThisFieldRequired;
                            return null;
                          },
                        ).expand(),
                        16.width,
                        AppTextField(
                          controller: questionImageCont,
                          textFieldType: TextFieldType.OTHER,
                          focus: questionImageFocus,
                          decoration: inputDecoration(
                              labelText: appStore.translate("lbl_image_uRL")),
                          keyboardType: TextInputType.url,
                          isValidationRequired: false,
                          validator: (s) {
                            if (s!.trim().isEmpty && imagesPicket == null) {
                              return errorThisFieldRequired;
                            } else if (s.trim().isNotEmpty &&
                                !s.validateURL()) {
                              return 'URL is invalid';
                            }
                            return null;
                          },
                        ).expand(),
                      ],
                    ),
                    16.height,
                    !context.isDesktop()
                        ? SizedBox(
                            height: 150,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(appStore.translate("lbl_question_type"),
                                    style: boldTextStyle()),
                                16.width,
                                Container(
                                  child: RadioListTile(
                                    value: 1,
                                    groupValue: questionTypeGroupValue,
                                    title: Text(
                                        appStore.translate("lbl_options"),
                                        style: boldTextStyle(size: 18)),
                                    onChanged: (dynamic newValue) {
                                      questionTypeGroupValue = newValue;
                                      option1Cont.text = '';
                                      option2Cont.text = '';
                                      questionType = QuestionTypeOption;

                                      correctAnswer = null;
                                      setState(() {});
                                    },
                                    activeColor: Colors.red,
                                    selected: true,
                                  ),
                                ).expand(),
                                16.width,
                                Container(
                                  child: RadioListTile(
                                    value: 2,
                                    groupValue: questionTypeGroupValue,
                                    title: Text(
                                        appStore.translate("lbl_true_false"),
                                        style: boldTextStyle(size: 18)),
                                    onChanged: (dynamic newValue) {
                                      questionTypeGroupValue = newValue;
                                      option1Cont.text = 'true';
                                      option2Cont.text = 'false';

                                      questionType = QuestionTypeTrueFalse;
                                      correctAnswer = null;

                                      setState(() {});
                                    },
                                    activeColor: Colors.red,
                                    selected: false,
                                  ),
                                ).expand(),
                                Container(
                                  child: RadioListTile(
                                    value: 3,
                                    groupValue: questionTypeGroupValue,
                                    title: Text(
                                        appStore.translate('lbl_guess_word'),
                                        style: boldTextStyle(size: 18)),
                                    onChanged: (dynamic newValue) {
                                      print(newValue);
                                      questionTypeGroupValue = newValue;
                                      questionType = QuestionTypeGuessWord;

                                      correctAnswer = null;
                                      setState(() {});
                                    },
                                    activeColor: Colors.red,
                                    selected: true,
                                  ),
                                ).expand(),
                                16.width,
                              ],
                            ),
                          )
                        : Row(
                            children: [
                              Text(appStore.translate("lbl_question_type"),
                                  style: boldTextStyle()),
                              16.width,
                              Container(
                                child: RadioListTile(
                                  value: 1,
                                  groupValue: questionTypeGroupValue,
                                  title: Text(appStore.translate("lbl_options"),
                                      style: boldTextStyle(size: 18)),
                                  onChanged: (dynamic newValue) {
                                    questionTypeGroupValue = newValue;
                                    option1Cont.text = '';
                                    option2Cont.text = '';
                                    questionType = QuestionTypeOption;

                                    correctAnswer = null;
                                    setState(() {});
                                  },
                                  activeColor: Colors.red,
                                  selected: true,
                                ),
                              ).expand(),
                              16.width,
                              Container(
                                child: RadioListTile(
                                  value: 2,
                                  groupValue: questionTypeGroupValue,
                                  title: Text(
                                      appStore.translate("lbl_true_false"),
                                      style: boldTextStyle(size: 18)),
                                  onChanged: (dynamic newValue) {
                                    questionTypeGroupValue = newValue;
                                    option1Cont.text = 'true';
                                    option2Cont.text = 'false';
                                    questionType = QuestionTypeTrueFalse;
                                    correctAnswer = null;
                                    setState(() {});
                                  },
                                  activeColor: Colors.red,
                                  selected: false,
                                ),
                              ).expand(),
                              Container(
                                child: RadioListTile(
                                  value: 3,
                                  groupValue: questionTypeGroupValue,
                                  title: Text(
                                      appStore.translate('lbl_guess_word'),
                                      style: boldTextStyle(size: 18)),
                                  onChanged: (dynamic newValue) {
                                    print(newValue);
                                    questionTypeGroupValue = newValue;
                                    questionType = QuestionTypeGuessWord;

                                    correctAnswer = null;
                                    setState(() {});
                                  },
                                  activeColor: Colors.red,
                                  selected: true,
                                ),
                              ).expand(),
                              16.width,
                            ],
                          ),
                    16.height,
                    Row(
                      children: [
                        Text("Images:", style: boldTextStyle()),
                        10.width,
                        SizedBox(
                          width: context.width() * 0.2,
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
                                : widget.data?.image == null
                                    ? null
                                    : DecorationImage(
                                        image: NetworkImage(
                                            widget.data?.image ?? ""),
                                        fit: BoxFit.cover,
                                      ),
                          ),
                          child: imageData != null
                              ? Center(
                                  child: imageData != null
                                      ? Image.memory(imageData!)
                                      : CircularProgressIndicator(),
                                )
                              : widget.data?.image == null &&
                                      imagesPicket == null
                                  ? Center(
                                      child: Icon(Icons.image_rounded),
                                    )
                                  : null,
                        ),
                      ],
                    ),
                    16.height,
                    //
                    // Fichier Audio
                    //
                    Row(
                      children: [
                        Text("Audio :", style: boldTextStyle()),
                        10.width,
                        SizedBox(
                          width: context.width() * 0.2,
                          child: commonAppButton(
                            context,
                            '',
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Choisir l\'audio'),
                                8.width,
                                Icon(Icons.file_copy_outlined)
                              ],
                            ),
                            onTap: () async {
                              await pickAudio();
                            },
                          ),
                        ),
                        16.width,
                        Container(
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: colorSecondary),
                          ),
                          child: loadingAudio
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 21, horizontal: 10),
                                  child: LinearProgressIndicator(
                                    color: colorPrimary,
                                    minHeight: 5,
                                    borderRadius: BorderRadius.circular(5),
                                  ))
                              : duration == null
                                  ? null
                                  : BuildPlayerWidger(),
                        ).expand(),
                      ],
                    ),
                    16.height,
                    //
                    //Fin
                    //

                    Row(
                      children: [
                        Text(appStore.translate('lbl_enter_ans'),
                                style: boldTextStyle())
                            .visible(questionTypeGroupValue == 3)
                            .visible(questionTypeGroupValue == 3),
                        Row(
                          children: [
                            Text(appStore.translate("lbl_potion_a"),
                                style: boldTextStyle()),
                            8.width,
                            AppTextField(
                              controller: option1Cont,
                              focus: option1Focus,
                              nextFocus: option2Focus,
                              textFieldType: TextFieldType.NAME,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: inputDecoration(),
                              keyboardType: TextInputType.url,
                              enabled: questionTypeGroupValue == 1,
                              onChanged: (s) {
                                option1 = s;
                                correctAnswer = null;
                                setState(() {});
                              },
                              validator: (s) {
                                if (s!.trim().isEmpty)
                                  return errorThisFieldRequired;
                                return null;
                              },
                            ).expand(),
                          ],
                        ).expand().visible(questionTypeGroupValue != 3),
                        16.width,
                        Row(
                          children: [
                            Text(appStore.translate("lbl_potion_b"),
                                style: boldTextStyle()),
                            8.width,
                            AppTextField(
                              controller: option2Cont,
                              focus: option2Focus,
                              nextFocus: option3Focus,
                              textFieldType: TextFieldType.NAME,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: inputDecoration(),
                              keyboardType: TextInputType.url,
                              enabled: questionTypeGroupValue == 1,
                              onChanged: (s) {
                                option2 = s;
                                correctAnswer = null;
                                setState(() {});
                              },
                              validator: (s) {
                                if (s!.trim().isEmpty)
                                  return errorThisFieldRequired;
                                return null;
                              },
                            ).expand(),
                          ],
                        ).expand().visible(questionTypeGroupValue != 3),
                      ],
                    ),
                    16.height,
                    Row(
                      children: [
                        AppTextField(
                          textFieldType: TextFieldType.NAME,
                          controller: ansCont,
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 1,
                          decoration: inputDecoration(
                              labelText: appStore.translate('lbl_enter_ans')),
                          validator: (s) {
                            if (s!.trim().isEmpty)
                              return errorThisFieldRequired;
                            return null;
                          },
                        ).expand().visible(questionTypeGroupValue == 3),
                        Row(
                          children: [
                            Text(appStore.translate("lbl_potion_c"),
                                style: boldTextStyle()),
                            8.width,
                            AppTextField(
                              controller: option3Cont,
                              focus: option3Focus,
                              nextFocus: option4Focus,
                              textFieldType: TextFieldType.NAME,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: inputDecoration(),
                              keyboardType: TextInputType.url,
                              isValidationRequired: false,
                              onChanged: (s) {
                                option3 = s;
                                correctAnswer = null;

                                setState(() {});
                              },
                              validator: (s) {
                                if (s!.trim().isEmpty)
                                  return errorThisFieldRequired;
                                return null;
                              },
                            ).expand(),
                          ],
                        ).expand().visible(questionTypeGroupValue == 1),
                        16.width,
                        Row(
                          children: [
                            Text(appStore.translate("lbl_potion_d"),
                                style: boldTextStyle()),
                            8.width,
                            AppTextField(
                              controller: option4Cont,
                              focus: option4Focus,
                              nextFocus: option5Focus,
                              textFieldType: TextFieldType.NAME,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: inputDecoration(),
                              keyboardType: TextInputType.url,
                              isValidationRequired: false,
                              onChanged: (s) {
                                option4 = s;
                                correctAnswer = null;
                                setState(() {});
                              },
                              validator: (s) {
                                if (s!.trim().isEmpty)
                                  return errorThisFieldRequired;
                                return null;
                              },
                            ).expand(),
                          ],
                        ).expand().visible(questionTypeGroupValue == 1),
                      ],
                    ),
                    16.height,
                    Row(
                      children: [
                        Row(
                          children: [
                            Text(appStore.translate("lbl_potion_e"),
                                style: boldTextStyle()),
                            8.width,
                            AppTextField(
                              controller: option5Cont,
                              focus: option5Focus,
                              textFieldType: TextFieldType.NAME,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: inputDecoration(),
                              keyboardType: TextInputType.url,
                              onChanged: (s) {
                                option5 = s;
                                correctAnswer = null;
                                setState(() {});
                              },
                              isValidationRequired: false,
                              validator: (s) {
                                return null;
                              },
                            ).expand(),
                          ],
                        ).expand(),
                        16.width,
                        SizedBox().expand()
                      ],
                    ).visible(questionTypeGroupValue == 1),
                    16.height,
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                appStore.translate("lbl_select_correct_answer"),
                                style: boldTextStyle()),
                            8.height,
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: radius(),
                                  color: Colors.grey.shade200),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 4),
                              child: DropdownButton<String>(
                                isExpanded: true,
                                underline: Offstage(),
                                hint: Text('Select Correct Answer'),
                                value: correctAnswer,
                                onChanged: (newValue) {
                                  correctAnswer = newValue;

                                  setState(() {});
                                },
                                items: options.map(
                                  (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value.validate(value: '')),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ],
                        ).expand().visible(questionTypeGroupValue != 3),
                        16.width.visible(questionTypeGroupValue != 3),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(appStore.translate("lbl_add_note"),
                                style: boldTextStyle()),
                            8.height,
                            AppTextField(
                              controller: noteCont,
                              textFieldType: TextFieldType.NAME,
                              textCapitalization: TextCapitalization.sentences,
                              maxLines: 3,
                              minLines: 1,
                              decoration: inputDecoration(labelText: 'Note'),
                              isValidationRequired: false,
                            ),
                          ],
                        ).expand(),
                      ],
                    ),
                    16.height,
                    Align(
                      alignment: Alignment.bottomRight,
                      child: commonAppButton(
                          context,
                          isUpdate
                              ? appStore.translate("lbl_save")
                              : appStore.translate("lbl_create_now"),
                          onTap: () {
                        if (!loadingSave)
                          save();
                        else
                          toast("Opération en cour");
                      }, isFull: false),
                    )
                  ],
                ).paddingAll(16),
              ),
            ),
          ),
          loadingSave
              ? Container(
                  height: double.infinity,
                  width: double.infinity,
                  child: Center(
                    child: Loader(),
                  ),
                )
              : const SizedBox.shrink()
        ],
      ),
    ).cornerRadiusWithClipRRect(16);
  }

  File? imagesPicket;
  File? audioPicket;

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

// Audio playser variables;

  final player = AudioPlayer();
  bool loadingAudio = false;
  bool loadingSave = false;

  Future pickAudio() async {
    setState(() => loadingAudio = true);
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      final file = result.files.single.bytes!;
      audioData = file;
      await player
          .setAudioSource(MyCustomSource(audioData!.toList()))
          .then((value) {
        duration = value ?? Duration.zero;
        loadingAudio = false;
      }).onError((error, stackTrace) {
        loadingAudio = false;
        toast(error.toString());
      });

      setState(() {});
    } else {
      setState(() => loadingAudio = false);
    }
  }

  PLAYERSTATE playerstate = PLAYERSTATE.pause;
  Duration? duration;
  Duration position = Duration.zero;
  StreamSubscription? subscriptionPosition;
  StreamSubscription? subscriptionPlayed;
  StreamSubscription? subscriptionDuration;

  Widget BuildPlayerWidger() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              InkWell(
                splashColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                onTap: () async {
                  if (playerstate == PLAYERSTATE.played) {
                    await player.pause();
                  } else {
                    await player.play();
                  }
                },
                child: Icon(
                  playerstate != PLAYERSTATE.pause
                      ? Icons.pause_circle_outlined
                      : Icons.play_circle_outline,
                  size: 35,
                ),
              ),
              3.width,
              Text('${formatTime(position.inSeconds)}'),
              3.width,
              Slider(
                min: 0,
                max: duration!.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                activeColor: colorPrimary,
                onChanged: (value) async {
                  position = Duration(seconds: value.toInt());
                  await player.seek(position);
                  if (playerstate == PLAYERSTATE.played) player.play();
                  setState(() {});
                },
              ).expand(),
              5.width,
              Text('${formatTime(duration!.inSeconds - position.inSeconds)}'),
              InkWell(
                splashColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                onTap: () async {
                  await disposePalerStream();
                  setState(() {});
                },
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        2.height,
        Row(),
      ],
    );
  }

  initPalerStream() {
    subscriptionPosition = player.positionStream.listen((event) {
      position = event;
      // duration = (duration! - position);
      setState(() {});
    });
    subscriptionDuration = player.durationStream.listen((event) {
      if (event != null) {
        duration = event;
        setState(() {});
      }
    });
    subscriptionPlayed = player.playingStream.listen((event) {
      if (event) {
        playerstate = PLAYERSTATE.played;
        setState(() {});
      } else
        playerstate = PLAYERSTATE.pause;
      setState(() {});
    });
  }

  disposePalerStream() async {
    duration = null;
    position = Duration.zero;
    audioData = null;
    imageData = null;
    imagesPicket = null;
    await subscriptionDuration?.cancel();
    await subscriptionDuration?.cancel();
    await subscriptionPlayed?.cancel();
    await player.dispose();
  }

  initAudioFromNetWork(String url) async {
    setState(() => loadingAudio = false);
    await player.setUrl(url).then((value) {
      duration = value ?? Duration.zero;
      loadingAudio = false;
    }).onError((error, stackTrace) {
      loadingAudio = false;
      toast(error.toString());
    });
    setState(() {});
  }

  //
}

class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;
  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

String formatTime(int totalSeconds) {
  int minutes = totalSeconds ~/ 60;
  int seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
