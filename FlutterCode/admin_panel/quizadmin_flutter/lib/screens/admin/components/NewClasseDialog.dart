// ignore_for_file: body_might_complete_normally_catch_error

import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/ClasseModel.dart';
import 'package:quizeapp/services/Settingservice.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';
import '../../../main.dart';

class NewClassDialog extends StatefulWidget {
  static String tag = '/NewClassDialog';
  final ClasseModel? classeModel;

  NewClassDialog({this.classeModel});

  @override
  _NewClassDialogState createState() => _NewClassDialogState();
}

class _NewClassDialogState extends State<NewClassDialog> {
  var formKey = GlobalKey<FormState>();

  TextEditingController nameCont = TextEditingController();
  TextEditingController shortNamCont = TextEditingController();
  TextEditingController imageCont = TextEditingController();
  File? imagesPicket;

  late ClasseType classeType;

  FocusNode imageFocus = FocusNode();

  bool isUpdate = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isUpdate = widget.classeModel != null;
    classeType = widget.classeModel?.classeType ?? ClasseType.academic;

    if (isUpdate) {
      print(widget.classeModel.toString());
      shortNamCont.text = widget.classeModel?.shurt_name ?? '';
      nameCont.text = widget.classeModel!.long_name!;
      imageCont.text = widget.classeModel!.image!;
      setState(() {});
    }
  }

  Future makeSave() async {
    if (formKey.currentState!.validate()) {
      setState(() => isSaving = true);
      if (imagesPicket == null) {
        save();
      } else {
        try {
          final url = await saveFile('Classes/${nameCont.text}', imagesPicket!);
          if (url == null) {
            toast("impossible de charger l'image");
            setState(() => isSaving = false);
            finish(context);
          } else {
            imageCont = TextEditingController(text: url);
            save();
          }
        } catch (e) {
          setState(() => isSaving = false);
          toast(e.toString());
          finish(context);
        }
      }
    }
  }

  Future<void> save() async {
    if (getBoolAsync(IS_TEST_USER)) return toast(mTestUserMsg);
    if (formKey.currentState!.validate()) {
      ClasseModel classeModel = ClasseModel();

      classeModel.long_name = nameCont.text.trim();
      classeModel.image = imageCont.text.trim();
      classeModel.shurt_name = shortNamCont.text.trim();
      classeModel.updatedAt = DateTime.now();
      classeModel.classeType = classeType;

      if (isUpdate) {
        classeModel.id_classe = widget.classeModel!.id_classe;
        classeModel.createdAt = widget.classeModel!.createdAt;
      } else {
        classeModel.createdAt = DateTime.now();
        classeModel.updatedAt = DateTime.now();
      }

      if (isUpdate) {
        await classeService
            .updateDocument(classeModel.toMap(), classeModel.id_classe)
            .then((value) {
          finish(context);
          setState(() => isSaving = false);
        }).catchError((e) {
          setState(() => isSaving = false);
          toast(e.toString());
        });
      } else {
        await classeService.addDocument(classeModel.toMap()).then(
          (value) {
            toast('Add Category Successfully');
            setState(() => isSaving = false);
            finish(context);
          },
        ).catchError(
          (e) {
            setState(() => isSaving = false);
            log(e.toString());
          },
        );
      }
    }
  }

  Future<void> delete(String? id) async {
    if (getBoolAsync(IS_TEST_USER)) return toast(mTestUserMsg);

    await classeService.removeDocument(id).then(
      (value) {
        finish(context);
      },
    ).catchError(
      (e) {
        toast(e.toString());
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: () {
                        finish(context);
                      },
                      icon: Icon(Icons.close))),
              8.height,
              AppTextField(
                controller: nameCont,
                textFieldType: TextFieldType.NAME,
                nextFocus: imageFocus,
                decoration: inputDecoration(
                    labelText: appStore.translate("lbl_classe_name")),
                autoFocus: true,
              ),
              16.height,
              AppTextField(
                controller: shortNamCont,
                textFieldType: TextFieldType.NAME,
                nextFocus: imageFocus,
                decoration: inputDecoration(
                    labelText: appStore.translate("lbl_classe_short")),
                autoFocus: true,
              ),
              16.height,
              AppTextField(
                controller: imageCont,
                textFieldType: TextFieldType.OTHER,
                focus: imageFocus,
                decoration: inputDecoration(
                    labelText: appStore.translate("lbl_image_uRL")),
                keyboardType: TextInputType.url,
                validator: (s) {
                  if (imagesPicket != null) return null;
                  if (s!.isEmpty) return errorThisFieldRequired;
                  if (!s.validateURL()) return 'URL is invalid';
                  return null;
                },
              ),
              16.height,
              Text("Type"),
              Container(
                width: context.width() * 0.25,
                decoration: BoxDecoration(
                    borderRadius: radius(), color: Colors.grey.shade200),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButton<ClasseType>(
                  underline: Offstage(),
                  hint: Text("Type de classe"),
                  items: ClasseType.values.map((e) {
                    return DropdownMenuItem<ClasseType>(
                      child: Text(e.toString().split('.').last),
                      value: e,
                    );
                  }).toList(),
                  isExpanded: true,
                  value: classeType,
                  onChanged: (ClasseType? c) {
                    classeType = c!;
                    setState(() {});
                  },
                ),
              ),
              16.height,
              Row(
                children: [
                  Material(
                    elevation: 1.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: imageData != null
                            ? null
                            : widget.classeModel?.image == null
                                ? null
                                : DecorationImage(
                                    image: NetworkImage(
                                        widget.classeModel?.image ?? ""),
                                    fit: BoxFit.cover,
                                  ),
                      ),
                      child: imageData != null
                          ? Center(
                              child: imageData != null
                                  ? Image.memory(imageData!)
                                  : CircularProgressIndicator(),
                            )
                          : widget.classeModel?.image == null &&
                                  imagesPicket == null
                              ? Center(
                                  child: Icon(Icons.image_rounded),
                                )
                              : null,
                    ),
                  ),
                  15.width,
                  SizedBox(
                    width: 160,
                    child: commonAppButton(
                      context,
                      'Images',
                      onTap: () async {
                        File? imageFile =
                            (await ImagePickerWeb.getMultiImagesAsFile())?[0];
                        if (imageFile != null) {
                          imagesPicket = imageFile;
                          _loadImage();
                          setState(() {});
                        }
                      },
                    ),
                  )
                ],
              ),
              16.height,
              Row(
                children: [
                  commonAppButton(context, appStore.translate("lbl_delete"),
                          onTap: () {
                    showConfirmDialogCustom(
                      context,
                      title: appStore.translate('lbl_delete_category_dialog'),
                      subTitle:
                          appStore.translate('lbl_delete_subcategory_message'),
                      primaryColor: colorPrimary,
                      onAccept: (p0) async {
                        // final id = widget.classeModel!.id_classe;
                        // await delete(id);
                        // finish(context);
                      },
                    ).catchError(
                      (e) {
                        log(e.toString());
                      },
                    );
                  }, isFull: false)
                      .visible(isUpdate),
                  16.width,
                  commonAppButton(
                    context,
                    appStore.translate("lbl_save"),
                    onTap: () {
                      if (!isSaving)
                        makeSave();
                      else
                        toast('Running process');
                    },
                    isFull: false,
                    child: isSaving
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(color: white),
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  var imageData;
  void _loadImage() {
    final reader = FileReader();
    reader.onLoadEnd.listen((event) {
      setState(() {
        imageData = reader.result as Uint8List?;
      });
    });
    reader.readAsArrayBuffer(imagesPicket!);
  }
}
