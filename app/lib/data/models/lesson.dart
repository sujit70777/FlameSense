import 'json_utils.dart';

/// A cited source link.
class SourceLink {
  const SourceLink({required this.label, required this.url});

  /// Parses {"label", "url"}.
  factory SourceLink.fromJson(Map<String, dynamic> j) => SourceLink(
    label: asString(j['label']) ?? '',
    url: asString(j['url']) ?? '',
  );

  final String label, url;
}

/// One Earth lesson (PLAN.md §3.8). Text comes only from lessons.json.
class Lesson {
  const Lesson(this.j, this.sources);

  /// Parses one lesson.
  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
    j,
    asList(j['sources']).map((s) => SourceLink.fromJson(asMap(s))).toList(),
  );

  final Map<String, dynamic> j;
  final List<SourceLink> sources;

  String get id => asString(j['id']) ?? '';
  String get status => asString(j['status']) ?? 'draft';
  String? get reviewedBy => asString(j['reviewed_by']);
  bool get isApproved =>
      status == 'approved' &&
      reviewedBy != null &&
      sources.any((s) => s.url.isNotEmpty);

  /// Localised field, e.g. text('title', 'bn'), falling back to English.
  String text(String field, String lang) =>
      asString(j['${field}_$lang']) ?? asString(j['${field}_en']) ?? '';
}
