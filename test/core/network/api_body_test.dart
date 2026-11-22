import 'package:flutter_test/flutter_test.dart';
import 'package:monthra/core/network/api_body.dart';
import 'package:monthra/core/network/api_exception.dart';

void main() {
  int count(Map<String, Object?> json) => json['count']! as int;

  test('reads a body with the given decoder', () {
    expect(readJson({'count': 3}, count), 3);
  });

  test('an empty body is unexpected', () {
    expect(
      () => readJson<int>(null, count),
      throwsA(isA<UnexpectedApiException>()),
    );
  });

  test('a body the decoder refuses is unexpected', () {
    expect(
      () => readJson({'count': 'three'}, count),
      throwsA(isA<UnexpectedApiException>()),
    );
  });
}
