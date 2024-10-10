// ignore_for_file: body_might_complete_normally_catch_error

import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/CategorieTypeModel.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/services/Settingservice.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';
import 'package:collection/collection.dart';
import '../../../main.dart';

class NewCategoryDialog extends StatefulWidget {
  static String tag = '/NewCategoryDialog';
  final CategoryData? categoryData;

  NewCategoryDialog({this.categoryData});

  @override
  _NewCategoryDialogState createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<NewCategoryDialog> {
  var formKey = GlobalKey<FormState>();

  TextEditingController nameCont = TextEditingController();
  TextEditingController imageCont = TextEditingController();
  File? imagesPicket;

  FocusNode imageFocus = FocusNode();

  bool isUpdate = false;

  TypeCategorie? typeCategorie;
  List<TypeCategorie> typeCategorieListe = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  getTypeCategorie() async {
    await typeCategorieServices.getTypeCategorieList().then((value) {
      typeCategorieListe
          .add(TypeCategorie(nameTypeCategorie: "Aucune", id: null));
      typeCategorieListe.addAll(value);
    });
    if (isUpdate) {
      typeCategorie = typeCategorieListe.firstWhereOrNull(
          (element) => element.id == widget.categoryData?.type);
    } else {
      // typeCategorie = typeCategorieListe.firstOrNull;
    }

    setState(() {});
  }

  Future<void> init() async {
    isUpdate = widget.categoryData != null;

    if (isUpdate) {
      nameCont.text = widget.categoryData!.name!;
      imageCont.text = widget.categoryData!.image!;
    }
    await getTypeCategorie();
  }

  Future makeSave() async {
    if (nameCont.text.trim().length >= 3) {
      if (imagesPicket == null) {
        save();
      } else {
        try {
          final url =
              await saveFile('Catégorie/${nameCont.text}', imagesPicket!);
          if (url == null) {
            toast("impossible de charger l'image");
            finish(context);
          } else {
            imageCont = TextEditingController(text: url);
            save();
          }
        } catch (e) {
          toast(e.toString());
          finish(context);
        }
      }
    }
  }

  Future<void> save() async {
    if (getBoolAsync(IS_TEST_USER)) return toast(mTestUserMsg);
    if (formKey.currentState!.validate()) {
      CategoryData categoryData = CategoryData();

      categoryData.name = nameCont.text.trim();
      categoryData.image = imageCont.text.trim();
      categoryData.updatedAt = DateTime.now();
      if (typeCategorie?.id != null) categoryData.type = typeCategorie?.id;
      categoryData.parentCategoryId = '';
      if (appStore.classeModel != null &&
          appStore.classeModel?.trim().isNotEmpty == true) {
        categoryData.classe = appStore.classeModel;
      }
      if (isUpdate) {
        categoryData.id = widget.categoryData!.id;
        categoryData.createdAt = widget.categoryData!.createdAt;
      } else {
        categoryData.createdAt = DateTime.now();
      }

      if (isUpdate) {
        await categoryService
            .updateDocument(categoryData.toJson(), categoryData.id)
            .then((value) {
          finish(context);
        }).catchError((e) {
          toast(e.toString());
        });
      } else {
        await categoryService.addDocument(categoryData.toJson()).then(
          (value) {
            toast('Add Category Successfully');
            finish(context);
          },
        ).catchError(
          (e) {
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
                decoration: inputDecoration(
                    labelText: appStore.translate("lbl_category_name")),
                autoFocus: true,
              ),
              if (typeCategorieListe.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    16.height,
                    Text("Type"),
                    Container(
                      width: context.width() * 0.25,
                      decoration: BoxDecoration(
                          borderRadius: radius(), color: Colors.grey.shade200),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: DropdownButton<TypeCategorie>(
                        underline: Offstage(),
                        hint: Text("Type de classe"),
                        items: typeCategorieListe.map((e) {
                          return DropdownMenuItem<TypeCategorie>(
                            child: Text(e.nameTypeCategorie ?? ""),
                            value: e,
                          );
                        }).toList(),
                        isExpanded: true,
                        value: typeCategorie,
                        onChanged: (TypeCategorie? c) {
                          typeCategorie = c!;
                          setState(() {});
                        },
                      ),
                    ),
                    16.height,
                  ],
                ),
              AppTextField(
                controller: imageCont,
                textFieldType: TextFieldType.OTHER,
                focus: imageFocus,
                decoration: inputDecoration(
                    labelText: appStore.translate("lbl_image_uRL")),
                keyboardType: TextInputType.url,
                validator: (s) {
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
                            : widget.categoryData?.image == null
                                ? null
                                : DecorationImage(
                                    image: NetworkImage(
                                        widget.categoryData?.image ?? ""),
                                    fit: BoxFit.cover,
                                  ),
                      ),
                      child: imageData != null
                          ? Center(
                              child: imageData != null
                                  ? Image.memory(imageData!)
                                  : CircularProgressIndicator(),
                            )
                          : widget.categoryData?.image == null &&
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
                        categoryService
                            .categoriesFuture(
                                parentCategoryId: widget.categoryData!.id!)
                            .then((value) {
                          value.forEach((element) {
                            delete(element.id);
                          });
                        });
                        delete(widget.categoryData!.id);
                      },
                    ).catchError(
                      (e) {
                        log(e.toString());
                      },
                    );
                  }, isFull: false)
                      .visible(isUpdate),
                  16.width,
                  commonAppButton(context, appStore.translate("lbl_save"),
                      onTap: () {
                    makeSave();
                  }, isFull: false),
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
