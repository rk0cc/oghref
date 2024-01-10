part of '../fetch/fetch.dart';

/// Combined notations of [StateError] and [ArgumentError] that
/// [MetaPropertyParser.propertyNamePrefix] is an empty [String].
/// 
/// This exception will be happened in [MetaFetch] only when
/// related [MetaPropertyParser] is attempted to interact with
/// [MetaFetch].
final class UnnamedMetaPropertyPrefixError extends StateError
    implements ArgumentError {
  final MetaPropertyParser _parser;

  /// Name of invalid argument.
  @override
  final String? name;

  UnnamedMetaPropertyPrefixError._(this._parser,
      {this.name, String message =
          "This parser contains unnamed property prefix which should not be accepted."})
      : super(message);

  /// An invalid value that causes [UnnamedMetaPropertyPrefixError]
  /// thrown.
  /// 
  /// It typically is [MetaPropertyParser.propertyNamePrefix]
  /// which occured if contains nothing.
  @override
  // ignore: return_of_do_not_store
  get invalidValue => _parser.propertyNamePrefix;

  /// Return [Type] of [MetaPropertyParser] that causing
  /// this error thrown.
  Type get parserType => _parser.runtimeType;

  @override
  String toString() {
    StringBuffer buf = StringBuffer();

    buf
      ..write("UnnamedMetaPropertyPrefixError: ")
      ..writeln(message)
      ..writeln()
      ..write("Parser type: ")
      ..writeln(parserType);

    return buf.toString();
  }
}
