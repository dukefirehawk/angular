import 'dart:js_interop';

import 'package:test/test.dart';
import 'package:web/web.dart';

import 'package:ngdart/angular.dart';

/// Matches textual content of an element including children.
Matcher hasTextContent(String expected) => _HasTextContent(expected);

final throwsNoProviderError = throwsA(_isNoProviderError);
final _isNoProviderError = const TypeMatcher<NoProviderError>();

class _HasTextContent extends Matcher {
  final String expectedText;

  const _HasTextContent(this.expectedText);

  @override
  bool matches(Object? item, void _) => _elementText(item) == expectedText;

  @override
  Description describe(Description description) =>
      description.add(expectedText);

  @override
  Description describeMismatch(
    item,
    Description mismatchDescription,
    void _,
    void __,
  ) {
    mismatchDescription.add('Text content of element: '
        '\'${_elementText(item)}\'');
    return mismatchDescription;
  }
}

String? _elementText(Object? n) {
  // TODO: Migrate to 3.6 (Need review)
  /*
  if (n is Iterable) {
    return n.map(_elementText).join('');
  } else if (n is Node) {

    if (n is ContentElement) {
      return _elementText(n.getDistributedNodes());
    }

    if (n is Element && n.shadowRoot != null) {
      return _elementText(n.shadowRoot!.childNodes);
    }

    if (n.childNodes.isDefinedAndNotNull) {
      return _elementText(n.childNodes);
    }

    return n.textContent;
  } else {
    return '$n';
  }
  */

  if (n == null) {
    return '';
  }

  if (n is Iterable) {
    return n.map(_elementText).join('');
  } else if (n == Node) {
    var node = n as Node;

    //if (node is ContentElement) {
    //  return _elementText(n.getDistributedNodes());
    //}

    if (node.isA<Element>()) {
      var el = n as Element;
      if (el.shadowRoot != null) {
        return _elementText(el.shadowRoot!.childNodes);
      }
    }

    if (node.childNodes.isDefinedAndNotNull) {
      return _elementText(node.childNodes);
    }

    return n.textContent;
  } else {
    return '$n';
  }
}
