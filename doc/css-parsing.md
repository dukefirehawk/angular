# CSS Shimming

## Pipeline

@Component
  ↓
ComponentReader
  ↓
ComponentMetadata
  ↓
ComponentStylesheet
  ↓
CssShim   ← selector rewriting happens here
  ↓
StylesheetEmitter
  ↓
*.css.shim.dart
  ↓
*.template.dart
  ↓
Runtime DOM styling

## Classes

* StylesheetCompiler
* processStylesheet
