import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/lucy_service.dart';
import '../widgets/lucy_orb.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  final _service = LucyService();
  bool _sending = false;

  final _tasks = const [
    LucyTask(
      title: 'Open Spotify and play my liked songs',
      status: TaskStatus.completed,
      time: 'Today, 5:42 PM',
    ),
    LucyTask(
      title: 'Calculate the total in my Excel sheet',
      status: TaskStatus.completed,
      time: 'Today, 4:18 PM',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty || _sending) return;

    setState(() => _sending = true);
    await _service.sendTask(prompt);
    if (!mounted) return;

    setState(() {
      _sending = false;
      _controller.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task sent to Lucy')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    const Text(
                      'Lucy',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.8,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_outlined),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 38, 22, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    const LucyOrb(size: 112),
                    const SizedBox(height: 28),
                    Text(
                      'What can I do for you?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Give Lucy a task and she will take care of it.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 26),
                    TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Ask Lucy to do something...',
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(7),
                          child: IconButton.filled(
                            onPressed: _sending ? null : _send,
                            icon: _sending
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.arrow_upward_rounded),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 38, 22, 12),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'Recent tasks',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w650,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
              sliver: SliverList.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 7,
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF1D3328),
                          child: Icon(
                            Icons.check_rounded,
                            color: Color(0xFF7DE2A8),
                          ),
                        ),
                        title: Text(task.title),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(task.time),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
