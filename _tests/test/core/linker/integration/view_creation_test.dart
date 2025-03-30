import 'dart:async';
import 'package:web/web.dart';

import 'package:test/test.dart';
import 'package:ngdart/angular.dart';
import 'package:ngtest/angular_test.dart';

import 'view_creation_test.template.dart' as ng;

void main() {
  tearDown(disposeAnyRunningTest);

  test('should support imperative views', () async {
    final testBed = NgTestBed<SimpleImperativeViewComponent>(
      ng.createSimpleImperativeViewComponentFactory(),
    );
    final testFixture = await testBed.create();
    expect(testFixture.text, 'hello imp view');
  });

  test('should support moving embedded views', () async {
    final template = HTMLTemplateElement()..append(HTMLDivElement());
    final testBed = NgTestBed<MovesEmbeddedViewComponent>(
      ng.createMovesEmbeddedViewComponentFactory(),
    ).addInjector(
      (i) => Injector.map({
        ANCHOR_ELEMENT: template,
      }, i),
    );
    final testFixture = await testBed.create();
    final viewport = testFixture.assertOnlyInstance.viewport!;
    expect(viewport.anchor.textContent, '');
    await testFixture.update((component) => component.ctxBoolProp = true);
    expect(viewport.anchor.textContent, 'hello');
    await testFixture.update((component) => component.ctxBoolProp = false);
    expect(viewport.anchor.textContent, '');
  });

  group('property bindings', () {
    test("shouldn't throw if unknown property exists on directive", () async {
      final testBed = NgTestBed<UnknownPropertyOnDirectiveComponent>(
        ng.createUnknownPropertyOnDirectiveComponentFactory(),
      );
      await testBed.create();
    });

    test("shouldn't be created when a directive property has the same name",
        () async {
      final testBed = NgTestBed<OverriddenPropertyComponent>(
        ng.createOverriddenPropertyComponentFactory(),
      );
      final testFixture = await testBed.create();
      final span =
          testFixture.rootElement.querySelector('span') as HTMLSpanElement;
      expect(span.title, isEmpty);
    });

    test('should allow directive host property to update DOM', () async {
      final testBed = NgTestBed<DirectiveUpdatesDomComponent>(
        ng.createDirectiveUpdatesDomComponentFactory(),
      );
      final testFixture = await testBed.create();
      final span =
          testFixture.rootElement.querySelector('span') as HTMLSpanElement;
      expect(span.title, 'TITLE');
    });
  });

  group('property decorators', () {
    test('should support @Input', () async {
      final testBed = NgTestBed<DecoratorsComponent>(
        ng.createDecoratorsComponentFactory(),
      );
      final testFixture = await testBed.create();
      final directive = testFixture.assertOnlyInstance.directive;
      expect(directive!.dirProp, 'foo');
    });

    test('should support @HostBinding', () async {
      final testBed = NgTestBed<DecoratorsComponent>(
        ng.createDecoratorsComponentFactory(),
      );
      final testFixture = await testBed.create();
      await testFixture.update((component) {
        component.directive!.myAttr = 'bar';
      });
      final directiveElement = testFixture.rootElement.children.item(0);
      expect(directiveElement?.attributes, containsPair('my-attr', 'bar'));
    });

    test('should support @Output', () async {
      final testBed = NgTestBed<DecoratorsComponent>(
        ng.createDecoratorsComponentFactory(),
      );
      final testFixture = await testBed.create();
      await testFixture.update((component) {
        expect(component.value, isNull);
        component.directive!.fireEvent('fired!');
      });
      expect(testFixture.assertOnlyInstance.value, 'called');
    });

    test('should support @HostListener', () async {
      final testBed = NgTestBed<DecoratorsComponent>(
        ng.createDecoratorsComponentFactory(),
      );
      final testFixture = await testBed.create();
      final directive = testFixture.assertOnlyInstance.directive!;
      expect(directive.target, isNull);
      final directiveElement = testFixture.rootElement.children.item(0);
      directiveElement?.dispatchEvent(MouseEvent('click'));
      await testFixture.update();
      expect(directive.target, directiveElement);
    });
  });

  test('should support svg elements', () async {
    final testBed = NgTestBed<SvgElementsComponent>(
      ng.createSvgElementsComponentFactory(),
    );

    // TODO: Migrate to 3.6 (Need review)
    final testFixture = await testBed.create();
    final svg =
        testFixture.rootElement.querySelector('svg')! as HTMLImageElement;
    expect(svg.namespaceURI, 'http://www.w3.org/2000/svg');
    final use =
        testFixture.rootElement.querySelector('use')! as HTMLImageElement;
    expect(use.namespaceURI, 'http://www.w3.org/2000/svg');
    final foreignObject = testFixture.rootElement
        .querySelector('foreignObject')! as HTMLObjectElement;
    expect(foreignObject.namespaceURI, 'http://www.w3.org/2000/svg');
    final div = testFixture.rootElement.querySelector('div')! as HTMLDivElement;
    expect(div.namespaceURI, 'http://www.w3.org/1999/xhtml');
    final p =
        testFixture.rootElement.querySelector('p')! as HTMLParagraphElement;
    expect(p.namespaceURI, 'http://www.w3.org/1999/xhtml');
  });

  group('namespace attributes', () {
    test('should be supported', () async {
      final testBed = NgTestBed<NamespaceAttributeComponent>(
        ng.createNamespaceAttributeComponentFactory(),
      );
      final testFixture = await testBed.create();
      final use = testFixture.rootElement.querySelector('use')!;
      expect(use.getAttributeNS('http://www.w3.org/1999/xlink', 'href'), '#id');
    });

    test('should support binding', () async {
      final testBed = NgTestBed<NamespaceAttributeBindingComponent>(
        ng.createNamespaceAttributeBindingComponentFactory(),
      );
      final testFixture = await testBed.create();
      final use = testFixture.rootElement.querySelector('use')!;
      expect(
          use.getAttributeNS('http://www.w3.org/1999/xlink', 'href'), isNull);
      await testFixture.update((component) => component.value = '#id');
      expect(use.getAttributeNS('http://www.w3.org/1999/xlink', 'href'), '#id');
    });
  });
}

@Component(
  selector: 'simple-imp-cmp',
  template: '',
)
class SimpleImperativeViewComponent {
  SimpleImperativeViewComponent(Element hostElement) {
    hostElement.append(Text('hello imp view'));
  }
}

const ANCHOR_ELEMENT = OpaqueToken('AnchorElement');

@Directive(
  selector: '[someImpvp]',
)
class SomeImperativeViewport {
  ViewContainerRef vc;
  TemplateRef templateRef;
  EmbeddedViewRef? view;
  HTMLTemplateElement anchor;

  SomeImperativeViewport(
      this.vc, this.templateRef, @Inject(ANCHOR_ELEMENT) this.anchor);

  @Input()
  set someImpvp(bool value) {
    if (view != null) {
      vc.clear();
      view = null;
    }
    if (value) {
      view = vc.createEmbeddedView(templateRef);
      var nodes = view!.rootNodes;
      for (var i = 0; i < nodes.length; i++) {
        anchor.append(nodes[i]);
      }
    }
  }
}

@Component(
  selector: 'moves-embedded-view',
  template: '<div><div *someImpvp="ctxBoolProp">hello</div></div>',
  directives: [SomeImperativeViewport],
)
class MovesEmbeddedViewComponent {
  bool ctxBoolProp = false;

  @ViewChild(SomeImperativeViewport)
  SomeImperativeViewport? viewport;
}

@Directive(
  selector: '[has-property]',
)
class PropertyDirective {
  @Input('property')
  String? value;
}

@Component(
  selector: 'unknown-property-on-directive',
  template: '<div has-property [property]="value"></div>',
  directives: [PropertyDirective],
)
class UnknownPropertyOnDirectiveComponent {
  String value = 'Hello world!';
}

@Directive(
  selector: '[title]',
)
class DirectiveWithTitle {
  @Input()
  String? title;
}

@Component(
  selector: 'overridden-property',
  template: '<span [title]="name"></span>',
  directives: [DirectiveWithTitle],
)
class OverriddenPropertyComponent {
  String name = 'TITLE';
}

@Directive(
  selector: '[title]',
)
class DirectiveWithTitleAndHostProperty {
  @HostBinding()
  @Input()
  String? title;
}

@Component(
  selector: 'directive-updates-dom',
  template: '<span [title]="name"></span>',
  directives: [DirectiveWithTitleAndHostProperty],
)
class DirectiveUpdatesDomComponent {
  String name = 'TITLE';
}

@Directive(
  selector: 'with-prop-decorators',
)
class DirectiveWithPropDecorators {
  final StreamController<String> _streamController = StreamController<String>();
  Element? target;

  @Input('elProp')
  String? dirProp;

  @Output('elEvent')
  Stream<String> get event => _streamController.stream;

  @HostBinding('attr.my-attr')
  String? myAttr;

  @HostListener('click', ['\$event.target'])
  void onClick(Element target) {
    this.target = target;
  }

  void fireEvent(String message) {
    _streamController.add(message);
  }
}

@Component(
  selector: 'uses-input-decorator',
  template: '''
<with-prop-decorators elProp="foo" (elEvent)="value='called'">
</with-prop-decorators>''',
  directives: [DirectiveWithPropDecorators],
)
class DecoratorsComponent {
  String? value;

  @ViewChild(DirectiveWithPropDecorators)
  DirectiveWithPropDecorators? directive;
}

@Component(
  selector: 'svg-elements',
  template: '''
<svg>
  <use xlink:href="Port"/>
</svg>
<svg>
  <foreignObject>
    <xhtml:div>
      <p>Test</p>
    </xhtml:div>
  </foreignObject>
</svg>
''',
)
class SvgElementsComponent {}

@Component(
  selector: 'namespace-attribute',
  template: '<svg:use xlink:href="#id"/>',
)
class NamespaceAttributeComponent {}

@Component(
  selector: 'namespace-attribute-binding',
  template: '<svg:use [attr.xlink:href]="value"/>',
)
class NamespaceAttributeBindingComponent {
  String? value;
}
