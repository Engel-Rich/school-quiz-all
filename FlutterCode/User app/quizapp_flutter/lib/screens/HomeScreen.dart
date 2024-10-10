import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
// import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:quizapp_flutter/models/CategorieTypeModel.dart';
import 'package:quizapp_flutter/models/ClasseModel.dart';
// import 'package:quizapp_flutter/models/ClasseModel.dart';
import 'package:quizapp_flutter/models/Publicite.dart';
import 'package:quizapp_flutter/models/QuestionModel.dart';
import 'package:quizapp_flutter/screens/DailyQuizDescriptionScreen.dart';
import 'package:quizapp_flutter/screens/QuizQuestionsScreen.dart';
import 'package:quizapp_flutter/screens/RandomQuizScreen.dart';
import 'package:quizapp_flutter/screens/abonnement/bottomsheet_abonnement.dart';
import 'package:quizapp_flutter/store/controllers/subscription_controller.dart';
// import 'package:video_player/video_player.dart';
// import 'package:quizapp_flutter/components/QuizQuestionComponent.dart';
import '../components/DrawerComponent.dart';
import '../components/PlayZoneComponent.dart';
import '../components/QuizCategoryComponent.dart';
import '../main.dart';
import '../models/CategoryModel.dart';
import '../models/PlayZoneModel.dart';
import '../services/QuizService.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/images.dart';
import '../utils/widgets.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'ContestScreen.dart';
import 'ProfileScreen.dart';
import 'QuizCategoryScreen.dart';
import 'QuizDescriptionScreen.dart';
import 'QuizScreen.dart';
import 'WheelSpinScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  AdvancedDrawerController _advancedDrawerController =
      AdvancedDrawerController();

  DateTime? currentBackPressTime;

  final Shader linearGradient = LinearGradient(
    colors: <Color>[colorPrimary, colorSecondary],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  Timer? timer;
  @override
  void initState() {
    super.initState();
    init();
  }

  PageController pageController = PageController();
  int timeCount = 0;

  changePage() {
    pageController.addListener(() {
      if (timeCount == 300) {
        final int currentPage = pageController.page!.toInt();
        if (currentPage == publicites.length - 1) {
          pageController.animateToPage(0,
              duration: Duration(milliseconds: 500), curve: Curves.easeIn);
        } else {
          pageController.animateToPage(currentPage + 1,
              duration: Duration(milliseconds: 500), curve: Curves.easeIn);
        }
      }
    });
    // pageCount++;
    // if (pageCount == publicites.length) {
    //   timeCount = 0;
    // }
  }

  Future<void> init() async {
    afterBuildCreated(() {
      SubscriptionController.to.initSubcription();

      setStatusBarColor(Colors.transparent,
          statusBarIconBrightness: Brightness.dark);

      appSettingService.setAppSettings();

      appStore.setAppLocalization(context);
      timer = Timer.periodic(Duration(seconds: 15), (timer) {
        setState(() {});
      });
      // initPlayZone();
      getTypeCategorieList();
      getActivesPubliciteList();
      OneSignal.Notifications.addClickListener(
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

    //   OneSignal.shared.setNotificationOpenedHandler(
    //         (OSNotificationOpenedResult result) {
    //       if (result.notification.additionalData!.containsKey('id')) {
    //         String quizId = result.notification.additionalData!['id'];
    //
    //         QuizService().getQuizByQuizId(quizId).then(
    //               (value) {
    //             QuizDescriptionScreen(quizModel: value.first).launch(context);
    //           },
    //         ).catchError(
    //               (e) {
    //             toast(e.toString());
    //           },
    //         );
    //       }
    //     },
    //   );
    // });

    await 5.seconds.delay;
    LiveStream().on(
      HideDrawerStream,
      (s) {
        scaffoldKey.currentState!.openEndDrawer();
      },
    );
  }

  showBottomSubscription() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomsheetAbonnement();
      },
    );
  }

  Future getTypeCategorieList() async {
    await typeCategorieServices.getTypeCategorieList().then((value) {
      typeCategorieList = value;
      typeCategorieList.forEach((element) {
        playZoneListOnline.add(
          PlayZoneModel(
            name: element.nameTypeCategorie,
            typeCategorie: element,
            typeCategorieimage: element.images,
            callback: () {
              if (SubscriptionController.to.currentSubscription.value == null) {
                showBottomSubscription();
              } else
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RandomQuizScreen(
                      typeCategorie: element,
                    ),
                  ),
                );
            },
          ),
        );
      });

      setState(() {});
    });
    setState(() {});
  }

  List<Publicite> publicites = [];
  Future getActivesPubliciteList() async {
    await publiciteServices.allPubliciteActive().then((value) {
      publicites.addAll(value);
      publicites.forEach((item) {
        publiciteListWidget.add(
          BuildPubliciteWidget(
            pageController: pageController,
            publicites: publicites,
            item: item,
          ),
        );
      });
    });
    setState(() {});
  }

  @override
  void dispose() {
    LiveStream().dispose(HideDrawerStream);
    timer?.cancel();
    super.dispose();
  }

  List<TypeCategorie> typeCategorieList = [];
  List<PlayZoneModel> playZoneList = [];
  List<PlayZoneModel> playZoneListOnline = [];
  List<Widget> publiciteListWidget = [];

  @override
  Widget build(BuildContext context) {
    double heightOfStatusBar = MediaQuery.of(context).viewPadding.top;
    double width = MediaQuery.of(context).size.width;
    appStore.setAppLocalization(context);
    List<QuestionModel> queList = [];
// If user classe type is academique
    final ClasseModel classeModel =
        ClasseModel.fromMap(jsonDecode(appStore.userClasse!));
    // if (classeModel.classeType == ClasseType.academic) {
    playZoneList = [
      PlayZoneModel(
        name: appStore.translate('lbl_daily_quiz'),
        image: "images/1 Daily Quiz.png",
        callback: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DailyQuizDescriptionScreen(),
            ),
          );
        },
      ),
      if (classeModel.classeType == ClasseType.trainning)
        ...List.generate(
          playZoneListOnline.length,
          (index) {
            return playZoneListOnline[index];
          },
        ),
      if (classeModel.classeType == ClasseType.academic) ...[
        PlayZoneModel(
            name: appStore.translate('lbl_random_quiz_title'),
            image: "images/2 Random Quiz.png",
            callback: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RandomQuizScreen(),
                ),
              );
            }),
        PlayZoneModel(
            name: classeModel.classeType == ClasseType.trainning
                ? "Entrainement"
                : appStore.translate('lbl_true_false'),
            image: "images/3 Truefalse.png",
            callback: () {
              // if (classeModel.classeType == ClasseType.trainning)
              //   showDialog(
              //     context: context,
              //     builder: (context) {
              //       return Material(
              //         color: Colors.transparent,
              //         elevation: 0,
              //         child: Center(
              //           child: Container(
              //             width: double.infinity,
              //             decoration: BoxDecoration(
              //               borderRadius: BorderRadius.circular(8),
              //               color: Theme.of(context).scaffoldBackgroundColor,
              //             ),
              //             child: Column(
              //               mainAxisAlignment: MainAxisAlignment.center,
              //               mainAxisSize: MainAxisSize.min,
              //               children: [
              //                 SizedBox(height: 16),
              //                 Text(
              //                   "Choisissez une catégorie",
              //                   style: boldTextStyle(size: 25),
              //                 ).paddingSymmetric(vertical: 16),
              //                 SizedBox(
              //                   child: Wrap(
              //                     spacing: 16,
              //                     runSpacing: 16,
              //                     children: List.generate(
              //                       playZoneListOnline.length,
              //                       (index) {
              //                         return PlayZoneComponent(
              //                           model: playZoneListOnline[index],
              //                         );
              //                       },
              //                     ),
              //                   ),
              //                 ),
              //                 SizedBox(height: 16),
              //                 AppButton(
              //                   width: context.width() * 0.8,
              //                   color: colorPrimary,
              //                   text: "Fermer",
              //                   height: 50,
              //                   onTap: () {
              //                     Navigator.pop(context);
              //                   },
              //                 ).paddingSymmetric(vertical: 16),
              //                 SizedBox(height: 16),
              //               ],
              //             ),
              //           ).paddingSymmetric(horizontal: 8),
              //         ),
              //       );
              //     },
              //   );
              // else
              showConfirmDialogCustom(context,
                  title: appStore.translate('lbl_do_play_quiz'),
                  positiveText: appStore.translate('lbl_yes'),
                  negativeText: appStore.translate('lbl_no'),
                  customCenterWidget: customCenterDialogImage(image: Quiz_icon),
                  primaryColor: colorPrimary, onAccept: (p0) async {
                questionService.questionByType("truefalse").then((value) async {
                  value.forEach((element) {
                    queList.add(element);
                    setState(() {});
                  });
                  await QuizQuestionsScreen(
                          quizType: QuizTypeTrueFalse,
                          queList: queList,
                          time: 5)
                      .launch(context);
                });
              });
            }
            // callback: () {
            //
            //
            // },
            ),
        PlayZoneModel(
            name: appStore.translate('lbl_guess_word_title'),
            image: "images/4 Guess The Word.png",
            callback: () {
              showConfirmDialogCustom(
                context,
                primaryColor: colorPrimary,
                title: appStore.translate('lbl_do_play_quiz'),
                positiveText: appStore.translate('lbl_yes'),
                negativeText: appStore.translate('lbl_no'),
                customCenterWidget: customCenterDialogImage(image: Quiz_icon),
                onAccept: (p0) async {
                  questionService
                      .questionByType("GuessWord")
                      .then((value) async {
                    value.forEach((element) {
                      queList.add(element);
                      setState(() {});
                    });
                    await QuizQuestionsScreen(
                            quizType: QuizTypeGuessWord,
                            queList: queList,
                            time: 5)
                        .launch(context);
                  });
                },
              );
            }),
      ],
    ];
    // }
    return AdvancedDrawer(
      backdropColor: context.scaffoldBackgroundColor,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: appStore.selectedLanguage == 'ar' ? true : false,
      disabledGestures: false,
      childDecoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      openRatio: 0.6,
      openScale: 0.8,
      drawer: DrawerComponent(onCall: () {
        _advancedDrawerController.hideDrawer();
        setState(() {});
      }),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor:
            appStore.isDarkMode == true ? Colors.black : Color(0xfff6f6f6),
        // drawer: DrawerComponent(),
        body: WillPopScope(
          onWillPop: onWillPop,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  systemOverlayStyle: SystemUiOverlayStyle(
                      statusBarBrightness: Brightness.dark,
                      statusBarColor: Colors.transparent),
                  // backgroundColor: colorPrimary,
                  iconTheme: IconThemeData(color: scaffoldColor),
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          _advancedDrawerController.showDrawer();
                        },
                        child: Icon(Icons.menu, color: Colors.white, size: 26),
                      ),
                      Observer(
                        builder: (context) => appStore.userProfileImage
                                .validate()
                                .isEmpty
                            ? CircleAvatar(
                                radius: 26, child: Image.asset(UserPic))
                            : CircleAvatar(
                                radius: 24,
                                child: cachedImage(
                                        appStore.userProfileImage.validate(),
                                        usePlaceholderIfUrlEmpty: true,
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.cover)
                                    .cornerRadiusWithClipRRect(35),
                              ),
                      ).onTap(() async {
                        await ProfileScreen().launch(context);
                        setState(() {});
                      }),
                    ],
                  ).paddingOnly(bottom: 4),
                  centerTitle: true,
                  pinned: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(26),
                        bottomRight: Radius.circular(26)),
                  ),
                  expandedHeight: appStore.selectedLanguage == 'ar'
                      ? 300
                      : (context.width() / 3) + 150,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(26),
                            bottomRight: Radius.circular(26)),
                        gradient: LinearGradient(
                            colors: [colorPrimary, colorSecondary],
                            begin: FractionalOffset.centerLeft,
                            end: FractionalOffset.centerRight)),
                    child: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: Container(
                        padding:
                            EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(26),
                              bottomRight: Radius.circular(26)),
                          gradient: LinearGradient(
                              colors: [colorPrimary, colorSecondary],
                              begin: FractionalOffset.centerLeft,
                              end: FractionalOffset.centerRight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: heightOfStatusBar),
                            66.height,
                            RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: <TextSpan>[
                                  TextSpan(
                                      text: appStore.translate('lbl_welcome'),
                                      style: primaryTextStyle(
                                          color: Colors.white, size: 24)),
                                  TextSpan(
                                      text: " , ${appStore.userName ?? ""}",
                                      style: boldTextStyle(
                                          color: Colors.white, size: 22)),
                                ],
                              ),
                            ),
                            10.height,
                            publiciteListWidget.isEmpty
                                ? Stack(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      WheelSpinScreen()));
                                        },
                                        child: Container(
                                          height: (context.width() / 3) + 20,
                                          padding: EdgeInsets.all(16),
                                          width: width,
                                          decoration: BoxDecoration(
                                              color: appStore.isDarkMode
                                                  ? Colors.black
                                                      .withOpacity(0.8)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(16)),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 170,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      appStore.translate(
                                                          'lbl_spin_play'),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20,
                                                          foreground: Paint()
                                                            ..shader =
                                                                linearGradient),
                                                    ),
                                                    appStore.selectedLanguage ==
                                                            'ar'
                                                        ? 3.height
                                                        : 18.height,
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 25,
                                                              vertical: 10),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                                begin: Alignment
                                                                    .topLeft,
                                                                end: Alignment
                                                                    .topRight,
                                                                colors: [
                                                              colorPrimary,
                                                              colorSecondary
                                                            ]),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Text(
                                                          appStore.translate(
                                                              'lbl_click'),
                                                          style:
                                                              primaryTextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: -100,
                                        right: appStore.selectedLanguage == 'ar'
                                            ? null
                                            : 0,
                                        left: appStore.selectedLanguage == 'ar'
                                            ? 0
                                            : null,
                                        child: Image.asset(Spin_gif,
                                            width: (context.width() / 2) + 30,
                                            height: (context.width() / 2) + 30),
                                      ),
                                    ],
                                  )
                                : SizedBox(
                                    height: context.width() / 2.5,
                                    width: width,
                                    child: PageView.builder(
                                      controller: pageController,
                                      onPageChanged: (value) {},
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) =>
                                          publiciteListWidget[index],
                                      itemCount: publiciteListWidget.length,
                                    ),
                                  )
                            // FlutterCarousel(
                            //     items: [
                            //       for (var item in publicites)
                            //         buildPubliciteWidget(
                            //           // width: width,
                            //           item: item,
                            //         ),
                            //     ],
                            //     options: CarouselOptions(
                            //       height: (context.width() / 3) + 20,
                            //       aspectRatio: 16 / 9,
                            //       viewportFraction: 1.0,
                            //       initialPage: 0,
                            //       enableInfiniteScroll: true,
                            //       reverse: false,
                            //       autoPlay: false,
                            //       autoPlayInterval:
                            //           const Duration(seconds: 5),
                            //       autoPlayAnimationDuration:
                            //           const Duration(milliseconds: 750),
                            //       autoPlayCurve: Curves.easeInOutExpo,
                            //       enlargeCenterPage: true,
                            //       controller: CarouselController(),
                            //       onPageChanged: (index, reason) {},
                            //       pageSnapping: true,
                            //       scrollDirection: Axis.horizontal,
                            //       pauseAutoPlayOnTouch: true,
                            //       floatingIndicator: true,
                            //       pauseAutoPlayOnManualNavigate: true,
                            //       pauseAutoPlayInFiniteScroll: false,
                            //       enlargeStrategy:
                            //           CenterPageEnlargeStrategy.scale,
                            //       disableCenter: false,
                            //       showIndicator: true,
                            //       slideIndicator: CircularSlideIndicator(
                            //         currentIndicatorColor: colorPrimary,
                            //         indicatorBackgroundColor:
                            //             Colors.black.withOpacity(0.1),
                            //       ),
                            //     ),
                            //   ),

                            // Positioned(
                            //   child: Row(
                            //     children: [
                            //       // if (item.playUrl == null)
                            //       IconButton(
                            //         onPressed: () {},
                            //         icon: FaIcon(
                            //           FontAwesomeIcons.googlePlay,
                            //           color: black,
                            //         ),
                            //       ),
                            //       ...[
                            //         5.width,
                            //         IconButton(
                            //           onPressed: () {},
                            //           icon: FaIcon(
                            //             FontAwesomeIcons.appStore,
                            //             color: black,
                            //           ),
                            //         ),
                            //       ],
                            //       ...[
                            //         5.width,
                            //         IconButton(
                            //           onPressed: () {},
                            //           icon: FaIcon(
                            //             FontAwesomeIcons.sitemap,
                            //             color: black,
                            //           ),
                            //         ),
                            //       ],
                            //     ],
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: SingleChildScrollView(
              child: AnimationLimiter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: AnimationConfiguration.toStaggeredList(
                      duration: Duration(seconds: 1),
                      childAnimationBuilder: (widget) => SlideAnimation(
                            horizontalOffset: 50.0,
                            child: FadeInAnimation(
                              child: widget,
                            ),
                          ),
                      children: [
                        22.height,
                        Text(appStore.translate('lbl_play_zone'),
                                style: boldTextStyle(size: 20))
                            .paddingOnly(left: 16, right: 16),
                        12.height,
                        SizedBox(
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: List.generate(
                              playZoneList.length,
                              (index) {
                                return PlayZoneComponent(
                                  model: playZoneList[index],
                                );
                              },
                            ),
                          ),
                        ).paddingOnly(left: 16, right: 16),
                        22.height,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(appStore.translate('lbl_category'),
                                style: boldTextStyle(size: 20)),
                            Text(
                              appStore.translate('lbl_see_all'),
                              style: primaryTextStyle(color: colorPrimary),
                            ).onTap(
                              () {
                                QuizCategoryScreen().launch(context);
                              },
                            )
                          ],
                        ).paddingOnly(left: 16, right: 16),
                        12.height,
                        StreamBuilder(
                          stream:
                              categoryService.categoriesStream(hasLimite: true),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<CategoryModel> data =
                                  snapshot.data as List<CategoryModel>;
                              return Container(
                                alignment: Alignment.topCenter,
                                padding: EdgeInsets.only(left: 16, right: 16),
                                child: Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: List.generate(
                                    data.length,
                                    (index) {
                                      CategoryModel? mData = data[index];
                                      return AnimationConfiguration
                                          .staggeredList(
                                        position: index,
                                        duration: Duration(milliseconds: 375),
                                        child: SlideAnimation(
                                          verticalOffset: 50.0,
                                          child: FadeInAnimation(
                                            child: QuizCategoryComponent(
                                                    category: mData)
                                                .onTap(
                                              () {
                                                QuizScreen(
                                                        catId: mData.id,
                                                        catName: mData.name)
                                                    .launch(context);
                                              },
                                              highlightColor:
                                                  Colors.transparent,
                                              splashColor: Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                            return snapWidgetHelper(snapshot,
                                errorWidget: emptyWidget(
                                    text:
                                        appStore.translate('lbl_noDataFound')));
                          },
                        ),
                        22.height,
                        Text(appStore.translate('lbl_contest'),
                                style: boldTextStyle(size: 20))
                            .paddingOnly(left: 16, right: 16),
                        12.height,
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ContestScreen()));
                          },
                          child: Container(
                            margin: EdgeInsets.only(left: 16, right: 16),
                            padding: EdgeInsets.only(
                                right:
                                    appStore.selectedLanguage == 'ar' ? 0 : 16,
                                left:
                                    appStore.selectedLanguage == 'ar' ? 16 : 0),
                            decoration: BoxDecoration(
                                color: Color(0xfff66f5b),
                                borderRadius: BorderRadius.circular(16)),
                            width: width,
                            height: 120,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(ContestImage,
                                    height: 120, width: 120),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(appStore.translate("lbl_play_quiz"),
                                        style: boldTextStyle(
                                            color: Colors.white, size: 36),
                                        softWrap: true,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis),
                                    2.height,
                                    Text(appStore.translate('lbl_tournament'),
                                        style: boldTextStyle(
                                            size: 20,
                                            color: Color(0xff464646))),
                                  ],
                                ).expand(),
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.5),
                                        blurRadius: 10.0,
                                        offset: Offset(-5, 5),
                                      )
                                    ],
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.topRight,
                                        colors: [colorPrimary, colorSecondary]),
                                  ),
                                  child: Icon(Icons.arrow_forward_rounded,
                                      color: Colors.white),
                                )
                              ],
                            ),
                          ),
                        ),
                        20.height
                      ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Press back again to exit");
      return Future.value(false);
    }
    return Future.value(true);
  }
}

class BuildPubliciteWidget extends StatelessWidget {
  final PageController pageController;
  final List<Publicite> publicites;
  const BuildPubliciteWidget({
    super.key,
    required this.pageController,
    required this.publicites,
    required this.item,
  });

  // final double width;
  final Publicite item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (context.width() / 3) + 20,
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        color:
            appStore.isDarkMode ? Colors.black.withOpacity(0.8) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: item.videoUrl != null
            ? VideoplayWidget(
                publicite: item,
                pageController: pageController,
                publicites: publicites,
              )
            : BuildImagesWidget(
                publicite: item,
                pageController: pageController,
                publicites: publicites,
              ),
      ),
    );
  }
}

class BuildImagesWidget extends StatefulWidget {
  final PageController pageController;
  final Publicite publicite;
  final List<Publicite> publicites;
  const BuildImagesWidget({
    super.key,
    required this.pageController,
    required this.publicites,
    required this.publicite,
  });

  @override
  State<BuildImagesWidget> createState() => _BuildImagesWidgetState();
}

class _BuildImagesWidgetState extends State<BuildImagesWidget> {
  int timeCount = 0;
  bool isPresse = false;
  changePage() {
    final publicites = widget.publicites;
    final pageController = widget.pageController;
    final int currentPage = pageController.page!.toInt();
    if (currentPage == publicites.length - 1) {
      pageController.jumpTo(0);
    } else {
      pageController.animateToPage(currentPage + 1,
          duration: Duration(milliseconds: 500), curve: Curves.easeIn);
    }
  }

  timer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!isPresse) timeCount++;
      if (timeCount == 3) {
        changePage();
      }
    });
  }

  initState() {
    super.initState();
    timer();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => setState(
        () => isPresse = true,
      ),
      onLongPressEnd: (details) => setState(
        () => isPresse = false,
      ),
      child: CachedNetworkImage(
        imageUrl: widget.publicite.imageUrl!,
        fit: BoxFit.contain,
        height: (context.width() / 3) + 20,
      ),
    );
  }
}

//

class VideoplayWidget extends StatefulWidget {
  final Publicite publicite;
  final PageController pageController;
  final List<Publicite> publicites;
  const VideoplayWidget({
    super.key,
    required this.publicite,
    required this.pageController,
    required this.publicites,
  });

  @override
  State<VideoplayWidget> createState() => _VideoplayWidgetState();
}

class _VideoplayWidgetState extends State<VideoplayWidget> {
  // late VideoPlayerController _controller;

  changePage() {
    final publicites = widget.publicites;
    final pageController = widget.pageController;
    final int currentPage = pageController.page!.toInt();
    if (currentPage == publicites.length - 1) {
      pageController.jumpTo(0);
    } else {
      pageController.animateToPage(currentPage + 1,
          duration: Duration(milliseconds: 500), curve: Curves.easeIn);
    }
  }

  late CachedVideoPlayerPlusController _controller;

  @override
  void initState() {
    print(widget.publicite.videoUrl!);
    _controller = CachedVideoPlayerPlusController.networkUrl(
      Uri.parse(widget.publicite.videoUrl!),
      invalidateCacheIfOlderThan: const Duration(days: 69),
    )..initialize().then((_) {
        setState(() {});
      });
    _controller.addListener(() {
      if (_controller.value.isCompleted) {
        changePage();
      }
    });
    _controller.play();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _controller.value.isInitialized
          ? GestureDetector(
              onLongPress: () {
                _controller.pause();
              },
              onLongPressEnd: (details) {
                _controller.play();
                setState(() {});
              },
              child: CachedVideoPlayerPlus(_controller),
            )
          : Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
    );
  }
}
