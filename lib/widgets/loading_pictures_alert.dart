import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:misstory/style/app_style.dart';

/*

void _showLoadingAlertView(BuildContext cxt) {
    double sum = 0;
    bool isCancel = false;
    ///
    LoadingPicturesAlert alert = LoadingPicturesAlert(
      alertTitle: richTitle("初次使用需根据您的相册\n为您生成时间轴", context),
      alertSubtitle: richSubtitle("此过程大概需要3～5分钟", context),
      cancelProgressBlock: () {
        isCancel = true;
      },
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });

    /// 延时1s执行返回 不延迟 会出现命令行报错updateProgress为空
    Future.delayed(Duration(seconds: 1), () {
      Timer.periodic(Duration(microseconds: 500), (t) {
        alert.updateProgress(sum += 0.000001);
        if (sum > 1 || isCancel) {
          t.cancel();
          Navigator.pop(cxt, 0);
        }
      });
    });
  }
 */

typedef CancelProgressBlock = void Function();

class LoadingPicturesAlert extends StatefulWidget {
  /// The title of the dialog is displayed in a large font at the top
  /// of the dialog.
  ///
  /// Usually has a bigger fontSize than the [alertSubtitle].
  final Text alertTitle;

  /// The subtitle of the dialog is displayed in a medium-sized font beneath
  /// the title of the dialog.
  ///
  /// Usually has a smaller fontSize than the [alertTitle]
  final Text alertSubtitle;

  /// Specifies how blur the screen overlay effect should be.
  /// Higher values mean more blurred overlays.
  final double blurValue;

  // Specifies the opacity of the screen overlay
  final double backgroundOpacity;

  final CancelProgressBlock cancelProgressBlock;

  LoadingPicturesAlert({
    Key key,
    @required this.alertTitle,
    @required this.alertSubtitle,
    this.blurValue,
    this.backgroundOpacity,
    this.cancelProgressBlock,
  }) : super(key: key);
  _LoadingPicturesAlertState _state;

  updateProgress(double progress) {
    _state.updateProgress(progress);
  }

  createState() {
    _state = _LoadingPicturesAlertState();
    return _state;
  }
}

class _LoadingPicturesAlertState extends State<LoadingPicturesAlert> {
  double deviceWidth;
  double deviceHeight;
  double dialogHeight;
  double progressNum = 0.001;

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    Size screenSize = MediaQuery.of(context).size;

    deviceWidth = orientation == Orientation.portrait
        ? screenSize.width
        : screenSize.height;
    deviceHeight = orientation == Orientation.portrait
        ? screenSize.height
        : screenSize.width;
    dialogHeight = deviceHeight * (2 / 5);

    return MediaQuery(
      data: MediaQueryData(),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurValue != null ? widget.blurValue : 3.0,
          sigmaY: widget.blurValue != null ? widget.blurValue : 3.0,
        ),
        child: Container(
          height: deviceHeight,
          color: Colors.white.withOpacity(widget.backgroundOpacity != null
              ? widget.backgroundOpacity
              : 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      child: Container(
                        height: dialogHeight,
                        width: deviceWidth * 0.75,
                        child: Card(
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          color: Colors.white,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(height: dialogHeight / 4),
                              widget.alertTitle,
                              Padding(
                                padding: EdgeInsets.only(top: 10),
                              ),
                              widget.alertSubtitle,
                              SizedBox(height: dialogHeight / 10),
                              buildProgress(),
                              SizedBox(height: dialogHeight / 9),
                              Spacer(flex: 1),
                              _lineWidget(context),
                              Container(
                                child: _defaultAction(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: deviceHeight / 7 * 1.5,
                      child: _defaultTopView(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProgress() {
    return ClipRRect(
      // 边界半径（`borderRadius`）属性，圆角的边界半径。
      borderRadius: BorderRadius.all(Radius.circular(8)),
      child: SizedBox(
        width: deviceWidth * 0.75 - 20 * 2,
        height: 6,
        child: LinearProgressIndicator(
          backgroundColor: AppStyle.colors(context).colorProgressBg,
          valueColor:
              AlwaysStoppedAnimation(AppStyle.colors(context).colorPrimary),
          value: progressNum,
        ),
      ),
    );
  }

  Widget _defaultIcon() {
    return SizedBox(
      child: SvgPicture.asset("assets/images/icon_picture_process.svg"),
      width: deviceHeight / 7 / 2,
      height: deviceHeight / 7 / 2,
    );
  }

  Widget _defaultTopView() {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          width: deviceHeight / 7,
          height: deviceHeight / 7,
          child: DecoratedBox(
              decoration: BoxDecoration(
                  gradient: RadialGradient(
                      //背景径向渐变
                      colors: [Color(0xFF4580FC), Color(0xFF565BEA)],
                      center: Alignment.topLeft,
                      radius: .98),
                  borderRadius: BorderRadius.all(
                      Radius.circular(deviceHeight / 7 / 2.0)))),
        ),
        _defaultIcon(),
      ],
    );
  }

  Widget _lineWidget(BuildContext context) {
    return Container(
      width: deviceWidth * 0.75,
      height: 1,
      color: Color(0xFFEBEEF3),
    );
  }

  Widget _defaultAction(BuildContext context) {
    return SizedBox(
      width: deviceWidth * 0.75,
      height: 50,
      child: FlatButton(
        child: Text(
          "暂时跳过",
          style: TextStyle(
              color: AppStyle.colors(context).colorPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w400),
        ),
        onPressed: () {
          widget.cancelProgressBlock();
          //Navigator.pop(context);
        },
      ),
    );
  }

  ///更新进度
  updateProgress(double progress) {
    if (progress < progressNum) return;
    if (progress > 1) progress = 1;
    if (progress < 0) progress = 0;

    progressNum = progress;
    if (mounted) {
      setState(() {});
    }
  }
}

Text richTitle(String title, BuildContext context) {
  return Text(
    title,
    style: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 16,
        color: AppStyle.colors(context).colorMainText),
    maxLines: 2,
    textAlign: TextAlign.center,
  );
}

Text richSubtitle(String subtitle, BuildContext context) {
  return Text(
    subtitle,
    style: TextStyle(color: AppStyle.colors(context).colorProgressSubText),
  );
}
