import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../models/QuizHistoryModel.dart';
import '/../utils/constants.dart';

class QuizHistoryComponent extends StatefulWidget {
  static String tag = '/QuizHistoryComponent';

  final QuizHistoryModel? quizHistoryData;

  QuizHistoryComponent({this.quizHistoryData});

  @override
  QuizHistoryComponentState createState() => QuizHistoryComponentState();
}

class QuizHistoryComponentState extends State<QuizHistoryComponent> {
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
    return Container(
      margin: EdgeInsets.zero,
      decoration: boxDecorationWithRoundedCorners(borderRadius: BorderRadius.circular(defaultRadius), backgroundColor: Theme.of(context).cardColor),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.quizHistoryData!.quizTitle}', maxLines: 2, overflow: TextOverflow.ellipsis, style: primaryTextStyle()),
              8.height,
              Text('Score: ${widget.quizHistoryData!.rightQuestion}/${widget.quizHistoryData!.totalQuestion}', style: boldTextStyle()),
              8.height,
              Text('${DateFormat('dd-MM-yyyy kk:mm').format(DateTime.fromMicrosecondsSinceEpoch(widget.quizHistoryData!.createdAt!.microsecondsSinceEpoch))}', style: secondaryTextStyle()),
            ],
          ).expand(flex: 3),
          widget.quizHistoryData!.quizType!=QuizTypeGuessWord?widget.quizHistoryData!.quizType != QuizTypeSelfChallenge ? widget.quizHistoryData!.quizType != QuizTypeTrueFalse?widget.quizHistoryData!.quizType != QuizTypeRandom?16.width:SizedBox() : SizedBox():SizedBox():SizedBox(),
          widget.quizHistoryData!.quizType!=QuizTypeGuessWord? widget.quizHistoryData!.quizType != QuizTypeSelfChallenge ? widget.quizHistoryData!.quizType != QuizTypeTrueFalse?widget.quizHistoryData!.quizType != QuizTypeRandom?Image.network(widget.quizHistoryData!.image!, height: 100, fit: BoxFit.fill).cornerRadiusWithClipRRect(defaultRadius).expand(flex: 2):SizedBox() : SizedBox():SizedBox():SizedBox(),
        ],
      ),
    );
  }
}
