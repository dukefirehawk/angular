@JS()
library;

import 'dart:js_interop';
import 'package:ngdart/angular.dart';
import 'package:ngdart/experimental.dart';

import 'change_detection_link.template.dart' as ng;

/// Avoids Dart2JS thinking something is constant/unchanging.
@JS()
external T deopt<T>([Object? any]);

void main() {
  runApp(ng.createGoldenComponentFactory());
}

/// This demonstrates the code generated to implement `@changeDetectionLink`.
///
/// In practice, you'd only use `@changeDetectionLink` if this component were
/// passing a [ComponentFactory] that loads another Default component to its
/// OnPush descendants. However, this isn't needed to generate the code in
/// interest.
@Component(
  selector: 'golden',
  template: '''
    <on-push-link></on-push-link>
  ''',
  directives: [OnPushLink],
)
class GoldenComponent {}

@changeDetectionLink
@Component(
  selector: 'on-push-link',
  template: '''
    <template #container></template>
    <ng-container *ngIf="isVisible">
      <template #embeddedContainer></template>
    </ng-container>
    <nested-on-push></nested-on-push>
    <nested-on-push-link></nested-on-push-link>
    <nested-on-push-link *ngIf="isVisible"></nested-on-push-link>
  ''',
  directives: [
    NestedOnPush,
    NestedOnPushLink,
    NgIf,
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class OnPushLink {
  @ViewChild('container', read: ViewContainerRef)
  set container(ViewContainerRef? _) => deopt(_);

  @ViewChild('embeddedContainer', read: ViewContainerRef)
  set embeddedContainer(ViewContainerRef? _) => deopt(_);

  bool isVisible = deopt();
}

// Should not be linked.
@Component(
  selector: 'nested-on-push',
  template: '',
  changeDetection: ChangeDetectionStrategy.onPush,
)
class NestedOnPush {}

@changeDetectionLink
@Component(
  selector: 'nested-on-push-link',
  template: '''
    <template #container></template>
  ''',
  changeDetection: ChangeDetectionStrategy.onPush,
)
class NestedOnPushLink {
  @ViewChild('container', read: ViewContainerRef)
  set container(ViewContainerRef? _) => deopt(_);
}
