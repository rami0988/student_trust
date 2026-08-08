import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../features/example_feature/presentation/pages/example_item_details_args.dart';
import '../extensions/navigation.dart';
import '../routing/routes.dart';

/// Deep-link plumbing (app_links).
///
/// TODO(template): adjust [_handleUri] to your own link scheme. The example
/// below handles `https://your.domain/app/item/<id>` by opening the example
/// item details page.
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
    final List<String> segments = uri.pathSegments;

    if (segments.length >= 2 && segments[segments.length - 2] == 'item') {
      final int? id = int.tryParse(segments.last);
      if (id != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final BuildContext? context = _navigatorKey.currentState?.context;
          if (context == null) return;
          context.pushNamed(
            Routes.exampleItemDetails,
            arguments: ExampleItemDetailsArgs(itemId: id),
          );
        });
      }
    }
  }

  void dispose() {
    _linkSub?.cancel();
  }
}
