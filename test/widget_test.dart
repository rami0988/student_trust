import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_template/core/network/endpoints.dart';

void main() {
  test('Endpoints.baseURL appends the unversioned /api path to the server URL', () {
    Endpoints.setServerUrl('https://example.com');

    expect(Endpoints.baseURL, 'https://example.com/api');
  });
}
