import 'package:flutter/material.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-06-28
///
class ScrollTopButton extends StatefulWidget {
  final double bottom, right;
  final ScrollController scrollController;

  /// 按钮消失或出现的时间
  final int buttonAnimationTime;

  /// 回到顶部的时间
  final int scrollAnimationTime;

  /// 滚动多高后出现ScrollTopButton
  final double showDistance;

  final Color color;

  final Icon icon;

  ScrollTopButton(
    this.bottom,
    this.right,
    this.scrollController, {
    this.color,
    this.icon,
    this.buttonAnimationTime = 300,
    this.scrollAnimationTime = 400,
    this.showDistance = 1000,
  });

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ScrollTopButtonState();
  }
}

class _ScrollTopButtonState extends State<ScrollTopButton>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  bool _showToTopBtn = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = new AnimationController(
      vsync: this,
      lowerBound: -80,
      upperBound: widget.bottom,
      duration: Duration(milliseconds: widget.buttonAnimationTime),
    )..addListener(() {
        setState(() {});
      });
    addListener();
  }

  addListener() {
    try {
      widget.scrollController?.addListener(() {
        if (widget.scrollController.offset < widget.showDistance &&
            _showToTopBtn) {
          _showToTopBtn = false;
          _controller.reverse();
        } else if (widget.scrollController.offset >= widget.showDistance &&
            _showToTopBtn == false) {
          _showToTopBtn = true;
          _controller.forward();
        }
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
//    addListener();
    // TODO: implement build
    return Positioned(
      right: widget.right,
      bottom: _controller.value,
      child: FloatingActionButton(
        onPressed: () {
          widget.scrollController.animateTo(0,
              duration: Duration(milliseconds: widget.scrollAnimationTime),
              curve: Curves.ease);
        },
        child: widget.icon ??
            Icon(
              Icons.arrow_upward,
              color: Colors.white,
            ),
        backgroundColor: widget.color ?? Theme.of(context).accentColor,
        heroTag: null,
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }
}
