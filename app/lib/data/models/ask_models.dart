import 'json_utils.dart';

/// One numbered citation in an Ask answer (PLAN.md §3.9).
class AskCitation {
  const AskCitation({
    required this.n,
    required this.chunkId,
    required this.title,
    required this.url,
    required this.page,
    required this.snippet,
  });

  /// Parses one citation.
  factory AskCitation.fromJson(Map<String, dynamic> j) => AskCitation(
    n: asInt(j['n']) ?? 0,
    chunkId: asString(j['chunk_id']) ?? '',
    title: asString(j['title']) ?? '',
    url: asString(j['url']) ?? '',
    page: asInt(j['page']),
    snippet: asString(j['snippet']) ?? '',
  );

  final int n;
  final int? page;
  final String chunkId, title, url, snippet;
}

/// `AskResponse` from /api/ask or ask_cache.json.
class AskResponse {
  const AskResponse({
    required this.answer,
    required this.citations,
    required this.grounded,
    required this.model,
    required this.cached,
  });

  /// Parses an AskResponse.
  factory AskResponse.fromJson(Map<String, dynamic> j, {bool? cached}) =>
      AskResponse(
        answer: asString(j['answer']) ?? '',
        citations: asList(j['citations'])
            .map((c) => AskCitation.fromJson(asMap(c)))
            .toList(),
        grounded: asBool(j['grounded']) ?? false,
        model: asString(j['model']) ?? '',
        cached: cached ?? asBool(j['cached']) ?? false,
      );

  final String answer, model;
  final List<AskCitation> citations;
  final bool grounded, cached;
}

/// One cached suggested question.
class AskCacheEntry {
  const AskCacheEntry({
    required this.id,
    required this.qEn,
    required this.qBn,
    required this.answer,
  });

  final String id, qEn, qBn;
  final AskResponse answer;
}

/// Parses ask_cache.json into entries (keeps file order).
List<AskCacheEntry> parseAskCache(Map<String, dynamic> j) => j.entries
    .map(
      (e) => AskCacheEntry(
        id: e.key,
        qEn: asString(asMap(e.value)['q_en']) ?? '',
        qBn: asString(asMap(e.value)['q_bn']) ?? '',
        answer: AskResponse.fromJson(
          asMap(asMap(e.value)['answer']),
          cached: true,
        ),
      ),
    )
    .toList();
