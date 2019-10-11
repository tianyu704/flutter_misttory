import 'dart:io';

import 'package:amap_base/amap_base.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:misstory/db/helper/story_helper.dart';
import 'package:misstory/pages/home_page.dart';
import 'package:misstory/db/db_manager.dart';
import 'package:misstory/provider/theme_provider.dart';
import 'package:provider/provider.dart';

import 'db/local_storage.dart';
import 'generated/i18n.dart';

void main() async {
  /// 初始化数据库
  await DBManager.initDB();
  await AMap.init('11bcf7a88c8b1a9befeefbaa2ceaef71');
  await StoryHelper().deleteMisstory();
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: const [
        S.delegate,
        // You need to add them if you are using the material library.
        // The material components usses this delegates to provide default
        // localization
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      localeListResolutionCallback:
          S.delegate.listResolution(fallback: const Locale('zh', '')),
      home: HomePage(),
    );
  }
}
