import 'package:flutter_test/flutter_test.dart';

import 'package:aura_coach_ai/features/auth/providers/auth_provider.dart';

void main() {
  test('AuthStatus has expected values', () {
    expect(AuthStatus.values.length, 3);
    expect(AuthStatus.values, contains(AuthStatus.unknown));
    expect(AuthStatus.values, contains(AuthStatus.authenticated));
    expect(AuthStatus.values, contains(AuthStatus.unauthenticated));
  });

  test('AuthMethod has expected values', () {
    expect(AuthMethod.values.length, 3);
    expect(AuthMethod.values, contains(AuthMethod.google));
    expect(AuthMethod.values, contains(AuthMethod.apple));
    expect(AuthMethod.values, contains(AuthMethod.guest));
  });
}
