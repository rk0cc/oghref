import 'package:meta/meta.dart';

abstract mixin class ImmutableBuffer<T extends Object> {
  bool _initialized = false;

  bool get isInitalized => _initialized;

  @mustCallSuper
  void markInitalized() {
    _initialized = true;
  }

  T compile();
  void reset();
}
