import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'offline_crypto.dart';

/// A long-lived background isolate that decrypts lesson chunks on demand.
///
/// Playback asks for chunks continuously — sequentially while watching, at
/// random while seeking — so spawning an isolate per chunk would pay startup
/// cost on every read. One worker stays up for as long as the media server
/// runs, and decrypted bytes come back as [TransferableTypedData], so a 1 MiB
/// chunk moves to the UI isolate without being copied.
class OfflineDecryptWorker {
  OfflineDecryptWorker._(this._isolate, this._inbox, this._requests);

  final Isolate _isolate;
  final ReceivePort _inbox;
  final SendPort _requests;
  final Map<int, Completer<Uint8List>> _pending = {};
  int _nextId = 0;
  bool _disposed = false;

  static Future<OfflineDecryptWorker> spawn() async {
    final ReceivePort inbox = ReceivePort();
    final Isolate isolate = await Isolate.spawn(_workerMain, inbox.sendPort, debugName: 'offline-decrypt');
    final Completer<SendPort> ready = Completer<SendPort>();
    late final OfflineDecryptWorker worker;
    inbox.listen((dynamic message) {
      if (message is SendPort) {
        ready.complete(message);
      } else {
        worker._onResponse(message as List<dynamic>);
      }
    });
    worker = OfflineDecryptWorker._(isolate, inbox, await ready.future);
    return worker;
  }

  /// Decrypts chunk [index] of [source]. Fails with
  /// [ChunkAuthenticationException] when the chunk doesn't verify, and with
  /// [OfflineDecryptException] for anything else (unreadable file, etc.).
  Future<Uint8List> decrypt(OfflinePlaybackSource source, int index) {
    if (_disposed) return Future<Uint8List>.error(StateError('decrypt worker disposed'));
    final int id = _nextId++;
    final Completer<Uint8List> completer = Completer<Uint8List>();
    _pending[id] = completer;
    _requests.send(<dynamic>[id, source, index]);
    return completer.future;
  }

  void _onResponse(List<dynamic> message) {
    final Completer<Uint8List>? completer = _pending.remove(message[0] as int);
    if (completer == null) return;
    switch (message[1] as String) {
      case 'ok':
        completer.complete((message[2] as TransferableTypedData).materialize().asUint8List());
      case 'auth':
        completer.completeError(ChunkAuthenticationException(message[2] as int));
      default:
        completer.completeError(OfflineDecryptException(message[2] as String));
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _isolate.kill(priority: Isolate.immediate);
    _inbox.close();
    for (final Completer<Uint8List> c in _pending.values) {
      c.completeError(StateError('decrypt worker disposed'));
    }
    _pending.clear();
  }
}

/// A chunk could not be read or decrypted for a reason other than a failed
/// integrity check (missing file, I/O error, bad v1 padding).
class OfflineDecryptException implements Exception {
  final String message;
  const OfflineDecryptException(this.message);

  @override
  String toString() => 'OfflineDecryptException($message)';
}

void _workerMain(SendPort replies) {
  final ReceivePort requests = ReceivePort();
  replies.send(requests.sendPort);
  requests.listen((dynamic raw) {
    final List<dynamic> message = raw as List<dynamic>;
    final int id = message[0] as int;
    final OfflinePlaybackSource source = message[1] as OfflinePlaybackSource;
    final int index = message[2] as int;
    try {
      final Uint8List plain = decryptSourceChunk(source, index);
      replies.send(<dynamic>[
        id,
        'ok',
        TransferableTypedData.fromList(<TypedData>[plain]),
      ]);
    } on ChunkAuthenticationException catch (e) {
      replies.send(<dynamic>[id, 'auth', e.chunkIndex]);
    } catch (e) {
      replies.send(<dynamic>[id, 'error', e.toString()]);
    }
  });
}
