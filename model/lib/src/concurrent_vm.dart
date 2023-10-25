import 'dart:isolate';

Future<bool> createIsolateStreamOperation<T>(
    Stream<T> stream, void Function(T data) onData) async {
      
  await Isolate.run<void>(() async {
    await for (T data in stream) {
      onData(data);
    }
  });

  return true;
}
