import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_template/core/network/endpoints.dart';

void main() {
  test('template uses the mock API by default', () {
    Endpoints.setServerUrl(Endpoints.mockServerUrl);

    expect(Endpoints.isMockServer, isTrue);
    expect(Endpoints.baseURL, 'https://mock.example.com/api/v1');
  });
}
