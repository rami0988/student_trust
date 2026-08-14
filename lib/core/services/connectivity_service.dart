import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

/// Watches and checks whether the device has real internet access.
///
/// Two layers:
///  * `connectivity_plus` reports interface-level changes (Wi-Fi/cell up or
///    down) — instant, but a device can be on Wi-Fi with no actual internet.
///  * A set of captive-portal probes verifies real reachability. Crucially the
///    probes do NOT depend solely on the app's own backend: if the backend /
///    ngrok tunnel is down that must surface as a normal API error later — not
///    as a fake "no internet" screen while the phone is clearly online.
///
/// Used by the offline/downloads features, which need a "real internet"
/// signal beyond the interceptor-level check in [NetworkInfo].
@lazySingleton
class ConnectivityService {
  ConnectivityService(this._connectivity)
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
          sendTimeout: const Duration(seconds: 4),
        ),
      );

  final Dio _dio;
  final Connectivity _connectivity;

  StreamController<bool>? _controller;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _pollTimer;
  bool _probing = false;
  bool? _lastOnline;

  /// How often real reachability is re-probed while [isOnline] has a
  /// listener. Interface events alone can never catch the common "still
  /// joined to Wi-Fi, but the router lost its WAN link" case — nothing
  /// changes at the interface level, so only an actual probe reveals it.
  /// Costs nothing when there is no interface at all (the probe is skipped).
  static const Duration pollInterval = Duration(seconds: 8);

  /// Lightweight "204 No Content" captive-portal probes as a real-reachability
  /// check independent of the app's own backend.
  static const List<String> _probes = [
    'https://clients3.google.com/generate_204',
    'https://www.gstatic.com/generate_204',
    'https://cloudflare.com/cdn-cgi/trace',
  ];

  /// Emits true/false whenever real connectivity changes. Driven by two
  /// sources: instant interface events from `connectivity_plus`, and a
  /// [pollInterval] timer that re-probes reachability (see that constant for
  /// why the events alone are not enough). Duplicate values are skipped, so
  /// listeners only ever see genuine transitions.
  Stream<bool> get isOnline {
    _controller ??= StreamController<bool>.broadcast(onListen: _startWatching, onCancel: _stopWatching);
    return _controller!.stream;
  }

  void _startWatching() {
    _subscription ??= _connectivity.onConnectivityChanged.listen(_evaluate);
    _pollTimer ??= Timer.periodic(pollInterval, (_) => _poll());
    // Seed an initial value immediately instead of making the first listener
    // wait a whole interval for the first reading.
    _poll();
  }

  void _stopWatching() {
    _subscription?.cancel();
    _subscription = null;
    _pollTimer?.cancel();
    _pollTimer = null;
    _lastOnline = null;
  }

  Future<void> _poll() async => _evaluate(await _connectivity.checkConnectivity());

  Future<void> _evaluate(List<ConnectivityResult> results) async {
    // A probe round can outlive the poll interval on a slow link; skip
    // overlapping runs so a stalled check can't pile up requests.
    if (_probing) return;
    _probing = true;
    try {
      final bool hasInterface = results.any((r) => r != ConnectivityResult.none);
      // No interface at all → offline for sure, skip the probe round-trip.
      final bool online = hasInterface && await checkConnection();
      _emit(online);
    } finally {
      _probing = false;
    }
  }

  void _emit(bool online) {
    if (online == _lastOnline) return;
    _lastOnline = online;
    _controller?.add(online);
  }

  /// One-time check for real internet access (probe-verified).
  Future<bool> checkConnection() async {
    // Fire all probes at once and succeed on the first one that answers, so a
    // single slow/blocked host doesn't hold up the whole check.
    final Completer<bool> completer = Completer<bool>();
    int pending = _probes.length;

    for (final String url in _probes) {
      _reachable(url).then((bool ok) {
        if (ok && !completer.isCompleted) {
          completer.complete(true);
        } else {
          pending--;
          if (pending == 0 && !completer.isCompleted) {
            completer.complete(false);
          }
        }
      });
    }

    return completer.future;
  }

  Future<bool> hasInternet() => checkConnection();

  Future<bool> _reachable(String url) async {
    try {
      await _dio.get(url, options: Options(validateStatus: (_) => true));
      return true; // any HTTP response proves we reached the internet
    } on DioException catch (e) {
      return e.response != null;
    } catch (_) {
      return false;
    }
  }
}
