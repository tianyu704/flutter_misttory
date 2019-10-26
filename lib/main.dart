import 'dart:io';

import 'package:amap_base/amap_base.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/pages/home_page.dart';
import 'package:misstory/db/db_manager.dart';
import 'package:misstory/pages/preloading_page.dart';
import 'package:misstory/provider/theme_provider.dart';
import 'package:misstory/utils/common_localization_delegate.dart';
import 'package:provider/provider.dart';

import 'constant.dart';
import 'db/helper/picture_helper.dart';
import 'db/local_storage.dart';
import 'generated/i18n.dart';
import 'style/app_style.dart';
bool hasCreatePicture;
void main() async {
  /// 初始化数据库
  await DBManager.initDB();
  await AMap.init(Constant.iosMapKey);
  await StoryHelper().updateAllDefaultAddress();

  ///TODO:此时就要求授权了 等产品逻辑具体化 再修改
  hasCreatePicture = await PictureHelper().hasCreatePicture();
//  await StoryHelper().clear();
//  await PictureHelper().addPath();

  /// 主题
  bool isNight = (await LocalStorage.get(LocalStorage.isNight)) ?? false;
  if (Platform.isAndroid) {
    //以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
  return runApp(MultiProvider(providers: [
    ChangeNotifierProvider<ThemeProvider>.value(
        value: ThemeProvider(isNight ? AppTheme.night : AppTheme.light)),
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Misstory",
      onGenerateTitle: (context) => S.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: AppStyle.colors(context).colorBgPage,
        accentColor: AppStyle.colors(context).colorAccent,
        primaryColor: AppStyle.colors(context).colorPrimary,
        appBarTheme: AppBarTheme(
          brightness: ThemeProvider.getAppTheme(context) == AppTheme.light
              ? Brightness.light
              : Brightness.dark,
        ),
      ),
      localizationsDelegates: const [
        S.delegate,
        ChineseCupertinoLocalizations.delegate, // 这里加上这个,是自定义的delegate
        DefaultCupertinoLocalizations.delegate, // 这个截止目前只包含英文
        // You need to add them if you are using the material library.
        // The material components usses this delegates to provide default
        // localization
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      localeListResolutionCallback:
          S.delegate.listResolution(fallback: const Locale('zh', '')),
      home: PreLoadingPage(),
    );
  }
}
