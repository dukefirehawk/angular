import 'package:analyzer/dart/element/element.dart';
import 'package:ngcompiler/v1/src/angular_compiler/analyzer/types.dart';
import 'package:test/test.dart';

import '../src/resolve.dart';

//const $Directive = TypeChecker.fromUrl('package:ngdart/angular.dart#Directive');
//const $Component = TypeChecker.fromUrl('package:ngdart/angular.dart#Component');
//const $Service = TypeChecker.fromUrl('package:ngdart/angular.dart#Service');
//const $Injectable =
//    TypeChecker.fromUrl('package:ngdart/angular.dart#Injectable');

void main() {
  group('should resolve', () {
    late LibraryElement testLib;

    setUpAll(() async {
      testLib = await resolveLibrary(r'''

        @Directive()
        class ADirective {}

        @Component()
        class AComponent {}

        @Injectable()
        class AnInjectable {}

        void hasInject(@Inject(#dep) List dep) {}

        void hasOptional(@Optional() List dep) {}

        void hasSelf(@Self() List dep) {}

        void hasSkipSelf(@SkipSelf() List dep) {}

        void hasHost(@Host() List dep) {}
      ''');
    });

    test('@Directive', () {
      final aDirective = testLib.getClass('ADirective')!;
      expect($Directive.firstAnnotationOfExact(aDirective), isNotNull);
    });

    test('@Component', () {
      final aComponent = testLib.getClass('AComponent')!;
      expect($Component.firstAnnotationOfExact(aComponent), isNotNull);
    });

    test('@Injectable', () {
      final anInjectable = testLib.getClass('AnInjectable')!;
      expect($Injectable.firstAnnotationOfExact(anInjectable), isNotNull);
    });

    group('injection annotations', () {
      Element getParameterFrom(String name) =>
          testLib.definingCompilationUnit.functions
              .firstWhere((e) => e.name == name)
              .parameters
              .first;

      const {
        'hasHost': $Host,
        'hasInject': $Inject,
        'hasOptional': $Optional,
        'hasSelf': $Self,
        'hasSkipSelf': $SkipSelf,
      }.forEach((name, type) {
        test('of $type should find "$name"', () {
          final parameter = getParameterFrom(name);
          expect(type.firstAnnotationOfExact(parameter), isNotNull);
        });
      });
    });
  });
}
