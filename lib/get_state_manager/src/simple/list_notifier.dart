import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:getxify/get_common/obx_error.dart';

/// Callback function to remove a listener.
///
/// This is returned by [addListener] and can be called to remove
/// the listener from the notifier.
typedef Disposer = void Function();

/// Callback function to update state.
///
/// This is used to trigger widget rebuilds when state changes.
typedef GetStateUpdate = void Function();

/// A notifier that combines single and group listener capabilities.
///
/// This class extends [Listenable] and provides both single listener
/// functionality (via [ListNotifierSingleMixin]) and group listener
/// functionality (via [ListNotifierGroupMixin]). It's the base notifier
/// used by GetX controllers.
class ListNotifier extends Listenable
    with ListNotifierSingleMixin, ListNotifierGroupMixin {}

/// A notifier with single listener support.
///
/// This is a type alias for [ListNotifier] with only the
/// [ListNotifierSingleMixin] mixed in, providing basic single
/// listener functionality.
class ListNotifierSingle = ListNotifier with ListNotifierSingleMixin;

/// A notifier with group listener support identified by ID.
///
/// This is a type alias for [ListNotifier] with only the
/// [ListNotifierGroupMixin] mixed in, providing group listener
/// functionality where listeners can be grouped by ID.
class ListNotifierGroup = ListNotifier with ListNotifierGroupMixin;

/// Mixin that adds single listener functionality to [Listenable].
///
/// This mixin provides the core listener management for a single
/// listener group, including [addListener], [removeListener], and
/// [containsListener] methods.
mixin ListNotifierSingleMixin on Listenable {
  List<GetStateUpdate>? _updaters = <GetStateUpdate>[];

  @override
  Disposer addListener(GetStateUpdate listener) {
    assert(_debugAssertNotDisposed());
    _updaters!.add(listener);
    return () => _updaters!.remove(listener);
  }

  bool containsListener(GetStateUpdate listener) {
    return _updaters?.contains(listener) ?? false;
  }

  @override
  void removeListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    _updaters!.remove(listener);
  }

  /// Notifies all listeners to update.
  ///
  /// This method triggers all registered listeners to call their
  /// update callbacks. It's typically called when the state changes.
  @protected
  void refresh() {
    assert(_debugAssertNotDisposed());
    _notifyUpdate();
  }

  /// Reports that this notifier was read.
  ///
  /// This is used by the reactive system to track dependencies.
  @protected
  void reportRead() {
    Notifier.instance.read(this);
  }

  /// Reports a disposer callback to the global notifier.
  ///
  /// This is used to register cleanup callbacks that will be
  /// called when the notifier is disposed.
  @protected
  void reportAdd(VoidCallback disposer) {
    Notifier.instance.add(disposer);
  }

  void _notifyUpdate() {
    final list = _updaters?.toList() ?? [];

    for (var element in list) {
      element();
    }
  }

  bool get isDisposed => _updaters == null;

  bool _debugAssertNotDisposed() {
    assert(() {
      if (isDisposed) {
        throw FlutterError(
          '''A $runtimeType was used after being disposed.\n
'Once you have called dispose() on a $runtimeType, it can no longer be used.''',
        );
      }
      return true;
    }());
    return true;
  }

  /// Returns the number of active listeners.
  int get listenersLength {
    assert(_debugAssertNotDisposed());
    return _updaters!.length;
  }

  /// Disposes the notifier and removes all listeners.
  ///
  /// After calling this method, the notifier can no longer be used.
  /// Any attempt to use it will throw an error.
  @mustCallSuper
  void dispose() {
    assert(_debugAssertNotDisposed());
    _updaters = null;
  }
}

/// Mixin that adds group listener functionality to [Listenable].
///
/// This mixin provides listener management where listeners can be
/// grouped by an ID. This allows for selective updates of specific
/// listener groups rather than all listeners.
mixin ListNotifierGroupMixin on Listenable {
  HashMap<Object?, ListNotifierSingleMixin>? _updatersGroupIds =
      HashMap<Object?, ListNotifierSingleMixin>();

  /// Notifies all listeners in a specific group.
  void _notifyGroupUpdate(Object id) {
    if (_updatersGroupIds!.containsKey(id)) {
      _updatersGroupIds![id]!._notifyUpdate();
    }
  }

  /// Reports that a listener group was read.
  @protected
  void notifyGroupChildrens(Object id) {
    assert(_debugAssertNotDisposed());
    Notifier.instance.read(_updatersGroupIds![id]!);
  }

  /// Checks if a listener group with the given ID exists.
  bool containsId(Object id) {
    return _updatersGroupIds?.containsKey(id) ?? false;
  }

  /// Refreshes only the listeners in a specific group.
  @protected
  void refreshGroup(Object id) {
    assert(_debugAssertNotDisposed());
    _notifyGroupUpdate(id);
  }

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_updatersGroupIds == null) {
        throw FlutterError(
          '''A $runtimeType was used after being disposed.\n
'Once you have called dispose() on a $runtimeType, it can no longer be used.''',
        );
      }
      return true;
    }());
    return true;
  }

  /// Removes a listener from a specific group.
  void removeListenerId(Object id, VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    if (_updatersGroupIds!.containsKey(id)) {
      _updatersGroupIds![id]!.removeListener(listener);
    }
  }

  /// Disposes all listener groups.
  @mustCallSuper
  void dispose() {
    assert(_debugAssertNotDisposed());
    _updatersGroupIds?.forEach((key, value) => value.dispose());
    _updatersGroupIds = null;
  }

  /// Adds a listener to a specific group identified by [key].
  Disposer addListenerId(Object? key, GetStateUpdate listener) {
    _updatersGroupIds![key] ??= ListNotifierSingle();
    return _updatersGroupIds![key]!.addListener(listener);
  }

  /// Disposes a specific listener group.
  ///
  /// This removes the group from future updates. IDs are registered
  /// by widgets like `GetBuilder()` to link state changes with
  /// specific widgets.
  void disposeId(Object id) {
    _updatersGroupIds?[id]?.dispose();
    _updatersGroupIds!.remove(id);
  }
}

/// Singleton that manages reactive dependencies.
///
/// This class tracks which reactive variables are being read during
/// a widget build and automatically sets up the necessary listeners.
/// It's used internally by GetX's reactive system.
class Notifier {
  Notifier._();

  static Notifier? _instance;
  static Notifier get instance => _instance ??= Notifier._();

  NotifyData? _notifyData;

  /// Adds a disposer callback to the current notification data.
  void add(VoidCallback listener) {
    _notifyData?.disposers.add(listener);
  }

  /// Reads a notifier and sets up automatic listener tracking.
  void read(ListNotifierSingleMixin updaters) {
    final listener = _notifyData?.updater;
    if (listener != null && !updaters.containsListener(listener)) {
      updaters.addListener(listener);
      add(() => updaters.removeListener(listener));
    }
  }

  /// Executes a builder function with reactive tracking.
  ///
  /// This method sets up the tracking context, executes the builder,
  /// and ensures that reactive dependencies were properly tracked.
  T append<T>(NotifyData data, T Function() builder) {
    _notifyData = data;
    final result = builder();
    if (data.disposers.isEmpty && data.throwException) {
      throw const ObxError();
    }
    _notifyData = null;
    return result;
  }
}

/// Data container for reactive notification tracking.
///
/// This class holds the updater callback and list of disposers
/// that are used during reactive tracking in widgets.
class NotifyData {
  const NotifyData({
    required this.updater,
    required this.disposers,
    this.throwException = true,
  });

  /// The callback to update the widget when dependencies change.
  final GetStateUpdate updater;

  /// List of disposers to clean up listeners.
  final List<VoidCallback> disposers;

  /// Whether to throw an exception if no dependencies were tracked.
  final bool throwException;
}
