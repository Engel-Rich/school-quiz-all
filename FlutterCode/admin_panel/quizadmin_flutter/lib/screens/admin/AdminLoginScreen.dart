import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
// import 'package:quizeapp/models/UserModel.dart';
import 'package:quizeapp/screens/admin/AdminDashboardScreen.dart';
import 'package:quizeapp/services/AuthService.dart';
// import 'package:quizeapp/services/UserService.dart';
import 'package:quizeapp/utils/Colors.dart';
import 'package:quizeapp/utils/Common.dart';
import '../../main.dart';
import '../../utils/Constants.dart';

class AdminLoginScreen extends StatefulWidget {
  @override
  AdminDashboardScreenState createState() => AdminDashboardScreenState();
}

class AdminDashboardScreenState extends State<AdminLoginScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  var formKey1 = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  FocusNode passFocus = FocusNode();
  FocusNode emailFocus = FocusNode();

  Future<void> signIn() async {
    if (formKey1.currentState!.validate()) {
      formKey1.currentState!.save();
      appStore.setLoading(true);

      await signInWithEmail(emailController.text, passwordController.text).then(
        (user) {
          log(user.toJson());
          if (user.isAdmin.validate() || user.isTestUser.validate()) {
            if (user.email == test_user) setValue(IS_TEST_USER, true);
            AdminDashboardScreen().launch(context, isNewTask: true);
          } else {
            logout(context);
            toast('You are not allowed to login');
          }
        },
      ).catchError(
        (e) {
          log(e);
          toast(e.toString().splitAfter(']').trim());
        },
      );
      appStore.setLoading(false);
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: formKey,
      body: Container(
        alignment: Alignment.center,
        width: 500,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Form(
              key: formKey1,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    // StreamBuilder<List<UserModel>>(
                    //   stream: UserService().users(),
                    //   builder: (context, snapshot) {
                    //     return snapshot.data == null
                    //         ? Text('Pas de données')
                    //         : snapshot.hasError
                    //             ? Text("${snapshot.error}")
                    //             : snapshot.data != null
                    //                 ? ListView.builder(
                    //                     shrinkWrap: true,
                    //                     physics: NeverScrollableScrollPhysics(),
                    //                     itemCount: snapshot.data!.length,
                    //                     itemBuilder: (context, index) =>
                    //                         ListTile(
                    //                       title: Text(
                    //                           '${snapshot.data![index].email}'),
                    //                     ),
                    //                   )
                    //                 : Text("Snapshot a pas de données");
                    //   },
                    // ),

                    Image.asset('assets/splash_app_logo.png', height: 100),
                    8.height,
                    gradientText(mAppName, style: boldTextStyle(size: 22)),
                    24.height,
                    AppTextField(
                      controller: emailController,
                      textFieldType: TextFieldType.EMAIL,
                      decoration: inputDecoration(
                          labelText: appStore.translate("lbl_email")),
                      nextFocus: passFocus,
                      autoFocus: true,
                    ),
                    16.height,
                    AppTextField(
                      controller: passwordController,
                      textFieldType: TextFieldType.PASSWORD,
                      focus: passFocus,
                      decoration: inputDecoration(
                          labelText: appStore.translate("lbl_password")),
                      onFieldSubmitted: (s) {
                        signIn();
                      },
                    ),
                    16.height,
                    commonAppButton(context, appStore.translate("lbl_login"),
                        onTap: () {
                      signIn();
                    }),
                    16.height,
                  ],
                ),
              ),
            ),
            Observer(
                builder: (_) =>
                    Loader(valueColor: AlwaysStoppedAnimation(colorPrimary))
                        .visible(appStore.isLoading)),
          ],
        ),
      ).center(),
    );
  }
}
