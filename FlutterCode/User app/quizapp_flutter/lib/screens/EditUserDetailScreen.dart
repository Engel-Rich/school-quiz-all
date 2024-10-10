import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizapp_flutter/models/ClasseModel.dart';
import 'package:quizapp_flutter/services/ClasseService.dart';
import 'package:quizapp_flutter/utils/colors.dart';
import '/../main.dart';
import '/../utils/ModelKeys.dart';
import '/../utils/constants.dart';
import '/../utils/images.dart';
import '/../utils/strings.dart';
import '/../utils/widgets.dart';
import 'HomeScreen.dart';
import 'package:collection/collection.dart';

class EditUserDetailScreen extends StatefulWidget {
  static String tag = '/EditUserDetailScreen';

  final bool isFromGoogle;

  EditUserDetailScreen({this.isFromGoogle = false});

  @override
  EditUserDetailScreenState createState() => EditUserDetailScreenState();
}

class EditUserDetailScreenState extends State<EditUserDetailScreen> {
  GlobalKey<FormState> formKey = GlobalKey();

  List<String> ageRangeList = [
    '5 - 10',
    '10 - 15',
    '15 - 20',
    '20 - 25',
    '25 - 30',
    '30 - 35',
    '35 - 40',
    '40 - 45',
    '45 - 50',
  ];

  TextEditingController nameController = TextEditingController();

  String? dropdownValue;
  ClasseModel? selectedModel;

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
      editClasse();
    } else {
      editClasse();
    }
    dropdownValue = ageRangeList.first;
  }

  editClasse() {
    final classe = appStore.userClasse != null
        ? ClasseModel.fromMap(jsonDecode(appStore.userClasse!))
        : null;
    if (classe?.id_classe != null) {
      selectedModel = ClasseService.classeModelList.firstWhereOrNull(
          (element) => element.id_classe == classe?.id_classe);
      setState(() {});
    } else {
      selectedModel = ClasseService.classeModelList.firstOrNull;
      setState(() {});
    }
  }

  Future<void> editData() async {
    if (formKey.currentState!.validate()) {
      appStore.setLoading(true);
      userDBService.updateDocument({
        UserKeys.age: dropdownValue.validate(),
        if (selectedModel?.id_classe != null)
          UserKeys.classe: selectedModel?.id_classe,
        if (nameController.text.isNotEmpty) UserKeys.name: nameController.text
      }, appStore.userId).then(
        (value) {
          appStore.setLoading(false);
          setValue(USER_AGE, dropdownValue.validate());
          setValue(USER_CLASSE, selectedModel?.toJson());
          appStore.setUserAge(dropdownValue.validate());
          appStore.setUserClasse(selectedModel?.toJson());
          if (nameController.text.isNotEmpty) {
            setValue(USER_DISPLAY_NAME, nameController.text);
            appStore.setName(nameController.text);
          }
          // HomeScreen().launch(context);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false);
        },
      ).catchError(
        (e) {
          appStore.setLoading(false);
          toast(e.toString());
        },
      );
    }
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
                  children: [
                    Image.asset(LoginPageImage,
                        height: context.height() * 0.35,
                        width: context.width(),
                        fit: BoxFit.fill),
                    Positioned(
                      top: 30,
                      left: 16,
                      child: Image.asset(
                        LoginPageLogo,
                        width: 80,
                        height: 80,
                      ),
                    ),
                    Positioned(
                      bottom: 50,
                      left: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lbl_enter_details,
                              style: boldTextStyle(color: white, size: 30)),
                          8.height,
                          Icon(Icons.arrow_back, color: white).onTap(
                            () {
                              finish(context);
                            },
                          ),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      (widget.isFromGoogle &&
                              appStore.userName?.trim().isNotEmpty == true)
                          ? SizedBox()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lbl_name, style: primaryTextStyle()),
                                8.height,
                                AppTextField(
                                  controller: nameController,
                                  textFieldType: TextFieldType.NAME,
                                  decoration: inputDecoration(
                                    hintText:
                                        appStore.translate('lbl_name_hint'),
                                  ),
                                ),
                                16.height,
                              ],
                            ),
                      Text(appStore.translate('lbl_age'),
                          style: primaryTextStyle()),
                      8.height,
                      DropdownButtonFormField(
                        value: dropdownValue,
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
                        decoration: inputDecoration(),
                      ),
                      30.height,

                      //Ajout de la classe

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
                              onChanged: (ClasseModel? value) {
                                selectedModel = value;
                                setState(() {});
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
                      30.height,

                      ///Fin de l'Ajout de  la classe
                    ],
                  ).paddingOnly(left: 16, right: 16),
                ).paddingSymmetric(horizontal: 10),
                16.height,
                gradientButton(
                        text: lbl_save,
                        onTap: editData,
                        context: context,
                        isFullWidth: true)
                    .paddingSymmetric(horizontal: 10),
              ],
            ),
          ),
          Observer(builder: (context) => Loader().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}
