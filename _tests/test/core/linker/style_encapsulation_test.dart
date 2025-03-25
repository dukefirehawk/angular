import 'package:web/web.dart';

import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';

import 'style_encapsulation_test.template.dart' as ng;

void main() {
  tearDown(() {
    document.head!.querySelectorAll('style').forEach((e) => e.remove());
    return disposeAnyRunningTest();
  });

  String failureReason(Element target) {
    final lastStyles = document.head!.querySelectorAll('style');
    final styleText = lastStyles.map((e) => e.text).join('\n');
    return 'HTML:\n\n${target.outerHtml}\nCSS:\n\n$styleText';
  }

  test('should encapsulate usages of [class]=', () async {
    final testBed =
        NgTestBed<TestSetClassProperty>(ng.createTestSetClassPropertyFactory());
    final fixture = await testBed.create();
    final element = fixture.rootElement.querySelector('div')!;
    expect(
      element.getComputedStyle().position,
      'absolute',
      reason: failureReason(element),
    );
  });

  test('should encapsulate usages of [attr.class]=', () async {
    final testBed = NgTestBed<TestSetClassAttribute>(
        ng.createTestSetClassAttributeFactory());
    final fixture = await testBed.create();
    final element = fixture.rootElement.querySelector('div')!;
    expect(
      element.getComputedStyle().position,
      'absolute',
      reason: failureReason(element),
    );
  });

  test('should support encapsulation piercing ::ng-deep', () async {
    final testBed = NgTestBed<TestEncapsulationPierce>(
        ng.createTestEncapsulationPierceFactory());
    final fixture = await testBed.create();
    final element = fixture.rootElement.querySelector('button')!;
    expect(
      element.getComputedStyle().textTransform,
      isNot('uppercase'),
      reason: failureReason(element),
    );
  });
}

@Component(
  selector: 'test',
  template: r'''
    <div [class]="className">Hello World</div>
  ''',
  styles: [
    r'''
    .is-fancy {
      position: absolute;
    }
  '''
  ],
)
class TestSetClassProperty {
  String get className => 'is-fancy';
}

@Component(
  selector: 'test',
  template: r'''
    <div [attr.class]="className">Hello World</div>
  ''',
  styles: [
    r'''
    .is-fancy {
      position: absolute;
    }
  '''
  ],
)
class TestSetClassAttribute {
  String get className => 'is-fancy';
}

@Component(
  selector: 'test',
  template: r'''
    <child-with-text class="no-uppercase-test"></child-with-text>
  ''',
  directives: [
    ChildComponentWithUppercaseText,
  ],
  styles: [
    r'''
    .no-uppercase-test ::ng-deep .trigger-button {
      text-transform: inherit;
    }
  '''
  ],
)
class TestEncapsulationPierce {}

@Component(
  selector: 'child-with-text',
  template: r'''
    <button class="trigger-button">Hello World</button>
  ''',
  styles: [
    r'''
    .trigger-button {
      text-transform: uppercase;
    }
  '''
  ],
)
class ChildComponentWithUppercaseText {}
