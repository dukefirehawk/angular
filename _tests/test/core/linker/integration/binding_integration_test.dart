import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';
import 'package:web/web.dart';

import 'binding_integration_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('should consume text binding', () async {
    final testBed =
        NgTestBed<BoundTextComponent>(ng.createBoundTextComponentFactory());
    final testFixture = await testBed.create();
    expect(testFixture.text, 'Initial text');
    await testFixture.update((component) => component.text = 'New text');
    expect(testFixture.text, 'New text');
  });

  test('should interpolate null as blank string', () async {
    final testBed =
        NgTestBed<BoundTextComponent>(ng.createBoundTextComponentFactory());
    final testFixture = await testBed.create();
    expect(testFixture.text, 'Initial text');
    await testFixture.update((component) => component.text = null);
    expect(testFixture.text, '');
  });

  test('should consume property binding', () async {
    final testBed = NgTestBed<BoundPropertyComponent>(
        ng.createBoundPropertyComponentFactory());
    final testFixture = await testBed.create();
    final div = testFixture.rootElement.querySelector('div')!;
    expect(div.id, 'Initial ID');
    await testFixture.update((component) => component.id = 'New ID');
    expect(div.id, 'New ID');
  });

  test('should consume ARIA attribute binding', () async {
    final testBed = NgTestBed<BoundAriaAttributeComponent>(
        ng.createBoundAriaAttributeComponentFactory());
    final testFixture = await testBed.create();
    final div = testFixture.rootElement.querySelector('div')!;
    expect(div.attributes, containsPair('aria-label', 'Initial label'));
    await testFixture.update((component) => component.label = 'New label');
    expect(div.attributes, containsPair('aria-label', 'New label'));
  });

  test('should remove attribute when bound expression is null', () async {
    final testBed = NgTestBed<BoundAttributeComponent>(
        ng.createBoundAttributeComponentFactory());
    final testFixture = await testBed.create();
    final div = testFixture.rootElement.querySelector('div')!;
    expect(div.attributes, containsPair('foo', 'Initial value'));
    await testFixture.update((component) => component.value = null);
    expect(div.attributes, isNot(contains('foo')));
  });

  test('should remove style when bound expression is null', () async {
    final testBed =
        NgTestBed<BoundStyleComponent>(ng.createBoundStyleComponentFactory());
    final testFixture = await testBed.create();
    final div = testFixture.rootElement.querySelector('div')! as HTMLDivElement;
    expect(div.style.height, '10px');
    await testFixture.update((component) => component.height = null);
    expect(div.style.height, '');
  });

  test('should consume property binding with mismatched value name', () async {
    final testBed = NgTestBed<BoundMismatchedPropertyComponent>(
        ng.createBoundMismatchedPropertyComponentFactory());
    final testFixture = await testBed.create();
    final div = testFixture.rootElement.querySelector('div')! as HTMLDivElement;
    expect(div.tabIndex, 0);
    await testFixture.update((component) => component.index = 5);
    expect(div.tabIndex, 5);
  });

  test('should consume camel case property binding', () async {
    final testBed = NgTestBed<BoundCamelCasePropertyComponent>(
        ng.createBoundCamelCasePropertyComponentFactory());
    final testFixture = await testBed.create();
    final div = testFixture.rootElement.querySelector('div')! as HTMLDivElement;
    expect(div.tabIndex, 1);
    await testFixture.update((component) => component.index = 0);
    expect(div.tabIndex, 0);
  });

  test('should consume innerHtml binding', () async {
    final testBed = NgTestBed<BoundInnerHtmlComponent>(
        ng.createBoundInnerHtmlComponentFactory());
    final testFixture = await testBed.create();
    final div = testFixture.rootElement.querySelector('div')!;
    expect(div.innerHTML, 'Initial <span>HTML</span>');
    await testFixture
        .update((component) => component.html = 'New <div>HTML</div>');
    expect(div.innerHTML, 'New <div>HTML</div>');
  });

  test('should consume className binding using class alias', () async {
    final testBed =
        NgTestBed<BoundClassNameAlias>(ng.createBoundClassNameAliasFactory());
    final testFixture = await testBed.create();
    final div = testFixture.rootElement.querySelector('div')! as HTMLDivElement;
    expect(div.classList, contains('foo'));
    expect(div.classList, contains('bar'));
    expect(div.classList, isNot(contains('initial')));
  });
}

@Component(
  selector: 'bound-text',
  template: '<div>{{text}}</div>',
)
class BoundTextComponent {
  String? text = 'Initial text';
}

@Component(
  selector: 'bound-property',
  template: '<div [id]="id"></div>',
)
class BoundPropertyComponent {
  String id = 'Initial ID';
}

@Component(
  selector: 'bound-aria-attribute',
  template: '<div [attr.aria-label]="label"></div>',
)
class BoundAriaAttributeComponent {
  String label = 'Initial label';
}

@Component(
  selector: 'bound-attribute',
  template: '<div [attr.foo]="value"></div>',
)
class BoundAttributeComponent {
  String? value = 'Initial value';
}

@Component(
  selector: 'bound-style',
  template: '<div [style.height.px]="height"></div>',
)
class BoundStyleComponent {
  int? height = 10;
}

@Component(
  selector: 'bound-mismatched-property',
  template: '<div [tabindex]="index"></div>',
)
class BoundMismatchedPropertyComponent {
  int? index = 0;
}

@Component(
  selector: 'bound-camel-case-property',
  template: '<div [tabIndex]="index"></div>',
)
class BoundCamelCasePropertyComponent {
  int? index = 1;
}

@Component(
  selector: 'bound-inner-html',
  template: '<div [innerHtml]="html"></div>',
)
class BoundInnerHtmlComponent {
  String? html = 'Initial <span>HTML</span>';
}

@Component(
  selector: 'bound-class-name-alias',
  template: '<div class="initial" [class]="classes"></div>',
)
class BoundClassNameAlias {
  String classes = 'foo bar';
}
