import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';
import 'package:web/web.dart';

import 'clear_component_styles_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  // Note that `NgTestFixture.dipose()` invokes `debugClearComponentStyles()`.
  group('debugClearComponentStyles()', () {
    test('should clear component styles from DOM', () async {
      await expectTextFontStyle(
          ng.createItalicTextComponentFactory(), 'italic');
      await expectTextFontStyle(
          ng.createNormalTextComponentFactory(), 'normal');
    });
    test('should allow reloading the same component styles', () async {
      await expectTextFontStyle(
          ng.createItalicTextComponentFactory(), 'italic');
      await expectTextFontStyle(
          ng.createItalicTextComponentFactory(), 'italic');
    });
  });
}

/// Loads [ComponentFactory] and expects its text to have [fontStyle].
Future<void> expectTextFontStyle(
  ComponentFactory<Object> componentFactory,
  String fontStyle,
) async {
  final testBed = NgTestBed(componentFactory);
  final testFixture = await testBed.create();
  final text = testFixture.rootElement.querySelector('.text');
  expect(
      window.getComputedStyle(text).getPropertyValue('font-style'), fontStyle);
  return testFixture.dispose();
}

@Component(
  selector: 'test',
  template: '<p class="text"></p>',
  styles: [
    // Intentionally unscoped to leak between test fixtures if not cleared.
    '''
      ::ng-deep .text {
        font-style: italic;
      }
    ''',
  ],
)
class ItalicTextComponent {}

@Component(
  selector: 'test',
  template: '<p class="text"></p>',
)
class NormalTextComponent {}
