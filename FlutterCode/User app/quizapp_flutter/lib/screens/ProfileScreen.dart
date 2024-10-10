import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizapp_flutter/models/ClasseModel.dart';
import 'package:quizapp_flutter/services/ClasseService.dart';
import '/../main.dart';
import '/../services/FileStorageService.dart';
import '/../utils/ModelKeys.dart';
import '/../utils/colors.dart';
import '/../utils/constants.dart';
import '/../utils/widgets.dart';
import 'package:collection/collection.dart';

import '../components/AppBarComponent.dart';
import '../utils/images.dart';

class ProfileScreen extends StatefulWidget {
  static String tag = '/ProfileScreen';

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController nameController =
      TextEditingController(text: appStore.userName);
  TextEditingController emailController =
      TextEditingController(text: appStore.userEmail);
  XFile? image;

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

  String? dropdownValue = appStore.userAge;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    if (ClasseService.classeModelList.isEmpty) {
      await ClasseService.getClasseList().then((value) => editClasse());
    } else {
      editClasse();
    }
  }

  Widget profileImage() {
    if (image != null) {
      return Image.file(File(image!.path),
          height: 130,
          width: 130,
          fit: BoxFit.cover,
          alignment: Alignment.center);
    } else {
      if (getStringAsync(LOGIN_TYPE) == LoginTypeGoogle ||
          getStringAsync(LOGIN_TYPE) == LoginTypeEmail) {
        if (appStore.userProfileImage == '') {
          return CircleAvatar(radius: 50, child: Image.asset(UserPic))
              .paddingAll(16);
        }
        return cachedImage(appStore.userProfileImage.validate(),
            height: 130,
            width: 130,
            fit: BoxFit.cover,
            alignment: Alignment.center);
      } else {
        return CircleAvatar(radius: 26, child: Image.asset(UserPic))
            .paddingAll(16);
      }
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future update() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);

      appStore.setLoading(true);
      setState(() {});

      Map<String, dynamic> req = {};

      if (nameController.text != appStore.userName) {
        req.putIfAbsent(UserKeys.name, () => nameController.text.trim());
      }
      if (dropdownValue != getStringAsync(USER_AGE)) {
        req.putIfAbsent(UserKeys.age, () => dropdownValue);
        setValue(USER_AGE, dropdownValue);
      }
      if (selectedModel != null) {
        req.putIfAbsent(UserKeys.classe, () => selectedModel?.id_classe);
        setValue(USER_AGE, selectedModel?.id_classe);
      }
      if (image != null) {
        await uploadFile(file: File(image!.path), prefix: 'userProfiles').then(
          (path) async {
            req.putIfAbsent(UserKeys.photoUrl, () => path);
            await setValue(USER_PHOTO_URL, path);
            appStore.setProfileImage(path);
          },
        ).catchError(
          (e) {
            toast(e.toString());
          },
        );
      }

      await userDBService.updateDocument(req, appStore.userId).then(
        (value) async {
          appStore.setLoading(false);
          appStore.setName(nameController.text);
          setValue(USER_DISPLAY_NAME, nameController.text);
          appStore.setUserAge(dropdownValue);
          setValue(USER_AGE, dropdownValue);
          setValue(USER_CLASSE, selectedModel?.toJson());
          appStore.setUserClasse(selectedModel?.toJson());
          finish(context);
        },
      );
    }
  }

  Future getImage() async {
    if (!isLoggedInWithGoogle()) {
      // ignore: deprecated_member_use
      image = await ImagePicker()
          .pickImage(source: ImageSource.gallery, imageQuality: 100);
      setState(() {});
    }
  }

  editClasse() {
    final classe = appStore.userClasse != null
        ? ClasseModel.fromMap(jsonDecode(appStore.userClasse!))
        : null;
    if (classe!.id_classe != null) {
      selectedModel = ClasseService.classeModelList
          .firstWhereOrNull((element) => element.id_classe == classe.id_classe);
      setState(() {});
    } else {
      selectedModel = ClasseService.classeModelList.firstOrNull;
      setState(() {});
    }
  }

  ClasseModel? selectedModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(
          context: context, title: appStore.translate('lbl_profile')),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: <Widget>[
                      Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 2,
                        margin: EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(80)),
                        child: profileImage(),
                      ),
                      Positioned(
                        child: CircleAvatar(
                          backgroundColor: colorPrimary,
                          radius: 15,
                          child:
                              Icon(Icons.edit_outlined, color: white, size: 20)
                                  .onTap(
                            () {
                              getImage();
                            },
                          ),
                        ),
                        right: 8,
                        bottom: 8,
                      ).visible(!isLoggedInWithGoogle()),
                    ],
                  ).paddingOnly(top: 16, bottom: 16).center(),
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
                  Text(appStore.translate('lbl_email_id'),
                      style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: emailController,
                    textFieldType: TextFieldType.EMAIL,
                    focus: nameFocus,
                    readOnly: true,
                    onTap: () {
                      toast("you can't change email address");
                    },
                    decoration: inputDecoration(
                        hintText: appStore.translate('lbl_email_hint')),
                  ),
                  16.height,
                  Text(appStore.translate('lbl_name'),
                      style: primaryTextStyle()),
                  8.height,
                  AppTextField(
                    controller: nameController,
                    textFieldType: TextFieldType.NAME,
                    readOnly: (appStore.userName != null &&
                            appStore.userName?.isNotEmpty == true)
                        ? true
                        : false,
                    decoration: inputDecoration(
                        hintText: appStore.translate('lbl_name_hint')),
                  ),
                  16.height,
                  Text(appStore.translate('lbl_age'),
                      style: primaryTextStyle()),
                  8.height,
                  DropdownButtonFormField(
                    value: dropdownValue,
                    decoration: inputDecoration(),
                    dropdownColor: Theme.of(context).cardColor,
                    items: List.generate(
                      ageRangeList.length,
                      (index) {
                        return DropdownMenuItem(
                            value: ageRangeList[index],
                            child: Text('${ageRangeList[index]}',
                                style: primaryTextStyle()));
                      },
                    ),
                    onChanged: (dynamic value) {
                      dropdownValue = value;
                    },
                    validator: (dynamic value) {
                      return value == null ? errorThisFieldRequired : null;
                    },
                  ),
                  //Ajout de la classe
                  16.height,
                  Text('Classe', style: primaryTextStyle()),
                  8.height,
                  ClasseService.classeModelList.isNotEmpty
                      ? DropdownButtonFormField(
                          value: selectedModel,
                          decoration: inputDecoration(),
                          dropdownColor: Theme.of(context).cardColor,
                          items: List.generate(
                            ClasseService.classeModelList.length,
                            (index) {
                              return DropdownMenuItem(
                                value: ClasseService.classeModelList[index],
                                child: Text(
                                    '${ClasseService.classeModelList[index].long_name}',
                                    style: primaryTextStyle()),
                              );
                            },
                          ),
                          onChanged: (dynamic value) {
                            selectedModel = value;
                          },
                          // decoration: inputDecoration(),
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

                  ///Fin de l'Ajout de  la classe
                  30.height,
                  Container(
                    width: context.width(),
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorPrimary,
                          colorSecondary,
                        ],
                        begin: FractionalOffset.centerLeft,
                        end: FractionalOffset.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(defaultRadius),
                    ),
                    child: TextButton(
                      child: Text(appStore.translate('lbl_update_profile'),
                          style: primaryTextStyle(color: white)),
                      onPressed: update,
                    ),
                  ).visible(true /*!isLoggedInWithGoogle()*/),
                  22.height
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
