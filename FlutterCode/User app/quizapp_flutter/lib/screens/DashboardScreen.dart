import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '/../components/DrawerComponent.dart';
import '/../components/QuizCategoryComponent.dart';
import '/../main.dart';
import '/../models/CategoryModel.dart';
import '/../screens/QuizCategoryScreen.dart';
import '/../screens/QuizDescriptionScreen.dart';
import '/../screens/QuizScreen.dart';
import '/../services/QuizService.dart';
import '/../utils/colors.dart';
import '/../utils/constants.dart';
import '/../utils/images.dart';
import '/../utils/widgets.dart';
import '../models/QuestionModel.dart';
import '../models/QuizModel.dart';
import 'ContestScreen.dart';
import 'HomeScreen.dart';
import 'RandomQuizScreen.dart';
import 'WheelSpinScreen.dart';

class DashboardScreen extends StatefulWidget {
  static String tag = '/DashboardScreen';

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  QuizModel? trueFalse;

  List<QuestionModel> queList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    afterBuildCreated(() {
      setStatusBarColor(Colors.transparent, statusBarIconBrightness: Brightness.dark);
      appSettingService.getAppSettings();
      // appSettingService.setAppSettings();

      appStore.setAppLocalization(context);

      OneSignal.Notifications.
      addClickListener(
        (notification) {
          if (notification.notification.additionalData!.containsKey('id')) {
            String quizId = notification.notification.additionalData!['id'];

            QuizService().getQuizByQuizId(quizId).then(
              (value) {
                QuizDescriptionScreen(quizModel: value.first).launch(context);
              },
            ).catchError(
              (e) {
                toast(e.toString());
              },
            );
          }
        },
      );
    });



    await 5.seconds.delay;
    LiveStream().on(
      HideDrawerStream,
      (s) {
        scaffoldKey.currentState!.openEndDrawer();
      },
    );
  }

  @override
  void dispose() {
    LiveStream().dispose(HideDrawerStream);
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    appStore.setAppLocalization(context);
    return RefreshIndicator(
      onRefresh: () async {
        await appSettingService.setAppSettings();
        setState(() {});
        await 2.seconds.delay;
      },
      child: Scaffold(
        key: scaffoldKey,
        drawer: DrawerComponent(),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
                backgroundColor: appStore.isDarkMode ? Theme.of(context).cardColor : colorPrimary,
                iconTheme: IconThemeData(color: scaffoldColor),
                actions: [
                  InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen())),
                    child: Icon(Icons.military_tech_outlined, size: 30),
                  ),
                  16.width,
                ],
                title: Text(
                  mAppName,
                  style: TextStyle(color: Colors.white),
                ),
                centerTitle: true,
                pinned: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(defaultRadius), bottomRight: Radius.circular(defaultRadius)),
                ),
                expandedHeight: context.height() * 0.5,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Image.asset(DashboardImage, fit: BoxFit.cover),
                ),
              ),
            ];
          },
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                16.height,
                InkWell(
                  onTap: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => WheelSpinScreen()));
                  },
                  child: Container(
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 24),
                          decoration: boxDecorationWithRoundedCorners(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            backgroundColor: Theme.of(context).cardColor,
                          ),
                          height: 120,
                          width: context.width(),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Text(
                            "Spin wheel",
                            style: boldTextStyle(),
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 16,
                          width: 100,
                          height: 80,
                          child: Image.network(
                            "https://www.postplanner.com/hubfs/blog_post_images/8_Facebook_Contest_Ideas_You_Can_Run_on_Your_Timeline_TODAY-ls.png",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return placeHolderWidget();
                            },
                          ).cornerRadiusWithClipRRect(16),
                        ),
                      ],
                    ),
                  ),
                ).paddingOnly(left: 16,right: 16,bottom: 16),
                FutureBuilder(
                  future: categoryService.categories(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<CategoryModel> data = snapshot.data as List<CategoryModel>;
                      return ListView(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: 24),
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(appStore.translate('lbl_choose_categories'), style: boldTextStyle(size: 20)),
                              Text(
                                appStore.translate('lbl_see_all'),
                                style: boldTextStyle(color: colorPrimary, size: 18),
                              ).onTap(
                                () {
                                  QuizCategoryScreen().launch(context);
                                },
                              ),
                            ],
                          ).paddingOnly(left: 16, right: 16),
                          24.height,
                          Container(
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
                                      QuizScreen(catId: mData.id, catName: mData.name).launch(context);
                                    },
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return snapWidgetHelper(snapshot, errorWidget: emptyWidget(text: appStore.translate('lbl_noDataFound')));
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Play Zone", style: boldTextStyle(size: 20)),
                    Text(
                      appStore.translate('lbl_see_all'),
                      style: boldTextStyle(color: colorPrimary, size: 18),
                    ),
                  ],
                ).paddingOnly(left: 16, right: 16),
                16.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () async {
                        // questionService.questionByType().then((value) {
                        //   print("====== ${value.length}");
                        //   value.forEach((element) {
                        //     print("=================>  ${element.id} ==========> ${element.questionType}");
                        //     queList.add(element);
                        //     setState(() {});
                        //   });
                        // });
                        // await 5.seconds.delay;
                        // await QuizQuestionsScreen(quizType: QuizTypeTrueFalse, queList: queList, time: 5).launch(context);
                      },
                      child: Container(
                        width: (context.width() * 0.5) - 24,
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 24),
                              decoration: boxDecorationWithRoundedCorners(
                                borderRadius: BorderRadius.circular(defaultRadius),
                                backgroundColor: Theme.of(context).cardColor,
                              ),
                              height: 120,
                              width: context.width(),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Text(
                                "True False",
                                style: boldTextStyle(),
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              width: 80,
                              height: 80,
                              child: Image.network(
                                "",
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return placeHolderWidget();
                                },
                              ).cornerRadiusWithClipRRect(defaultRadius),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => RandomQuizScreen()));
                      },
                      child: Container(
                        width: (context.width() * 0.5) - 24,
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 24),
                              decoration: boxDecorationWithRoundedCorners(
                                borderRadius: BorderRadius.circular(defaultRadius),
                                backgroundColor: Theme.of(context).cardColor,
                              ),
                              height: 120,
                              width: context.width(),
                            ),
                            Positioned(
                              bottom: 16,
                              left: 16,
                              right: 16,
                              child: Text(
                                "Random Quiz",
                                style: boldTextStyle(),
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              width: 80,
                              height: 80,
                              child: Image.network(
                                "",
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return placeHolderWidget();
                                },
                              ).cornerRadiusWithClipRRect(defaultRadius),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Text("Contest", style: boldTextStyle(size: 20)).paddingAll(16),
                InkWell(
                  onTap: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ContestScreen()));
                  },
                  child: Container(
                    child: Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 24),
                          decoration: boxDecorationWithRoundedCorners(
                            borderRadius: BorderRadius.circular(defaultRadius),
                            backgroundColor: Theme.of(context).cardColor,
                          ),
                          height: 120,
                          width: context.width(),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Text(
                            "Contest",
                            style: boldTextStyle(),
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 16,
                          width: 100,
                          height: 80,
                          child: Image.network(
                            "https://www.postplanner.com/hubfs/blog_post_images/8_Facebook_Contest_Ideas_You_Can_Run_on_Your_Timeline_TODAY-ls.png",
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return placeHolderWidget();
                            },
                          ).cornerRadiusWithClipRRect(16),
                        ),
                      ],
                    ),
                  ),
                ).paddingOnly(left: 16,right: 16,bottom: 16)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
