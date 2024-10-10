import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/widgets.dart';

class ForgotPasswordDialog extends StatefulWidget {
  static String tag = '/ForgotPasswordDialog';

  @override
  _ForgotPasswordDialogState createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  TextEditingController emailCont = TextEditingController();

  Future<void> submit() async {
    if (emailCont.text.trim().isEmpty) return toast(errorThisFieldRequired);

    if (!emailCont.text.trim().validateEmail()) return toast(appStore.translate('lbl_invalidEmail'));

    hideKeyboard(context);
    appStore.setLoading(true);

    if (await userDBService.isUserExist(emailCont.text, LoginTypeEmail)) {
      ///
      await auth.sendPasswordResetEmail(email: emailCont.text).then((value) {
        toast(appStore.translate('lbl_resetEmail')+' ${emailCont.text}');

        finish(context);
      }).catchError((e) {
        toast(e.toString());
      });

      ///
      appStore.setLoading(false);
    } else {
      toast(appStore.translate('lbl_noUserFound'));
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(appStore.translate('lbl_forgotPassword'), style: boldTextStyle(size: 20)),
              CloseButton(),
            ],
          ),
          8.height,
          AppTextField(
            controller: emailCont,
            textFieldType: TextFieldType.EMAIL,
            decoration: inputDecoration(hintText: appStore.translate('lbl_email_id')),
            textStyle: primaryTextStyle(),
            autoFocus: true,
          ),
          30.height,
          Stack(
            alignment: Alignment.center,
            children: [
              InkWell(
                onTap: () {
                  submit();
                },
                child: Container(
                  padding: EdgeInsets.only(left: 30, right: 30),
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(defaultRadius),
                    gradient: LinearGradient(
                      colors: [colorPrimary, colorSecondary],
                      begin: FractionalOffset.centerLeft,
                      end: FractionalOffset.centerRight,
                    ),
                  ),
                  child: Text(appStore.translate('lbl_send'),style: boldTextStyle(color: Colors.white)),
                ),
              ),
              Observer(builder: (_) => Loader().visible(appStore.isLoading)),
            ],
          ),
        ],
      ),
    );
  }
}
