@JS()
library;

import 'dart:js_interop';
import 'package:ngdart/angular.dart';

import 'opaque_token.template.dart' as ng;

/// Avoids Dart2JS thinking something is constant/unchanging.
@JS()
external T deopt<T>([Object? any]);

void main() {
  runApp(ng.createGoldenComponentFactory(), createInjector: goldenInjector);
}

const untypedToken = OpaqueToken('untypedToken');
const genericTyped = OpaqueToken<String>('genericTyped');
const untypedMulti = MultiToken('untypedMulti');
const genericMulti = MultiToken<String>('genericMulti');

class CustomToken extends OpaqueToken<String> {
  const CustomToken();
}

class CustomMulti extends MultiToken<String> {
  const CustomMulti();
}

const customToken = CustomToken();
const customMulti = CustomMulti();

const provideTokens = [
  ValueProvider.forToken(untypedToken, 'untypedToken: Hello World'),
  ValueProvider.forToken(genericTyped, 'genericTyped: Hello World'),
  ValueProvider.forToken(untypedMulti, 'untypedMulti: A'),
  ValueProvider.forToken(untypedMulti, 'untypedMulti: B'),
  ValueProvider.forToken(genericMulti, 'untypedMulti: A'),
  ValueProvider.forToken(genericMulti, 'untypedMulti: B'),
  ValueProvider.forToken(customToken, 'customToken: Hello World'),
  ValueProvider.forToken(customMulti, 'customMulti: A'),
  ValueProvider.forToken(customMulti, 'customMulti: B'),
];

@Component(
  selector: 'golden',
  template: '',
  providers: [
    provideTokens,
  ],
)
class GoldenComponent {
  GoldenComponent(Injector injector) {
    deopt(injector);
  }
}

@GenerateInjector(provideTokens)
final InjectorFactory goldenInjector = ng.goldenInjector$Injector;
