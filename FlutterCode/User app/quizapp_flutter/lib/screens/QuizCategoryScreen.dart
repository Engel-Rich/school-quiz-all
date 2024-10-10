import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../components/QuizCategoryComponent.dart';
import '/../main.dart';
import '/../models/CategoryModel.dart';
import '/../screens/QuizScreen.dart';
import '/../utils/widgets.dart';

import '../components/AppBarComponent.dart';

class QuizCategoryScreen extends StatefulWidget {
  static String tag = '/QuizCategoryScreen';

  @override
  QuizCategoryScreenState createState() => QuizCategoryScreenState();
}

class QuizCategoryScreenState extends State<QuizCategoryScreen> {
  List<CategoryModel> categoryItems = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(
          context: context, title: appStore.translate('lbl_quiz_category')),
      body: FutureBuilder(
        future: categoryService.categories(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<CategoryModel> data = snapshot.data as List<CategoryModel>;
            return SingleChildScrollView(
              child: Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.all(16),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: List.generate(
                    data.length,
                    (index) {
                      CategoryModel? mData = data[index];
                      return QuizCategoryComponent(category: mData).onTap(
                        () {
                          QuizScreen(catId: mData.id, catName: mData.name)
                              .launch(context);
                        },
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                      );
                    },
                  ),
                ),
              ),
            );
          }
          return snapWidgetHelper(snapshot,
              errorWidget:
                  emptyWidget(text: appStore.translate('lbl_noDataFound')));
        },
      ),
    );
  }
}
