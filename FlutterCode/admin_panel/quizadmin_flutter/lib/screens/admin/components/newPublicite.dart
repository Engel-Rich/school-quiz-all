// ignore_for_file: body_might_complete_normally_catch_error

import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:quizeapp/models/CategorieTypeModel.dart';
// import 'package:quizeapp/models/publiciteData.dart';
import 'package:quizeapp/models/Publicite.dart';
import 'package:quizeapp/services/Settingservice.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import 'package:quizeapp/utils/Constants.dart';
import '../../../main.dart';

class NewPubliciteDialog extends StatefulWidget {
  static String tag = '/NewPubliciteDialog';
  final Publicite? publiciteData;

  NewPubliciteDialog({this.publiciteData});

  @override
  _NewPubliciteDialogState createState() => _NewPubliciteDialogState();
}

class _NewPubliciteDialogState extends State<NewPubliciteDialog> {
  var formKey = GlobalKey<FormState>();

  TextEditingController nameCont = TextEditingController();
  TextEditingController imageCont = TextEditingController();
  TextEditingController videoCont = TextEditingController();
  TextEditingController siteCont = TextEditingController();
  TextEditingController playCont = TextEditingController();
  TextEditingController appstoreCont = TextEditingController();
  File? imagesPicket;
  File? videoPicket;

  // = FocusNode();

  bool isUpdate = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isUpdate = widget.publiciteData != null;

    if (isUpdate) {
      nameCont.text = widget.publiciteData!.libelle ?? "";
      imageCont.text = widget.publiciteData!.imageUrl ?? "";
      playCont.text = widget.publiciteData!.playUrl ?? "";
      appstoreCont.text = widget.publiciteData!.iosUrl ?? "";
      siteCont.text = widget.publiciteData!.sitUrl ?? "";
      videoCont.text = widget.publiciteData!.videoUrl ?? "";
      status = widget.publiciteData?.isactive == true
          ? statusChoice.first
          : statusChoice.last;
    }
  }

  Future makeSave() async {
    isLoading = true;
    setState(() {});
    if (nameCont.text.trim().length >= 3) {
      if (imagesPicket == null && videoPicket == null) {
        save();
      } else {
        try {
          if (imagesPicket != null) {
            final url =
                await saveFile('Publicite/${nameCont.text}', imagesPicket!);
            imageCont = TextEditingController(text: url);

            if (url != null) {
              videoCont = TextEditingController(text: url);
            } else {
              isLoading = false;
              setState(() {});
              toast("impossible de charger la video");
              finish(context);
            }
          }
          if (videoPicket != null) {
            final videoUrl =
                await saveFile('Publicite/${nameCont.text}', videoPicket!);

            if (videoUrl != null) {
              videoCont = TextEditingController(text: videoUrl);
            } else {
              isLoading = false;
              setState(() {});
              toast("impossible de charger la video");
              finish(context);
            }
          }
          save();
        } catch (e) {
          isLoading = false;
          setState(() {});
          toast(e.toString());
          finish(context);
        }
      }
    }
  }

  bool isLoading = false;
  Future<void> save() async {
    if (getBoolAsync(IS_TEST_USER)) return toast(mTestUserMsg);
    if (formKey.currentState!.validate()) {
      isLoading = true;
      setState(() {});
      Publicite publicite = Publicite(userSeeingList: [], userTapedList: []);

      publicite.libelle = nameCont.text.trim();
      publicite.imageUrl = imageCont.text.trim();
      publicite.videoUrl = videoCont.text.trim();
      publicite.iosUrl = appstoreCont.text.trim();
      publicite.playUrl = playCont.text.trim();
      publicite.sitUrl = siteCont.text.trim();
      publicite.updatedAt = DateTime.now();
      publicite.isactive = status == statusChoice.first;

      if (isUpdate) {
        publicite.id = widget.publiciteData!.id;
        publicite.createdAt = widget.publiciteData!.createdAt;
        publicite.userSeeingList = widget.publiciteData!.userSeeingList;
        publicite.userTapedList = widget.publiciteData!.userTapedList;
      } else {
        publicite.createdAt = DateTime.now();
      }

      if (isUpdate) {
        await publiciteServices
            .updateDocument(publicite.toMap(), publicite.id)
            .then((value) {
          isLoading = false;
          setState(() {});
          finish(context);
        }).catchError((e) {
          isLoading = false;
          setState(() {});
          toast(e.toString());
        });
      } else {
        await publiciteServices.addDocument(publicite.toMap()).then(
          (value) {
            isLoading = false;
            setState(() {});
            toast('Add Category Successfully');
            finish(context);
          },
        ).catchError(
          (e) {
            isLoading = false;
            setState(() {});
            log(e.toString());
          },
        );
      }
    } else {
      isLoading = false;
      setState(() {});
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

  final statusChoice = ['activé', 'désactivé'];
  String status = 'désactiver';

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
                decoration: inputDecoration(
                    labelText: appStore.translate("lbl_category_name")),
                autoFocus: true,
                validator: (s) {
                  if (s != null && s.length < 4) return 'Name is invalid';
                  return null;
                },
              ),
              16.height,
              AppTextField(
                controller: imageCont,
                textFieldType: TextFieldType.OTHER,
                decoration: inputDecoration(
                    labelText: appStore.translate("lbl_image_uRL")),
                keyboardType: TextInputType.url,
                validator: (s) {
                  if (s?.trim().isNotEmpty == true && !s.validateURL())
                    return 'URL is invalid';
                  return null;
                },
              ),
              16.height,
              AppTextField(
                controller: videoCont,
                textFieldType: TextFieldType.OTHER,
                decoration: inputDecoration(labelText: "Url de la video"),
                keyboardType: TextInputType.url,
                validator: (s) {
                  if (s?.trim().isNotEmpty == true && !s.validateURL())
                    return 'URL is invalid';
                  return null;
                },
              ),
              16.height,
              AppTextField(
                controller: siteCont,
                textFieldType: TextFieldType.OTHER,
                decoration:
                    inputDecoration(labelText: "Url du site publicitaire"),
                keyboardType: TextInputType.url,
                validator: (s) {
                  if (s?.trim().isNotEmpty == true && !s.validateURL())
                    return 'URL is invalid';
                  return null;
                },
              ),
              16.height,
              AppTextField(
                controller: playCont,
                textFieldType: TextFieldType.OTHER,
                decoration: inputDecoration(labelText: "Url Play store"),
                keyboardType: TextInputType.url,
                validator: (s) {
                  if (s?.trim().isNotEmpty == true && !s.validateURL())
                    return 'URL is invalid';
                  return null;
                },
              ),
              16.height,
              AppTextField(
                controller: appstoreCont,
                textFieldType: TextFieldType.OTHER,
                decoration: inputDecoration(labelText: "Url Apple Store"),
                keyboardType: TextInputType.url,
                validator: (s) {
                  if (s?.trim().isNotEmpty == true && !s.validateURL())
                    return 'URL is invalid';
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
                child: DropdownButton<String>(
                  underline: Offstage(),
                  hint: Text("Type de classe"),
                  items: statusChoice.map((e) {
                    return DropdownMenuItem<String>(
                      child: Text(e),
                      value: e,
                    );
                  }).toList(),
                  isExpanded: true,
                  value: status,
                  onChanged: (c) {
                    status = c!;
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
                            : widget.publiciteData?.imageUrl == null
                                ? null
                                : DecorationImage(
                                    image: NetworkImage(
                                        widget.publiciteData?.imageUrl ?? ""),
                                    fit: BoxFit.cover,
                                  ),
                      ),
                      child: imageData != null
                          ? Center(
                              child: imageData != null
                                  ? Image.memory(imageData!)
                                  : CircularProgressIndicator(),
                            )
                          : widget.publiciteData?.imageUrl == null &&
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
                        delete(widget.publiciteData!.id);
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
  var videoData;

  void _loadImage() {
    final reader = FileReader();
    reader.onLoadEnd.listen((event) {
      setState(() {
        imageData = reader.result as Uint8List?;
      });
    });
    reader.readAsArrayBuffer(imagesPicket!);
  }

  void _loadVideo() {
    final reader = FileReader();
    reader.onLoadEnd.listen((event) {
      setState(() {
        videoData = reader.result as Uint8List?;
      });
    });
    reader.readAsArrayBuffer(videoPicket!);
  }
}
