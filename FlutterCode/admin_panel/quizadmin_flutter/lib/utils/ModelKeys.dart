class CommonKeys {
  static String id = 'id';
  static String createdAt = 'createdAt';
  static String updatedAt = 'updatedAt';
}

class UserKeys {
  static String name = 'name';
  static String email = 'email';
  static String photoUrl = 'photoUrl';
  static String password = 'password';
  static String loginType = 'loginType';
  static String isNotificationOn = 'isNotificationOn';
  static String themeIndex = 'themeIndex';
  static String appLanguage = 'appLanguage';
  static String oneSignalPlayerId = 'oneSignalPlayerId';
  static String isAdmin = 'isAdmin';
  static String isSuperAdmin = 'isSuperAdmin';
  static String isTestUser = 'isTestUser';
  static String points = 'points';
}

class CategoryKeys {
  static String name = 'name';
  static String image = 'image';
  static String parentCategoryId = 'parentCategoryId';
  static String classe = 'classe';
  static String type = 'type';
}

class NewsKeys {
  static String commentCount = 'commentCount';
  static String content = 'content';
  static String shortContent = 'shortContent';
  static String thumbnail = 'thumbnail';
  static String sourceUrl = 'sourceUrl';
  static String image = 'image';
  static String newsStatus = 'newsStatus';
  static String postViewCount = 'postViewCount';
  static String title = 'title';
  static String newsType = 'newsType';
  static String allowComments = 'allowComments';
  static String categoryRef = 'category';
  static String authorRef = 'authorRef';
  static String caseSearch = 'caseSearch';
}

class AppSettingKeys {
  static String disableAd = 'disableAd';
  static String termCondition = 'termCondition';
  static String privacyPolicy = 'privacyPolicy';
  static String contactInfo = 'contactInfo';
  static String referPoints = 'referPoints';
}

class SubCategoryKeys {
  static String name = 'name';
  static String image = 'image';
}

class QuizKeys {
  static String questionRef = 'questionRef';
  static String minRequiredPoint = 'minRequiredPoint';
  static String imageUrl = 'imageUrl';
  static String quizTitle = 'quizTitle';
  static String categoryId = 'categoryId';
  static String quizTime = 'quizTime';
  static String description = 'description';
  static String subcategoryId = 'subcategoryId';
  static String startAt = 'startAt';
  static String endAt = 'endAt';
  static String isSpin = 'isSpin';
}

class QuestionKeys {
  static String questionType = 'questionType';
  static String correctAnswer = 'correctAnswer';
  static String note = 'note';
  static String addQuestion = 'addQuestion';
  static String optionList = 'optionList';
  static String subcategoryId = 'subcategoryId';
  static String audio = 'audio';
}

class QuizHistoryKeys {
  static String userId = 'userId';
  static String quizAnswers = 'quizAnswers';
  static String quizTitle = 'quizTitle';
  static String image = 'image';
  static String quizType = 'quizType';
  static String totalQuestion = 'totalQuestion';
  static String rightQuestion = 'rightQuestion';
}

class QuizAnswerKeys {
  static String question = 'question';
  static String answers = 'answers';
  static String correctAnswer = 'correctAnswer';
}
