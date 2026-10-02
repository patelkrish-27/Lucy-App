import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/cute_graphics.dart';
import '../widgets/lucy_orb.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final tasks = const [
    LucyTask(title: 'Open Spotify and play my liked songs', status: TaskStatus.completed, time: 'Today · 5:42 PM'),
    LucyTask(title: 'Calculate the total in my Excel sheet', status: TaskStatus.completed, time: 'Today · 4:18 PM'),
    LucyTask(title: 'Build and test the Lucy mobile app', status: TaskStatus.running, time: 'Today · 3:51 PM'),
    LucyTask(title: 'Send the project report on WhatsApp', status: TaskStatus.failed, time: 'Yesterday · 8:24 PM'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          const LucyPageHeader(title: 'Your tasks', subtitle: 'Everything Lucy has been asked to do.'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 30),
              children: [
                LucyCard(
                  child: Row(
                    children: [
                      LucyGlow(size: 58, child: Image.asset('assets/lucy/lucy.webp', width: 48, height: 48)),
                      const SizedBox(width: 12),
                      const Expanded(child: Text('Lucy remembers your recent work so you can pick up where you left off.')),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ...tasks.asMap().entries.map((entry) {
                  final i = entry.key;
                  final task = entry.value;
                  final color = task.status == TaskStatus.completed
                      ? const Color(0xFF72E6A4)
                      : task.status == TaskStatus.running
                          ? const Color(0xFF7DB7FF)
                          : const Color(0xFFFF7899);
                  final label = task.status == TaskStatus.completed ? 'Done' : task.status == TaskStatus.running ? 'Running' : 'Failed';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Duration(milliseconds: 280 + i * 70),
                      curve: Curves.easeOutCubic,
                      builder: (_, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(offset: Offset(0, 14 * (1 - value)), child: child),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task))),
                        child: LucyCard(
                          child: Row(
                            children: [
                              Container(
                                width: 44, height: 44,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: .12)),
                                child: Icon(
                                  task.status == TaskStatus.completed ? Icons.check_rounded : task.status == TaskStatus.running ? Icons.bolt_rounded : Icons.close_rounded,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(task.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 5),
                                Text(task.time, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                              ])),
                              StatusPill(label: label, color: color),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.task});
  final LucyTask task;

  @override
  Widget build(BuildContext context) {
    final running = task.status == TaskStatus.running;
    final color = running ? const Color(0xFF7DB7FF) : task.status == TaskStatus.completed ? const Color(0xFF72E6A4) : const Color(0xFFFF7899);
    return Scaffold(
      appBar: AppBar(title: const Text('Task details')),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          LucyCard(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              children: [
                LucyMascot(size: 150, state: running ? LucyMascotState.working : LucyMascotState.success),
                Text(task.title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                StatusPill(label: running ? 'Lucy is working' : task.status == TaskStatus.completed ? 'Completed' : 'Needs attention', color: color),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const LucyCard(child: _Timeline()),
          if (running) ...[
            const SizedBox(height: 16),
            FilledButton.icon(onPressed: () {}, icon: const Icon(Icons.stop_rounded), label: const Text('Stop task')),
          ],
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Understood request', true),
      ('Connected to your computer', true),
      ('Checking required apps', true),
      ('Executing task', false),
    ];
    return Column(
      children: items.map((item) => ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        leading: Icon(item.$2 ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: item.$2 ? const Color(0xFF72E6A4) : const Color(0xFFB58CFF)),
        title: Text(item.$1),
      )).toList(),
    );
  }
}
