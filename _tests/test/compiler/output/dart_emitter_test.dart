import 'package:test/test.dart';
import 'package:ngcompiler/v1/src/compiler/compile_metadata.dart'
    show CompileIdentifierMetadata;
import 'package:ngcompiler/v1/src/compiler/output/dart_emitter.dart'
    show DartEmitter;
import 'package:ngcompiler/v1/src/compiler/output/output_ast.dart' as o;

var someModuleUrl = 'asset:somePackage/lib/somePath';
var anotherModuleUrl = 'asset:somePackage/lib/someOtherPath';
var sameModuleIdentifier =
    CompileIdentifierMetadata(name: 'someLocalId', moduleUrl: someModuleUrl);
var externalModuleIdentifier = CompileIdentifierMetadata(
    name: 'someExternalId', moduleUrl: anotherModuleUrl);

void main() {
  // Not supported features of our OutputAst in Dart:
  // - declaring what should be exported via a special statement like `export`.
  //   Dart exports everything that has no `_` in its name.
  // - declaring private fields via a statement like `private`.
  //   Dart exports everything that has no `_` in its name.
  // - return types for function expressions
  group('DartEmitter', () {
    DartEmitter emitter;
    o.ReadVarExpr someVar;
    setUp(() {
      emitter = DartEmitter();
      someVar = o.variable('someVar');
    });

    void enableNullSafety() {
      emitter = DartEmitter(emitNullSafeSyntax: true);
    }

    String emitStmt(o.Statement stmt) {
      return emitter.emitStatements(someModuleUrl, [stmt]);
    }

    test('should declare variables', () {
      expect(
          emitStmt(someVar.set(o.literal(1)).toDeclStmt()), 'var someVar = 1;');
      expect(
          emitStmt(someVar
              .set(o.literal(1))
              .toDeclStmt(null, [o.StmtModifier.finalStmt])),
          'final someVar = 1;');
      expect(
          emitStmt(someVar
              .set(o.literal(1))
              .toDeclStmt(null, [o.StmtModifier.staticStmt])),
          'static var someVar = 1;');
      expect(
          emitStmt(someVar
              .set(o.literal(
                  1,
                  o.BuiltinType(o.BuiltinTypeName.intName,
                      [o.TypeModifier.constModifier])))
              .toDeclStmt(null, [o.StmtModifier.finalStmt])),
          'final someVar = 1;');
      expect(
          emitStmt(someVar.set(o.literal(1)).toDeclStmt()), 'var someVar = 1;');
      expect(emitStmt(someVar.set(o.literal(1)).toDeclStmt(o.intType)),
          'int someVar = 1;');
    });
    test('should read and write variables', () {
      expect(emitStmt(someVar.toStmt()), 'someVar;');
      expect(emitStmt(someVar.set(o.literal(1)).toStmt()), 'someVar = 1;');
      expect(
          emitStmt(someVar
              .set(o.variable('someOtherVar').set(o.literal(1)))
              .toStmt()),
          'someVar = (someOtherVar = 1);');
    });
    test('should read and write keys', () {
      expect(
          emitStmt(o.variable('someMap').key(o.variable('someKey')).toStmt()),
          'someMap[someKey];');
      expect(
          emitStmt(o
              .variable('someMap')
              .key(o.variable('someKey'))
              .set(o.literal(1))
              .toStmt()),
          'someMap[someKey] = 1;');
    });
    test('should read and write properties', () {
      expect(emitStmt(o.variable('someObj').prop('someProp').toStmt()),
          'someObj.someProp;');
      expect(
          emitStmt(o
              .variable('someObj')
              .prop('someProp')
              .set(o.literal(1))
              .toStmt()),
          'someObj.someProp = 1;');
    });
    test('should invoke functions and methods and constructors', () {
      expect(emitStmt(o.variable('someFn').callFn([o.literal(1)]).toStmt()),
          'someFn(1);');
      expect(
          emitStmt(o
              .variable('someObj')
              .callMethod('someMethod', [o.literal(1)]).toStmt()),
          'someObj.someMethod(1);');
      expect(
          emitStmt(
              o.variable('SomeClass').instantiate([o.literal(1)]).toStmt()),
          'SomeClass(1);');
      expect(
          emitStmt(o
              .variable('a')
              .plus(o.variable('b'))
              .callMethod('toString', []).toStmt()),
          '(a + b).toString();');
      expect(
          emitStmt(o.not(o.variable('a')).callMethod('toString', []).toStmt()),
          '(!a).toString();');
    });

    test('should support but hide the non-nullable assertion operator', () {
      expect(
        emitStmt(o.variable('a').notNull().callFn([o.literal(1)]).toStmt()),
        '(a/*!*/)(1);',
      );
    });

    test('should support and write the non-nullable assertion operator', () {
      enableNullSafety();
      expect(
        emitStmt(o.variable('a').notNull().callFn([o.literal(1)]).toStmt()),
        '(a!)(1);',
      );
    });

    test('should support but hide a nullable built-in type', () {
      final nullableString = o.BuiltinType(
        o.BuiltinTypeName.stringName,
        [o.TypeModifier.nullableModifier],
      );
      var writeVarExpr = o.variable('a').set(o.literal(null));
      expect(
        emitStmt(writeVarExpr.toDeclStmt(nullableString)),
        'String/*?*/ a = null;',
      );
    });

    test('should support and write a nullable built-in type', () {
      enableNullSafety();
      final nullableString = o.BuiltinType(
        o.BuiltinTypeName.stringName,
        [o.TypeModifier.nullableModifier],
      );
      var writeVarExpr = o.variable('a').set(o.literal(null));
      expect(
        emitStmt(writeVarExpr.toDeclStmt(nullableString)),
        'String? a = null;',
      );
    });

    test('should support but hide the late declaration modifier', () {
      var writeVarExpr = o.variable('a').set(o.literal('Hello'));
      expect(
        emitStmt(
            writeVarExpr.toDeclStmt(o.stringType, [o.StmtModifier.lateStmt])),
        '/*late*/ String a = \'Hello\';',
      );
    });

    test('should support and write the late declaration modifier', () {
      enableNullSafety();
      var writeVarExpr = o.variable('a').set(o.literal('Hello'));
      expect(
        emitStmt(
            writeVarExpr.toDeclStmt(o.stringType, [o.StmtModifier.lateStmt])),
        'late String a = \'Hello\';',
      );
    });

    test('should support but hide late + final declaration modifier', () {
      var writeVarExpr = o.variable('a').set(o.literal('Hello'));
      expect(
        emitStmt(writeVarExpr.toDeclStmt(o.stringType, [
          o.StmtModifier.lateStmt,
          o.StmtModifier.finalStmt,
        ])),
        '/*late final*/ String a = \'Hello\';',
      );
    });

    test('should support and write late + final declaration modifier', () {
      enableNullSafety();
      var writeVarExpr = o.variable('a').set(o.literal('Hello'));
      expect(
        emitStmt(writeVarExpr.toDeclStmt(o.stringType, [
          o.StmtModifier.lateStmt,
          o.StmtModifier.finalStmt,
        ])),
        'late final String a = \'Hello\';',
      );
    });

    test('should support Never but emit Null when not opted-in', () {
      var declareVar = o.variable('a').set(o.nullExpr);
      expect(
        emitStmt(declareVar.toDeclStmt(o.neverType)),
        'Null /*Never*/ a = null;',
      );
    });

    test('should support and write Never', () {
      enableNullSafety();
      var declareVar = o.variable('a').set(o.nullExpr);
      expect(
        emitStmt(declareVar.toDeclStmt(o.neverType)),
        // = null isn't semantically valid, but this is a synthetic test anyway.
        'Never a = null;',
      );
    });

    test('should omit optional const', () {
      expect(
        emitStmt(o.variable('SomeClass').instantiate(
          [
            o.literalMap(
              [
                [
                  'a',
                  o.literalArr(
                    [o.literal(1)],
                    o.ArrayType(o.intType, [o.TypeModifier.constModifier]),
                  )
                ],
              ],
              o.MapType(o.ArrayType(o.intType), [o.TypeModifier.constModifier]),
            ),
          ],
          type: o.importType(
            CompileIdentifierMetadata(name: 'SomeClass'),
            [],
            [o.TypeModifier.constModifier],
          ),
        ).toStmt()),
        "const SomeClass(<String, List<int>>{'a': [1]});",
      );
    });
    test('should support builtin methods', () {
      expect(
          emitStmt(o.variable('arr1').callMethod(
              o.BuiltinMethod.concatArray, [o.variable('arr2')]).toStmt()),
          'arr1..addAll(arr2);');
      expect(
          emitStmt(o.variable('observable').callMethod(
              o.BuiltinMethod.subscribeObservable,
              [o.variable('listener')]).toStmt()),
          'observable.listen(listener);');
    });
    test('should support literals', () {
      expect(emitStmt(o.literal(0).toStmt()), '0;');
      expect(emitStmt(o.literal(true).toStmt()), 'true;');
      expect(emitStmt(o.literal('someStr').toStmt()), '\'someStr\';');
      expect(emitStmt(o.literal('\$a').toStmt()), '\'\\\$a\';');
      expect(emitStmt(o.literalArr([o.literal(1)]).toStmt()), '[1];');
      expect(
          emitStmt(o.literalMap([
            ['someKey', o.literal(1)]
          ]).toStmt()),
          '{\'someKey\': 1};');
      expect(
          emitStmt(o.literalMap([
            ['someKey', o.literal(1)]
          ], o.MapType(o.numberType)).toStmt()),
          '<String, num>{\'someKey\': 1};');
    });
    test('should support external identifiers', () {
      expect(emitStmt(o.importExpr(sameModuleIdentifier).toStmt()),
          'someLocalId;');
      expect(
          emitStmt(o.importExpr(externalModuleIdentifier).toStmt()),
          ['import \'someOtherPath\' as import0;', 'import0.someExternalId;']
              .join('\n'));
    });
    test('should support operators', () {
      var lhs = o.variable('lhs');
      var rhs = o.variable('rhs');
      expect(emitStmt(someVar.cast(o.intType).toStmt()), '(someVar as int);');
      expect(emitStmt(o.not(someVar).toStmt()), '(!someVar);');
      expect(
          emitStmt(someVar
              .conditional(o.variable('trueCase'), o.variable('falseCase'))
              .toStmt()),
          '(someVar? trueCase: falseCase);');
      expect(emitStmt(lhs.equals(rhs).toStmt()), '(lhs == rhs);');
      expect(emitStmt(lhs.notEquals(rhs).toStmt()), '(lhs != rhs);');
      expect(emitStmt(lhs.identical(rhs).toStmt()), 'identical(lhs, rhs);');
      expect(emitStmt(lhs.notIdentical(rhs).toStmt()), '!identical(lhs, rhs);');
      expect(emitStmt(lhs.minus(rhs).toStmt()), '(lhs - rhs);');
      expect(emitStmt(lhs.plus(rhs).toStmt()), '(lhs + rhs);');
      expect(emitStmt(lhs.divide(rhs).toStmt()), '(lhs / rhs);');
      expect(emitStmt(lhs.multiply(rhs).toStmt()), '(lhs * rhs);');
      expect(emitStmt(lhs.modulo(rhs).toStmt()), '(lhs % rhs);');
      expect(emitStmt(lhs.and(rhs).toStmt()), '(lhs && rhs);');
      expect(emitStmt(lhs.or(rhs).toStmt()), '(lhs || rhs);');
      expect(emitStmt(lhs.lower(rhs).toStmt()), '(lhs < rhs);');
      expect(emitStmt(lhs.lowerEquals(rhs).toStmt()), '(lhs <= rhs);');
      expect(emitStmt(lhs.bigger(rhs).toStmt()), '(lhs > rhs);');
      expect(emitStmt(lhs.biggerEquals(rhs).toStmt()), '(lhs >= rhs);');
    });
    test('should support function expressions', () {
      expect(emitStmt(o.fn([], []).toStmt()), ['() {', '};'].join('\n'));
      expect(emitStmt(o.fn([o.FnParam('param1', o.intType)], []).toStmt()),
          ['(int param1) {', '};'].join('\n'));
    });
    test('should support function statements', () {
      expect(emitStmt(o.DeclareFunctionStmt('someFn', [], [])),
          ['void someFn() {', '}'].join('\n'));
      expect(
          emitStmt(o.DeclareFunctionStmt(
              'someFn', [], [o.ReturnStatement(o.literal(1))],
              type: o.intType)),
          ['int someFn() {', '  return 1;', '}'].join('\n'));
      expect(
          emitStmt(o.DeclareFunctionStmt(
              'someFn', [o.FnParam('param1', o.intType)], [])),
          ['void someFn(int param1) {', '}'].join('\n'));
    });
    test('should support generic functions', () {
      final t = o.importType(CompileIdentifierMetadata(name: 'T'));
      final r = o.importType(CompileIdentifierMetadata(name: 'R'));
      expect(
        emitStmt(o.DeclareFunctionStmt(
          'genericFn',
          [o.FnParam('t', t)],
          [],
          typeParameters: [o.TypeParameter('T', bound: o.numberType)],
        )),
        ['void genericFn<T extends num>(T t) {', '}'].join('\n'),
      );
      expect(
        emitStmt(o.DeclareFunctionStmt(
          'genericFn',
          [o.FnParam('t', t)],
          [],
          type: r,
          typeParameters: [
            o.TypeParameter('T', bound: r),
            o.TypeParameter('R')
          ],
        )),
        ['R genericFn<T extends R, R>(T t) {', '}'].join('\n'),
      );
    });
    test('should support comments', () {
      expect(emitStmt(o.CommentStmt('a\nb')), ['// a', '// b'].join('\n'));
    });
    test('should support if stmt', () {
      var trueCase = o.variable('trueCase').callFn([]).toStmt();
      var falseCase = o.variable('falseCase').callFn([]).toStmt();
      expect(emitStmt(o.IfStmt(o.variable('cond'), [trueCase])),
          ['if (cond) { trueCase(); }'].join('\n'));
      expect(
          emitStmt(o.IfStmt(o.variable('cond'), [trueCase], [falseCase])),
          ['if (cond) {', '  trueCase();', '} else {', '  falseCase();', '}']
              .join('\n'));
    });
    test('should support try/catch', () {
      var bodyStmt = o.variable('body').callFn([]).toStmt();
      var catchStmt = o
          .variable('catchFn')
          .callFn([o.catchErrorVar, o.catchStackVar]).toStmt();
      expect(
          emitStmt(o.TryCatchStmt([bodyStmt], [catchStmt])),
          [
            'try {',
            '  body();',
            '} catch (error, stack) {',
            '  catchFn(error,stack);',
            '}'
          ].join('\n'));
    });
    test('should support support throwing', () {
      expect(emitStmt(o.ThrowStmt(someVar)), 'throw someVar;');
    });
    group('classes', () {
      o.Statement callSomeMethod;
      setUp(() {
        callSomeMethod = o.thisExpr.callMethod('someMethod', []).toStmt();
      });
      test('should support declaring classes', () {
        expect(emitStmt(o.ClassStmt('SomeClass', null, [], [], null, [])),
            ['class SomeClass {', '}'].join('\n'));
        expect(
            emitStmt(o.ClassStmt(
                'SomeClass', o.variable('SomeSuperClass'), [], [], null, [])),
            ['class SomeClass extends SomeSuperClass {', '}'].join('\n'));
      });
      test('should support declaring constructors', () {
        var superCall = o.superExpr.callFn([o.variable('someParam')]).toStmt();
        expect(
            emitStmt(
                o.ClassStmt('SomeClass', null, [], [], o.Constructor(), [])),
            ['class SomeClass {', '  SomeClass();', '}'].join('\n'));
        expect(
            emitStmt(o.ClassStmt(
                'SomeClass',
                null,
                [],
                [],
                o.Constructor(params: [o.FnParam('someParam', o.intType)]),
                [])),
            ['class SomeClass {', '  SomeClass(int someParam);', '}']
                .join('\n'));
        expect(
            emitStmt(o.ClassStmt('SomeClass', null, [], [],
                o.Constructor(initializers: [superCall]), [])),
            ['class SomeClass {', '  SomeClass(): super(someParam);', '}']
                .join('\n'));
        expect(
            emitStmt(o.ClassStmt('SomeClass', null, [], [],
                o.Constructor(body: [callSomeMethod]), [])),
            [
              'class SomeClass {',
              '  SomeClass() {',
              '    this.someMethod();',
              '  }',
              '}'
            ].join('\n'));
      });
      test('should support declaring fields', () {
        expect(
            emitStmt(o.ClassStmt(
                'SomeClass', null, [o.ClassField('someField')], [], null, [])),
            ['class SomeClass {', '  var someField;', '}'].join('\n'));
        expect(
            emitStmt(o.ClassStmt(
                'SomeClass',
                null,
                [o.ClassField('someField', outputType: o.intType)],
                [],
                null,
                [])),
            ['class SomeClass {', '  int someField;', '}'].join('\n'));
        expect(
            emitStmt(o.ClassStmt(
                'SomeClass',
                null,
                [
                  o.ClassField('someField',
                      outputType: o.intType,
                      modifiers: const [o.StmtModifier.finalStmt])
                ],
                [],
                null,
                [])),
            ['class SomeClass {', '  final int someField;', '}'].join('\n'));
      });
      test('should support declaring getters', () {
        expect(
            emitStmt(o.ClassStmt('SomeClass', null, [],
                [o.ClassGetter('someGetter', [])], null, [])),
            ['class SomeClass {', '  get someGetter {', '  }', '}'].join('\n'));
        expect(
            emitStmt(o.ClassStmt('SomeClass', null, [],
                [o.ClassGetter('someGetter', [], o.intType)], null, [])),
            ['class SomeClass {', '  int get someGetter {', '  }', '}']
                .join('\n'));
        expect(
            emitStmt(o.ClassStmt(
                'SomeClass',
                null,
                [],
                [
                  o.ClassGetter('someGetter', [callSomeMethod])
                ],
                null,
                [])),
            [
              'class SomeClass {',
              '  get someGetter {',
              '    this.someMethod();',
              '  }',
              '}'
            ].join('\n'));
      });
      test('should support methods', () {
        expect(
            emitStmt(o.ClassStmt('SomeClass', null, [], [], null,
                [o.ClassMethod('someMethod', [], [])])),
            ['class SomeClass {', '  void someMethod() {', '  }', '}']
                .join('\n'));
        expect(
            emitStmt(o.ClassStmt('SomeClass', null, [], [], null,
                [o.ClassMethod('someMethod', [], [], o.intType)])),
            ['class SomeClass {', '  int someMethod() {', '  }', '}']
                .join('\n'));
        expect(
            emitStmt(o.ClassStmt(
                'SomeClass',
                null,
                [],
                [],
                null,
                [
                  o.ClassMethod(
                      'someMethod', [o.FnParam('someParam', o.intType)], [])
                ])),
            [
              'class SomeClass {',
              '  void someMethod(int someParam) {',
              '  }',
              '}'
            ].join('\n'));
        expect(
            emitStmt(o.ClassStmt(
                'SomeClass',
                null,
                [],
                [],
                null,
                [
                  o.ClassMethod('someMethod', [], [callSomeMethod])
                ])),
            [
              'class SomeClass {',
              '  void someMethod() {',
              '    this.someMethod();',
              '  }',
              '}'
            ].join('\n'));
      });
      test('should support type parameters', () {
        expect(
          emitStmt(o.ClassStmt('GenericClass', null, [], [], null, [],
              typeParameters: [
                o.TypeParameter(
                  'T',
                  bound: o.importType(
                    CompileIdentifierMetadata(name: 'GenericBound'),
                    [o.stringType],
                  ),
                ),
              ])),
          [
            'class GenericClass<T extends GenericBound<String>> {',
            '}',
          ].join('\n'),
        );
        expect(
          emitStmt(o.ClassStmt(
            'GenericClass',
            o.importExpr(
              CompileIdentifierMetadata(name: 'GenericParent'),
              typeParams: [o.importType(CompileIdentifierMetadata(name: 'T'))],
            ),
            [],
            [],
            null,
            [],
            typeParameters: [o.TypeParameter('T')],
          )),
          ['class GenericClass<T> extends GenericParent<T> {', '}'].join('\n'),
        );
      });
    });
    test('should support builtin types', () {
      var writeVarExpr = o.variable('a').set(o.nullExpr);
      expect(emitStmt(writeVarExpr.toDeclStmt(o.dynamicType)),
          'dynamic a = null;');
      expect(emitStmt(writeVarExpr.toDeclStmt(o.boolType)), 'bool a = null;');
      expect(emitStmt(writeVarExpr.toDeclStmt(o.intType)), 'int a = null;');
      expect(emitStmt(writeVarExpr.toDeclStmt(o.numberType)), 'num a = null;');
      expect(
          emitStmt(writeVarExpr.toDeclStmt(o.stringType)), 'String a = null;');
      expect(emitStmt(writeVarExpr.toDeclStmt(o.functionType)),
          'Function a = null;');
    });
    test('should support external types', () {
      var writeVarExpr = o.variable('a').set(o.nullExpr);
      expect(
          emitStmt(writeVarExpr.toDeclStmt(o.importType(sameModuleIdentifier))),
          'someLocalId a = null;');
      expect(
          emitStmt(
              writeVarExpr.toDeclStmt(o.importType(externalModuleIdentifier))),
          [
            'import \'someOtherPath\' as import0;',
            'import0.someExternalId a = null;'
          ].join('\n'));
    });
    test('should support combined types', () {
      var writeVarExpr = o.variable('a').set(o.nullExpr);
      expect(emitStmt(writeVarExpr.toDeclStmt(o.ArrayType(null))),
          'List<dynamic> a = null;');
      expect(emitStmt(writeVarExpr.toDeclStmt(o.ArrayType(o.intType))),
          'List<int> a = null;');
      expect(emitStmt(writeVarExpr.toDeclStmt(o.MapType(null))),
          'Map<String, dynamic> a = null;');
      expect(emitStmt(writeVarExpr.toDeclStmt(o.MapType(o.intType))),
          'Map<String, int> a = null;');
    });
    test('should support shadowing members', () {
      var name = 'someValue';
      var field = o.ClassField(name);
      var method = o.ClassMethod(
        'someMethod',
        [o.FnParam(name)],
        [
          // Test shadowing of `WriteClassMemberExpr`.
          o.WriteClassMemberExpr(name, o.variable(name)).toStmt(),
          // Test shadowing of `ReadClassMemberExpr`.
          o.variable(name).set(o.ReadClassMemberExpr(name)).toStmt(),
        ],
      );
      var classStmt =
          o.ClassStmt('SomeClass', null, [field], [], null, [method]);
      expect(
        emitStmt(classStmt),
        [
          'class SomeClass {',
          '  var $name;',
          '  void someMethod($name) {',
          '    this.$name = $name;',
          '    $name = this.$name;',
          '  }',
          '}'
        ].join('\n'),
      );
    });
  });
}
