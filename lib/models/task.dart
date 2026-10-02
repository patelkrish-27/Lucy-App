enum TaskStatus { running, completed, failed }

class LucyTask {
  const LucyTask({
    required this.title,
    required this.status,
    required this.time,
  });

  final String title;
  final TaskStatus status;
  final String time;
}
