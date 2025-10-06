import 'dart:isolate';

class IsolateRunner {
  Future<R> run<R, T>(R Function(T) fn, T message) async {
    final p = ReceivePort();
    await Isolate.spawn<_IsoMsg<R, T>>(_entry<R, T>, _IsoMsg<R, T>(fn, message, p.sendPort));
    final result = await p.first as R;
    p.close();
    return result;
  }

  static void _entry<R, T>(_IsoMsg<R, T> msg) {
    final result = msg.fn(msg.message);
    msg.port.send(result);
  }
}

class _IsoMsg<R, T> {
  const _IsoMsg(this.fn, this.message, this.port);
  final R Function(T) fn;
  final T message;
  final SendPort port;
}


