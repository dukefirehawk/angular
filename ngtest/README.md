# ngtest

[![Pub package](https://img.shields.io/pub/v/ngtest.svg)](https://pub.dev/packages/ngtest)
[![Build Status](https://img.shields.io/github/actions/workflow/status/angulardart-community/angular/dart.yml?branch=master)](https://github.com/angulardart-community/angular/actions/workflows/dart.yml)
[![Gitter](https://img.shields.io/gitter/room/angulardart/community)](https://gitter.im/angulardart/community)

Testing infrastructure for [AngularDart][webdev_angular], used with the
[`build_runner` package][build_runner].

See <https://github.com/angulardart-community> for current updates on this project.

Documentation and examples:

* [`_tests/test/`][test_folder] (tests for the main dart-lang/angular package)

[build_runner]: https://pub.dev/packages/build_runner
[test_folder]: https://github.com/angulardart-community/angular/tree/master/_tests/test
[webdev_angular]: https://pub.dev/packages/ngdart

Additional resources:

* Community/support: [Gitter chat room]

[Gitter chat room]: https://gitter.im/angulardart/community

## Overview

`ngtest` is a library for writing tests for AngularDart components.

```dart
// Assume this is 'my_test.dart'.
import 'my_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('should render "Hello World"', () async {
    final testBed = NgTestBed<HelloWorldComponent>();
    final testFixture = await testBed.create();
    expect(testFixture.text, 'Hello World');
    await testFixture.update((c) => c.name = 'Universe');
    expect(testFixture.text, 'Hello Universe');
  });
}

@Component(selector: 'test', template: 'Hello {{name}}')
class HelloWorldComponent {
  String name = 'World';
}
```

To use `ngtest`, configure your package's `pubspec.yaml` as follows:

```yaml
# Use the latest versions if possible.
dev_dependencies:
  build_runner: ^2.3.0
  build_test: ^2.1.0
  build_web_compilers: ^4.1.0
```

**IMPORTANT**: `ngtest` will not run without these dependencies set.

To run tests, use `dart run build_runner test`. It automatically compiles your templates and annotations with AngularDart, and then compiles all of the Dart code to JavaScript in order to run browser tests. Here's an example of using Chrome with Dartdevc:

```bash
dart run build_runner test -- -p chrome
```

For more information using `dart run build_runner test`, see the documentation:
<https://github.com/dart-lang/build/tree/master/build_runner#built-in-commands>

## Debug

* `.dart_tool/build/entrypoint/build.dart`
