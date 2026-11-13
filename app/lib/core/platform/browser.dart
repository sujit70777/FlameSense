/// Browser-only actions behind a conditional import so tests run on the VM.
library;

export 'browser_stub.dart' if (dart.library.js_interop) 'browser_web.dart';
