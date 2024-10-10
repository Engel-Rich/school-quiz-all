import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import '../utils/images.dart';
import '/../main.dart';
import 'package:nb_utils/nb_utils.dart';
import '../components/AppBarComponent.dart';
import '../utils/colors.dart';
import 'QuizDescriptionScreen.dart';

class WheelSpinScreen extends StatefulWidget {
  static String tag = '/WheelSpinScreen';

  @override
  WheelSpinScreenState createState() => WheelSpinScreenState();
}

class WheelSpinScreenState extends State<WheelSpinScreen> {
  StreamController<int> selected = StreamController<int>();
  int? random;
  List<String> items = [];
  List<String> itemsName = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await quizService.getQuiz().then((value) {
      value.forEach((element) {
        if (element.isSpin == true) {
          items.add(element.id!);
          itemsName.add(element.quizTitle!);
        }
      });
      if (items.length <= 1) {
        isLoading = true;
      } else {
        setState(() {
          isLoading = false;
        });
      }
    });
    if (items.length <= 1) {
      await quizService.quizList.then((value) {
        value.forEach((e) {
          e.isSpin = true;
          quizService.updateDocument(e.toJson(), e.id);
        });
        setState(() {});
      });
      await quizService.getQuiz().then((value) {
        value.forEach((element) {
          if (element.isSpin == true) {
            items.add(element.id!);
            itemsName.add(element.quizTitle!);
          }
        });
        setState(() {
          isLoading = false;
        });
      });
    }
    random = Fortune.randomInt(0, items.length);
    setState(() {
      selected.add(random!);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(context: context, title: appStore.translate('lbl_spin_play')),
      extendBodyBehindAppBar: true,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : items.length != 0
              ? GestureDetector(
                  onTap: () {
                    random = Fortune.randomInt(0, items.length);
                    setState(() {
                      selected.add(random!);
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: SizedBox(
                          width: context.width() - 30,
                          height: context.width() - 30,
                          child: FortuneWheel(
                            selected: selected.stream,
                            indicators: <FortuneIndicator>[
                              FortuneIndicator(
                                alignment: Alignment.topCenter,
                                child: TriangleIndicator(
                                  color: Color(0xffe1b100),
                                ),
                              ),
                            ],
                            onAnimationEnd: () {
                              quizService.quizByQuizID(items[random!]).then((value) {
                                QuizDescriptionScreen(quizModel: value).launch(context);
                              }).catchError((e) {
                                toast(e.toString());
                              });
                            },
                            items: List.generate(
                              itemsName.length,
                              (index) {
                                return FortuneItem(
                                  child: Text(itemsName[index], style: boldTextStyle(color: Colors.white)),
                                  style: FortuneItemStyle(borderColor: Color(0xffcb4346), borderWidth: 8, color: index % 2 == 0 ? colorPrimary : colorSecondary),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(EmptyImage, height: 200, width: 200),
                    Text('No Spin available', style: boldTextStyle()),
                  ],
                ).center(),
    );
  }
}
