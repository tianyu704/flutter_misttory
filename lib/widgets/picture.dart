import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:local_image_provider/local_image.dart';
import 'package:local_image_provider/local_image_provider.dart';
import 'package:misstory/utils/ms_image_cache.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-10-22
///
class Picture extends StatefulWidget {
  final LocalImage localImage;
  final double width, height;
  final double radius;
  final Function onTap;
  final BoxFit fit;
  final ExtendedImageMode mode;

  Picture(this.localImage,
      {this.width = 200,
      this.height = 200,
      this.radius = 6,
      this.onTap,
      this.fit = BoxFit.cover,
      this.mode = ExtendedImageMode.none});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PictureState();
  }
}

class _PictureState extends State<Picture> with TickerProviderStateMixin {
  LocalImage _localImage;
  bool _isLoading = false;
  StreamSubscription _subscription;
  Uint8List _imageMemory;
  AnimationController _controller;
  Animation animation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    animation = CurvedAnimation(parent: _controller, curve: Curves.easeInBack);
    _localImage = widget.localImage;
    _imageMemory = _localImage.bytes;
    if (!_isLoading) {
      _loadImage();
    }
  }

  _loadImage() {
    _isLoading = true;
    Uint8List list = MSImageCache().getImageCache(_getKey());
    if (list != null) {
      _imageMemory = list;
      _isLoading = false;
      if (mounted) {
        setState(() {});
      }
    } else {
      _subscription = Stream.fromFuture(LocalImageProvider().imageBytes(
        Platform.isAndroid ? _localImage.path : _localImage.id,
        widget.width.toInt(),
        widget.height.toInt(),
      )).listen((value) {
        _imageMemory = value;
        _localImage.bytes = _imageMemory;
        MSImageCache().addCache(_getKey(), _imageMemory);
        _isLoading = false;
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  String _getKey() {
    return "${_localImage.id}_${widget.width}x${widget.height}";
  }

  @override
  Widget build(BuildContext context) {
//    print("==========${_imageMemory?.length}");
    _controller.forward();
    // TODO: implement build
    return GestureDetector(
      onTap: _imageMemory == null ? null : widget.onTap,
      child: FadeTransition(
        opacity: animation,
        child: _imageMemory == null
            ? Container(
                decoration: BoxDecoration(
                    color: Color(0xFFDDDDDD),
                    borderRadius:
                        BorderRadius.all(Radius.circular(widget.radius))),
//              child: Icon(
//                Icons.image,
//                color: Colors.grey,
//              ),
              )
            : ExtendedImage.memory(
                _imageMemory,
                fit: widget.fit,
                width: widget.width,
                height: widget.height,
                borderRadius: BorderRadius.all(Radius.circular(widget.radius)),
                shape: BoxShape.rectangle,
                mode: widget.mode,
              ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _subscription?.cancel();
    _controller.dispose();
    _isLoading = false;
    super.dispose();
  }
}
