import 'package:dio/dio.dart';

import '../utils/logger.dart';
import 'endpoints.dart';

/// Serves fake responses shaped exactly like the real backend envelope
/// (`{success, message, data, meta}` → BaseModel) while
/// [Endpoints.isMockServer] is true, so the template runs end-to-end with
/// zero backend setup.
///
/// For list/detail requests it first tries to fetch real data from
/// jsonplaceholder.typicode.com and wraps it into the envelope; when offline
/// it falls back to locally generated items, so the app always works.
///
/// DELETE THIS FILE (and its registration in DioFactory) once you point
/// [Endpoints] at a real backend.
class MockApiInterceptor extends Interceptor {
  static const int _pageSize = 10;
  static const int _lastPage = 5;
  static const Duration _simulatedLatency = Duration(milliseconds: 400);

  /// In-memory "database" for the like toggle, so optimistic updates survive
  /// navigation while the app is running.
  static final Map<int, bool> _likes = {};

  final Dio _jsonPlaceholderDio = Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String path = options.path;

    if (path == Endpoints.exampleItems && options.method == 'GET') {
      final int page = int.tryParse('${options.queryParameters['page'] ?? 1}') ?? 1;
      final List<Map<String, dynamic>> items = await _getItemsPage(page);
      await Future.delayed(_simulatedLatency);
      return handler.resolve(
        _envelope(
          options,
          data: items,
          meta: {
            'current_page': page,
            'last_page': _lastPage,
            'per_page': _pageSize,
            'total': _pageSize * _lastPage,
          },
        ),
      );
    }

    final RegExpMatch? detailsMatch = RegExp(r'^/example-items/(\d+)$').firstMatch(path);
    if (detailsMatch != null && options.method == 'GET') {
      final int id = int.parse(detailsMatch.group(1)!);
      final int page = ((id - 1) ~/ _pageSize) + 1;
      final List<Map<String, dynamic>> items = await _getItemsPage(page);
      final Map<String, dynamic> item = items.firstWhere(
        (item) => item['id'] == id,
        orElse: () => _localItem(id),
      );
      await Future.delayed(_simulatedLatency);
      return handler.resolve(_envelope(options, data: item));
    }

    final RegExpMatch? likeMatch = RegExp(r'^/example-items/(\d+)/like$').firstMatch(path);
    if (likeMatch != null) {
      final int id = int.parse(likeMatch.group(1)!);
      _likes[id] = options.method == 'PUT';
      await Future.delayed(_simulatedLatency);
      return handler.resolve(_envelope(options, data: null));
    }

    // Unknown endpoint: let the request go through (and fail) normally.
    handler.next(options);
  }

  Future<List<Map<String, dynamic>>> _getItemsPage(int page) async {
    try {
      final Response<List<dynamic>> response = await _jsonPlaceholderDio.get(
        '/posts',
        queryParameters: {'_page': page, '_limit': _pageSize},
      );
      final List<dynamic> posts = response.data ?? [];
      if (posts.isEmpty) throw StateError('Empty jsonplaceholder response');
      return posts
          .map(
            (post) => <String, dynamic>{
              'id': post['id'],
              'title': post['title'],
              'description': post['body'],
              'is_liked': _likes[post['id']] ?? false,
            },
          )
          .toList();
    } catch (error) {
      Logger.warning(
        name: 'MockApiInterceptor',
        'jsonplaceholder unreachable, serving offline fixtures. ($error)',
      );
      return List.generate(_pageSize, (index) {
        final int id = (page - 1) * _pageSize + index + 1;
        return _localItem(id);
      });
    }
  }

  Map<String, dynamic> _localItem(int id) => <String, dynamic>{
    'id': id,
    'title': 'Example item #$id (offline)',
    'description': 'This item was generated locally because the fake remote API '
        '(jsonplaceholder.typicode.com) could not be reached.',
    'is_liked': _likes[id] ?? false,
  };

  Response<Map<String, dynamic>> _envelope(
    RequestOptions options, {
    required dynamic data,
    Map<String, dynamic>? meta,
  }) {
    return Response<Map<String, dynamic>>(
      requestOptions: options,
      statusCode: 200,
      data: <String, dynamic>{
        'success': true,
        'message': 'OK',
        'data': data,
        'meta': ?meta,
      },
    );
  }
}
