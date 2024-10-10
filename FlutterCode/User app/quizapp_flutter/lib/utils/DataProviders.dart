import 'package:nb_utils/nb_utils.dart';
import '/../main.dart';
import '/../models/Model.dart';
import '/../screens/DailyQuizDescriptionScreen.dart';
import '/../screens/EarnPointScreen.dart';
import '/../screens/MyQuizHistoryScreen.dart';
import '/../screens/QuizCategoryScreen.dart';
import '/../screens/SelfChallengeFormScreen.dart';
import '/../screens/SettingScreen.dart';
import '/../utils/ModelKeys.dart';
import '/../utils/constants.dart';
import '/../utils/images.dart';
import '../screens/HelpDeskScreen.dart';
import '../screens/LeaderBoardScreen.dart';
import '../screens/ReferAndEarnScreen.dart';

String description =
    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.";

List<DrawerItemModel> getDrawerItems() {
  List<DrawerItemModel> drawerItems = [];
  drawerItems.add(
      DrawerItemModel(name: appStore.translate('lbl_home'), image: HomeImage));
  // drawerItems.add(DrawerItemModel(name: appStore.translate('lbl_profile'), image: ProfileImage, widget: ProfileScreen()));
  drawerItems.add(DrawerItemModel(
      name: appStore.translate('lbl_leaderboard'),
      image: leaderBoard,
      widget: LeadingBoardScreen(isContest: false)));
  drawerItems.add(DrawerItemModel(
      name: appStore.translate('lbl_daily_quiz'),
      image: DailyQuizImage,
      widget: DailyQuizDescriptionScreen()));
  drawerItems.add(DrawerItemModel(
      name: appStore.translate('lbl_quiz_category'),
      image: QuizCategoryImage,
      widget: QuizCategoryScreen()));
  drawerItems.add(DrawerItemModel(
      name: appStore.translate('lbl_self_challenge'),
      image: SelfChallengeImage,
      widget: SelfChallengeFormScreen()));
  drawerItems.add(DrawerItemModel(
      name: appStore.translate('lbl_my_quiz_history'),
      image: QuizHistoryImage,
      widget: MyQuizHistoryScreen()));
  if (!getBoolAsync(DISABLE_AD))
    drawerItems.add(DrawerItemModel(
        name: appStore.translate('lbl_earn_points'),
        image: EarnPointsImage,
        widget: EarnPointScreen()));
  drawerItems.add(DrawerItemModel(
      name: appStore.translate('lbl_refer_earn'),
      widget: ReferAndEarnScreen(),
      image: referEarn));
  drawerItems.add(DrawerItemModel(
      name: appStore.translate('lbl_setting'),
      widget: SettingScreen(),
      image: SettingImage));
  drawerItems.add(DrawerItemModel(
      name: appStore.translate('lbl_help_desk'),
      widget: HelpDeskScreen(),
      image: helpDesk));
  drawerItems.add(DrawerItemModel(
      name: appStore.translate('lbl_delete_account'), image: delete));
  drawerItems.add(DrawerItemModel(
      name: appStore.translate('lbl_logout'), image: LogoutImage));
  return drawerItems;
}

List<WalkThroughItemModel> getWalkThroughItems() {
  List<WalkThroughItemModel> walkThroughItems = [];
  walkThroughItems.add(
    WalkThroughItemModel(
      image: WalkThroughImage1,
      title: "Explorez un apprentissage ludique avec School Quiz!",
      subTitle:
          "Plongez dans une expérience d'apprentissage addictive avec School Quiz, où vous pouvez tester et améliorer vos compétences en langues ainsi que votre savoir scolaire. Du TCF, TEF, DALFC1 DALFC2 au TOEFL, découvrez une approche divertissante pour renforcer votre maîtrise linguistique.",
    ),
  );
  walkThroughItems.add(
    WalkThroughItemModel(
      image: WalkThroughImage2,
      title: "Explorez le Savoir Éducatif et Culturel avec School Quiz!",
      subTitle:
          "Découvrez une mine de connaissances basée sur le programme éducatif actuel et enrichissez votre culture générale avec School Quiz. Plongez dans un univers d'apprentissage où le savoir académique se marie harmonieusement avec la découverte de sujets culturels passionnants.",
    ),
  );
  walkThroughItems.add(
    WalkThroughItemModel(
      image: WalkThroughImage3,
      title: "Maîtrisez Votre Évolution avec School Quiz!",
      subTitle:
          "Explorez votre progression à chaque étape de votre parcours d'apprentissage grâce à School Quiz. Suivez votre niveau de compétence de manière interactive et surveillez votre évolution tout au long de votre voyage éducatif.",
    ),
  );
  walkThroughItems.add(
    WalkThroughItemModel(
      image: WalkThroughImage3,
      title: "Étendez Vos Connaissances Sans Effort avec School Quiz!",
      subTitle:
          "Découvrez comment School Quiz peut vous aider à développer rapidement votre niveau de connaissances. Grâce à notre approche innovante, vous pouvez atteindre une croissance exponentielle de vos compétences en un temps record, sans tracas ni effort excessif.",
    ),
  );
  return walkThroughItems;
}

List<DrawerItemModel> getQuestionTypeList() {
  List<DrawerItemModel> questionTypeList = [];
  questionTypeList
      .add(DrawerItemModel(image: OptionQuiz, name: QuestionTypeKeys.options));
  questionTypeList.add(
      DrawerItemModel(image: TruFalseQuiz, name: QuestionTypeKeys.trueFalse));

  return questionTypeList;
}

List<AddAnswerModel> getAddAnswerList() {
  List<AddAnswerModel> addAnswerList = [];
  addAnswerList.add(AddAnswerModel(name: '+  Add Answer'));
  addAnswerList.add(AddAnswerModel(name: '+  Add Answer'));
  addAnswerList.add(AddAnswerModel(name: '+  Add Answer'));
  addAnswerList.add(AddAnswerModel(name: '+  Add Answer'));

  return addAnswerList;
}

List<AddAnswerModel> getTrueFalseAddAnswerList() {
  List<AddAnswerModel> addTrueFalseAnswerList = [];
  addTrueFalseAnswerList.add(AddAnswerModel(name: 'True'));
  addTrueFalseAnswerList.add(AddAnswerModel(name: 'False'));
  return addTrueFalseAnswerList;
}
