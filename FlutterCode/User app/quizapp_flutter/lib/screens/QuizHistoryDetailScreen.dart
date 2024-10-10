import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../main.dart';
import '/../models/QuizHistoryModel.dart';
import '/../utils/images.dart';
import '../components/AppBarComponent.dart';

class QuizHistoryDetailScreen extends StatefulWidget {
  static String tag = '/QuizHistoryDetailScreen';

  final QuizHistoryModel? quizHistoryData;

  QuizHistoryDetailScreen({this.quizHistoryData});

  @override
  QuizHistoryDetailScreenState createState() => QuizHistoryDetailScreenState();
}

class QuizHistoryDetailScreenState extends State<QuizHistoryDetailScreen> {
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
      appBar: appBarComponent(context: context, title: ''),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.quizHistoryData!.quizTitle}',
                        style: boldTextStyle(size: 17)),
                    16.height,
                    Text(
                        '${appStore.translate('lbl_total_questions')}: ${widget.quizHistoryData!.totalQuestion}',
                        style: boldTextStyle(size: 17)),
                  ],
                ),
                Row(
                  children: [
                    Image.asset(rightIconImage, height: 30, width: 30),
                    8.width,
                    Text('${widget.quizHistoryData!.rightQuestion}',
                        style: boldTextStyle(size: 20)),
                    16.width,
                    Image.asset(wrongIconImage, height: 30, width: 30),
                    8.width,
                    Text(
                        '${widget.quizHistoryData!.totalQuestion! - widget.quizHistoryData!.rightQuestion!}',
                        style: boldTextStyle(size: 20)),
                  ],
                ),
              ],
            ),
            16.height,
            Divider(),
            16.height,
            ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: widget.quizHistoryData!.quizAnswers!.length,
              itemBuilder: (context, index) {
                QuizAnswer mData = widget.quizHistoryData!.quizAnswers![index];
                return Container(
                  decoration: boxDecorationWithRoundedCorners(
                      backgroundColor: Theme.of(context).cardColor),
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${index + 1}.', style: boldTextStyle()),
                      16.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${mData.question}',
                              softWrap: true, style: primaryTextStyle()),
                          16.height,
                          Container(
                            padding: EdgeInsets.all(8),
                            width: context.width(),
                            decoration: boxDecorationWithRoundedCorners(
                                backgroundColor:
                                    mData.correctAnswer == mData.answers
                                        ? Colors.green.shade500
                                        : Colors.red.shade500),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(appStore.translate('lbl_answer') + ":",
                                    style: boldTextStyle(color: Colors.white)),
                                8.height,
                                Text('${mData.answers}',
                                    softWrap: true,
                                    style:
                                        primaryTextStyle(color: Colors.white)),
                              ],
                            ),
                          ),
                          16.height,
                          Container(
                            padding: EdgeInsets.all(8),
                            width: context.width(),
                            decoration: boxDecorationWithRoundedCorners(
                                backgroundColor: Theme.of(context).cardColor),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    appStore.translate('lbl_correct_answer') +
                                        ':',
                                    style: boldTextStyle()),
                                8.height,
                                Text('${mData.correctAnswer}',
                                    softWrap: true, style: primaryTextStyle()),
                              ],
                            ),
                          ),
                        ],
                      ).expand(),
                    ],
                  ),
                );
              },
            ),
          ],
        ).paddingOnly(left: 16, right: 16),
      ),
    );
  }
}
