import 'package:flutter/foundation.dart';

import '../../data/models/lesson.dart';

/// Lessons to show: approved only in release; debug builds also show drafts (flagged).
List<Lesson> visibleLessons(List<Lesson> all, {bool release = kReleaseMode}) =>
    all.where((l) => l.isApproved || !release).toList();
