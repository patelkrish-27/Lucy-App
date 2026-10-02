import 'package:flutter/material.dart';
import '../widgets/cute_graphics.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          const LucyPageHeader(title: 'Settings', subtitle: 'Make Lucy feel like yours.'),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
            child: LucyCard(
              child: Row(children: [
                LucyMascot(size: 62, state: LucyMascotState.idle),
                const SizedBox(width: 12),
                const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Lucy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('Your personal AI agent'),
                ])),
              ]),
            ),
          ),
          _SettingsGroup(title: 'Connection', children: const [
            _SettingTile(icon: Icons.computer_rounded, title: 'Computer', subtitle: 'Connected to Lucy desktop', trailing: StatusPill(label: 'Online', color: Color(0xFF72E6A4))),
            _SettingTile(icon: Icons.cloud_outlined, title: 'Agent server', subtitle: 'Configure Lucy API endpoint'),
          ]),
          _SettingsGroup(title: 'Lucy', children: const [
            _SettingTile(icon: Icons.notifications_none_rounded, title: 'Notifications', subtitle: 'Task completion and errors'),
            _SettingTile(icon: Icons.vibration_rounded, title: 'Haptics', subtitle: 'Small feedback when Lucy reacts'),
            _SettingTile(icon: Icons.animation_rounded, title: 'Animations', subtitle: 'Mascot movement and effects'),
          ]),
          _SettingsGroup(title: 'Appearance', children: const [
            _SettingTile(icon: Icons.dark_mode_outlined, title: 'Theme', subtitle: 'Lucy dark · purple glow'),
            _SettingTile(icon: Icons.auto_awesome_rounded, title: 'Mascot', subtitle: 'Interactive Lucy'),
          ]),
          _SettingsGroup(title: 'About', children: const [
            _SettingTile(icon: Icons.info_outline_rounded, title: 'About Lucy', subtitle: 'Version 0.1.0'),
          ]),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(left: 4, bottom: 9), child: Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: const Color(0xFFB58CFF), fontWeight: FontWeight.w700))),
        LucyCard(child: Column(children: children)),
      ]),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.icon, required this.title, required this.subtitle, this.trailing});
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 3),
      leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFFB58CFF).withValues(alpha: .1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: const Color(0xFFB58CFF))),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
    );
  }
}
