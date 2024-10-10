import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../components/UpgradeLevelDialogComponent.dart';
import '/../main.dart';
import '/../utils/ModelKeys.dart';
import '/../utils/colors.dart';
import '/../utils/constants.dart';
import '/../utils/widgets.dart';
import '../components/AppBarComponent.dart';

class EarnPointScreen extends StatefulWidget {
  static String tag = '/EarnPointScreen';

  @override
  EarnPointScreenState createState() => EarnPointScreenState();
}

class EarnPointScreenState extends State<EarnPointScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
  RewardedAd? rewardedAd;

  bool isWatchVideo = true;
  bool isRewardedAdReady = false;

  String? oldLevel, newLevel;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    createRewardedAd();
  }

  void createRewardedAd() {
    int numRewardedLoadAttempts = 0;
    RewardedAd.load(
      adUnitId: mAdMobRewardId,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          log('${ad.runtimeType} loaded.');
          rewardedAd = ad;
          numRewardedLoadAttempts = 0;
          isRewardedAdReady = true;
          setState(() {});
        },
        onAdFailedToLoad: (LoadAdError error) {
          toast('RewardedAd failed to load');
          log("$error");
          rewardedAd = null;
          numRewardedLoadAttempts += 1;
          if (numRewardedLoadAttempts <= maxFailedLoadAttempts) {
            createRewardedAd();
          }
        },
      ),
    );
  }

  Future<void> showRewardedAd() async {
    if (rewardedAd == null) {
      log('attempt to show rewarded before loaded.');
      return;
    }
    try {
      rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (RewardedAd ad) =>
            log('ad onAdShowedFullScreenContent.'),
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          appStore.setLoading(false);
          log('${ad.runtimeType} closed.');
          createRewardedAd();
          rewarded = true;
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          appStore.setLoading(false);
          print('$ad onAdFailedToShowFullScreenContent: $error');
          createRewardedAd();
          isRewardedAdReady = false;
        },
      );
      appStore.setLoading(false);
      rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          appStore.setLoading(true);
          log('$RewardedAd with reward $RewardItem(${reward.amount}, ${reward.type})');
          userDBService.updateDocument(
              {UserKeys.points: FieldValue.increment(10)},
              appStore.userId).then(
            (value) {
              appStore.setLoading(false);
              oldLevel = getLevel(points: getIntAsync('USER_POINTS'));
              setValue(USER_POINTS, getIntAsync(USER_POINTS) + 10);
              newLevel = getLevel(points: getIntAsync('USER_POINTS'));
              setState(() {});
              Future.delayed(
                2.seconds,
                () {
                  if (oldLevel != newLevel) {
                    showInDialog(context, builder: (BuildContext context) {
                      return UpgradeLevelDialogComponent(level: newLevel);
                    });
                  }
                },
              );
            },
          );
          setState(() => isWatchVideo = false);
        },
      );
      rewardedAd = null;
    } on AdError catch (e) {
      appStore.setLoading(false);
      toast("Erreur de chargement : ${e.message}");
      print("Erreur de chargement : ${e.message}");
    } catch (e) {
      appStore.setLoading(false);
      print("Erreur de chargement : $e");
    }
  }

//
  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(
          context: context, title: appStore.translate('lbl_earn_points')),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    elevation: 16,
                    margin: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(80)),
                    child: cachedImage(appStore.userProfileImage.validate(),
                        height: 130,
                        width: 130,
                        fit: BoxFit.cover,
                        alignment: Alignment.center),
                  ).center(),
                  16.height,
                  Observer(
                      builder: (context) => Text(appStore.userName ?? "",
                              style: boldTextStyle(size: 20))
                          .center()),
                  4.height,
                  Text('${appStore.translate('lbl_points')} ${getIntAsync(USER_POINTS)}',
                          style: boldTextStyle(size: 18, color: colorPrimary))
                      .center(),
                  16.height,
                  Divider(),
                  16.height,
                  Container(
                    width: context.width(),
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
                      child: Text(appStore.translate('lbl_watch_video'),
                          style: primaryTextStyle(color: white)),
                      onPressed: () async {
                        appStore.setLoading(true);
                        await 2.seconds.delay;
                        showRewardedAd();
                        // if (isRewardedAdReady) {
                        //   showRewardedAd();
                        //   appStore.setLoading(false);
                        // } else {
                        //   toast(appStore.translate('lbl_failed_reward_ad'));
                        //   appStore.setLoading(false);
                        // }
                      },
                    ),
                  ).visible(isWatchVideo),
                ],
              ).paddingOnly(left: 16, right: 16),
            ),
          ),
          Observer(
            builder: (context) => Loader().visible(appStore.isLoading),
          ),
        ],
      ),
    );
  }
}
