import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import '/../utils/colors.dart';

class AppTheme {
  //
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: createMaterialColor(colorPrimary),
    primaryColor: colorPrimary,
    scaffoldBackgroundColor: scaffoldColor,
    fontFamily: GoogleFonts.roboto().fontFamily,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: Colors.white),
    iconTheme: IconThemeData(color: scaffoldSecondaryDark),
    textTheme: TextTheme(titleLarge: TextStyle()),
    dialogBackgroundColor: Colors.white,
    unselectedWidgetColor: Colors.black,
    dividerColor: viewLineColor,
    cardColor: Colors.white,
    //appBarTheme: appStore.appBarTheme,
    dialogTheme: DialogTheme(shape: dialogShape()),
  ).copyWith(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: createMaterialColor(colorPrimary),
    primaryColor: colorPrimary,
    scaffoldBackgroundColor: scaffoldBakGroundColor,
    fontFamily: GoogleFonts.roboto().fontFamily,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: scaffoldSecondaryDark),
    iconTheme: IconThemeData(color: Colors.white),
    textTheme: TextTheme(titleLarge: TextStyle(color: textSecondaryColor)),
    dialogBackgroundColor: scaffoldSecondaryDark,
    unselectedWidgetColor: Colors.white60,
    dividerColor: Colors.white60,
    cardColor: scaffoldSecondaryDark,
    // buttonColor: app_background_black,
    inputDecorationTheme: InputDecorationTheme(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.yellow))),

    //appBarTheme: appStore.appBarTheme,
    dialogTheme: DialogTheme(shape: dialogShape(),backgroundColor: scaffoldSecondaryDark),
  ).copyWith(
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
