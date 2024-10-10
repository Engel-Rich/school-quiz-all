import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:quizeapp/models/QuestionData.dart';
import 'package:quizeapp/utils/Constants.dart';

import '../../../main.dart';
import '../../../utils/Colors.dart';
import '../AddNewQuestionsScreen.dart';
import 'AppWidgets.dart';

class QuestionsPaginationWidget extends StatefulWidget {
  final Query questionQuery;
  final UniqueKey uniqueKey;

  QuestionsPaginationWidget(this.uniqueKey, this.questionQuery);

  @override
  _QuestionsPaginationWidgetState createState() => _QuestionsPaginationWidgetState();
}

class _QuestionsPaginationWidgetState extends State<QuestionsPaginationWidget> {

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
    return PaginateFirestore(
      key: widget.uniqueKey,
      query: widget.questionQuery,
      shrinkWrap: true,
      padding: EdgeInsets.all(8),
      itemsPerPage: DocLimit,
      bottomLoader: Loader(valueColor: AlwaysStoppedAnimation(colorPrimary)),
      initialLoader: Loader(valueColor: AlwaysStoppedAnimation(colorPrimary)),
      isLive: true,
      onEmpty: noDataWidget(),
      onError: (e) => Text(e.toString(), style: primaryTextStyle()).center(),
      itemBuilderType: PaginateBuilderType.listView,
      itemBuilder: (context, documentSnapshots, index) {
        QuestionData data = QuestionData.fromJson(documentSnapshots[index].data() as Map<String, dynamic>);

        return Container(
          decoration: BoxDecoration(boxShadow: defaultBoxShadow(), color: Colors.white, borderRadius: radius()),
          margin: EdgeInsets.only(bottom: 8, top: 8, right: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    // padding: EdgeInsets.all(16),
                    // margin: EdgeInsets.only(top: 8, bottom: 8),
                    child: Text('${index + 1}. ' + ' ${data.questionTitle}'.trim().capitalizeFirstLetter(), style: boldTextStyle(size: 18)),
                  ).expand(),
                  16.width,
                  InkWell(
                    onTap: () {
                      AddNewQuestionsScreen(data: data, isShowElevation: true).launch(context);
                    },
                    child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(colors: [colorPrimary, colorSecondary], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight),
                        ),
                        child: Icon(Icons.edit, color: Colors.white, size: 18)),
                  ),
                  16.width,
                  InkWell(
                    onTap: () {
                      showConfirmDialogCustom(
                        context,
                        title: appStore.translate("lbl_delete_questions"),
                        positiveText: appStore.translate("lbl_yes"),
                        negativeText: appStore.translate("lbl_no"),
                        primaryColor: colorPrimary,
                        onAccept: (p0) {
                          if (getBoolAsync(IS_TEST_USER)) return toast(mTestUserMsg);

                          questionServices.removeDocument(data.id).then(
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
                    child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(colors: [colorPrimary, colorSecondary], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight),
                        ),
                        child: Icon(Icons.delete, color: Colors.white, size: 18)),
                  )
                ],
              ),
              22.height,
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Wrap(
                  direction: Axis.horizontal,
                  children: data.optionList!.map(
                    (e) {
                      return Container(
                        padding: EdgeInsets.all(8),
                        margin: EdgeInsets.only(right: 16),
                        alignment: Alignment.center,
                        decoration: boxDecorationWithRoundedCorners(
                          borderRadius: BorderRadius.circular(8),
                          backgroundColor: e == data.correctAnswer ? Colors.green : Colors.transparent,
                          border: Border.all(color: gray.withOpacity(0.4), width: 0.1),
                        ),
                        child: Text(e, style: e == data.correctAnswer ? boldTextStyle(color: Colors.white) : secondaryTextStyle(color: Colors.black)),
                      );
                    },
                  ).toList(),
                ),
              ),
              // 16.height,
              Row(
                children: [
                  Text(appStore.translate("lbl_correct_answer"), style: boldTextStyle(size: 18)),
                  8.width,
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8),
                    decoration: boxDecorationWithRoundedCorners(
                      borderRadius: BorderRadius.circular(8),
                      backgroundColor: Colors.green,
                    ),
                    child: Text(data.correctAnswer!, style: boldTextStyle(color: Colors.white)),
                  ),
                ],
              ).visible(data.questionType == 'GuessWord')
            ],
          ).paddingSymmetric(horizontal: 16, vertical: 16),
        );
      },
    );
  }
}
