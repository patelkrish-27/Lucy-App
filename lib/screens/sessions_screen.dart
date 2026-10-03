import 'package:flutter/material.dart';
import '../widgets/cute_graphics.dart';
import '../widgets/lucy_orb.dart';

class SessionsScreen extends StatelessWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sessions', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text('Control Lucy from anywhere', style: TextStyle(color: Color(0xFFB9AEC7))),
                      ],
                    ),
                  ),
                  LucyMascot(size: 66, state: LucyMascotState.idle),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
            sliver: SliverList.list(children: [
              _ConnectionCard(),
              const SizedBox(height: 22),
              const Text('Active sessions', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              _SessionCard(
                title: 'Lucy Desktop',
                subtitle: '~/projects/lucy',
                agent: 'Lucy Agent',
                icon: Icons.auto_awesome_rounded,
                status: 'ACTIVE',
                color: Color(0xFFB879FF),
              ),
              const SizedBox(height: 12),
              _SessionCard(
                title: 'OpenCode',
                subtitle: '~/bigboot',
                agent: 'OpenCode',
                icon: Icons.terminal_rounded,
                status: 'ACTIVE',
                color: Color(0xFF6FB5FF),
              ),
              const SizedBox(height: 12),
              _SessionCard(
                title: 'Codex',
                subtitle: '~/Lucy-App',
                agent: 'Codex',
                icon: Icons.code_rounded,
                status: 'IDLE',
                color: Color(0xFF6EE7A8),
              ),
              const SizedBox(height: 22),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded),
                label: const Text('Start new session'),
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _ConnectionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LucyCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF72E6A4).withValues(alpha: .12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.wifi_rounded, color: Color(0xFF72E6A4)),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Your computer', style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 3),
              Text('Connected over secure WebSocket', style: TextStyle(fontSize: 12, color: Color(0xFFAAA0B5))),
            ]),
          ),
          const StatusPill(label: 'ONLINE', color: Color(0xFF72E6A4)),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.title, required this.subtitle, required this.agent,
    required this.icon, required this.status, required this.color,
  });

  final String title, subtitle, agent, status;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => TerminalSessionScreen(title: title, path: subtitle, agent: agent, color: color)),
      ),
      child: LucyCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(color: color.withValues(alpha: .12), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 25),
            ),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFFAAA0B5), fontSize: 12)),
              const SizedBox(height: 8),
              Text(agent, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              StatusPill(label: status, color: status == 'ACTIVE' ? color : const Color(0xFF77717F)),
              const SizedBox(height: 10),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF77717F)),
            ]),
          ],
        ),
      ),
    );
  }
}

class TerminalSessionScreen extends StatelessWidget {
  const TerminalSessionScreen({super.key, required this.title, required this.path, required this.agent, required this.color});
  final String title, path, agent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 14), child: StatusPill(label: '● WS', color: color)),
        ],
      ),
      body: Column(children: [
        Container(
          margin: const EdgeInsets.fromLTRB(14, 4, 14, 0),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFF15131A), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            Icon(Icons.folder_open_rounded, size: 17, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(path, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
            Text(agent, style: TextStyle(fontSize: 11, color: color)),
          ]),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 10, 14, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF09090C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF30283B)),
            ),
            child: const SingleChildScrollView(
              child: SelectableText(
r'''lucy@desktop:~/projects/lucy$
> hello! 💜

Lucy is connected and ready.

✓ WebSocket connected
✓ Agent session attached
✓ Computer available

What would you like me to do?

> _''',
                style: TextStyle(fontFamily: 'monospace', height: 1.65, fontSize: 13, color: Color(0xFFD7CCDF)),
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Ask Lucy anything...',
                prefixIcon: const Icon(Icons.chevron_right_rounded),
                suffixIcon: IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_upward_rounded)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}