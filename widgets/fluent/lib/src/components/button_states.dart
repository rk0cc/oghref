import 'package:fluent_ui/fluent_ui.dart';
import 'package:meta/meta.dart';

@internal
final class SingleButtonState<T> implements ButtonState<T> {
  final T value;

  const SingleButtonState(this.value);

  @override
  T resolve(Set<ButtonStates> states) {
    return value;
  }
}
