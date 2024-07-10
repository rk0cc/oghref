import 'package:fluent_ui/fluent_ui.dart';
import 'package:meta/meta.dart';

/// Extended class from [WidgetStateProperty] that it only show
/// a constant [value] no matter which [WidgetState]
/// need to be [resolve].
@internal
final class SingleButtonState<T> implements WidgetStateProperty<T> {
  /// Constant value that will be returns.
  final T value;

  /// Create new [WidgetStateProperty] which only returns specific
  /// [value] no matter which [WidgetState] is applied.
  const SingleButtonState(this.value);

  @override
  T resolve(Set<WidgetState> states) {
    return value;
  }
}
