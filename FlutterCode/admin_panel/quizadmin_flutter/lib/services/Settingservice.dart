import 'dart:html';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/AppSettingModel.dart';
import '../utils/Constants.dart';
import 'BaseService.dart';

class SettingsService extends BaseService {
  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  // FirebaseStorage _storage = FirebaseStorage.instance;
  late CollectionReference userRef;

  settingsService() {
    userRef = fireStore.collection(NOTIFICATION);
  }

  setOneSignalSettings({OneSignalModel? oneSignalModel}) async {
    return ref.doc("onesignal").set(oneSignalModel!.toJson());
  }

  Future<OneSignalModel> getOneSignalSettings() async {
    return await ref.get().then((value) async {
      if (value.docs.isEmpty) {
        return await setOneSignalSettings();
      } else {
        return await ref.doc('onesignal').get().then((value) async {
          return OneSignalModel.fromJson(value.data() as Map<String, dynamic>);
        }).catchError((e) {
          throw e;
        });
      }
    }).catchError((e) {
      throw e;
    });
  }
}

FirebaseStorage storage = FirebaseStorage.instance;

Future<String?> saveFile(String folder, File file) async {
  try {
    final path = storage
        .ref()
        .child(folder)
        .child(DateTime.now().microsecondsSinceEpoch.toString());
    await path.putBlob(file);
    return await path.getDownloadURL();
  } catch (e) {
    return null;
  }
}

Future<String?> saveAudio(String folder, Uint8List file,
    {String extension = '.mp3'}) async {
  try {
    final path = storage
        .ref()
        .child(folder)
        .child("${DateTime.now().microsecondsSinceEpoch}$extension");
    await path.putData(file);
    return await path.getDownloadURL();
  } catch (e) {
    return null;
  }
}
