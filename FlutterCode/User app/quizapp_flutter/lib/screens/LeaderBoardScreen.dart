import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../utils/colors.dart';
import '../main.dart';
import '../models/LeaderBoardModel.dart';
import '../utils/images.dart';
import '../utils/widgets.dart';

class LeadingBoardScreen extends StatefulWidget {
  final bool? isContest;
  final String? contestId;

  LeadingBoardScreen({this.isContest, this.contestId});

  @override
  State<LeadingBoardScreen> createState() => _LeadingBoardScreenState();
}

class _LeadingBoardScreenState extends State<LeadingBoardScreen> {
  List<LeaderBoardModel> userList = [];
  bool isShow = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    if (widget.isContest == false) {
      userDBService.userByPoints().then((value) {
        value.forEach((element) {
          if (element.id == appStore.userId) {
            element.name = "You";
            userList.add(LeaderBoardModel(points: element.points, photoUrl: element.photoUrl, name: element.name, id: element.id));
          } else {
            userList.add(LeaderBoardModel(name: element.name, points: element.points, photoUrl: element.photoUrl, id: element.id));
          }
          print("id ======================================> ${element.id}  points =======>${element.points}");
        });
        setState(() {
          isShow = true;
        });
      });
    } else {
      print(".................... $isShow");
      quizHistoryService.quizHistoryByQuiz(quizId: widget.contestId).then((value) {
        value.forEach((e) {
          userDBService.getUserById(e.userId!).then((v) {
            userList.add(LeaderBoardModel(name: v.name, points: (e.rightQuestion! * 10), photoUrl: v.photoUrl, id: v.id));
            isShow = true;
            setState(() {});
          });
        });
        if (value.length == 0) {
          print("No Record");
          setState(() {
            isShow = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      body: isShow == false
          ? Center(child: CircularProgressIndicator())
          : userList.length == 0
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(padding: EdgeInsets.only(left: 16, right: 16, bottom: 16), child: Icon(Icons.close, color: appStore.isDarkMode ? Colors.white : Colors.black))),
                    ).paddingOnly(top: height + 6),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(EmptyImage, height: 150, fit: BoxFit.cover),
                        Text('No One Has Played This Contest ', style: boldTextStyle(size: 20)),
                      ],
                    ).expand(),
                  ],
                ).center()
              : NestedScrollView(
          headerSliverBuilder:(context, innerBoxIsScrolled) {
            return[
             SliverAppBar(
               expandedHeight:450,
               pinned: true,
               iconTheme:IconThemeData(color:Colors.white) ,
               elevation: 0,
               backgroundColor: Colors.transparent,
               flexibleSpace: Container(
                 decoration: BoxDecoration(
                     borderRadius: BorderRadius.only(bottomLeft: Radius.circular(26), bottomRight: Radius.circular(26)),
                     gradient: LinearGradient(colors: [colorPrimary, colorSecondary], begin: FractionalOffset.centerLeft, end: FractionalOffset.centerRight)),
                 child: FlexibleSpaceBar(
                 collapseMode: CollapseMode.pin,
                 background:Stack(
                   children: [
                     Image.asset(background_image, height: 450, fit: BoxFit.fitHeight, opacity: AlwaysStoppedAnimation(.85)),
                     // Positioned(
                     //   top: height + 6,
                     //   left:appStore.selectedLanguage=='ar'?null: 16,
                     //   right: appStore.selectedLanguage=='ar'?16:null,
                     //   child: InkWell(onTap: () => Navigator.pop(context), child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28)),
                     // ),
                     Positioned(
                       bottom: 0,
                       left: 16,
                       right: 16,
                       child: Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         crossAxisAlignment: CrossAxisAlignment.end,
                         children: [
                           Column(
                             children: [
                               userList.length >= 3
                                   ? userList[1].photoUrl!.isEmpty
                                   ? CircleAvatar(
                                 radius: 50,
                                 child: Image.asset(UserPic),
                               )
                                   : CircleAvatar(
                                 radius: 50,
                                 child: cachedImage(userList[1].photoUrl!, usePlaceholderIfUrlEmpty: true, height: 80, width: 80, fit: BoxFit.cover).cornerRadiusWithClipRRect(40),
                               )
                                   : CircleAvatar(
                                 radius: 50,
                                 child: Icon(
                                   Icons.question_mark,
                                   size: 50,
                                   color: Theme.of(context).iconTheme.color,
                                 ).cornerRadiusWithClipRRect(40),
                               ),
                               16.height,
                               Stack(
                                 children: [
                                   Container(
                                     width: 90,
                                     height: 180,
                                     decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)), color: Colors.red),
                                   ),
                                   Positioned.fill(
                                     top: 16,
                                     child: Align(
                                       alignment: Alignment.topCenter,
                                       child: Column(
                                         children: [
                                           Container(
                                             width: 30,
                                             height: 30,
                                             alignment: Alignment.center,
                                             decoration: BoxDecoration(
                                               shape: BoxShape.circle,
                                               color: Colors.grey.withOpacity(0.6),
                                             ),
                                             child: Text("2", style: boldTextStyle(color: Colors.white)),
                                           ),
                                           6.height,
                                           userList.length >= 3 ? Text(userList[1].name!, style: boldTextStyle(color: Colors.white), overflow: TextOverflow.ellipsis) : Text(""),
                                           6.height,
                                           userList.length >= 3 ? Text(userList[1].points!.toString(), style: boldTextStyle(color: Colors.white,size: 20)) : Text(""),
                                         ],
                                       ),
                                     ),
                                   )
                                 ],
                               )
                             ],
                           ),
                           Column(
                             children: [
                               userList[0].photoUrl!.isEmpty
                                   ? CircleAvatar(
                                 radius: 50,
                                 child: Image.asset(UserPic),
                               )
                                   : CircleAvatar(
                                 radius: 50,
                                 child: cachedImage(userList.first.photoUrl!, usePlaceholderIfUrlEmpty: true, height: 80, width: 80, fit: BoxFit.cover).cornerRadiusWithClipRRect(40),
                               ),
                               16.height,
                               Stack(
                                 children: [
                                   Container(
                                     width: 90,
                                     height: 260,
                                     decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)), color: Colors.red),
                                   ),
                                   Positioned.fill(
                                     top: 16,
                                     child: Align(
                                       alignment: Alignment.topCenter,
                                       child: Column(
                                         children: [
                                           Container(
                                             width: 30,
                                             height: 30,
                                             alignment: Alignment.center,
                                             decoration: BoxDecoration(
                                               shape: BoxShape.circle,
                                               color: Colors.grey.withOpacity(0.6),
                                             ),
                                             child: Text("1", style: boldTextStyle(color: Colors.white)),
                                           ),
                                           6.height,
                                           Text(userList[0].name!, style: boldTextStyle(color: Colors.white), overflow: TextOverflow.ellipsis),
                                           6.height,
                                           Text(userList[0].points!.toString(), style: boldTextStyle(color: Colors.white,size: 20)),
                                         ],
                                       ),
                                     ),
                                   )
                                 ],
                               ),
                             ],
                           ),
                           Column(
                             children: [
                               userList.length >= 4
                                   ? userList[2].photoUrl!.isEmpty
                                   ? CircleAvatar(
                                 radius: 50,
                                 child: Image.asset(UserPic),
                               )
                                   : CircleAvatar(
                                 radius: 50,
                                 child: cachedImage(userList[2].photoUrl!, usePlaceholderIfUrlEmpty: true, height: 80, width: 80, fit: BoxFit.cover).cornerRadiusWithClipRRect(40),
                               )
                                   : CircleAvatar(
                                 radius: 50,
                                 child: Icon(
                                   Icons.question_mark,
                                   size: 40,
                                   color: Theme.of(context).iconTheme.color,
                                 ).cornerRadiusWithClipRRect(40),
                               ),
                               16.height,
                               Stack(
                                 children: [
                                   Container(
                                     width: 90,
                                     height: 120,
                                     decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)), color: Colors.red),
                                   ),
                                   Positioned.fill(
                                     top: 16,
                                     child: Align(
                                       alignment: Alignment.topCenter,
                                       child: Column(
                                         children: [
                                           Container(
                                             width: 30,
                                             height: 30,
                                             alignment: Alignment.center,
                                             decoration: BoxDecoration(
                                               shape: BoxShape.circle,
                                               color: Colors.grey.withOpacity(0.6),
                                             ),
                                             child: Text("3", style: boldTextStyle(color: Colors.white)),
                                           ),
                                           6.height,
                                           userList.length >= 4 ? Text(userList[2].name!, style: boldTextStyle(color: Colors.white), overflow: TextOverflow.ellipsis) : Text(""),
                                           6.height,
                                           userList.length >= 4 ? Text(userList[2].points!.toString(), style: boldTextStyle(color: Colors.white,size: 20)) : Text(""),
                                         ],
                                       ),
                                     ),
                                   )
                                 ],
                               ),
                             ],
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
               ),
               ),

             )
            ];
          },
        body: SingleChildScrollView(
          child: Column(
                      children: [
                        SizedBox(
                          child: Wrap(
                            runSpacing: 16,
                            children: List.generate(
                              userList.length,
                              (index) {
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: Duration(seconds: 1),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: index == 0
                                          ? Container(
                                              width: context.width(),
                                              height: 80,
                                              margin: EdgeInsets.symmetric(horizontal: 10),
                                              decoration: BoxDecoration(color: Color(0xfffd7647).withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Image.asset(one, width: 50, height: 50,color:colorSecondary),
                                                      6.width,
                                                      CircleAvatar(
                                                        radius: 20,
                                                        child: cachedImage(userList[index].photoUrl!, usePlaceholderIfUrlEmpty: true, height: 80, width: 80, fit: BoxFit.cover)
                                                            .cornerRadiusWithClipRRect(40),
                                                      ),
                                                      6.width,
                                                      Text(userList[index].name!, style: boldTextStyle()),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(userList[index].points.toString(), style: boldTextStyle(size: 18)),
                                                      4.width,
                                                      Text("Points", style: primaryTextStyle()),
                                                    ],
                                                  ).paddingOnly(right: appStore.selectedLanguage=='ar'?0:16,left: appStore.selectedLanguage=='ar'?16:0)
                                                ],
                                              ),
                                            )
                                          : index == 1
                                              ? Container(
                                                  width: context.width(),
                                                  height: 80,
                                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                                  decoration: BoxDecoration(color: Color(0xfffd7647).withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Image.asset(two, width: 50, height: 50,color:colorSecondary),
                                                          6.width,
                                                          CircleAvatar(
                                                            radius: 20,
                                                            child: cachedImage(userList[index].photoUrl!, usePlaceholderIfUrlEmpty: true, height: 80, width: 80, fit: BoxFit.cover)
                                                                .cornerRadiusWithClipRRect(40),
                                                          ),
                                                          6.width,
                                                          Text(userList[index].name!, style: boldTextStyle()),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(userList[index].points.toString(), style: boldTextStyle(size: 18)),
                                                          4.width,
                                                          Text("Points", style: primaryTextStyle()),
                                                        ],
                                                      ).paddingOnly(right:  appStore.selectedLanguage=='ar'?0:16,left: appStore.selectedLanguage=='ar'?16:0)
                                                    ],
                                                  ),
                                                )
                                              : index == 2
                                                  ? Container(
                                                      width: context.width(),
                                                      height: 80,
                                                      margin: EdgeInsets.symmetric(horizontal: 10),
                                                      decoration: BoxDecoration(color: Color(0xfffd7647).withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Image.asset(three, width: 50, height: 50,color:colorSecondary),
                                                              6.width,
                                                              CircleAvatar(
                                                                radius: 20,
                                                                child: cachedImage(userList[index].photoUrl!, usePlaceholderIfUrlEmpty: true, height: 80, width: 80, fit: BoxFit.cover)
                                                                    .cornerRadiusWithClipRRect(40),
                                                              ),
                                                              6.width,
                                                              Text(userList[index].name!, style: boldTextStyle()),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(userList[index].points.toString(), style: boldTextStyle(size: 18)),
                                                              4.width,
                                                              Text("Points", style: primaryTextStyle()),
                                                            ],
                                                          ).paddingOnly(right:  appStore.selectedLanguage=='ar'?0:16,left: appStore.selectedLanguage=='ar'?16:0)
                                                        ],
                                                      ),
                                                    )
                                                  : Container(
                                                      padding: EdgeInsets.only(left: 30, right: 26),
                                                      decoration: BoxDecoration(color: userList[index].id == appStore.userId ? Colors.grey.withOpacity(0.3) : Colors.transparent),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              SizedBox(width:30,child: Text("${index + 1}".toString(), style: boldTextStyle())),
                                                              // CircleAvatar(
                                                              //   radius: 20,
                                                              //   child: cachedImage(userList[index].photoUrl!, usePlaceholderIfUrlEmpty: true, height: 80, width: 80, fit: BoxFit.cover)
                                                              //       .cornerRadiusWithClipRRect(40),
                                                              // ),
                                                              6.width,
                                                              SizedBox(width:context.width()-230,child: Text(userList[index].name!, style: boldTextStyle())),
                                                            ],
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(userList[index].points.toString(), style: boldTextStyle(size: 18)),
                                                              4.width,
                                                              Text("Points", style: primaryTextStyle()),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ).paddingOnly(top: 16, bottom: 16),
                        ),
                      ],
                    ),
        ),
              ),
    );
  }
}
