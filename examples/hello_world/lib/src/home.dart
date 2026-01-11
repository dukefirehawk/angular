library;

import 'package:ngdart/angular.dart';

//@Component(selector: 'home-panel', template: '<h1>Welcome Home</h1>')
@Component(
  selector: 'home-panel',
  // styles: [
  //   '''
  //     .home-panel {
  //         padding: 16px;
  //         background-color: #f5f5f5;
  //         border-radius: 8px;
  //         text-align: center;
  //     }
  //   ''',
  // ],
  //styleUrls: ['home.css'],
  templateUrl: 'home.html',
  directives: [NgIf],
  providers: [],
  encapsulation: ViewEncapsulation.emulated,
)
class HomeComponent {}
