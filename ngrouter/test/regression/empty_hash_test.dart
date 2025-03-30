import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:ngrouter/ngrouter.dart';

class MockPlatformLocation extends Mock implements PlatformLocation {}

void main() {
  late LocationStrategy locationStrategy;
  late MockPlatformLocation platformLocation;

  group("empty URL doesn't overwrite query parameters", () {
    setUp(() {
      platformLocation = MockPlatformLocation();
      locationStrategy = HashLocationStrategy(platformLocation, null);
      when(platformLocation.pathname).thenReturn('/foo');
      when(platformLocation.search).thenReturn('?bar=baz');
    });

    test('on push', () {
      locationStrategy.pushState(null, '', '', '');
      verify(platformLocation.pushState(null, '', '/foo?bar=baz'));
    });

    test('on replace', () {
      locationStrategy.replaceState(null, '', '', '');
      verify(platformLocation.replaceState(null, '', '/foo?bar=baz'));
    });
  });
}
