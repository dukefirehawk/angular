library;

import 'package:ngdart/angular.dart';

import 'src/home.dart';

@Component(
  selector: 'my-app',
  //styleUrls: ['app.css'],
  //template: '<h1>Welcome Home</h1>',
  templateUrl: 'app.html',
  directives: [HomeComponent],
  providers: [],
)
class MyAppComponent {}
