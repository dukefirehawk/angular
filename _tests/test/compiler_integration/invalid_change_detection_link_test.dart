import 'package:test/test.dart';
import 'package:_tests/compiler.dart';
import 'package:ngcompiler/v2/context.dart';

const ngExperimentalImport = 'package:$ngPackage/experimental.dart';

void main() {
  CompileContext.overrideForTesting();

  group('@changeDetectionLink', () {
    test('should compile on OnPush component', () async {
      await compilesNormally("""
        import '$ngImport';
        import '$ngExperimentalImport';

        @changeDetectionLink
        @Component(
          selector: 'test',
          template: '',
          changeDetection: ChangeDetectionStrategy.onPush,
        )
        class OnPushComponent {}
      """);
    });

    test("shouldn't compile on CheckAlways component", () async {
      await compilesExpecting("""
        import '$ngImport';
        import '$ngExperimentalImport';

        @changeDetectionLink
        @Component(
          selector: 'test',
          template: '',
        )
        class CheckAlwaysComponent {}
      """, errors: [
        allOf([
          contains(
            'Only supported on components that use "OnPush" change detection',
          ),
          containsSourceLocation(4, 9),
        ]),
      ]);
    });

    test("shouldn't compile on directive", () async {
      await compilesExpecting("""
        import '$ngImport';
        import '$ngExperimentalImport';

        @changeDetectionLink
        @Directive(selector: '[test]')
        class TestDirective {}
      """, errors: [
        allOf([
          contains(
            'Only supported on components that use "OnPush" change detection',
          ),
          containsSourceLocation(4, 9),
        ]),
      ]);
    });
  });
}
