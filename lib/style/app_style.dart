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

  static TextStyle mainText10(BuildContext context,
          {bold = false, weight = FontWeight.normal, color = null}) =>
      TextStyle(
          color: color == null ? colors(context).colorMainText : color,
          fontSize: 10,
          decoration: TextDecoration.none,
          fontWeight: bold ? FontWeight.bold : weight);

  static TextStyle mainText12(BuildContext context,
          {bold = false, weight = FontWeight.normal, color = null}) =>
      TextStyle(
          color: color == null ? colors(context).colorMainText : color,
          fontSize: 12,
          decoration: TextDecoration.none,
          fontWeight: bold ? FontWeight.bold : weight);

  static TextStyle mainText14(BuildContext context,
          {bold = false, weight = FontWeight.normal}) =>
      TextStyle(
          color: colors(context).colorMainText,
          fontSize: 14,
          decoration: TextDecoration.none,
          fontWeight: bold ? FontWeight.bold : weight);

  static TextStyle mainText16(BuildContext context,
          {fontWeight = FontWeight.normal}) =>
      TextStyle(
          color: colors(context).colorMainText,
          fontSize: 16,
          decoration: TextDecoration.none,
          fontWeight: fontWeight);

  static TextStyle mainText17(BuildContext context, {bold = false}) =>
      TextStyle(
          color: colors(context).colorMainText,
          fontSize: 17,
          decoration: TextDecoration.none,
          fontWeight: bold ? FontWeight.w500 : FontWeight.normal);

  static TextStyle mainText18(BuildContext context, {fontWeight = FontWeight.normal}) =>
      TextStyle(
          color: colors(context).colorMainText,
          fontSize: 18,
          decoration: TextDecoration.none,
          fontWeight: fontWeight);

  static TextStyle mainText20(BuildContext context) => TextStyle(
        color: colors(context).colorMainText,
        fontSize: 20,
        decoration: TextDecoration.none,
      );

  static TextStyle mainText22(BuildContext context) => TextStyle(
        color: colors(context).colorMainText,
        fontSize: 22,
        decoration: TextDecoration.none,
      );

  static TextStyle contentText12(BuildContext context) => TextStyle(
        color: colors(context).colorContentText,
        fontSize: 12,
        decoration: TextDecoration.none,
      );

  static TextStyle contentText14(BuildContext context) => TextStyle(
        color: colors(context).colorContentText,
        fontSize: 14,
        decoration: TextDecoration.none,
      );

  static TextStyle contentText16(BuildContext context) => TextStyle(
        color: colors(context).colorContentText,
        fontSize: 16,
        decoration: TextDecoration.none,
      );

  static TextStyle confirmText14(BuildContext context) => TextStyle(
        color: colors(context).colorConfirm,
        fontSize: 14,
        decoration: TextDecoration.none,
      );

  static TextStyle cancelText14(BuildContext context) => TextStyle(
        color: colors(context).colorCancel,
        fontSize: 14,
        decoration: TextDecoration.none,
      );

  static TextStyle cancelText12(BuildContext context) => TextStyle(
        color: colors(context).colorCancel,
        fontSize: 12,
        decoration: TextDecoration.none,
      );

  static TextStyle descText12(BuildContext context) => TextStyle(
        color: colors(context).colorDescText,
        fontSize: 12,
        decoration: TextDecoration.none,
      );

  static TextStyle primaryText28(BuildContext context) => TextStyle(
        color: colors(context).colorPrimary,
        fontSize: 28,
        decoration: TextDecoration.none,
      );

  static TextStyle locationText14(BuildContext context) => TextStyle(
        color: colors(context).colorLocationText,
        fontSize: 14,
        decoration: TextDecoration.none,
      );

  static TextStyle locationText16(BuildContext context) => TextStyle(
        color: colors(context).colorLocationText,
        fontSize: 16,
        decoration: TextDecoration.none,
      );

  static TextStyle navCancelText(BuildContext context) => TextStyle(
        color: colors(context).colorCancelText,
        fontSize: 17,
        decoration: TextDecoration.none,
      );

  static TextStyle navSaveText(BuildContext context) => TextStyle(
      color: colors(context).colorSaveText,
      fontSize: 17,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.bold);

  static TextStyle placeholderText(BuildContext context) => TextStyle(
      color: colors(context).colorPlaceholderText,
      fontSize: 14,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.normal);
}
