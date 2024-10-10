import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../screens/HomeScreen.dart';
import '../main.dart';
import '../screens/RegisterScreen.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../utils/widgets.dart';

class OTPDialog extends StatefulWidget {
  static String tag = '/OTPDialog';
  final String? verificationId;
  final String? phoneNumber;
  final bool? isCodeSent;
  final PhoneAuthCredential? credential;

  OTPDialog({this.verificationId, this.isCodeSent, this.phoneNumber, this.credential});

  @override
  OTPDialogState createState() => OTPDialogState();
}

class OTPDialogState extends State<OTPDialog> {
  TextEditingController numberController = TextEditingController();
  String? countryCode = '';
  String otpCode = '';

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> submit() async {
    appStore.setLoading(true);
    AuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationId!, smsCode: otpCode.validate());

    await FirebaseAuth.instance.signInWithCredential(credential).then((result) async {
      User currentUser = result.user!;

      await userDBService.userByMobileNumber(currentUser.phoneNumber).then((user) async {
        await setValue(LOGIN_TYPE, LoginTypeOTP);
        await authService.setUserDetailPreference(user).whenComplete(() => HomeScreen().launch(context, isNewTask: true));
      }).catchError((e) {
        log(e);
        if (e.toString() == 'EXCEPTION_NO_USER_FOUND') {
          appStore.setLoading(false);
          RegisterScreen(userModel: currentUser, phoneNumber: currentUser.phoneNumber, isPhone: true).launch(context).then((value) {
            appStore.setLoading(false);
          });
        } else {
          throw e;
        }
      });
    }).catchError((e) {
      log(e);
      // toast(e.toString());
      appStore.setLoading(false);
    });
  }

  Future<void> sendOTP() async {
    hideKeyboard(context);
    if (numberController.text.trim().isEmpty) {
      return toast(errorThisFieldRequired);
    }
    appStore.setLoading(true);
    setState(() {});

    String number = '+$countryCode${numberController.text.trim()}';
    if (!number.startsWith('+')) {
      number = '+$countryCode${numberController.text.trim()}';
    }

    await authService.loginWithOTP(context, number).then((value) {
      appStore.setLoading(false);

      //
    }).catchError((e) {
      appStore.setLoading(false);

      toast(e.toString());
    });
    appStore.setLoading(false);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: radius(defaultRadius)),
      child: Container(
        width: context.width(),
        child: !widget.isCodeSent.validate()
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("OTP Login", style: boldTextStyle(size: 18)).paddingOnly(left: 16, top: 16),
                      IconButton(
                        onPressed: () {
                          finish(context);
                        },
                        icon: Icon(Icons.close_sharp),
                      )
                    ],
                  ),
                  Container(
                    height: 100,
                    child: Row(
                      children: [
                        CountryCodePicker(
                          initialSelection: 'IN',
                          showCountryOnly: false,
                          showFlag: false,
                          boxDecoration: BoxDecoration(borderRadius: radius(defaultRadius), color: context.scaffoldBackgroundColor),
                          showFlagDialog: true,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                          textStyle: primaryTextStyle(),
                          onInit: (c) {
                            countryCode = c!.dialCode;
                          },
                          onChanged: (c) {
                            countryCode = c.dialCode;
                          },
                        ),
                        AppTextField(
                          controller: numberController,
                          textFieldType: TextFieldType.PHONE,
                          decoration: inputDecoration(hintText: "Mobile number"),
                          autoFocus: true,
                          onFieldSubmitted: (s) {
                            sendOTP();
                          },
                        ).expand(),
                      ],
                    ),
                  ).paddingOnly(left: 16, right: 16),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AppButton(
                        onTap: () {
                          appStore.setLoading(true);
                          print("send OTP");
                          sendOTP();
                        },
                        text: "Send OTP",
                        color: appStore.isDarkMode ? scaffoldDarkColor : colorPrimary,
                        textStyle: boldTextStyle(color: Colors.white),
                        width: context.width(),
                      ),
                      Loader().visible(appStore.isLoading),
                    ],
                  ).paddingOnly(left: 16, right: 16, bottom: 16)
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(appStore.translate('lbl_otp'), style: boldTextStyle()),
                      IconButton(
                          onPressed: () {
                            finish(context);
                          },
                          icon: Icon(Icons.close_sharp))
                    ],
                  ).paddingOnly(left: 16),
                  16.height,
                  OTPTextField(
                    pinLength: 6,
                    fieldWidth: 30,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (s) {
                      otpCode = s;
                    },
                    onCompleted: (pin) {
                      otpCode = pin;
                      submit();
                    },
                  ),
                  16.height,
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      AppButton(
                        onTap: () {
                          appStore.setLoading(true);
                          submit();
                        },
                        text: appStore.translate('lbl_conform'),
                        color: appStore.isDarkMode ? scaffoldDarkColor : colorPrimary,
                        textStyle: boldTextStyle(color: Colors.white),
                        width: context.width(),
                        shapeBorder: RoundedRectangleBorder(borderRadius: radius(defaultRadius)),
                      ).paddingOnly(left: 16, right: 16, bottom: 12),
                      Loader().visible(appStore.isLoading),
                    ],
                  )
                ],
              ),
      ),
    );
  }
}
