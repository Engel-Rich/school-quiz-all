// ignore_for_file: body_might_complete_normally_catch_error

import 'dart:html';

import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/CategorieTypeModel.dart';
import 'package:quizeapp/models/CategoryData.dart';
import 'package:quizeapp/services/Settingservice.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';
import 'package:collection/collection.dart';

class NewSubCategoryDialog extends StatefulWidget {
  static String tag = '/NewCategoryDialog';
  final CategoryData? subCategoryData;
  final String? categoryId;

  NewSubCategoryDialog({this.subCategoryData, this.categoryId});

  @override
  _NewCategoryDialogState createState() => _NewCategoryDialogState();
}

class _NewCategoryDialogState extends State<NewSubCategoryDialog> {
  AsyncMemoizer<List<CategoryData>> categoryMemoizer =
      AsyncMemoizer<List<CategoryData>>();

  var formKey = GlobalKey<FormState>();

  TextEditingController nameCont = TextEditingController();
  TextEditingController imageCont = TextEditingController();

  FocusNode imageFocus = FocusNode();

  bool isUpdate = false;

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
          (element) => element.id == widget.subCategoryData?.type);
    } else {
      // typeCategorie = typeCategorieListe.firstOrNull;
    }
    setState(() {});
  }

  Future<void> init() async {
    isUpdate = widget.subCategoryData != null;

    if (isUpdate) {
      nameCont.text = widget.subCategoryData!.name.validate();
      imageCont.text = widget.subCategoryData!.image.validate();
    }
    await getTypeCategorie();
  }

  Future<void> save() async {
    if (getBoolAsync(IS_TEST_USER)) return toast(mTestUserMsg);

    if (formKey.currentState!.validate()) {
      CategoryData categoryData = CategoryData();

      categoryData.parentCategoryId = widget.categoryId;
      categoryData.name = nameCont.text.trim();
      categoryData.image = imageCont.text.trim();
      categoryData.updatedAt = DateTime.now();
      if (typeCategorie?.id != null) categoryData.type = typeCategorie?.id;

      ///Add New Code
      ///
      if (isUpdate) {
        categoryData.createdAt = widget.subCategoryData!.createdAt;
      } else {
        categoryData.createdAt = DateTime.now();
      }

      if (isUpdate) {
        categoryData.id = widget.subCategoryData!.id;
        categoryData.createdAt = widget.subCategoryData!.createdAt;
        await categoryService
            .updateDocument(categoryData.toJson(), categoryData.id)
            .then(
          (value) {
            finish(context);
          },
        ).catchError(
          (e) {
            toast(e.toString());
          },
        );
      } else {
        await categoryService.addDocument(categoryData.toJson()).then(
          (value) {
            finish(context);
          },
        ).catchError(
          (e) {
            toast(e.toString());
          },
        );
      }
    }
  }

  TypeCategorie? typeCategorie;
  List<TypeCategorie> typeCategorieListe = [];
  Future<void> delete() async {
    if (getBoolAsync(IS_TEST_USER)) return toast(mTestUserMsg);

    await categoryService.removeDocument(widget.subCategoryData!.id).then(
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
              /*      FutureBuilder<List<CategoryData>>(
                future: categoryMemoizer.runOnce(() => categoryService.categoriesFuture()),
                builder: (_, snap) {
                  if (snap.hasData) {
                    if (snap.data!.isEmpty) return SizedBox();

                    if (selectCategoryId == null) {
                      if (isUpdate) {
                        selectCategoryId = snap.data!.firstWhere((element) => element.id == widget.subCategoryData!.parentCategoryId);
                      } else {
                        //  selectCategoryId = snap.data.first;
                      }
                    }

                    return Container(
                      decoration: BoxDecoration(borderRadius: radius(), color: Colors.grey.shade200),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: DropdownButton(
                        hint: Text('Select Category'),
                        underline: Offstage(),
                        items: snap.data!.map((e) {
                          return DropdownMenuItem(
                            child: Text(e.name.validate()),
                            value: e,
                          );
                        }).toList(),
                        isExpanded: true,
                        value: selectCategoryId,
                        onChanged: (c) {
                          selectCategoryId = c as CategoryData?;

                          setState(() {});
                        },
                      ),
                    );
                  } else {
                    return snapWidgetHelper(snap);
                  }
                },
              ),
              16.height,*/
              AppTextField(
                controller: nameCont,
                textFieldType: TextFieldType.NAME,
                nextFocus: imageFocus,
                decoration: inputDecoration(
                    labelText: appStore.translate("lbl_sub_category_name")),
                autoFocus: true,
              ),
              16.height,
              AppTextField(
                controller: imageCont,
                textFieldType: TextFieldType.URL,
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
                            : widget.subCategoryData?.image == null
                                ? null
                                : DecorationImage(
                                    image: NetworkImage(
                                        widget.subCategoryData?.image ?? ""),
                                    fit: BoxFit.cover,
                                  ),
                      ),
                      child: imageData != null
                          ? Center(
                              child: imageData != null
                                  ? Image.memory(imageData!)
                                  : CircularProgressIndicator(),
                            )
                          : widget.subCategoryData?.image == null &&
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
              AppButton(
                text: appStore.translate("lbl_delete"),
                padding: EdgeInsets.all(20),
                onTap: () {
                  showConfirmDialogCustom(
                    context,
                    primaryColor: colorPrimary,
                    title: appStore.translate("lbl_delete_subcategory_dialog"),
                    onAccept: (p0) {
                      delete();
                    },
                  ).catchError(
                    (e) {
                      toast(e.toString());
                    },
                  );
                },
              ).visible(isUpdate),
              16.height,
              AppButton(
                text: appStore.translate("lbl_save"),
                width: context.width(),
                padding: EdgeInsets.all(20),
                onTap: () {
                  makeSave();
                },
              ),
            ],
          ),
        ),
      ),
    );
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

  File? imagesPicket;
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
