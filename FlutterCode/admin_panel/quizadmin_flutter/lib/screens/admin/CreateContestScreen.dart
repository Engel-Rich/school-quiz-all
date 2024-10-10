import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../main.dart';
import '../../models/QuizData.dart';
import '../../utils/Colors.dart';
import '../../utils/Common.dart';
import 'AddContestScreen.dart';
import 'components/AppWidgets.dart';
import 'components/QuizDetailWidget.dart';

class CreateContestScreen extends StatefulWidget {
  const CreateContestScreen({Key? key}) : super(key: key);

  @override
  State<CreateContestScreen> createState() => _CreateContestScreenState();
}

class _CreateContestScreenState extends State<CreateContestScreen> {
  int _selectedIndex = 0;
  List<QuizData> live = [];
  List<String> tabName = [
    appStore.translate('lbl_all'),
    appStore.translate('lbl_ended'),
    appStore.translate('lbl_live'),
    appStore.translate('lbl_upcoming')
  ];

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    contestService.onGoingContest(date: DateTime.now()).then((value) {
      value.forEach((element) {
        if (element.endAt!.isAfter(DateTime.now()) ||
            element.endAt! == DateTime.now() ||
            element.startAt == DateTime.now()) {
          live.add(element);
          setState(() {});
          live.forEach((element) {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(appStore.translate('lbl_contest'),
                    style: boldTextStyle(size: 22)),
                commonAppButton(context, appStore.translate('lbl_add_contest'),
                    onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddContestScreen()));
                }, isFull: false),
              ],
            ).paddingAll(16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                  height: 500,
                  child: NavigationRail(
                    backgroundColor: Colors.white,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (int index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    groupAlignment: 0.0,
                    labelType: NavigationRailLabelType.selected,
                    destinations: List.generate(tabName.length, (index) {
                      return NavigationRailDestination(
                        icon: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: RotatedBox(
                              quarterTurns: 3,
                              child:
                                  Text(tabName[index], style: boldTextStyle())),
                        ),
                        selectedIcon: Container(
                          decoration: BoxDecoration(
                            borderRadius: radius(defaultRadius),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.topRight,
                                colors: [colorPrimary, colorSecondary]),
                            boxShadow: [
                              BoxShadow(
                                  color: shadowColorGlobal,
                                  spreadRadius: 1,
                                  blurRadius: 1)
                            ],
                          ),
                          padding: EdgeInsets.all(8),
                          child: RotatedBox(
                              quarterTurns: 3,
                              child: Text(tabName[index],
                                  style: boldTextStyle(
                                      color: Colors.white, size: 20))),
                        ),
                        label: Text(""),
                      );
                    }),
                  ),
                ),
                _selectedIndex == 0
                    ? all()
                    : _selectedIndex == 2
                        ? liveWidget(live)
                        : ended(index: _selectedIndex),
              ],
            )
          ],
        ),
      ),
    ).cornerRadiusWithClipRRect(16);
  }

  Widget all() {
    return SingleChildScrollView(
      child: SizedBox(
        width: (context.width() - context.width() * 0.049) - 300,
        child: StreamBuilder<List<QuizData>>(
          stream: contestService.getContest,
          builder: (_, snap) {
            if (snap.hasData) {
              if (snap.data!.isEmpty) return noDataWidget();
              return SingleChildScrollView(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 24,
                  children: snap.data!.map((e) {
                    return card(e: e);
                  }).toList(),
                ),
              );
            } else {
              return snapWidgetHelper(snap,
                  loadingWidget:
                      Loader(valueColor: AlwaysStoppedAnimation(colorPrimary))
                          .paddingOnly(top: 350));
            }
          },
        ),
      ),
    );
  }

  Widget liveWidget(List<QuizData> live) {
    return SizedBox(
      width: (context.width() - context.width() * 0.049) - 300,
      child: Wrap(
        spacing: 16,
        runSpacing: 24,
        children: List.generate(live.length, (index) {
          return card(e: live[index]);
        }),
      ),
    );
  }

  Widget ended({int? index}) {
    return Expanded(
      child: SizedBox(
        width: (context.width() - context.width() * 0.049) - 300,
        child: FutureBuilder<List<QuizData>>(
          future: index == 1
              ? contestService.endedContest(date: DateTime.now())
              : index == 3
                  ? contestService.upComingContest(date: DateTime.now())
                  : contestService.upComingContest(date: DateTime.now()),
          builder: (_, snap) {
            if (snap.hasData) {
              if (snap.data!.isEmpty) return noDataWidget();
              return Wrap(
                spacing: 16,
                runSpacing: 24,
                children: snap.data!.map((e) {
                  print("this is ended == ${e.quizTitle}");
                  return card(e: e);
                }).toList(),
              );
            } else {
              // return snapWidgetHelper(snap, loadingWidget: Loader(valueColor: AlwaysStoppedAnimation(colorPrimary)));
              return snapWidgetHelper(snap,
                  loadingWidget:
                      Loader(valueColor: AlwaysStoppedAnimation(colorPrimary))
                          .paddingOnly(top: 350));
            }
          },
        ),
      ),
    );
  }

  Widget card({required QuizData e}) {
    return InkWell(
      onTap: () {
        showInDialog(
          context,
          builder: (BuildContext context) {
            return Container(
              width: context.width() * 0.65,
              height: 550,
              child: QuizDetailWidget(data: e),
            );
          },
        );
      },
      child: Container(
        width: 180,
        height: 230,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              children: [
                Image.network(
                  e.imageUrl!,
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return cachedImage(
                      '',
                      height: 150,
                      width: context.width() / 5 - context.width() * 0.049,
                    );
                  },
                ).cornerRadiusWithClipRRect(16),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          AddContestScreen(quizData: e).launch(context);
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
                              Icon(Icons.edit, color: Colors.white, size: 18),
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
                              contestService.removeDocument(e.id);
                              toast("${e.quizTitle} Quiz Deleted");
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
            Text(
              e.quizTitle!,
              style: boldTextStyle(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
