import 'package:flutter/material.dart';

import '../../widgets/fs_page.dart';

/// Mission detail page. Placeholder until Phase 11B.
class MissionDetailPage extends StatelessWidget {
  const MissionDetailPage({super.key, required this.missionId});

  final String missionId;

  @override
  Widget build(BuildContext context) =>
      FsPage(title: missionId, children: const []);
}
