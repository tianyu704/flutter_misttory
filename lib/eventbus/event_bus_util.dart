import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:misstory/eventbus/refresh_day.dart';
import 'package:misstory/eventbus/refresh_after_pic_finish.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-06-26
///

class EventBusUtil {

  static fireRefreshDay() {
    eventBus.fire(RefreshDay());
  }

  static fireConvertAfterPictureFinish() {
    eventBus.fire(ConvertAfterPictureFinish());
  }

  static StreamSubscription<T> listen<T>(void onData(T event)) {
    return eventBus.on<T>().listen(onData);
  }
}

EventBus eventBus = EventBus();
