import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;

class _DigestCollector implements Sink<crypto.Digest> {
  crypto.Digest? _value;
  crypto.Digest get value => _value!;
  @override
  void add(crypto.Digest data) {
    _value = data;
  }

  @override
  void close() {}
}

class HashingUtils {
  static const int defaultChunkSizeBytes = 1024 * 128; // 128 KB

  static Future<String> md5File(File file, {int chunkSize = defaultChunkSizeBytes}) async {
    final collector = _DigestCollector();
    final input = crypto.md5.startChunkedConversion(collector);
    await _consumeFile(file, input, chunkSize: chunkSize);
    input.close();
    return collector.value.toString();
  }

  static Future<String> sha256File(File file, {int chunkSize = defaultChunkSizeBytes}) async {
    final collector = _DigestCollector();
    final input = crypto.sha256.startChunkedConversion(collector);
    await _consumeFile(file, input, chunkSize: chunkSize);
    input.close();
    return collector.value.toString();
  }

  static Future<String> quickHashPrefix(File file, {int prefixBytes = 64 * 1024}) async {
    final raf = await file.open();
    try {
      final toRead = file.lengthSync() < prefixBytes ? file.lengthSync() : prefixBytes;
      final data = await raf.read(toRead);
      return crypto.md5.convert(data).toString();
    } finally {
      await raf.close();
    }
  }

  static Stream<List<int>> _readFileChunks(File file, {int chunkSize = defaultChunkSizeBytes}) async* {
    final raf = await file.open();
    try {
      final length = await file.length();
      int offset = 0;
      while (offset < length) {
        final remaining = length - offset;
        final size = remaining < chunkSize ? remaining : chunkSize;
        final bytes = await raf.read(size);
        if (bytes.isEmpty) break;
        yield bytes;
        offset += bytes.length;
      }
    } finally {
      await raf.close();
    }
  }

  static Future<void> _consumeFile(File file, ByteConversionSink sink, {int chunkSize = defaultChunkSizeBytes}) async {
    await for (final bytes in _readFileChunks(file, chunkSize: chunkSize)) {
      sink.add(bytes);
    }
  }
}


