import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../data/models/ask_models.dart';
import '../../data/models/json_utils.dart';

/// Ask failure kinds mapped to DESIGN.md §12.4 copy. [unavailable]: the endpoint is
/// missing, not configured, or answered with something other than JSON (for example the
/// SPA's index.html on a static-only host).
enum AskErrorKind {
  invalid,
  rateLimited,

  /// The free AI service's quota is used up or it is overloaded; wait [AskError.retryAfterS].
  busy,
  upstream,
  server,
  offline,
  unavailable,
}

/// A failed Ask call.
class AskError implements Exception {
  const AskError(this.kind, {this.retryAfterS});
  final AskErrorKind kind;
  final int? retryAfterS;
}

/// Client-side limit; the function gives up on the model after 25 s, so this only
/// trips when the function itself hangs. Ask never waits longer than this.
const kAskTimeout = Duration(seconds: 30);

/// Ask API base URL from `--dart-define=ASK_API_BASE=https://…`; empty means the
/// current origin. Lets a static host (no functions) call the API on Cloudflare Pages.
const kAskApiBase = String.fromEnvironment('ASK_API_BASE');

/// POSTs to `/api/ask` on [kAskApiBase] or the current origin (PLAN.md §3.9).
class AskClient {
  AskClient({http.Client? client, Uri? endpoint})
    : _client = client ?? http.Client(),
      _endpoint =
          endpoint ??
          (kAskApiBase.isEmpty ? Uri.base : Uri.parse(kAskApiBase)).resolve(
            '/api/ask',
          );

  final http.Client _client;
  final Uri _endpoint;

  /// Asks [question] in [lang]; throws [AskError].
  Future<AskResponse> ask(String question, String lang) async {
    final http.Response res;
    try {
      res = await _client
          .post(
            _endpoint,
            headers: {'content-type': 'application/json'},
            body: jsonEncode({'question': question, 'lang': lang}),
          )
          .timeout(kAskTimeout);
    } catch (_) {
      throw const AskError(AskErrorKind.offline);
    }
    Map<String, dynamic> body() {
      try {
        return asMap(jsonDecode(utf8.decode(res.bodyBytes)));
      } catch (_) {
        return const {};
      }
    }

    final type = res.headers['content-type'] ?? '';
    if (!type.contains('application/json')) {
      throw const AskError(AskErrorKind.unavailable);
    }
    switch (res.statusCode) {
      case 200:
        final b = body();
        if (b.isEmpty) throw const AskError(AskErrorKind.server);
        return AskResponse.fromJson(b, cached: false);
      case 400:
        throw const AskError(AskErrorKind.invalid);
      case 429:
        final b = body();
        throw AskError(
          b['error'] == 'upstream_busy'
              ? AskErrorKind.busy
              : AskErrorKind.rateLimited,
          retryAfterS: asInt(b['retry_after_s']),
        );
      case 502 || 504:
        throw const AskError(AskErrorKind.upstream);
      case 404 || 405 || 501 || 503:
        throw const AskError(AskErrorKind.unavailable);
      default:
        throw const AskError(AskErrorKind.server);
    }
  }
}
