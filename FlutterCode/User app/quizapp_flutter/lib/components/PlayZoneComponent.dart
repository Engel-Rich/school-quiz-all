import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizapp_flutter/models/PlayZoneModel.dart';
import '../main.dart';
// import '../models/QuestionModel.dart';
// import '../screens/DailyQuizDescriptionScreen.dart';
// import '../screens/QuizQuestionsScreen.dart';
// import '../screens/RandomQuizScreen.dart';
import '../utils/colors.dart';
// import '../utils/constants.dart';
import '../utils/images.dart';
// import '../utils/widgets.dart';

class PlayZoneComponent extends StatefulWidget {
  // final String? name;
  // final String? image;
  final PlayZoneModel? model;

  PlayZoneComponent({this.model});

  @override
  State<PlayZoneComponent> createState() => _PlayZoneComponentState();
}

class _PlayZoneComponentState extends State<PlayZoneComponent> {
  // List<QuestionModel> queList = [];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.model?.callback,
      // () async {

      // if (widget.index == 0) {
      // } else if (widget.index == 1) {
      // } else if (widget.index == 2) {
      // } else {}
      // },
      child: Container(
        width: (context.width() - 48) / 2,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [colorPrimary, colorSecondary]),
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.model?.name ?? "",
                style: boldTextStyle(color: Colors.white, size: 18)),
            6.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(Play_icon, height: 20, width: 20),
                    6.width,
                    SizedBox(
                        width: ((context.width() - 48) / 2) - 104,
                        child: Text(appStore.translate('lbl_playNow'),
                            style:
                                primaryTextStyle(color: Colors.white, size: 15),
                            softWrap: true))
                  ],
                ),
                widget.model?.typeCategorie != null
                    ? CachedNetworkImage(
                        imageUrl: widget.model!.typeCategorie!.images!,
                        width: 40,
                        height: 40)
                    : Image.asset(widget.model!.image ?? "",
                        width: 40, height: 40)
              ],
            )
          ],
        ),
      ),
    );
  }
}
