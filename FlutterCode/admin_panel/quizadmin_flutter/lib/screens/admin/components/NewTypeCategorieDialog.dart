// ignore_for_file: body_might_complete_normally_catch_error

import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/CategorieTypeModel.dart';
import 'package:quizeapp/services/Settingservice.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';
import '../../../main.dart';

class NewTypeCategorieDialog extends StatefulWidget {
  static String tag = '/NewTypeCategorieDialog';
  final TypeCategorie? typeCategorie;

  NewTypeCategorieDialog({this.typeCategorie});

  @override
  _NewTypeCategorieDialogState createState() => _NewTypeCategorieDialogState();
}

class _NewTypeCategorieDialogState extends State<NewTypeCategorieDialog> {
  var formKey = GlobalKey<FormState>();

  TextEditingController nameCont = TextEditingController();
  TextEditingController imageCont = TextEditingController();
  File? imagesPicket;

  // late ClasseType classeType;

  FocusNode imageFocus = FocusNode();

  bool isUpdate = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isUpdate = widget.typeCategorie != null;

    if (isUpdate) {
      print(widget.typeCategorie.toString());
      nameCont.text = widget.typeCategorie!.nameTypeCategorie!;
      imageCont.text = widget.typeCategorie!.images ?? '';
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
          final url = await saveFile(
              'CategorieType/${nameCont.text.replaceAll(" ", "_")}',
              imagesPicket!);
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
      TypeCategorie typeCategorie = TypeCategorie();

      typeCategorie.nameTypeCategorie = nameCont.text.trim();
      typeCategorie.images = imageCont.text.trim();
      typeCategorie.updatedAt = DateTime.now();

      if (isUpdate) {
        typeCategorie.id = widget.typeCategorie!.id;
        typeCategorie.createdAt = widget.typeCategorie!.createdAt;
      } else {
        typeCategorie.createdAt = DateTime.now();
        typeCategorie.updatedAt = DateTime.now();
      }

      if (isUpdate) {
        await typeCategorieServices
            .updateDocument(typeCategorie.toMap(), typeCategorie.id)
            .then((value) {
          finish(context);
          setState(() => isSaving = false);
        }).catchError((e) {
          setState(() => isSaving = false);
          toast(e.toString());
        });
      } else {
        await typeCategorieServices.addDocument(typeCategorie.toMap()).then(
          (value) {
            toast('Add Type of  Category Successfully');
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

    await categoryService.removeDocument(id).then(
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
                decoration: inputDecoration(labelText: "Nom du type"),
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
                            : widget.typeCategorie?.images == null
                                ? null
                                : DecorationImage(
                                    image: NetworkImage(
                                        widget.typeCategorie?.images ?? ""),
                                    fit: BoxFit.cover,
                                  ),
                      ),
                      child: imageData != null
                          ? Center(
                              child: imageData != null
                                  ? Image.memory(imageData!)
                                  : CircularProgressIndicator(),
                            )
                          : widget.typeCategorie?.images == null &&
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
                      onAccept: (p0) {
                        // categoryService
                        //     .categoriesFuture(
                        //         parentCategoryId: widget.typeCategorie!.id!)
                        //     .then((value) {
                        //   value.forEach((element) {
                        //     delete(element.id);
                        //   });
                        // });
                        // delete(widget.typeCategorie!.id);
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
