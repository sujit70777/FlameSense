import 'dart:typed_data';

/// Files "downloaded" outside the browser (inspected by tests).
final List<({String name, String mime, Uint8List bytes})> debugDownloads = [];

/// Reloads the page (no-op outside the browser).
void reloadPage() {}

/// Triggers a browser download of [bytes] as [fileName] (recorded outside the browser).
void downloadBytes(String fileName, Uint8List bytes, String mime) {
  debugDownloads.add((name: fileName, mime: mime, bytes: bytes));
}

/// Sets the document title (no-op outside the browser).
void setDocumentTitle(String title) {}

/// Current origin, e.g. https://flamesense.ehsanur.com (empty outside the browser).
String currentOrigin() => '';
