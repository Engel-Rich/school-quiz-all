import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:widget_zoom/widget_zoom.dart';
import '/../main.dart';
import '/../models/QuestionModel.dart';
import '/../utils/colors.dart';
import '/../utils/constants.dart';
import '/../utils/widgets.dart';
import 'package:shake_animation_widget/shake_animation_widget.dart';

class QuizQuestionComponent extends StatefulWidget {
  static String tag = '/QuizQuestionComponent1';

  final QuestionModel? question;
  final bool? isShow;

  QuizQuestionComponent({this.question, this.isShow});

  @override
  QuizQuestionComponentState createState() => QuizQuestionComponentState();
}

class QuizQuestionComponentState extends State<QuizQuestionComponent> {
  List<String> ans = [];
  List<String> optionList = [];
  TextEditingController textEditingController = TextEditingController();
  final List<ShakeAnimationController> _shakeAnimationController =
      List.generate(5, (index) => ShakeAnimationController());

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (widget.question!.answer == null) {
      textEditingController.text = '';
    } else {
      textEditingController.text = widget.question!.answer!;
    }

    //
    // widget.question!.optionList!.forEach((element) {
    //   ans.add(element);
    // });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    ans.clear();
    widget.question!.optionList!.forEach((element) {
      ans.add(element);
    });
    if (widget.isShow == false) {
      ans.clear();
      widget.question!.optionList!.forEach((element) {
        if (element != widget.question!.correctAnswer) {
          optionList.add(element);
        }
      });
      ans.add(widget.question!.correctAnswer!);
      ans.add(optionList.first);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.question!.addQuestion}',
            style: boldTextStyle(size: 20), textAlign: TextAlign.center),
        30.height,
        (widget.question!.image != null && widget.question!.image!.isNotEmpty)
            ? WidgetZoom(
                heroAnimationTag: widget.question?.id ?? 'Question_Id',
                zoomWidget: cachedImage(widget.question!.image!.validate(),
                    height: 150, fit: BoxFit.contain, width: context.width()),
              )
            : Container(),
        if (widget.question?.audio != null &&
            widget.question!.audio!.trim().isNotEmpty)
          Column(
            children: [
              16.height,
              AudioPlayerComponent(videoUrl: widget.question!.audio!),
            ],
          ),
        16.height,
        Column(
          children: List.generate(
            ans.length,
            (index) {
              String mData = ans[index];
              return ShakeAnimationWidget(
                shakeAnimationController: _shakeAnimationController[index],
                isForward: false,
                child: Container(
                  padding: EdgeInsets.all(16),
                  width: context.width(),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: boxDecorationWithRoundedCorners(
                    backgroundColor:
                        widget.question!.selectedOptionIndex == index
                            ? colorPrimary.withOpacity(0.7)
                            : appStore.isDarkMode
                                ? Colors.grey.withOpacity(0.2)
                                : scaffoldColor,
                  ),
                  child: Text('$mData', style: primaryTextStyle()),
                ).onTap(
                  () async {
                    setState(
                      () {
                        widget.question!.selectedOptionIndex = index;
                        log(widget.question!.optionList![index]);
                        widget.question!.answer =
                            widget.question!.optionList![index];
                        LiveStream()
                            .emit(answerQuestionStream, widget.question);
                        _shakeAnimationController[index].start();
                      },
                    );
                    await Duration(milliseconds: 600).delay;
                    _shakeAnimationController[index].stop();
                  },
                ),
              );
            },
          ),
        ),
        SizedBox(
          child: AppTextField(
            controller: textEditingController,
            textFieldType: TextFieldType.NAME,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (p0) {
              setState(
                () {
                  widget.question!.answer = p0.toUpperCase();
                  LiveStream().emit(answerQuestionStream, widget.question);
                },
              );
            },
            onFieldSubmitted: (p0) {
              setState(
                () {
                  widget.question!.answer = p0.toUpperCase();
                  LiveStream().emit(answerQuestionStream, widget.question);
                },
              );
            },
          ),
        ).visible(widget.question!.questionType == QuestionTypeGuessWord)
      ],
    );
  }
}

class AudioPlayerComponent extends StatefulWidget {
  final String videoUrl;
  const AudioPlayerComponent({super.key, this.videoUrl = ''});

  @override
  State<AudioPlayerComponent> createState() => _AudioPlayerComponentState();
}

class _AudioPlayerComponentState extends State<AudioPlayerComponent> {
  final player = AudioPlayer();
  Duration? duration;
  Duration position = Duration.zero;

  bool isPlaying = false;

  StreamSubscription? audioPlayerPositionStream;
  StreamSubscription? audioPlayerDurationStream;
  StreamSubscription? audioPlayerStatusStream;

  @override
  void dispose() {
    disposeStream();
    super.dispose();
  }

  disposeStream() async {
    player.dispose();
    await audioPlayerDurationStream?.cancel();
    await audioPlayerPositionStream?.cancel();
    await audioPlayerStatusStream?.cancel();

    duration = null;
    setState(() {});
  }

  disposeAudio() async {
    await audioPlayerDurationStream?.cancel();
    await audioPlayerPositionStream?.cancel();
    await audioPlayerStatusStream?.cancel();
  }

  initVideoStream() async {
    duration = await player.setUrl(widget.videoUrl);
    setState(() {});
    audioPlayerStatusStream = player.playingStream.listen((event) {
      setState(() {
        isPlaying = event;
      });
    });
    audioPlayerPositionStream = player.positionStream.listen((event) {
      position = event;
      if (position.inSeconds == duration?.inSeconds) {
        isPlaying = false;
      }
      setState(() {});
    });
    audioPlayerDurationStream = player.durationStream.listen((event) {
      duration = event;

      setState(() {});
    });
  }

  String formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    disposeAudio();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initVideoStream();
    });
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5),
      width: context.width(),
      // margin: EdgeInsets.only(bottom: 16),
      decoration: boxDecorationWithRoundedCorners(
        backgroundColor:
            appStore.isDarkMode ? Colors.grey.withOpacity(0.2) : scaffoldColor,
      ),
      // margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: duration == null
            ? SizedBox(
                height: 2,
                width: double.infinity,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 23),
                  child: LinearProgressIndicator(
                    color: white,
                    backgroundColor: black,
                  ),
                ),
              )
            : Row(
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    onTap: () async {
                      if (isPlaying) {
                        await player.pause();
                      } else {
                        await player.play();
                      }
                    },
                    child: Icon(
                      isPlaying
                          ? Icons.pause_circle_outlined
                          : Icons.play_circle_outline,
                      size: 35,
                    ),
                  ),
                  3.width,
                  Text(
                    '${formatTime(duration!.inSeconds - position.inSeconds)}',
                    style: primaryTextStyle(),
                  ),
                  3.width,
                  IgnorePointer(
                    child: Slider(
                      min: 0,
                      max: duration!.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble(),
                      activeColor: colorPrimary,
                      onChanged: (value) async {
                        position = Duration(seconds: value.toInt());
                        await player.seek(position);
                        if (isPlaying) player.play();
                        setState(() {});
                      },
                    ),
                  ).expand(),
                  5.width,
                  Text(
                    '${formatTime(duration!.inSeconds)}',
                    style: primaryTextStyle(),
                  ),
                ],
              ),
      ),
    );
  }
}
