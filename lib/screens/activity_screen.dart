import 'package:flutter/material.dart';
import '../widgets/cute_graphics.dart';
import '../widgets/lucy_orb.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          const LucyPageHeader(title: 'Live activity', subtitle: 'See what Lucy is doing right now.'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
              children: [
                LucyCard(
                  padding: const EdgeInsets.fromLTRB(12, 10, 18, 10),
                  child: Row(
                    children: [
                      LucyMascot(size: 118, state: LucyMascotState.working),
                      const Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          StatusPill(label: 'Working now', color: Color(0xFF7DB7FF)),
                          SizedBox(height: 10),
                          Text('Build and test the Lucy mobile app', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          SizedBox(height: 6),
                          Text('Lucy is checking the project and preparing the next step.'),
                        ]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text('Execution timeline', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                const LucyCard(child: _ActivityTimeline()),
                const SizedBox(height: 18),
                Text('Recent events', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                const LucyCard(child: _Events()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline();

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Understanding request', 'Completed', Icons.auto_awesome_rounded),
      ('Checking computer connection', 'Completed', Icons.devices_rounded),
      ('Opening project', 'Completed', Icons.folder_open_rounded),
      ('Running build', 'In progress', Icons.construction_rounded),
    ];
    return Column(
      children: rows.map((r) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Icon(r.$3, size: 20, color: r.$2 == 'In progress' ? const Color(0xFFB58CFF) : const Color(0xFF72E6A4)),
          const SizedBox(width: 12),
          Expanded(child: Text(r.$1)),
          Text(r.$2, style: TextStyle(fontSize: 12, color: r.$2 == 'In progress' ? const Color(0xFFB58CFF) : const Color(0xFF72E6A4))),
        ]),
      )).toList(),
    );
  }
}

class _Events extends StatelessWidget {
  const _Events();

  @override
  Widget build(BuildContext context) {
    const events = ['Lucy connected to your computer', 'Task started', 'Spotify was opened', 'Waiting for your next instruction'];
    return Column(children: events.map((e) => ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.circle, size: 8, color: Color(0xFFC77CFF)), title: Text(e))).toList());
  }
}
