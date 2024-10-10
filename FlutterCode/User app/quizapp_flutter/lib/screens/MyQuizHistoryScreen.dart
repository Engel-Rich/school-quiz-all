import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../components/QuizHistoryComponent.dart';
import '/../main.dart';
import '/../models/QuizHistoryModel.dart';
import '/../screens/QuizHistoryDetailScreen.dart';
import '/../utils/colors.dart';
import '/../utils/constants.dart';
import '/../utils/widgets.dart';

class MyQuizHistoryScreen extends StatefulWidget {
  static String tag = '/MyQuizHistoryScreen';

  @override
  MyQuizHistoryScreenState createState() => MyQuizHistoryScreenState();
}

class MyQuizHistoryScreenState extends State<MyQuizHistoryScreen> {
  BannerAd? myBanner;

  List<String> dropdownItems = [All, QuizTypeDaily, QuizTypeSelfChallenge, QuizTypeCategory, QuizTypeTrueFalse,QuizTypeGuessWord,QuizTypeRandom,QuizTypeContest];
  String? dropdownValue;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    dropdownValue = dropdownItems.first;

    if (!getBoolAsync(DISABLE_AD)) {
      myBanner = buildBannerAd()..load();
    }
  }

  BannerAd buildBannerAd() {
    return BannerAd(
      size: AdSize.banner,
      request: AdRequest(keywords: adMobTestDevices),
      adUnitId: mAdMobBannerId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          log('${ad.runtimeType} loaded.');
          myBanner = ad as BannerAd?;
          myBanner!.load();
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          log('${ad.runtimeType} failed to load: $error.');
          ad.dispose();
          bannerReady = true;
        },
        onAdOpened: (Ad ad) {
          log('${ad.runtimeType} onAdOpened.');
        },
        onAdClosed: (Ad ad) {
          log('${ad.runtimeType} closed.');
          ad.dispose();
        },
      ),
    );
  }

  @override
  void dispose() {
    myBanner?.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark
        ),
        title: Text(
          appStore.translate('lbl_history'),
          style: TextStyle(color: scaffoldColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: scaffoldColor),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return List.generate(
                dropdownItems.length,
                (index) {
                  return PopupMenuItem(
                    value: dropdownItems[index],
                    child: Text('${dropdownItems[index]}', style: primaryTextStyle()),
                  );
                },
              );
            },
            onSelected: (dynamic value) {
              dropdownValue = value;
              setState(() {});
            },
          ),
        ],
        flexibleSpace: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(26), bottomLeft: Radius.circular(26)),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.topRight, colors: [
                colorPrimary,
                colorSecondary,
              ]),
            )),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder(
            future: quizHistoryService.quizHistoryByQuizType(quizType: dropdownValue),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<QuizHistoryModel> data = snapshot.data as List<QuizHistoryModel>;
                return data.isNotEmpty
                    ? AnimationLimiter(
                      child: ListView.builder(
                          itemCount: data.length,
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          padding: EdgeInsets.only(left: 16,right: 16,top: 16,bottom: 50),
                          itemBuilder: (context, index) {
                            QuizHistoryModel? mData = data[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration:Duration(milliseconds: 500),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: QuizHistoryComponent(quizHistoryData: mData).onTap(
                                    () {
                                      QuizHistoryDetailScreen(quizHistoryData: mData).launch(context,pageRouteAnimation: PageRouteAnimation.Fade,duration: Duration(microseconds: 500));
                                    },
                                    borderRadius: BorderRadius.circular(defaultRadius),
                                  ).paddingBottom(16),
                                ),
                              ),
                            );
                          },
                        ),
                    )
                    : emptyWidget(text: "No Quiz History");
              }
              return snapWidgetHelper(snapshot, defaultErrorMessage: errorSomethingWentWrong);
            },
          ),
         if(!getBoolAsync(DISABLE_AD) && myBanner != null)
            Positioned(
              child: Container(
                child: myBanner != null ? AdWidget(ad: myBanner!) : SizedBox(),
                color: Colors.transparent,
              ),
              height: myBanner!.size.height.toDouble(),
              bottom: 0,
              width: context.width(),
            ) ,
        ],
      ),
    );
  }
}
