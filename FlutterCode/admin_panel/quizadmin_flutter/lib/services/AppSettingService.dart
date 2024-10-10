import 'package:nb_utils/nb_utils.dart';
import 'package:quizeapp/models/AppSettingModel.dart';
import 'package:quizeapp/utils/Constants.dart';

import '../main.dart';
import 'BaseService.dart';

class AppSettingService extends BaseService {
  String? id;

  AppSettingService() {
    ref = db.collection('settings');
  }

  Future<AppSettingModel> getAppSettings() async {
    return await ref.get().then((value) async {
      if (value.docs.isEmpty) {
        print ("=============== isEmpty");
        return await setAppSettings();
      } else {
        return await ref.doc('setting').get().then((value) async {
          id = value.id;
          return AppSettingModel.fromJson(value.data() as Map<String, dynamic>);
        }).catchError((e) {
          throw e;
        });
      }
    });
  }

  Future<AppSettingModel> setAppSettings() async {
    AppSettingModel appSettingModel = AppSettingModel();

    appSettingModel.disableAd = false;
    appSettingModel.termCondition = '';
    appSettingModel.privacyPolicy = '';
    appSettingModel.contactInfo = '';
    appSettingModel.referPoints='';

    return ref.get().then((value) async {
      if (value.docs.isNotEmpty) {
        appSettingModel = await ref.doc('setting').get().then((value) => AppSettingModel.fromJson(value.data() as Map<String, dynamic>));
        await saveAppSettings(appSettingModel);
        LiveStream().emit(StreamRefresh, true);
      } else {
        ref.doc("setting").set(appSettingModel.toJson());
      }
      return appSettingModel;
    });
  }

  Future<void> saveAppSettings(AppSettingModel appSettingModel) async {
    await setValue(DISABLE_AD, appSettingModel.disableAd.validate());
    await setValue(TERMS_AND_CONDITION_PREF, appSettingModel.termCondition.validate());
    await setValue(PRIVACY_POLICY_PREF, appSettingModel.privacyPolicy.validate());
    await setValue(CONTACT_PREF, appSettingModel.contactInfo.validate());
  }
}
