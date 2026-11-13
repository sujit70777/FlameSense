import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Reloads the page.
void reloadPage() => web.window.location.reload();

/// Triggers a browser download of [bytes] as [fileName] via a Blob + anchor.
void downloadBytes(String fileName, Uint8List bytes, String mime) {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: mime));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = fileName
    ..style.display = 'none';
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}

/// Sets the document title.
void setDocumentTitle(String title) => web.document.title = title;

/// Current origin, e.g. https://flamesense.ehsanur.com.
String currentOrigin() => web.window.location.origin;
