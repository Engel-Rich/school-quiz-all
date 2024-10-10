import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/QuizData.dart';
import 'package:quizeapp/screens/admin/CreateQuizScreen.dart';
import 'package:quizeapp/screens/admin/components/QuizDetailWidget.dart';

import '../../../main.dart';
import '../../../services/QuizServices.dart';
import '../../../utils/Colors.dart';
import '../../../utils/Common.dart';
import 'AppWidgets.dart';

class QuizItemWidget extends StatefulWidget {
  static String tag = '/QuizItemWidget';
  final QuizData data;

  QuizItemWidget(this.data);

  @override
  _QuizItemWidgetState createState() => _QuizItemWidgetState();
}

class _QuizItemWidgetState extends State<QuizItemWidget> {
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
      width: 220,
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Stack(
            children: [
              InkWell(
                onTap: () {
                  showInDialog(
                    context,
                    builder: (BuildContext context) {
                      return Container(
                        width: 220,
                        height: 500,
                        child: QuizDetailWidget(data: widget.data),
                      );
                    },
                  );
                },
                child: Image.network(
                  widget.data.imageUrl!,
                  height: 180,
                  width: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return cachedImage(
                      '',
                      height: 180,
                      width: 220,
                    );
                  },
                ).cornerRadiusWithClipRRect(16),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        CreateQuizScreen(quizData: widget.data).launch(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                              colors: [colorPrimary, colorSecondary],
                              begin: FractionalOffset.centerLeft,
                              end: FractionalOffset.centerRight),
                        ),
                        child: Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                    6.width,
                    InkWell(
                      onTap: () {
                        showConfirmDialogCustom(
                          context,
                          title: appStore.translate('lbl_delete_quiz'),
                          positiveText: appStore.translate('lbl_yes'),
                          negativeText: appStore.translate('lbl_no'),
                          primaryColor: colorPrimary,
                          customCenterWidget: customCenterDialog(
                              icon: Icons.delete_outline_outlined),
                          onAccept: (p0) {
                            QuizServices().removeDocument(widget.data.id);
                            toast("${widget.data.quizTitle} Quiz Deleted");
                          },
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                              colors: [colorPrimary, colorSecondary],
                              begin: FractionalOffset.centerLeft,
                              end: FractionalOffset.centerRight),
                        ),
                        child:
                            Icon(Icons.delete, color: Colors.white, size: 18),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          16.height,
          Text(
            widget.data.quizTitle!,
            style: boldTextStyle(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
