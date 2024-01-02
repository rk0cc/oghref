import 'package:fluent_ui/fluent_ui.dart';
import 'package:meta/meta.dart';

/// Extended class from [ButtonState] that it only show
/// a constant [value] no matter which [ButtonStates]
/// need to be [resolve].
@internal
final class SingleButtonState<T> implements ButtonState<T> {
  /// Constant value that will be returns.
  final T value;

  /// Create new [ButtonState] which only returns specific
  /// [value] no matter which [ButtonStates] is applied.
  const SingleButtonState(this.value);

  @override
  T resolve(Set<ButtonStates> states) {
    return value;
  }
}
