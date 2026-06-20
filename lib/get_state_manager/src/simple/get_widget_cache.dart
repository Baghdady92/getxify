import 'package:flutter/widgets.dart';

/// Abstract widget that provides caching capabilities for GetX widgets.
///
/// This widget extends [Widget] and creates a [GetWidgetCacheElement] that
/// manages a [WidgetCache] instance. The cache provides lifecycle callbacks
/// (onInit, onClose) and a build method for efficient widget rebuilding.
///
/// Subclasses must implement [createWidgetCache] to provide the specific
/// cache implementation.
abstract class GetWidgetCache extends Widget {
  const GetWidgetCache({super.key});

  @override
  GetWidgetCacheElement createElement() => GetWidgetCacheElement(this);

  /// Creates the [WidgetCache] instance for this widget.
  ///
  /// This method is called when the element is created and should return
  /// a new instance of the cache that will manage this widget's state.
  @protected
  @factory
  WidgetCache createWidgetCache();
}

/// Element for [GetWidgetCache] that manages the widget cache lifecycle.
///
/// This element extends [ComponentElement] and integrates with a [WidgetCache]
/// instance to provide lifecycle management. It calls [onInit] when mounted,
/// [onClose] when unmounted, and delegates building to the cache.
class GetWidgetCacheElement extends ComponentElement {
  /// Creates a new element with the associated widget cache.
  GetWidgetCacheElement(GetWidgetCache widget)
    : cache = widget.createWidgetCache(),
      super(widget) {
    cache._element = this;
    cache._widget = widget;
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    cache.onInit();
    super.mount(parent, newSlot);
  }

  @override
  Widget build() => cache.build(this);

  /// The cache instance that manages this element's state.
  final WidgetCache<GetWidgetCache> cache;

  @override
  void activate() {
    super.activate();
    markNeedsBuild();
  }

  @override
  void unmount() {
    super.unmount();
    cache.onClose();
    cache._element = null;
  }
}

/// Abstract cache class for managing widget state and lifecycle.
///
/// This class provides a caching mechanism for [GetWidgetCache] widgets.
/// It offers lifecycle callbacks ([onInit], [onClose]) and a build method
/// for efficient widget rebuilding. The generic type [T] ensures type-safe
/// access to the associated widget.
///
/// Subclasses should override [build] to provide the widget content and
/// optionally override [onInit] and [onClose] for lifecycle logic.
abstract class WidgetCache<T extends GetWidgetCache> {
  /// The associated widget instance.
  T? get widget => _widget;
  T? _widget;

  /// The build context for this cache.
  BuildContext? get context => _element;

  GetWidgetCacheElement? _element;

  /// Called when the cache is initialized (widget is mounted).
  ///
  /// Override this method to perform initialization logic such as
  /// setting up controllers, listeners, or other resources.
  @protected
  @mustCallSuper
  void onInit() {}

  /// Called when the cache is disposed (widget is unmounted).
  ///
  /// Override this method to perform cleanup logic such as
  /// disposing controllers, closing streams, or releasing resources.
  @protected
  @mustCallSuper
  void onClose() {}

  /// Builds the widget content for this cache.
  ///
  /// This method is called by the element's build method and should
  /// return the widget tree to display.
  @protected
  Widget build(BuildContext context);
}
