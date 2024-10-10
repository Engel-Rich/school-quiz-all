const mAppName = 'School Quizzes';

const DocLimit = 10;

const storageName = "gs://mighty-quiz-app.appspot.com";

const mFirebaseStorageFilePath = 'images';
const mTestUserMsg = 'Test user not allowed to perform this action';

const defaultLanguage = 'en';

const mOneSignalAppId = 'a6b11e9e-7051-4c8f-b1ad-5e0b24a54c7f';
const mOneSignalRestKey = 'YmNmYTlkOWQtMWU0NC00MmJjLTk5NTgtNmRhOGZhN2FiZTYw';

const DailyQuestionLimit = 10;
const CurrentDateFormat = 'dd-MM-yyyy';
const CurrentDateFormat1 = 'dd MMM yyyy';

const mTesterNotAllowedMsg = 'Tester role not allowed to perform this action';

/// Question Type
const QuestionTypeOption = 'option';
const QuestionTypeTrueFalse = 'truefalse';
const QuestionTypeGuessWord = "GuessWord";
const QuestionTypePuzzle = 'puzzle';
const QuestionTypePoll = 'poll';

/* Login Type */
const LoginTypeApp = 'app';
const LoginTypeGoogle = 'google';
const LoginTypeOTP = 'otp';

/* Theme Mode Type */
const ThemeModeLight = 0;
const ThemeModeDark = 1;
const ThemeModeSystem = 2;

//region SharedPreferences Keys

///User keys
const IS_LOGGED_IN = 'IS_LOGGED_IN';
const IS_ADMIN = 'IS_ADMIN';
const IS_SUPER_ADMIN = 'IS_SUPER_ADMIN';
const IS_TEST_USER = 'IS_TEST_USER';
const USER_ID = 'USER_ID';
const FULL_NAME = 'FULL_NAME';
const USER_EMAIL = 'USER_EMAIL';
const USER_ROLE = 'USER_ROLE';
const PASSWORD = 'PASSWORD';
const PROFILE_IMAGE = 'PROFILE_IMAGE';
const THEME_MODE_INDEX = "THEME_MODE_INDEX";
const IS_NOTIFICATION_ON = "IS_NOTIFICATION_ON";
const IS_REMEMBERED = "IS_REMEMBERED";
const PLAYER_ID = 'PLAYER_ID';
const IS_SOCIAL_LOGIN = 'IS_SOCIAL_LOGIN';
const LOGIN_TYPE = 'LOGIN_TYPE';
const LANGUAGE = 'LANGUAGE';
const NOTIFICATION = 'notification';

const TERMS_AND_CONDITION_PREF = 'TERMS_AND_CONDITION_PREF';
const PRIVACY_POLICY_PREF = 'PRIVACY_POLICY_PREF';
const CONTACT_PREF = 'CONTACT_PREF';
const DISABLE_AD = 'DISABLE_AD';

const DASHBOARD_WIDGET_ORDER = 'DASHBOARD_WIDGET_ORDER';

//region LiveStream Keys
const StreamRefresh = 'StreamRefresh';

//AdminStatisticsWidget
const TotalCategories = 1;
const TotalQuestions = 3;
const TotalUsers = 9;

const test_user = "emilyjones@example.com";

enum PLAYERSTATE { played, pause }

enum ClasseType { trainning, academic }
