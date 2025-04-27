import 'package:ngdart/angular.dart';

import 'main.template.dart' as ng;

void main() => runApp<HelloWorldComponent>(ng.HelloWorldComponentNgFactory);

@Component(
  selector: 'hello-world',
  template: '<h1>Hello World</h1>',
)
class HelloWorldComponent {}
