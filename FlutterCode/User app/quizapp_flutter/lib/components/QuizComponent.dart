import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../main.dart';
import '/../models/QuizModel.dart';
import '/../utils/constants.dart';

class QuizComponent extends StatefulWidget {
  static String tag = '/QuizComponent';

  final QuizModel? quiz;

  QuizComponent({this.quiz});

  @override
  QuizComponentState createState() => QuizComponentState();
}

class QuizComponentState extends State<QuizComponent> {
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
    return Stack(
      children: [
        Container(
          width: (context.width()) ,
          decoration: boxDecorationWithRoundedCorners(
            borderRadius: BorderRadius.circular(defaultRadius),
            backgroundColor: widget.quiz!.minRequiredPoint! > getIntAsync(USER_POINTS) ? Colors.grey.withOpacity(0.3) : Theme.of(context).cardColor,
            boxShadow: appStore.isDarkMode ? null : defaultBoxShadow(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.quiz!.imageUrl!,
                      fit: BoxFit.fill,
                      height: 120,
                      width: (context.width() * 0.5) - 25,
                    ).cornerRadiusWithClipRRectOnly(topLeft: 12, topRight: 12),
                  ],
                ),
              ),
              10.height,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.quiz!.quizTitle}',
                    style: boldTextStyle(color: appStore.isDarkMode ? Colors.white : Colors.black),
                    maxLines: 1,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                  ).paddingOnly(left: 16,right:appStore.selectedLanguage=="ar"?16:0).expand(),
                  4.width,
                  Text(
                    '${widget.quiz!.questionRef!.length} Qs',
                    style: primaryTextStyle(size: 12, color: appStore.isDarkMode?Colors.white:Colors.black),
                    maxLines: 1,
                  ).paddingOnly(right: 16,left: appStore.selectedLanguage=="ar"?16:0)
                ],
              ),
              10.height,
            ],
          ),
        ),
        widget.quiz!.minRequiredPoint! > getIntAsync(USER_POINTS)
            ? Container(
                width: (context.width() - (3 * 16)) * 0.5,
                color: grey.withOpacity(0.3),
                height: 120,
              ).cornerRadiusWithClipRRectOnly(topLeft: 12, topRight: 12)
            : SizedBox(),
      ],
    );
  }
}
