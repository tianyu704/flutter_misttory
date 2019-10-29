import 'dart:typed_data';

///
/// Create by Hugo.Guo
/// Date: 2019-10-23
///
class MSImageCache {
  static final MSImageCache _instance = MSImageCache._internal();

  factory MSImageCache() => _instance;

  MSImageCache._internal();

  Map<String, Uint8List> imageCache = Map<String, Uint8List>();
  List<String> keys = List<String>();
  final num MAX_SIZE = 1024 * 1024 * 20;
  num size = 0;

  void addCache(String key, Uint8List value) {
    if (value == null) {
      return;
    }
    if (imageCache == null) {
      imageCache = Map<String, Uint8List>();
    }
    if (!imageCache.containsKey(key)) {
      imageCache[key] = value;
      size += value.length;
//      print((size / 1024 / 1024));
      keys.add(key);
      _judgeSize();
    }
  }

  void removeCache(String key) {
    if (imageCache != null && imageCache.containsKey(key)) {
      imageCache.remove(key);
    }
  }

  Uint8List getImageCache(String key) {
    if (imageCache.containsKey(key)) {
      return imageCache[key];
    } else {
      return null;
    }
  }

  void clear() {
    imageCache.clear();
    imageCache = null;
  }

  void _judgeSize() {
    if (size > MAX_SIZE) {
      size -= imageCache[keys.first].length;
      imageCache.remove(keys.first);
      keys.removeAt(0);
      _judgeSize();
    }
  }
}
