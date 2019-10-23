import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-07-25
///
class MyAppbar extends PreferredSize {
  final Widget title;
  final double height;
  final BuildContext context;
  final Widget leftIcon;
  final Widget leftText;
  final Widget rightIcon;
  final Widget rightText;
  final bool isHero;

  MyAppbar(
    this.context, {
    Key key,
    this.title,
    this.leftIcon,
    this.leftText,
    this.rightIcon,
    this.rightText,
    this.height = 56,
    this.isHero = false,
  }) : super(
          key: key,
          preferredSize: Size(double.infinity, height),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: height,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 60,
                    height: height,
                    child: Hero(
                      tag: isHero ? "back" : context.toString(),
                      child: leftText == null
                          ? (leftIcon == null
                              ? MaterialButton(
                                  child: SvgPicture.asset(
                                    "assets/images/icon_back.svg",
                                  ),
                                  shape: CircleBorder(
                                    side: BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                )
                              : leftIcon)
                          : leftText,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: title,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    height: height,
                    child: rightText == null ? rightIcon : rightText,
                  ),
                ],
              ),
            ),
          ),
        );
}
