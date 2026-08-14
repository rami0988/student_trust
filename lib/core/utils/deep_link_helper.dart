import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

/// Deep-link plumbing (app_links).
///
/// TODO(migration): wire [_handleUri] to a real link scheme (e.g. a lesson or
/// worksheet share link) once one is defined — no deep links exist yet.
@lazySingleton
class DeepLinkHelper {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;
  final GlobalKey<NavigatorState> _navigatorKey;
  DeepLinkHelper(this._navigatorKey);
  bool _isInitial = false;

  void init() {
    if (_isInitial) return;
    _isInitial = true;
    _linkSub = _appLinks.uriLinkStream.listen(_handleUri);
  }

  void _handleUri(Uri uri) {
    final NavigatorState? navigator = _navigatorKey.currentState;
    if (navigator == null) return;
    // TODO(migration): implement once a real deep-link scheme exists.
  }

  void dispose() {
    _linkSub?.cancel();
  }
}
