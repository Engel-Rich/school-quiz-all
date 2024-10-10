import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:form_validator/form_validator.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizapp_flutter/models/ClasseModel.dart';
import 'package:quizapp_flutter/services/ClasseService.dart';
import 'package:quizapp_flutter/utils/colors.dart';
import '/../main.dart';
import '/../utils/ModelKeys.dart';
import '/../utils/images.dart';
import '/../utils/widgets.dart';
import '../models/SettingModel.dart';
import '../models/UserModel.dart';
import '../utils/constants.dart';
import 'HomeScreen.dart';

class RegisterScreen extends StatefulWidget {
  static String tag = '/RegisterScreen';
  final String? phoneNumber;
  final User? userModel;
  final bool? isPhone;

  RegisterScreen({this.userModel, this.phoneNumber, this.isPhone = false});

  @override
  RegisterScreenState createState() => RegisterScreenState();
}

class RegisterScreenState extends State<RegisterScreen> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController referCodeController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passFocus = FocusNode();
  FocusNode nameFocus = FocusNode();

  List<String> ageRangeList = [
    '5 - 10',
    '10 - 15',
    '15 - 20',
    '20 - 25',
    '25 - 30',
    '30 - 35',
    '35 - 40',
    '40 - 45',
    '45 - 50'
  ];

  String? dropdownValue;

  AppSettingModel appSettingModel = AppSettingModel();

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
    if (ClasseService.classeModelList.isEmpty) {
      await ClasseService.getClasseList();
      selectedModel = ClasseService.classeModelList.firstOrNull;
      setState(() {});
    } else {
      selectedModel = ClasseService.classeModelList.first;
      setState(() {});
    }
    appSettingModel = await db
        .collection('settings')
        .get()
        .then((value) => AppSettingModel.fromJson(value.docs.first.data()));
  }

  ClasseModel? selectedModel;

  signUp() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      appStore.setLoading(true);

      await authService
          .signUpWithEmailPassword(
              name: nameController.text,
              email: emailController.text.trim(),
              password: passController.text.trim(),
              age: dropdownValue,
              classe: selectedModel?.id_classe)
          .then(
        (value) {
          print("length of refer code ${referCodeController.text.length}");
          if (referCodeController.text.length > 5) {
            userDBService
                .getUserByReferCode(referCodeController.text.toUpperCase())
                .then((value) async {
              Map<String, dynamic> req = {};
              int newPoints =
                  value.points! + appSettingModel.referPoints.toInt();
              req.putIfAbsent(UserKeys.points, () => newPoints);
              await userDBService.updateDocument(req, value.id);
            });
          }
          appStore.setLoading(false);
          HomeScreen().launch(context, isNewTask: true);
          finish(context);
        },
      ).catchError(
        (e) {
          toast(e.toString());

          appStore.setLoading(false);
        },
      );
    }
  }

  void signUpWithOtp() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      appStore.setLoading(true);
      if (await userDBService.isUserExist(emailController.text, LoginTypeOTP)) {
        toast("user already register with email");
        appStore.setLoading(false);
      } else {
        UserModel userModel = UserModel();
        userModel.id = widget.userModel!.uid;
        userModel.email = emailController.text.validate();
        userModel.name = nameController.text.validate();
        userModel.age = dropdownValue;
        userModel.photoUrl = '';
        userModel.mobileNumber = widget.phoneNumber;
        userModel.loginType = LoginTypeOTP;
        userModel.updatedAt = DateTime.now();
        userModel.createdAt = DateTime.now();
        userModel.referCode =
            widget.userModel!.uid.substring(0, 8).toUpperCase();
        userModel.isAdmin = false;
        userModel.isTestUser = false;
        await setValue(USER_ID, userModel.id);
        await setValue(USER_DISPLAY_NAME, userModel.name);
        await setValue(USER_EMAIL, userModel.email);
        await setValue(USER_AGE, userModel.age.validate());
        await setValue(USER_POINTS, userModel.points.validate());
        await setValue(USER_PHOTO_URL, userModel.photoUrl.validate());
        await setValue(LOGIN_TYPE, userModel.loginType.validate());
        await setValue(IS_LOGGED_IN, true);
        await userDBService
            .addDocumentWithCustomId(widget.userModel!.uid, userModel.toJson())
            .then((value) async {
          UserModel user = await value.get().then((value) =>
              UserModel.fromJson(value.data() as Map<String, dynamic>));
          log('Signed up');
          await authService
              .setUserDetailPreference(user)
              .whenComplete(() async {
            await setValue(LOGIN_TYPE, LoginTypeOTP);
            HomeScreen().launch(context, isNewTask: true);
          });
        }).catchError((e) {
          throw e;
        }).whenComplete(() => appStore.setLoading(false));
      }
    }
  }

  void onTap() {
    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty)
      signUpWithOtp();
    else
      signUp();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.topLeft,
                  children: [
                    Image.asset(LoginPageImage,
                        height: context.height() * 0.38,
                        width: context.width(),
                        fit: BoxFit.fill),
                    Positioned(
                      top: 74,
                      left: 16,
                      child: Image.asset(LoginPageLogo, width: 80, height: 80),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appStore.translate('lbl_sign_up'),
                              style: boldTextStyle(color: white, size: 30)),
                        ],
                      ),
                    ),
                  ],
                ),
                30.height,
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appStore.translate('lbl_name'),
                          style: primaryTextStyle()),
                      8.height,
                      AppTextField(
                        controller: nameController,
                        textFieldType: TextFieldType.NAME,
                        focus: nameFocus,
                        decoration: inputDecoration(
                            hintText: appStore.translate('lbl_name_hint')),
                      ),
                      16.height,
                      Text(appStore.translate('lbl_email_id'),
                          style: primaryTextStyle()),
                      8.height,
                      AppTextField(
                        controller: emailController,
                        textFieldType: TextFieldType.EMAIL,
                        focus: emailFocus,
                        nextFocus: passFocus,
                        decoration: inputDecoration(
                            hintText: appStore.translate('lbl_email_hint')),
                        validator: ValidationBuilder().email().build(),
                      ),
                      16.height,
                      Text(appStore.translate('lbl_age'),
                          style: primaryTextStyle()),
                      8.height,
                      SizedBox(
                        height: 50,
                        child: DropdownButtonFormField(
                          hint: Text(appStore.translate('lbl_select_age'),
                              style: secondaryTextStyle()),
                          value: dropdownValue,
                          decoration: inputDecoration(),
                          dropdownColor: Theme.of(context).cardColor,
                          items: List.generate(
                            ageRangeList.length,
                            (index) {
                              return DropdownMenuItem(
                                value: ageRangeList[index],
                                child: Text('${ageRangeList[index]}',
                                    style: primaryTextStyle()),
                              );
                            },
                          ),
                          onChanged: (dynamic value) {
                            dropdownValue = value;
                          },
                          validator: (dynamic value) {
                            return value == null
                                ? errorThisFieldRequired
                                : null;
                          },
                        ),
                      ),
                      //Ajout de la classe

                      Text('Classe', style: primaryTextStyle()),
                      8.height,
                      SizedBox(
                        height: 50,
                        child: ClasseService.classeModelList.isNotEmpty
                            ? DropdownButtonFormField(
                                value: selectedModel,
                                decoration: inputDecoration(),
                                dropdownColor: Theme.of(context).cardColor,
                                items: List.generate(
                                  ClasseService.classeModelList.length,
                                  (index) {
                                    return DropdownMenuItem(
                                      value:
                                          ClasseService.classeModelList[index],
                                      child: Text(
                                          '${ClasseService.classeModelList[index].long_name}',
                                          style: primaryTextStyle()),
                                    );
                                  },
                                ),
                                onChanged: (dynamic value) {
                                  selectedModel = value;
                                },
                              )
                            : Row(
                                children: [
                                  Expanded(
                                    child: Container(),
                                  ),
                                  8.width,
                                  IconButton(
                                    onPressed: () async {
                                      await ClasseService.getClasseList();
                                      setState(() {});
                                    },
                                    icon: Icon(
                                      Icons.refresh,
                                      size: 30,
                                      color: colorPrimary,
                                    ),
                                  )
                                ],
                              ),
                      ),
                      30.height,

                      //Fin de l'Ajout de  la classe

                      16.height.visible(widget.isPhone == false),
                      Text(appStore.translate('lbl_password'),
                              style: primaryTextStyle())
                          .visible(widget.isPhone == false),
                      8.height.visible(widget.isPhone == false),
                      AppTextField(
                        controller: passController,
                        validator: ValidationBuilder().minLength(6).build(),
                        focus: passFocus,
                        nextFocus: nameFocus,
                        textFieldType: TextFieldType.PASSWORD,
                        decoration: inputDecoration(
                          hintText: appStore.translate('lbl_password_hint'),
                        ),
                      ).visible(widget.isPhone == false),
                      16.height,
                      Text(appStore.translate('lbl_referenceCode'),
                          style: primaryTextStyle()),
                      8.height,
                      AppTextField(
                        controller: referCodeController,
                        inputFormatters: [LengthLimitingTextInputFormatter(8)],
                        textFieldType: TextFieldType.OTHER,
                        decoration: inputDecoration(
                          hintText:
                              appStore.translate('lbl_enterReferenceCode'),
                        ),
                      ),
                      30.height,
                      gradientButton(
                          text: appStore.translate('lbl_sign_up'),
                          onTap: onTap,
                          isFullWidth: true,
                          context: context),
                      16.height,
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          height: 50,
                          padding: EdgeInsets.only(
                              top: defaultRadius, bottom: defaultRadius),
                          width: context.width(),
                          child: Text(appStore.translate('lbl_sign_in'),
                                  style: boldTextStyle())
                              .center(),
                          decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius:
                                  BorderRadius.circular(defaultRadius)),
                        ),
                      ).visible(widget.isPhone == false)
                    ],
                  ).paddingOnly(left: 16, right: 16),
                ),
                16.height,
              ],
            ),
          ),
          Observer(builder: (context) => Loader().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
