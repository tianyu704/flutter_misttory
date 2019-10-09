import 'package:flutter/material.dart';
import 'package:misstory/provider/theme_provider.dart';
import 'package:provider/provider.dart';

import 'theme_base.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-06-12
///
class AppStyle {
  static const textSize9 = 9.0;
  static const textSize10 = 10.0;
  static const textSize11 = 11.0;
  static const textSize12 = 12.0;
  static const textSize13 = 13.0;
  static const textSize14 = 14.0;
  static const textSize15 = 15.0;
  static const textSize16 = 16.0;
  static const textSize17 = 17.0;
  static const textSize18 = 18.0;
  static const textSize19 = 19.0;
  static const textSize20 = 20.0;
  static const textSize21 = 21.0;
  static const textSize22 = 22.0;
  static const textSize23 = 23.0;
  static const textSize24 = 24.0;
  static const textSize25 = 25.0;
  static const textSize26 = 26.0;
  static const textSize27 = 27.0;
  static const textSize28 = 28.0;
  static const textSize29 = 29.0;
  static const textSize30 = 30.0;
  static const textSize31 = 31.0;
  static const textSize32 = 32.0;

  static ThemeBase colors(BuildContext context) =>
      Provider.of<ThemeProvider>(context).themeBase;

  static TextStyle mainText12(BuildContext context,
          {bold = false, weight = FontWeight.normal,color = null}
          ) =>
      TextStyle(
          color: color == null ? colors(context).colorMainText : color ,
          fontSize: 12,
          fontWeight: bold ? FontWeight.bold : weight);

  static TextStyle mainText14(BuildContext context,
          {bold = false, weight = FontWeight.normal}) =>
      TextStyle(
          color: colors(context).colorMainText,
          fontSize: 14,
          fontWeight: bold ? FontWeight.bold : weight);

  static TextStyle mainText16(BuildContext context, {bold = false}) =>
      TextStyle(
          color: colors(context).colorMainText,
          fontSize: 16,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal);

  static TextStyle mainText18(BuildContext context, {bold = false}) =>
      TextStyle(
          color: colors(context).colorMainText,
          fontSize: 18,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal);

  static TextStyle mainText20(BuildContext context) =>
      TextStyle(color: colors(context).colorMainText, fontSize: 20);

  static TextStyle mainText22(BuildContext context) =>
      TextStyle(color: colors(context).colorMainText, fontSize: 22);

  static TextStyle contentText12(BuildContext context) =>
      TextStyle(color: colors(context).colorContentText, fontSize: 12);

  static TextStyle contentText14(BuildContext context) =>
      TextStyle(color: colors(context).colorContentText, fontSize: 14);

  static TextStyle contentText16(BuildContext context) =>
      TextStyle(color: colors(context).colorContentText, fontSize: 16);

  static TextStyle confirmText14(BuildContext context) =>
      TextStyle(color: colors(context).colorConfirm, fontSize: 14);

  static TextStyle cancelText14(BuildContext context) =>
      TextStyle(color: colors(context).colorCancel, fontSize: 14);

  static TextStyle cancelText12(BuildContext context) =>
      TextStyle(color: colors(context).colorCancel, fontSize: 12);

  static TextStyle descText12(BuildContext context) =>
      TextStyle(color: colors(context).colorDescText, fontSize: 12);
}
