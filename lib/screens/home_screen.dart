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
  final _focusNode = FocusNode();
  final _service = LucyService();

  bool _sending = false;
  LucyMascotState _mascotState = LucyMascotState.idle;

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
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && !_sending && mounted) {
        setState(() => _mascotState = LucyMascotState.idle);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _setMascot(LucyMascotState state) {
    if (mounted) setState(() => _mascotState = state);
  }

  Future<void> _send() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _mascotState = LucyMascotState.thinking;
    });

    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() => _mascotState = LucyMascotState.working);

    try {
      await _service.sendTask(prompt);
      if (!mounted) return;

      setState(() {
        _sending = false;
        _controller.clear();
        _mascotState = LucyMascotState.success;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task sent to Lucy')),
      );

      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (mounted && !_sending) {
        setState(() => _mascotState = LucyMascotState.idle);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _mascotState = LucyMascotState.error;
      });
    }
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
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    LucyMascot(
                      size: 220,
                      state: _mascotState,
                      onTap: () => _setMascot(LucyMascotState.listening),
                      onDoubleTap: () => _setMascot(LucyMascotState.success),
                      onLongPress: () => _setMascot(LucyMascotState.thinking),
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        switch (_mascotState) {
                          LucyMascotState.idle => 'Ready when you are',
                          LucyMascotState.listening => 'I\'m listening…',
                          LucyMascotState.thinking => 'Let me think about that…',
                          LucyMascotState.working => 'Working on your task…',
                          LucyMascotState.success => 'Done! ✨',
                          LucyMascotState.error => 'Something went wrong',
                        },
                        key: ValueKey(_mascotState),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'What can I do for you?',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap Lucy, hold Lucy, or give her a task.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 26),
                    TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onTap: () => _setMascot(LucyMascotState.listening),
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
                    fontWeight: FontWeight.w600,
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
