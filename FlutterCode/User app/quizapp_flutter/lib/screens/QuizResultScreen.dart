import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../components/UpgradeLevelDialogComponent.dart';
import '/../main.dart';
import '/../models/QuizHistoryModel.dart';
import '/../screens/QuizHistoryDetailScreen.dart';
import '/../utils/colors.dart';
import '/../utils/constants.dart';
import '/../utils/images.dart';

import 'HomeScreen.dart';

class QuizResultScreen extends StatefulWidget {
  static String tag = '/QuizResultScreen';

  final QuizHistoryModel? quizHistoryData;
  final String? oldLevel, newLevel;

  QuizResultScreen({this.quizHistoryData, this.oldLevel, this.newLevel});

  @override
  QuizResultScreenState createState() => QuizResultScreenState();
}

class QuizResultScreenState extends State<QuizResultScreen> {
  late double? percentage;

  InterstitialAd? interstitialAd;

  @override
  void initState() {
    super.initState();
    init();
  }

  void createInterstitialAd() {
    int numInterstitialLoadAttempts = 0;
    InterstitialAd.load(
      adUnitId: mAdMobInterstitialId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          log('${ad.runtimeType} loaded.');
          interstitialReady = true;
          interstitialAd = ad;
          numInterstitialLoadAttempts = 0;
        },
        onAdFailedToLoad: (LoadAdError error) {
          log('InterstitialAd failed to load: $error.');
          numInterstitialLoadAttempts += 1;
          interstitialAd = null;
          if (numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
            createInterstitialAd();
          }
        },
      ),
    );
  }

  void showInterstitialAd(BuildContext context) {
    if (interstitialAd == null) {
      log('attempt to show interstitial before loaded.');
      finish(context);
      return;
    }
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) => print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        log('$ad onAdDismissedFullScreenContent.');
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        log('$ad onAdFailedToShowFullScreenContent: $error');
        createInterstitialAd();
      },
    );
    interstitialAd!.show();
    interstitialAd = null;
  }

  init() async {
    percentage = (widget.quizHistoryData!.rightQuestion! / widget.quizHistoryData!.totalQuestion!) * 100;
    Future.delayed(
      2.seconds,
      () {
        if (widget.oldLevel != widget.newLevel) {
          showInDialog(
            context,
            builder: (BuildContext context) {
              return UpgradeLevelDialogComponent(level: widget.newLevel);
            },
          );
        }
      },
    );

    if (!getBoolAsync(DISABLE_AD)) {
      createInterstitialAd();
    }
  }

  String? resultWiseImage() {
    if (percentage! >= 0 && percentage! <= 30) {
      return ResultTryAgainImage;
    } else if (percentage! > 30 && percentage! <= 60) {
      return ResultAverageImage;
    } else if (percentage! > 60 && percentage! <= 90) {
      return ResultGoodJobImage;
    } else if (percentage! > 90) {
      return ResultExcellentImage;
    } else {
      return '';
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() async {
    super.dispose();
    if (interstitialAd != null) {
      showInterstitialAd(context);
      interstitialAd?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).viewPadding.top;
    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            Container(
              width: context.width(),
              height: context.height(),
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage(ResultBgImage), fit: BoxFit.fill,opacity: 0.7),
              ),
            ),
            Container(
              height: context.height() * 0.80,
              width: context.width(),
              margin: EdgeInsets.only(left: 16, right: 16),
              child: Stack(
                alignment: AlignmentDirectional.center,
                children: [
                  Image.asset(ResultCardImage, fit: BoxFit.fill, width: context.width(), color: appStore.isDarkMode ? Colors.black : Colors.white).paddingOnly(top: 100),
                  Positioned(top: 16, height: 200, width: 200, child: Image.asset(resultWiseImage()!)),
                  Image.asset(ResultCompleteImage, height: 200, width: 200),
                  Text('${widget.quizHistoryData!.rightQuestion! * 10}', style: boldTextStyle(color: colorPrimary, size: 30)).paddingTop(30),
                  Positioned(
                    bottom: 40,
                    left: 16,
                    right: 16,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              color: colorSecondary,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(appStore.translate('lbl_total'), style: boldTextStyle(color: white)),
                                  4.height,
                                  Text('${widget.quizHistoryData!.totalQuestion}', style: boldTextStyle(color: white)),
                                ],
                              ),
                            ).cornerRadiusWithClipRRect(defaultRadius),
                            16.width,
                            Container(
                              width: 70,
                              height: 70,
                              color: greenColor,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(appStore.translate('lbl_right'), style: boldTextStyle(color: white)),
                                  4.height,
                                  Text('${widget.quizHistoryData!.rightQuestion}', style: boldTextStyle(color: white)),
                                ],
                              ),
                            ).cornerRadiusWithClipRRect(defaultRadius),
                            16.width,
                            Container(
                              width: 70,
                              height: 70,
                              color: Colors.red,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(appStore.translate('lbl_wrong'), style: boldTextStyle(color: white)),
                                  4.height,
                                  Text('${widget.quizHistoryData!.totalQuestion! - widget.quizHistoryData!.rightQuestion!}', style: boldTextStyle(color: white)),
                                ],
                              ),
                            ).cornerRadiusWithClipRRect(defaultRadius),
                          ],
                        ),
                        16.height,
                        Container(
                          width: 150,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colorPrimary, colorSecondary],
                              begin: FractionalOffset.centerLeft,
                              end: FractionalOffset.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(defaultRadius),
                          ),
                          child: TextButton(
                            onPressed:() => QuizHistoryDetailScreen(quizHistoryData: widget.quizHistoryData).launch(context),
                            child: Text(appStore.translate('lbl_see_answers'), style: primaryTextStyle(color: white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: height + 4,
              right: 16,
              child: Container(
                padding: EdgeInsets.all(8),
                color: appStore.isDarkMode ? Colors.black : white,
                child: Icon(Icons.home, color: colorPrimary).onTap(
                  () {
                    HomeScreen().launch(context, isNewTask: true);
                  },
                ),
              ).cornerRadiusWithClipRRect(defaultRadius),
            ),
          ],
        ),
      ),
    );
  }
}
