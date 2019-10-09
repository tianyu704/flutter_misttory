import 'package:flutter/material.dart';
import 'package:misstory/db/local_storage.dart';
import 'package:misstory/style/theme_base.dart';
import 'package:misstory/style/theme_black.dart';
import 'package:misstory/style/theme_normal.dart';
import 'package:provider/provider.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-07-23
///
class ThemeProvider with ChangeNotifier {
  ThemeBase _themeBase;
  AppTheme _appTheme;

  ///根据不同 AppTheme 加载不同的主题颜色
  static Map<AppTheme, ThemeBase> _colorValues = {
    AppTheme.night: new ThemeBlack(),
    AppTheme.light: new ThemeNormal(),
  };

  ThemeProvider(this._appTheme) {
    _themeBase = _colorValues[_appTheme];
  }

  void changeTheme(AppTheme theme) {
    _appTheme = theme;
    _themeBase = _colorValues[_appTheme];
    notifyListeners();
  }

  get themeBase => _themeBase;

  get appTheme => _appTheme;

  static void switchTheme(BuildContext context) {
    if (getAppTheme(context) == AppTheme.light) {
      LocalStorage.saveBool(LocalStorage.isNight, true);
      Provider.of<ThemeProvider>(context).changeTheme(AppTheme.night);
    } else {
      LocalStorage.saveBool(LocalStorage.isNight, false);
      Provider.of<ThemeProvider>(context).changeTheme(AppTheme.light);
    }
  }

  static AppTheme getAppTheme(BuildContext context) {
    return Provider.of<ThemeProvider>(context).appTheme;
  }
}

enum AppTheme { light, night }
