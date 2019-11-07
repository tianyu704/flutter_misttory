import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:misstory/eventbus/refresh_progress.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-06-26
///

class EventBusUtil {
  static fireRefreshProgress(num total, num count) {
    eventBus.fire(RefreshProgress(total, count));
  }

  static StreamSubscription<T> listen<T>(void onData(T event)) {
    return eventBus.on<T>().listen(onData);
  }
}

EventBus eventBus = EventBus();
