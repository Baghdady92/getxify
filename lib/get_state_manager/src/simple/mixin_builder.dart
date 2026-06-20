import 'package:flutter/material.dart';

import '../rx_flutter/rx_obx_widget.dart';
import 'get_controllers.dart';
import 'get_state.dart';

/// A widget that combines GetBuilder and Obx for reactive state management.
///
/// This widget provides both the lifecycle management of GetBuilder
/// and the reactive updates of Obx. It's useful when you want to
/// combine both approaches in a single widget.
class MixinBuilder<T extends GetxController> extends StatelessWidget {
  /// Builder function that creates the widget tree.
  final Widget Function(T) builder;

  /// Whether the controller is global (shared across the app).
  final bool global;

  /// The ID for this widget instance.
  final String? id;

  /// Whether to automatically remove the controller when the widget is disposed.
  final bool autoRemove;

  /// Callback called when the state is initialized.
  final void Function(BindElement<T> state)? initState,
      dispose,
      didChangeDependencies;

  /// Callback called when the widget updates.
  final void Function(Binder<T> oldWidget, BindElement<T> state)?
  didUpdateWidget;

  /// The initial controller instance.
  final T? init;

  /// Creates a new MixinBuilder widget.
  const MixinBuilder({
    super.key,
    this.init,
    this.global = true,
    required this.builder,
    this.autoRemove = true,
    this.initState,
    this.dispose,
    this.id,
    this.didChangeDependencies,
    this.didUpdateWidget,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      init: init,
      global: global,
      autoRemove: autoRemove,
      initState: initState,
      dispose: dispose,
      id: id,
      didChangeDependencies: didChangeDependencies,
      didUpdateWidget: didUpdateWidget,
      builder: (controller) => Obx(() => builder.call(controller)),
    );
  }
}
