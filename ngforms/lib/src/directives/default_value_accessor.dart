import 'package:web/web.dart';
//import 'dart:js_util' as js_util;

import 'package:ngdart/angular.dart';
import 'package:ngforms/src/directives/shared.dart' show setElementDisabled;

import 'control_value_accessor.dart';

const defaultValueAccessor = ExistingProvider.forToken(
  ngValueAccessor,
  DefaultValueAccessor,
);

/// The default accessor for writing a value and listening to changes that is used by the
/// [NgModel], [NgFormControl], and [NgControlName] directives.
///
/// ### Example
///     <input type="text" ngControl="searchQuery">
@Directive(
  selector: 'input:not([type=checkbox])[ngControl],'
      'textarea[ngControl],'
      'input:not([type=checkbox])[ngFormControl],'
      'textarea[ngFormControl],'
      'input:not([type=checkbox])[ngModel],'
      'textarea[ngModel],[ngDefaultControl]',
  providers: [defaultValueAccessor],
)
class DefaultValueAccessor extends Object
    with TouchHandler, ChangeHandler<String>
    implements ControlValueAccessor<dynamic> {
  final HtmlElement? _element;

  DefaultValueAccessor(@Optional() this._element);

  @HostListener('input', ['\$event.target.value'])
  void handleChange(String value) {
    onChange(value, rawValue: value);
  }

  @override
  void writeValue(value) {
    var normalizedValue = value ?? '';

    // TODO: Migrate to 3.6 (Need review)
    //js_util.setProperty(_element, 'value', normalizedValue);
    _element?.textContent = normalizedValue.toString();
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    setElementDisabled(_element, isDisabled);
  }
}
