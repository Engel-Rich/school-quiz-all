import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../models/Model.dart';
import '/../screens/LoginScreen.dart';
import '/../utils/DataProviders.dart';
import '/../utils/colors.dart';
import '/../utils/constants.dart';

class WalkThroughScreen extends StatefulWidget {
  static String tag = '/WalkThroughScreen';

  @override
  WalkThroughScreenState createState() => WalkThroughScreenState();
}

class WalkThroughScreenState extends State<WalkThroughScreen> {
  PageController? pageController;
  int currentPage = 0;
  List<WalkThroughItemModel> pages = getWalkThroughItems();

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    pageController = PageController(initialPage: currentPage);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: context.height()*0.5,
                child: PageView(
                  controller: pageController,
                  children: List.generate(
                    pages.length,
                    (index) {
                      return Column(
                        children: [
                          Image.asset(pages[index].image!, width: context.width(), height: context.height() * 0.5, fit: BoxFit.cover),
                        ],
                      );
                    },
                  ),
                  onPageChanged: (value) {
                    currentPage = value;
                    setState(() {});
                  },
                ),
              ),
              50.height,
              Column(
                children: [
                  Text(
                    pages[currentPage].title!,
                    style: boldTextStyle(size: 30),
                    textAlign: TextAlign.center,
                  ).paddingOnly(left: 30, right: 30),
                  30.height,
                  Text(
                    pages[currentPage].subTitle!,
                    textAlign: TextAlign.center,
                  ).paddingOnly(left: 30, right: 30),
                ],
              ),
              16.height,
            ],
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    await setValue(IS_FIRST_TIME, false);
                    LoginScreen().launch(context,isNewTask: true);
                  },
                  child: Text('Skip', style: boldTextStyle(color: grey)),
                ),
                DotIndicator(
                  pages: pages,
                  pageController: pageController!,
                  indicatorColor: colorPrimary,
                ),
                AppButton(
                  child: Text(
                    currentPage != pages.length-1?'Next':'Get Started',
                    style: boldTextStyle(color: white),
                  ),
                  color: colorPrimary,
                  splashColor: Colors.transparent,
                  onTap: () async {
                    if (currentPage != pages.length-1) {
                      pageController!.animateToPage(++currentPage, duration: Duration(milliseconds: 250), curve: Curves.bounceInOut);
                    } else {
                      await setValue(IS_FIRST_TIME, false);
                      LoginScreen().launch(context, isNewTask: true);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
