/// Defines the memory management and instance disposal behaviors of GetX.
///
/// GetX automatically disposes unused controllers from memory using
/// one of these configurations.
enum SmartManagement {
  /// The default management behavior.
  ///
  /// Disposes classes that are not currently being used by any active route,
  /// unless they were marked as permanent.
  full,

  /// Only disposes controllers started inside a builder (`init` parameter)
  /// or loaded via a route `Binding` with `Get.lazyPut()`.
  ///
  /// Instances created via `Get.put()` or other direct injection methods
  /// will not be automatically disposed.
  onlyBuilder,

  /// Disposes dependencies when they are no longer used (similar to [full]),
  /// but keeps their factory/builder callback in memory.
  ///
  /// This allows GetX to recreate the dependency on demand if it is requested again.
  keepFactory,
}
