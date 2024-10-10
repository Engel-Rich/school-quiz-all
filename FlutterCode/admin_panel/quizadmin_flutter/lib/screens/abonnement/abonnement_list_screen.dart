import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:paginate_firestore/widgets/empty_display.dart';
import 'package:quizeapp/main.dart';
import 'package:quizeapp/models/abonnement_model.dart';
import 'package:quizeapp/services/Settingservice.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';

class AbonnementListScreen extends StatefulWidget {
  const AbonnementListScreen({super.key});

  @override
  State<AbonnementListScreen> createState() => _AbonnementListScreenState();
}

class _AbonnementListScreenState extends State<AbonnementListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Abonnement List',
          style: primaryTextStyle(size: 20),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Abonnement List',
                    style: primaryTextStyle(size: 20),
                  ),
                  Container(
                    width: 200,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: commonAppButton(
                          context, appStore.translate("lbl_create_now"),
                          onTap: () {
                        showInDialog(context,
                            builder: (BuildContext context) => NewAbonnement());
                      }, isFull: false),
                    ).paddingAll(16),
                  )
                ],
              ),
              16.height,
              StreamBuilder<List<AbonnementModel>>(
                stream: abonnementServices.getAbonnement(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator().center();
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Something went wrong ${snapshot.error}'));
                  }
                  if (snapshot.hasData && snapshot.data!.length == 0 ||
                      snapshot.data == null) {
                    return Center(child: EmptyDisplay());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final data = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: colorPrimary),
                          ),
                          leading: Container(
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(data.imageUrl ?? ''),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          trailing: GestureDetector(
                            onTap: () {
                              showInDialog(
                                context,
                                builder: (BuildContext context) =>
                                    NewAbonnement(
                                  abonnementModel: data,
                                ),
                              );
                            },
                            child: Icon(
                              Icons.edit,
                              color: colorPrimary,
                            ),
                          ),
                          title: Text(
                            "${data.name}. ${data.numbreJours} Jours . ${data.price} FCFA",
                            style: primaryTextStyle(),
                          ),
                          subtitle: Text(
                            data.description ?? 'Abonnement valable pendant ',
                            style: secondaryTextStyle(),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewAbonnement extends StatefulWidget {
  static String tag = '/NewAbonnement';
  final AbonnementModel? abonnementModel;

  NewAbonnement({this.abonnementModel});

  @override
  _NewAbonnementState createState() => _NewAbonnementState();
}

class _NewAbonnementState extends State<NewAbonnement> {
  var formKey = GlobalKey<FormState>();

  TextEditingController nameCont = TextEditingController();
  TextEditingController dayCount = TextEditingController();
  TextEditingController priceAbonnement = TextEditingController();
  TextEditingController desCription = TextEditingController();
  TextEditingController imageCont = TextEditingController();
  File? imagesPicket;
  FocusNode imageFocus = FocusNode();

  bool isUpdate = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    isUpdate = widget.abonnementModel != null;

    if (isUpdate) {
      print(widget.abonnementModel.toString());
      dayCount.text = widget.abonnementModel?.numbreJours.toString() ?? '';
      nameCont.text = widget.abonnementModel?.name ?? '';
      priceAbonnement.text = widget.abonnementModel?.price.toString() ?? '';
      imageCont.text = widget.abonnementModel?.imageUrl ?? '';
      desCription.text = widget.abonnementModel?.description ?? '';
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
          final url =
              await saveFile('Abonnement/${nameCont.text}', imagesPicket!);
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
    if (formKey.currentState!.validate()) {
      AbonnementModel abonnementModel = AbonnementModel();
      abonnementModel.name = nameCont.text.trim();
      abonnementModel.imageUrl = imageCont.text.trim();
      abonnementModel.numbreJours = int.tryParse(dayCount.text);
      abonnementModel.price = double.tryParse(priceAbonnement.text);
      abonnementModel.updatedAt = DateTime.now();
      abonnementModel.description = desCription.text;

      if (isUpdate) {
        abonnementModel.id = widget.abonnementModel!.id;
        abonnementModel.createdAt = widget.abonnementModel!.createdAt;
        toast("update");
      } else {
        abonnementModel.createdAt = DateTime.now();
        abonnementModel.updatedAt = DateTime.now();
        toast("not update");
      }

      if (!isUpdate) {
        log(abonnementModel.toJson());
        await abonnementServices
            .addDocument(
          abonnementModel.toJson(),
        )
            .then((value) {
          finish(context);
          setState(() => isSaving = false);
        }).catchError((e) {
          setState(() => isSaving = false);
          toast(e.toString());
        });
      } else {
        await abonnementServices
            .updateDocument(abonnementModel.toJson(), abonnementModel.id)
            .then(
          (value) {
            toast('Add Abonnement Successfully');
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
                decoration: inputDecoration(labelText: "Name"),
                autoFocus: true,
              ),
              16.height,
              AppTextField(
                controller: dayCount,
                textFieldType: TextFieldType.NAME,
                decoration: inputDecoration(
                  labelText: "Number of days",
                ),
                autoFocus: true,
                validator: (s) {
                  if (s!.isEmpty) return errorThisFieldRequired;
                  if (int.tryParse(s) == null) return 'Incorrect number';
                  return null;
                },
              ),
              16.height,
              AppTextField(
                controller: imageCont,
                textFieldType: TextFieldType.OTHER,
                focus: imageFocus,
                decoration: inputDecoration(
                  labelText: appStore.translate("lbl_image_uRL"),
                ),
                keyboardType: TextInputType.url,
                validator: (s) {
                  if (imagesPicket != null) return null;
                  if (s!.isEmpty) return errorThisFieldRequired;
                  if (!s.validateURL()) return 'URL is invalid';
                  return null;
                },
              ),
              16.height,
              AppTextField(
                controller: priceAbonnement,
                textFieldType: TextFieldType.OTHER,
                decoration: inputDecoration(
                  labelText: "Price",
                ),
                keyboardType: TextInputType.url,
                validator: (s) {
                  if (s!.isEmpty) return errorThisFieldRequired;
                  if (double.tryParse(s) == null) return 'Incorrect number';
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
                            : widget.abonnementModel?.imageUrl == null
                                ? null
                                : DecorationImage(
                                    image: NetworkImage(
                                        widget.abonnementModel?.imageUrl ?? ""),
                                    fit: BoxFit.cover,
                                  ),
                      ),
                      child: imageData != null
                          ? Center(
                              child: imageData != null
                                  ? Image.memory(imageData!)
                                  : CircularProgressIndicator(),
                            )
                          : widget.abonnementModel?.imageUrl == null &&
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
                        // final id = widget.abonnementModel!.id_classe;
                        // await delete(id);
                        // finish(context);
                      },
                    ).catchError(
                      // ignore: body_might_complete_normally_catch_error
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
