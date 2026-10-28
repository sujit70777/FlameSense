import 'json_utils.dart';

/// One usability-test task (data/manual/usability.csv via export).
class UsabilityTask {
  const UsabilityTask({
    required this.en,
    required this.bn,
    required this.completed,
    required this.total,
    required this.medianSeconds,
  });

  final String en, bn;
  final int completed, total;
  final double medianSeconds;
}

/// Usability results; empty until the test sessions are recorded.
class Usability {
  const Usability({required this.tasks, required this.change});

  static const empty = Usability(tasks: [], change: '');

  /// Parses usability.json.
  factory Usability.fromJson(Map<String, dynamic> j) => Usability(
    tasks: asList(j['tasks'])
        .map(asMap)
        .map(
          (t) => UsabilityTask(
            en: asString(t['task_en']) ?? '',
            bn: asString(t['task_bn']) ?? asString(t['task_en']) ?? '',
            completed: asInt(t['completed']) ?? 0,
            total: asInt(t['total']) ?? 0,
            medianSeconds: asDouble(t['median_seconds']) ?? 0,
          ),
        )
        .toList(),
    change: asString(j['change']) ?? '',
  );

  final List<UsabilityTask> tasks;
  final String change;

  /// Largest number of testers across tasks.
  int get testers => tasks.fold(0, (m, t) => t.total > m ? t.total : m);
}
