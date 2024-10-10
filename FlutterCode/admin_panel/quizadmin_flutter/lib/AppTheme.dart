import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';
import 'utils/Colors.dart';

class AppTheme {
  //
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: createMaterialColor(colorPrimary),
    primaryColor: colorPrimary,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: GoogleFonts.montserrat().fontFamily,
    bottomNavigationBarTheme:
        BottomNavigationBarThemeData(backgroundColor: Colors.white),
    iconTheme: IconThemeData(color: scaffoldSecondaryDark),
    textTheme: TextTheme(bodySmall: TextStyle()),
    dialogBackgroundColor: Colors.white,
    unselectedWidgetColor: Colors.black,
    dividerColor: viewLineColor,
    cardColor: Colors.white,
    dialogTheme: DialogTheme(shape: dialogShape()),
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
      ),
    ),
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
    scaffoldBackgroundColor: scaffoldColorDark,
    fontFamily: GoogleFonts.montserrat().fontFamily,
    bottomNavigationBarTheme:
        BottomNavigationBarThemeData(backgroundColor: scaffoldSecondaryDark),
    iconTheme: IconThemeData(color: Colors.white),
    textTheme: TextTheme(bodySmall: TextStyle(color: textSecondaryColor)),
    dialogBackgroundColor: scaffoldSecondaryDark,
    unselectedWidgetColor: Colors.white60,
    dividerColor: Colors.white12,
    cardColor: scaffoldSecondaryDark,
    dialogTheme: DialogTheme(shape: dialogShape()),
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
      ),
    ),
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
