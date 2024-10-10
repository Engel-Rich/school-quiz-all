import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/models/QuestionData.dart';
import 'package:quizeapp/models/QuizData.dart';
import 'package:quizeapp/screens/admin/components/QuestionsPaginationWidget.dart';

class AllQuestionsListWidget extends StatefulWidget {
  final QuizData? quizData;

  AllQuestionsListWidget({this.quizData});

  @override
  AllQuestionsListWidgetState createState() => AllQuestionsListWidgetState();
}

class AllQuestionsListWidgetState extends State<AllQuestionsListWidget> {
  Query questionQuery = questionServices.getQuestions();
  UniqueKey uniqueKey = UniqueKey();

  List<CategoryData> categoriesFilter = [];
  List<CategoryData> subcategoriesFilter = [];
  List<QuestionData> questionList = [];

  CategoryData? selectedCategoryForFilter;
  CategoryData? selectedSubCategoryForFilter;
  bool isLoading = true;
  bool isUpdate = false;
  late CategoryData selectedCategory;
  late CategoryData selectedSubCategory;

  ScrollController _controller = ScrollController();

  String text = 'Initial';

  @override
  void initState() {
    super.initState();

    init();
  }

  Future<void> getSubcategorie(String parentCategorieId) async {
    subcategoriesFilter.clear();
    categoryService
        .categoriesFuture(parentCategoryId: parentCategorieId)
        .then((value) {
      subcategoriesFilter.add(CategoryData(name: 'All SubCategories'));
      subcategoriesFilter.addAll(value);
      setState(() {});
    });
  }

  Future<void> init() async {
    /// Load categories

    categoryService
        .categoriesFuture(classe: appStore.classeModel)
        .then((value) async {
      categoriesFilter.add(CategoryData(name: 'All Categories'));
      categoriesFilter.addAll(value);

      selectedCategoryForFilter = categoriesFilter.first;

      if (categoriesFilter.isNotEmpty) {
        if (isUpdate) {
          try {
            selectedCategory = await categoryService
                .getCategoryById(widget.quizData!.categoryId);
          } catch (e) {
            log(e);
          }
        } else {
          selectedCategory = categoriesFilter.first;
        }
      }

      setState(() {});
    }).catchError((e) {
      //
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        title: Container(
          height: 150,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16, bottom: 4),
                child: Row(
                  children: [
                    if (categoriesFilter.isNotEmpty)
                      Container(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                            borderRadius: radius(),
                            color: Colors.grey.shade200),
                        child: DropdownButton(
                          underline: Offstage(),
                          hint: Text('Please choose a category'),
                          items: categoriesFilter.map((e) {
                            return DropdownMenuItem(
                                child: Text(e.name.validate()), value: e);
                          }).toList(),
                          icon: Icon(Icons.filter_list_alt),
                          value: selectedCategoryForFilter,
                          onChanged: (dynamic c) {
                            print("New categorie is selected");
                            subcategoriesFilter = [];
                            selectedSubCategoryForFilter = null;

                            selectedCategoryForFilter = c;
                            if (selectedCategoryForFilter!.name ==
                                'All Categories') {
                              questionQuery = questionServices.getQuestions();
                            } else {
                              questionQuery = questionServices.getQuestions(
                                  categoryRef: categoryService.ref
                                      .doc(selectedCategoryForFilter!.id));
                              if (selectedCategoryForFilter?.id != null) {
                                getSubcategorie(selectedCategoryForFilter!.id!);
                              }
                            }
                            uniqueKey = UniqueKey();
                            setState(() {});
                          },
                        ),
                      ),
                    const SizedBox(width: 30),

                    ///
                    ///Ajout des sous catégories
                    ///

                    if (subcategoriesFilter.isNotEmpty)
                      Container(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        decoration: BoxDecoration(
                            borderRadius: radius(),
                            color: Colors.grey.shade200),
                        child: DropdownButton(
                          underline: Offstage(),
                          hint: Text('Please choose a subcategory'),
                          items: subcategoriesFilter.map((e) {
                            return DropdownMenuItem(
                                child: Text(e.name.validate()), value: e);
                          }).toList(),
                          icon: Icon(Icons.filter_list_alt),
                          value: selectedSubCategoryForFilter,
                          onChanged: (dynamic c) {
                            selectedSubCategoryForFilter = c;
                            if (selectedSubCategoryForFilter?.id == null) {
                              questionQuery = questionServices.getQuestions(
                                  categoryRef: categoryService.ref
                                      .doc(selectedCategoryForFilter!.id));
                            } else {
                              print("it is not null");
                              questionQuery =
                                  questionServices.questionListQuery(
                                categoryRef: categoryService.ref
                                    .doc(selectedCategoryForFilter!.id),
                                subcategorie: selectedSubCategoryForFilter!.id,
                              );
                            }
                            uniqueKey = UniqueKey();
                            setState(() {});
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        // thumbVisibility: false,
        // thickness: 5.0,
        // radius: Radius.circular(16),
        child: QuestionsPaginationWidget(uniqueKey, questionQuery),
      ),
    ).cornerRadiusWithClipRRect(16);
  }
}
