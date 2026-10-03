import 'package:flutter/material.dart';
import '../widgets/cute_graphics.dart';
import '../widgets/lucy_orb.dart';

class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});
  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  bool notifications = true;
  bool haptics = true;
  bool folderOnSession = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 34),
        children: [
          Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Config', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('Connect Lucy to your computer', style: TextStyle(color: Color(0xFFB9AEC7))),
            ])),
            LucyMascot(size: 62, state: LucyMascotState.listening),
          ]),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _showQr(context),
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Scan QR Code'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(58)),
          ),
          const SizedBox(height: 16),
          _OrDivider(),
          const SizedBox(height: 8),
          const Text('Server URL', style: TextStyle(fontWeight: FontWeight.w650)),
          const SizedBox(height: 7),
          TextField(
            controller: TextEditingController(text: 'ws://192.168.1.100:9847'),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.link_rounded),
              suffixIcon: Icon(Icons.help_outline_rounded, size: 19),
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 6, left: 4), child: Text('WebSocket URL from your Lucy desktop agent. Use Tailscale for remote access.', style: TextStyle(fontSize: 11, color: Color(0xFF8E8796)))),
          const SizedBox(height: 28),
          _Group(title: 'Notifications', children: [
            _SwitchRow(title: 'Notifications', subtitle: 'Notify when Lucy needs attention', value: notifications, onChanged: (v) => setState(() => notifications = v)),
          ]),
          _Group(title: 'Appearance', children: [
            _ActionRow(icon: Icons.palette_outlined, title: 'Lucy theme', subtitle: 'Dark violet · plush mascot', onTap: () {}),
            _ActionRow(icon: Icons.animation_rounded, title: 'Mascot animation', subtitle: 'Smooth and interactive', onTap: () {}),
          ]),
          _Group(title: 'Sessions', children: [
            _SwitchRow(title: 'Select folder on new session', subtitle: 'Choose the working directory before starting', value: folderOnSession, onChanged: (v) => setState(() => folderOnSession = v)),
            _ActionRow(icon: Icons.devices_rounded, title: 'Connected computers', subtitle: '1 computer online', onTap: () {}),
          ]),
          _Group(title: 'Feedback', children: [
            _SwitchRow(title: 'Haptics', subtitle: 'Small feedback when Lucy reacts', value: haptics, onChanged: (v) => setState(() => haptics = v)),
          ]),
          _Group(title: 'About', children: [
            _ActionRow(icon: Icons.info_outline_rounded, title: 'Lucy', subtitle: 'Version 0.1.0 · No cloud by default', onTap: () {}),
          ]),
        ],
      ),
    );
  }

  void _showQr(BuildContext context) {
    showModalBottomSheet(context: context, showDragHandle: true, builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const LucyMascot(size: 100, state: LucyMascotState.listening),
        const Text('Scan Lucy Desktop', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w750)),
        const SizedBox(height: 8),
        const Text('Your desktop agent can display a QR code containing the WebSocket address.', textAlign: TextAlign.center),
        const SizedBox(height: 18),
        Container(width: 170, height: 170, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.qr_code_2_rounded, size: 130, color: Colors.black)),
        const SizedBox(height: 16),
        const Text('Camera scanning will be connected to the desktop pairing flow.'),
      ]),
    ));
  }
}

class _OrDivider extends StatelessWidget {
  @override Widget build(BuildContext context) => Row(children: [
    const Expanded(child: Divider()),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: Text('or enter manually', style: TextStyle(color: Color(0xFF716A78), fontSize: 11))),
    const Expanded(child: Divider()),
  ]);
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title; final List<Widget> children;
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 25),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Color(0xFFB879FF), fontWeight: FontWeight.w750, fontSize: 13)),
      const SizedBox(height: 8),
      LucyCard(child: Column(children: children)),
    ]),
  );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.title, required this.subtitle, required this.value, required this.onChanged});
  final String title, subtitle; final bool value; final ValueChanged<bool> onChanged;
  @override Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero, title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)), value: value, onChanged: onChanged,
  );
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon; final String title, subtitle; final VoidCallback onTap;
  @override Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero, onTap: onTap, leading: Icon(icon, color: const Color(0xFFB879FF)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    trailing: const Icon(Icons.chevron_right_rounded),
  );
}