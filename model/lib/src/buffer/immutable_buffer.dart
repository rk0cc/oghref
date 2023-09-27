import 'package:meta/meta.dart';

/// A mixin for constructing immutable object in buffer.
/// 
/// The returned object [T] ideally should be annotated
/// with [Immutable] (from `meta` library) already.
abstract mixin class ImmutableBuffer<T extends Object> {
  bool _initialized = false;

  /// Determine this buffer has been initalized already.
  /// 
  /// This getter designs to prevent data assigned before
  /// specified conditions.
  bool get isInitalized => _initialized;

  /// Notify [ImmutableBuffer] that it has been [isInitalized]
  /// already.
  /// 
  /// If want to add additional features in this method,
  /// it is required to call super method to ensure
  /// [isInitalized] work normally.
  @mustCallSuper
  void markInitalized() {
    _initialized = true;
  }

  /// Apply all defined properties in [ImmutableBuffer] into
  /// [Immutable] object [T].
  /// 
  /// All primitive data type should be parsed to [T]'s constructor
  /// directly and [Iterable] related field must be assigned with deep copied
  /// value (e.g. [List.of]).
  T compile();

  /// Wipe all assigned data to [Null] and clear all stored elements
  /// in [Iterable].
  void reset();
}
