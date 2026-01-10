import 'package:examples_hello_world/app.dart';
import 'package:examples_hello_world/src/home.dart';
import 'package:ngdart/angular.dart';
import 'package:ngrouter/angular_router.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';

import 'package:examples_hello_world/app.template.dart' as app;

import 'main.template.dart' as ng;

const useHashLS = false;

@GenerateInjector([
  routerProvidersHash, // For development
  // routerProviders, // For Production
  ClassProvider(Client, useClass: BrowserClient),
])
final InjectorFactory injector = ng.injector$Injector;

void main() {
  runApp(app.MyAppComponentNgFactory, createInjector: injector);
}
