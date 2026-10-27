/// Small helpers for reading loosely typed JSON safely.
double? asDouble(Object? v) => v is num ? v.toDouble() : null;

/// Int or null.
int? asInt(Object? v) => v is num ? v.toInt() : null;

/// Non-empty string or null.
String? asString(Object? v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

/// Bool or null.
bool? asBool(Object? v) => v is bool ? v : null;

/// JSON object or an empty map.
Map<String, dynamic> asMap(Object? v) =>
    v is Map<String, dynamic> ? v : <String, dynamic>{};

/// JSON array or an empty list.
List<dynamic> asList(Object? v) => v is List ? v : const [];

/// List of doubles (nulls preserved as null).
List<double?> asDoubleList(Object? v) => asList(v).map(asDouble).toList();
