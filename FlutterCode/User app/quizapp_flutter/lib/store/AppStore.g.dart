// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AppStore on _AppStore, Store {
  late final _$isLoadingAtom =
      Atom(name: '_AppStore.isLoading', context: context);

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$userNameAtom =
      Atom(name: '_AppStore.userName', context: context);

  @override
  String? get userName {
    _$userNameAtom.reportRead();
    return super.userName;
  }

  @override
  set userName(String? value) {
    _$userNameAtom.reportWrite(value, super.userName, () {
      super.userName = value;
    });
  }

  //Current Classe

  late final _$currentClasseAtom =
      Atom(name: '_AppStore.currentClasse', context: context);

  @override
  ClasseModel? get currentClasse {
    _$currentClasseAtom.reportRead();
    return super.currentClasse;
  }

  @override
  set currentClasse(ClasseModel? value) {
    _$currentClasseAtom.reportWrite(value, super.currentClasse, () {
      super.currentClasse = value;
    });
  }
  // End Of Current classe

  late final _$isLoggedInAtom =
      Atom(name: '_AppStore.isLoggedIn', context: context);

  @override
  bool get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(bool value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  late final _$userProfileImageAtom =
      Atom(name: '_AppStore.userProfileImage', context: context);

  @override
  String? get userProfileImage {
    _$userProfileImageAtom.reportRead();
    return super.userProfileImage;
  }

  @override
  set userProfileImage(String? value) {
    _$userProfileImageAtom.reportWrite(value, super.userProfileImage, () {
      super.userProfileImage = value;
    });
  }

  late final _$userIdAtom = Atom(name: '_AppStore.userId', context: context);

  @override
  String? get userId {
    _$userIdAtom.reportRead();
    return super.userId;
  }

  @override
  set userId(String? value) {
    _$userIdAtom.reportWrite(value, super.userId, () {
      super.userId = value;
    });
  }

  late final _$userClasseAtom =
      Atom(name: '_AppStore.userClasse', context: context);

  @override
  String? get userClasse {
    _$userClasseAtom.reportRead();
    return super.userClasse;
  }

  @override
  set userClasse(String? value) {
    _$userClasseAtom.reportWrite(value, super.userClasse, () {
      super.userClasse = value;
    });
  }

  late final _$userEmailAtom =
      Atom(name: '_AppStore.userEmail', context: context);

  @override
  String? get userEmail {
    _$userEmailAtom.reportRead();
    return super.userEmail;
  }

  @override
  set userEmail(String? value) {
    _$userEmailAtom.reportWrite(value, super.userEmail, () {
      super.userEmail = value;
    });
  }

  late final _$userAgeAtom = Atom(name: '_AppStore.userAge', context: context);

  @override
  String? get userAge {
    _$userAgeAtom.reportRead();
    return super.userAge;
  }

  @override
  set userAge(String? value) {
    _$userAgeAtom.reportWrite(value, super.userAge, () {
      super.userAge = value;
    });
  }

  late final _$selectedLanguageAtom =
      Atom(name: '_AppStore.selectedLanguage', context: context);

  @override
  String get selectedLanguage {
    _$selectedLanguageAtom.reportRead();
    return super.selectedLanguage;
  }

  @override
  set selectedLanguage(String value) {
    _$selectedLanguageAtom.reportWrite(value, super.selectedLanguage, () {
      super.selectedLanguage = value;
    });
  }

  late final _$appLocaleAtom =
      Atom(name: '_AppStore.appLocale', context: context);

  @override
  AppLocalizations? get appLocale {
    _$appLocaleAtom.reportRead();
    return super.appLocale;
  }

  @override
  set appLocale(AppLocalizations? value) {
    _$appLocaleAtom.reportWrite(value, super.appLocale, () {
      super.appLocale = value;
    });
  }

  late final _$isDarkModeAtom =
      Atom(name: '_AppStore.isDarkMode', context: context);

  @override
  bool get isDarkMode {
    _$isDarkModeAtom.reportRead();
    return super.isDarkMode;
  }

  @override
  set isDarkMode(bool value) {
    _$isDarkModeAtom.reportWrite(value, super.isDarkMode, () {
      super.isDarkMode = value;
    });
  }

  late final _$setDarkModeAsyncAction =
      AsyncAction('_AppStore.setDarkMode', context: context);

  @override
  Future<void> setDarkMode(bool aIsDarkMode) {
    return _$setDarkModeAsyncAction.run(() => super.setDarkMode(aIsDarkMode));
  }

  late final _$_AppStoreActionController =
      ActionController(name: '_AppStore', context: context);

  @override
  void setAppLocalization(BuildContext context) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.setAppLocalization');
    try {
      return super.setAppLocalization(context);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLanguage(String val) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setLanguage');
    try {
      return super.setLanguage(val);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoading(bool value) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setLoading');
    try {
      return super.setLoading(value);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setLoggedIn(bool value) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setLoggedIn');
    try {
      return super.setLoggedIn(value);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setName(String? name) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setName');
    try {
      return super.setName(name);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  // Set currentClasse

  @override
  void setCurrentClasse(ClasseModel? name) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.setCurrentClasse');
    try {
      return super.setCurrentClasse(name);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserId(String? value) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setUserId');
    try {
      return super.setUserId(value);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserClasse(String? value) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.setUserClasse');
    try {
      return super.setUserClasse(value);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserEmail(String? value) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setUserEmail');
    try {
      return super.setUserEmail(value);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setUserAge(String? value) {
    final _$actionInfo =
        _$_AppStoreActionController.startAction(name: '_AppStore.setUserAge');
    try {
      return super.setUserAge(value);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setProfileImage(String? image) {
    final _$actionInfo = _$_AppStoreActionController.startAction(
        name: '_AppStore.setProfileImage');
    try {
      return super.setProfileImage(image);
    } finally {
      _$_AppStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoading: ${isLoading},
userName: ${userName},
isLoggedIn: ${isLoggedIn},
userProfileImage: ${userProfileImage},
userId: ${userId},
userClasse: ${userClasse},
userEmail: ${userEmail},
userAge: ${userAge},
selectedLanguage: ${selectedLanguage},
appLocale: ${appLocale},
currentClasse: ${currentClasse}
isDarkMode: ${isDarkMode}
    ''';
  }
}
