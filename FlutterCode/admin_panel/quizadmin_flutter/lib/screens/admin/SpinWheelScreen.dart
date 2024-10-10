import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/QuizData.dart';
import 'package:quizeapp/screens/admin/components/AppWidgets.dart';

import '../../utils/Colors.dart';

class SpinWheelScreen extends StatefulWidget {
  static String tag = '/SpinWheelScreen';

  @override
  _SpinWheelScreenState createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends State<SpinWheelScreen> {
  String? spinID = "spinList";
  int? length;
  List<QuizData> spinList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await quizServices.quizList.then((value) {
      print(" set of list =============================");
      value.forEach((element) {
        if (element.isSpin == true) {
          spinList.add(element);
        }
      });
      setState(() {});
    });
    if (spinList.length <= 1) {
      quizServices.quizList.then((value) {
        value.forEach((e) {
          e.isSpin = true;
          quizServices.updateDocument(e.toJson(), e.id);
        });
        setState(() {});
      });
    }
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
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            Text(appStore.translate('lbl_spin_wheel'),
                style: boldTextStyle(size: 22)),
            16.height,
            SizedBox(
              child: StreamBuilder<List<QuizData>>(
                stream: quizServices.streamQuizList(),
                builder: (_, snap) {
                  if (snap.hasData) {
                    if (snap.data!.isEmpty) return noDataWidget();
                    return Wrap(
                      spacing: 16,
                      runSpacing: 24,
                      children: snap.data!.map((e) {
                        return Container(
                          width: context.width() / 5 - context.width() * 0.049,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Stack(
                                children: [
                                  Image.network(
                                    e.imageUrl!,
                                    height: 180,
                                    width: context.width() / 5 -
                                        context.width() * 0.049,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) {
                                      return cachedImage(
                                        '',
                                        height: 180,
                                        width: context.width() / 5 -
                                            context.width() * 0.049,
                                      );
                                    },
                                  ).cornerRadiusWithClipRRect(16),
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Checkbox(
                                      activeColor: orange,
                                      value: e.isSpin,
                                      onChanged: (newValue) {
                                        if (newValue == false) {
                                          e.isSpin = false;
                                          quizServices.updateDocument(
                                              e.toJson(), e.id);
                                        } else {
                                          e.isSpin = true;
                                          quizServices.updateDocument(
                                              e.toJson(), e.id);
                                        }
                                        setState(() {});
                                        e.isSpin = newValue;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              16.height,
                              Text(e.quizTitle!, style: boldTextStyle()),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return Center(
                        child: snapWidgetHelper(snap,
                            loadingWidget: Loader(
                                    valueColor:
                                        AlwaysStoppedAnimation(colorPrimary))
                                .paddingOnly(top: 350)));
                    // return Center(child: snapWidgetHelper(snap,loadingWidget: Loader(valueColor:AlwaysStoppedAnimation(colorPrimary))));
                  }
                },
              ),
            ),
          ],
        ).paddingSymmetric(horizontal: 16),
      ),
    ).cornerRadiusWithClipRRect(16);
  }
}
