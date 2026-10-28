import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../data/models/ask_models.dart';
import '../../data/models/json_utils.dart';

/// Ask failure kinds mapped to DESIGN.md §12.4 copy.
enum AskErrorKind { invalid, rateLimited, upstream, server, offline }

/// A failed Ask call.
class AskError implements Exception {
  const AskError(this.kind, {this.retryAfterS});
  final AskErrorKind kind;
  final int? retryAfterS;
}

/// POSTs to `/api/ask` on the current origin (PLAN.md §3.9).
class AskClient {
  AskClient({http.Client? client, Uri? endpoint})
    : _client = client ?? http.Client(),
      _endpoint = endpoint ?? Uri.base.resolve('/api/ask');

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
          .timeout(const Duration(seconds: 40));
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

    switch (res.statusCode) {
      case 200:
        final b = body();
        if (b.isEmpty) throw const AskError(AskErrorKind.server);
        return AskResponse.fromJson(b, cached: false);
      case 400:
        throw const AskError(AskErrorKind.invalid);
      case 429:
        throw AskError(
          AskErrorKind.rateLimited,
          retryAfterS: asInt(body()['retry_after_s']),
        );
      case 502 || 504:
        throw const AskError(AskErrorKind.upstream);
      default:
        throw const AskError(AskErrorKind.server);
    }
  }
}
