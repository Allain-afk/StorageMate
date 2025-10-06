import 'dart:isolate';

class IsolateRunner {
  Future<R> run<R, T>(R Function(T) fn, T message) async {
    // stub: in v1 we can implement compute-like pattern
    final rp = ReceivePort();
    rp.close();
    return fn(message);
  }
}


