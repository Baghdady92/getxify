/// An interface to define dependency injection rules for routes or specific flows.
///
/// Classes implementing [BindingsInterface] override the [dependencies] method
/// to register controllers, services, or other objects (typically via `Get.put`,
/// `Get.lazyPut`, or using `Bind` widgets) before a route/page is built or
/// when entering a specific scope.
abstract class BindingsInterface<T> {
  /// Defines and registers dependencies.
  ///
  /// This method is called to execute dependency injection operations, such as
  /// registering services or controllers. It returns the configured type [T],
  /// representing the registered resources (for example, a list of `Bind` widgets).
  T dependencies();
}

/// A callback used to lazily initialize or register bindings.
typedef BindingBuilderCallback = void Function();
