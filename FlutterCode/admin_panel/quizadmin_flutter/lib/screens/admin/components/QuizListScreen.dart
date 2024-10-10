import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/models/QuizData.dart';
import 'package:quizeapp/screens/admin/components/AppWidgets.dart';
import 'package:quizeapp/screens/admin/components/QuizItemWidget.dart';

import '../../../utils/Colors.dart';

class QuizListScreen extends StatefulWidget {
  static String tag = '/QuizListScreen';

  @override
  _QuizListScreenState createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  List<CategoryData> categoriesFilter = [];
  List<CategoryData> subcategoriesFilter = [];
  CategoryData? selectedCategoryForFilter;
  CategoryData? selectedSubCategoryForFilter;

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
                          onChanged: (CategoryData? c) {
                            subcategoriesFilter = [];
                            selectedSubCategoryForFilter = null;
                            selectedCategoryForFilter = c;
                            if (selectedCategoryForFilter!.name ==
                                'All Categories') {
                            } else {
                              if (selectedCategoryForFilter?.id != null) {
                                getSubcategorie(selectedCategoryForFilter!.id!);
                              }
                            }
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
                            } else {
                              print("it is not null");
                            }

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
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: double.infinity),
            StreamBuilder<List<QuizData>>(
              stream: quizServices.streamQuizList(
                  category: selectedCategoryForFilter?.id,
                  subCategory: selectedSubCategoryForFilter?.id),
              builder: (_, snap) {
                if (snap.hasData) {
                  if (snap.data!.isEmpty) return noDataWidget();

                  return Wrap(
                    spacing: 16,
                    runSpacing: 24,
                    children: snap.data!.map((e) => QuizItemWidget(e)).toList(),
                  );
                } else {
                  return snapWidgetHelper(snap,
                      loadingWidget: Loader(
                              valueColor: AlwaysStoppedAnimation(colorPrimary))
                          .paddingOnly(top: 350));
                }
              },
            ),
          ],
        ),
      ),
    ).cornerRadiusWithClipRRect(16);
  }
}
